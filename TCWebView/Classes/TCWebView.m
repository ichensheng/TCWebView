//
//  TCWebView.m
//  TCWebView
//
//  Created by 陈 胜 on 16/5/24.
//  Copyright © 2016年 陈胜. All rights reserved.
//

#import "TCWebView.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "TCPluginProxy.h"

/**
 *  屏幕宽高
 */
#ifndef kScreenWidth
    #define kScreenWidth [UIScreen mainScreen].bounds.size.width
#endif
#ifndef kScreenHeight
    #define kScreenHeight [UIScreen mainScreen].bounds.size.height
#endif

static NSString *completedURLPath = @"__completedprogress__";
static const CGFloat kPrevSnapshotMarginLeft = 60.0f;

@interface TCWebView() <UIWebViewDelegate>

@property (nonatomic, weak) id<UIWebViewDelegate>webViewDelegate;

/**
 *  滑动返回相关
 */
@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer *backGesture;
@property (nonatomic, strong) NSMutableArray *historyStack;
@property (nonatomic, strong) UIView *currentSnapshot;
@property (nonatomic, strong) UIView *prevSnapshot;
@property (nonatomic, strong) UIView *swipingBackgoundView;
@property (nonatomic, assign, getter=isSwipingBack) BOOL swipingBack;

@end

@implementation TCWebView

- (instancetype)init {
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    return self;
}

#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView
    shouldStartLoadWithRequest:(NSURLRequest *)request
    navigationType:(UIWebViewNavigationType)navigationType {
    
    if ([self pathContainsCompleted:request.URL.fragment]) {
        return NO;
    }
    
    BOOL ret = YES;
    if (self.webViewDelegate
        && [self.webViewDelegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]) {
        
        ret = [self.webViewDelegate webView:webView
                 shouldStartLoadWithRequest:request
                             navigationType:navigationType];
    }
    
    NSString *url = webView.request.URL.absoluteString;
    BOOL isTopLevelNavigation = [request.mainDocumentURL isEqual:request.URL];
    NSString *scheme = request.URL.scheme.lowercaseString;
    if (ret/* && ![self isFragmentJump:url withRequest:request]*/
        && [self isHTTPOrFile:scheme] && isTopLevelNavigation) {
        if ([self isCorrectNavigationType:navigationType] && [url length] > 0) {
            [self snapshotWithURL:url];
        }
    }
    
    return ret;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    if (self.webViewDelegate && [self.webViewDelegate respondsToSelector:@selector(webViewDidStartLoad:)]) {
        [self.webViewDelegate webViewDidStartLoad:webView];
    }
    [self injectLoadDetection];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if (self.webViewDelegate && [self.webViewDelegate respondsToSelector:@selector(webViewDidFinishLoad:)]) {
        [self.webViewDelegate webViewDidFinishLoad:webView];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if (self.webViewDelegate
        && [self.webViewDelegate respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
        
        [self.webViewDelegate webView:webView didFailLoadWithError:error];
    }
}

#pragma mark - Private Methods

- (void)setup {
    self.dataDetectorTypes = UIDataDetectorTypeAll; // 数据检测，例如内容中有邮件地址，点击之后可以打开邮件软件编写邮件
    [super setDelegate:self];
    self.historyStack = [NSMutableArray array];
    self.backGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self
                                                                         action:@selector(swipeBack:)];
    self.backGesture.edges = UIRectEdgeLeft;
    self.backGesture.enabled = NO;
    [self addGestureRecognizer:self.backGesture];
    
    // 启用web cache
    id webView = [self valueForKeyPath:@"_internal.browserView._webView"];
    id preferences = [webView valueForKey:@"preferences"];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [preferences performSelector:@selector(_postCacheModelChangedNotification)];
#pragma clang diagnostic pop
}

- (void)swipeBack:(UIScreenEdgePanGestureRecognizer *)sender {
    if (![self canGoBack]) {
        return;
    }
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self startPopSnapshotView];
    } else if (sender.state == UIGestureRecognizerStateCancelled || sender.state == UIGestureRecognizerStateEnded) {
        [self endPopSnapshotView];
    } else if (sender.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [sender translationInView:self];
        [self popSnapShotViewWithSwipeDistance:translation.x];
    }
}

// 判断是否是fragment跳转
- (BOOL)isFragmentJump:(NSString *)url withRequest:(NSURLRequest *)request {
    if (request.URL && request.URL.fragment) {
        NSString *fragmentUrl = [@"#" stringByAppendingString:request.URL.fragment];
        NSString *nonFragmentURL = [request.URL.absoluteString stringByReplacingOccurrencesOfString:fragmentUrl
                                                                                         withString:@""];
        return [nonFragmentURL isEqualToString:url];
    }
    return NO;
}

// 排除其它类型的跳转
- (BOOL)isCorrectNavigationType:(UIWebViewNavigationType)navigationType {
    return navigationType == UIWebViewNavigationTypeLinkClicked
    || navigationType == UIWebViewNavigationTypeFormSubmitted
    || navigationType == UIWebViewNavigationTypeOther;
}

- (void)snapshotWithURL:(NSString *)url {
    if ([url isEqualToString:@"about:blank"]) {
        return;
    }
    
    NSString *lastURL = [[self.historyStack lastObject] objectForKey:@"url"];
    if (![lastURL isEqualToString:url]) {
        UIView *snapshotView = [self snapshotViewAfterScreenUpdates:NO];
        [self.historyStack addObject:@{@"preview":snapshotView, @"url":url}];
    }
    
    // 成功加载第二个网页之后启用手势返回
    if (self.historyStack.count > 0) {
        self.backGesture.enabled = YES;
    }
}

- (void)startPopSnapshotView {
    if (self.isSwipingBack) {
        return;
    }
    self.swipingBack = YES;
    
    // create a center of scrren
    CGPoint center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    
    self.currentSnapshot = [self snapshotViewAfterScreenUpdates:YES];
    
    // 上层快照滑动时的左侧阴影
    self.currentSnapshot.layer.shadowColor = [UIColor blackColor].CGColor;
    self.currentSnapshot.layer.shadowOffset = CGSizeMake(3, 3);
    self.currentSnapshot.layer.shadowRadius = 5;
    self.currentSnapshot.layer.shadowOpacity = 0.75;
    
    // move to center of screen
    self.currentSnapshot.center = center;
    
    self.prevSnapshot = (UIView *)[[self.historyStack lastObject] objectForKey:@"preview"];
    center.x -= kPrevSnapshotMarginLeft;
    self.prevSnapshot.center = center;
    self.prevSnapshot.alpha = 1;
    
    [self addSubview:self.prevSnapshot];
    [self addSubview:self.swipingBackgoundView];
    [self addSubview:self.currentSnapshot];
}

- (void)endPopSnapshotView {
    if (!self.isSwipingBack) {
        return;
    }
    
    // 滑动时禁止点击
    self.userInteractionEnabled = NO;
    
    CGFloat width = kScreenWidth;
    CGFloat height = kScreenHeight;
    if (self.frame.size.width > self.frame.size.height) { // 横屏
        width = kScreenHeight;
        height = kScreenWidth;
    }
    
    if (self.currentSnapshot.center.x >= width) {
        [UIView animateWithDuration:0.2 animations:^{
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            self.currentSnapshot.center = CGPointMake(width * 3 / 2, height / 2);
            self.prevSnapshot.center = CGPointMake(width / 2, height / 2);
            self.swipingBackgoundView.alpha = 0;
        } completion:^(BOOL finished) {
            [self goBack];
            [self.historyStack removeLastObject];
            self.userInteractionEnabled = YES;
            self.swipingBack = NO;
            
            // 没有返回时则关闭手势
            if (self.historyStack.count == 0) {
                self.backGesture.enabled = NO;
            }
            [self removeSnapshotScreen];
        }];
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            self.currentSnapshot.center = CGPointMake(width / 2, height / 2);
            self.prevSnapshot.center = CGPointMake(width / 2 - kPrevSnapshotMarginLeft, height / 2);
            self.prevSnapshot.alpha = 1;
        } completion:^(BOOL finished) {
            [self removeSnapshotScreen];
            self.userInteractionEnabled = YES;
            self.swipingBack = NO;
        }];
    }
}

- (void)removeSnapshotScreen {
    [self.prevSnapshot removeFromSuperview];
    [self.swipingBackgoundView removeFromSuperview];
    [self.currentSnapshot removeFromSuperview];
}

- (void)popSnapShotViewWithSwipeDistance:(CGFloat)distance {
    if (!self.isSwipingBack) {
        return;
    }
    
    if (distance <= 0) {
        return;
    }
    CGPoint prevSnapshotCenter = CGPointMake(kScreenWidth / 2, kScreenHeight / 2);
    prevSnapshotCenter.x -= (kScreenWidth - distance) * 60 / kScreenWidth;
    self.prevSnapshot.center = prevSnapshotCenter;
    CGRect frame = self.currentSnapshot.frame;
    frame.origin.x = distance;
    self.currentSnapshot.frame = frame;
    self.swipingBackgoundView.alpha = (kScreenWidth - distance) / kScreenWidth;
}

- (BOOL)isHTTPOrFile:(NSString *)scheme {
    return [scheme hasPrefix:@"http"] || [scheme hasPrefix:@"file"];
}

- (BOOL)pathContainsCompleted:(NSString *)path {
    return [path containsString:completedURLPath];
}

- (void)injectLoadDetection {
    NSString *scheme = self.request.mainDocumentURL.scheme;
    NSString *host = self.request.mainDocumentURL.host;
    if (!scheme) {
        scheme = @"file";
    }
    if (!host) {
        host = @"localhost";
    }
    NSString *waitForCompleteJS = [NSString stringWithFormat:@"if (!__waitForCompleteJS__) {"\
                                   "var __waitForCompleteJS__ = 1;"\
                                   "window.addEventListener('load', function() {" \
                                   "var iframe = document.createElement('iframe');" \
                                   "iframe.style.display = 'none';" \
                                   "iframe.src = '%@://%@/#%@';" \
                                   "document.body.appendChild(iframe);" \
                                   "}, false);}",
                                   scheme,
                                   host,
                                   completedURLPath];
    [self stringByEvaluatingJavaScriptFromString:waitForCompleteJS];
}

- (void)injectCSS:(NSString *)css {
    NSString *js = [NSString stringWithFormat:@"var script = document.createElement('style');"\
                    "script.type = 'text/css';"\
                    "script.innerHTML = '%@';"\
                    "document.head.appendChild(script);"
                    , css];
    [self stringByEvaluatingJavaScriptFromString:js];
}

#pragma mark - Getters and Setters

- (void)setDelegate:(id<UIWebViewDelegate>)delegate {
    self.webViewDelegate = delegate;
}

- (id<UIWebViewDelegate>)delegate {
    return self.webViewDelegate;
}

-(UIView *)swipingBackgoundView {
    if (!_swipingBackgoundView) {
        _swipingBackgoundView = [[UIView alloc] initWithFrame:self.bounds];
        _swipingBackgoundView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    }
    return _swipingBackgoundView;
}

- (void)dealloc {
    [_historyStack removeAllObjects];
    _historyStack = nil;
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"WebKitCacheModelPreferenceKey"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"WebKitDiskImageCacheEnabled"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"WebKitOfflineWebApplicationCacheEnabled"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

@end
