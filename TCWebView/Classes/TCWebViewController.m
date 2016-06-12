//
//  TCWebViewController.m
//  TCWebView
//
//  Created by 陈 胜 on 16/5/24.
//  Copyright © 2016年 陈胜. All rights reserved.
//

#import "TCWebViewController.h"
#import "TCWebView.h"
#import "NJKWebViewProgress.h"
#import "NJKWebViewProgressView.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "Masonry.h"
#import "TCCategories.h"
#import "TCPluginProxy.h"

#ifndef kWebViewBackgroundColor
#define kWebViewBackgroundColor [UIColor colorWithRed:46.0f / 255 green:49.0f / 255 blue:50.0f / 255 alpha:1]
#endif

static NSString * const kPluginProxy = @"__PLUGIN_PROXY__";

static const CGFloat kProgressBarHeight = 2.5;  // 进度条高度
static const CGFloat kLeftViewWidth = 10.0f;    // 左边竖条的宽度

static const CGFloat kBackButtonMaxWidth = 150;         // 返回按钮最大宽度
static const CGFloat kBackButtonHeight = 30;            // 返回按钮高度
static const CGFloat kBackButtonArrowWidth = 15;        // 返回箭头宽度


@interface TCWebViewController ()<UIWebViewDelegate, NJKWebViewProgressDelegate, TCWebViewSwipeDelegate>

@property (nonatomic, strong, readwrite) TCWebView *webView;
@property (nonatomic, strong) NSString *URLString;
@property (nonatomic, strong) NSString *html;
@property (nonatomic, strong) NJKWebViewProgress *progressProxy;        // 输出进度
@property (nonatomic, strong) NJKWebViewProgressView *progressView;     // 进度条
@property (nonatomic, strong) UILabel *webPageFromWho;                  // 网页由谁提供
@property (nonatomic, strong) UIBarButtonItem *backBarButtonItem;       // 返回按钮
@property (nonatomic, strong) UIBarButtonItem *closeBarButtonItem;      // 关闭按钮
@property (nonatomic, strong) UIView *leftView;                         // 防止网页里面的滑动影响手势滑动
@property (nonatomic, strong) TCPluginProxy *pluginProxy;               // 插件代理类

@end

@implementation TCWebViewController

#pragma mark - initialization

- (instancetype)initWithURL:(NSString *)URLString {
    if (self = [super init]) {
        _URLString = URLString;
    }
    return self;
}

+ (instancetype)instanceWithURL:(NSString *)URLString {
    return [[self alloc] initWithURL:URLString];
}

- (instancetype)initWithHTML:(NSString *)html {
    if (self = [super init]) {
        _html = html;
    }
    return self;
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.addedBackButton = YES;
    [self.navigationItem tc_setLeftBarButtonItems:@[self.backBarButtonItem]];
    
    if (self.URLString) {
        NSURLRequest *request = [self requestForURL:self.URLString];
        [self.webView loadRequest:request];
    } else if (self.html) {
        [self.webView loadHTMLString:self.html baseURL:nil];
    }
    
    // 在webview左边添加透明的view使得滑动返回不受网页里面的事件影响
    [self.webView addSubview:self.leftView];
    __weak typeof(self) weakself = self;
    [self.leftView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.width.mas_equalTo(kLeftViewWidth);
        make.height.equalTo(weakself.view.mas_height);
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.view addSubview:self.progressView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    NSURLRequest *request = webView.request;
    if (request.URL.host) {
        NSNumber *port = request.URL.port;
        if (port) {
            self.webPageFromWho.text = [NSString stringWithFormat:@"网页由 %@:%@ 提供", request.URL.host, port];
        } else {
            self.webPageFromWho.text = [NSString stringWithFormat:@"网页由 %@ 提供", request.URL.host];
        }
    } else { // 加载本地文件直接就到100%
        [self.progressView setProgress:1.0f animated:YES];
    }
    
    // 加载jsbridge
    [self loadJSBridge];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(nullable NSError *)error {
    self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    [self.progressView setProgress:1.0f animated:YES];
    
    if (error.code == NSURLErrorCancelled) { // 忽略这个错误。
        return;
    }
    
    NSInteger errorCode = error.code;
    if (errorCode == NSURLErrorNotConnectedToInternet
        || errorCode == NSURLErrorCannotFindHost
        || errorCode == NSURLErrorCannotConnectToHost
        || errorCode == NSURLErrorNetworkConnectionLost
        || errorCode == NSURLErrorDNSLookupFailed
        || errorCode == NSURLErrorTimedOut) { // 网络有问题
        
        [self.progressView setProgress:0 animated:NO];
    } else { // 其它错误
        NSLog(@"description:%@  userInfo:%@", error.localizedDescription, error.userInfo);
    }
}

#pragma mark - NJKWebViewProgressDelegate

- (void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress {
    if (self.progressView.hidden) {
        self.progressView.hidden = NO;
        [self.progressView setProgress:0.0f];
    }
    if (progress == 0.0f) {
        progress = 0.01f;
    }
    [self.progressView setProgress:progress animated:YES];
}

#pragma mark - RHWebViewSwipeDelegate

- (void)willSwipeBack {
}

- (void)didSwipeBack {
    [self.navigationItem tc_setLeftBarButtonItems:@[self.backBarButtonItem, self.closeBarButtonItem]];
}

#pragma mark - Custom Events

- (void)back:(UIBarButtonItem *)sender {
    if (self.webView.canGoBack) {
        [self.webView goBack];
        [self.navigationItem tc_setLeftBarButtonItems:@[self.backBarButtonItem, self.closeBarButtonItem]];
    } else {
        [self close:nil];
    }
}

- (void)close:(UIBarButtonItem *)sender {
    [self rotateToPortrait];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Private Methods

- (void)loadJSBridge {
    JSContext *jsContext = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    jsContext[kPluginProxy] = self.pluginProxy;
    
    /**
     *  载入js脚本
     */
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"plugins" ofType:@"bundle"];
    NSBundle *pluginsBundle = [NSBundle bundleWithPath:bundlePath];
    NSString *jsPath = [pluginsBundle pathForResource:@"webViewBridge" ofType:@"js"];
    NSString *script = [[NSString alloc] initWithContentsOfFile:jsPath
                                                       encoding:NSUTF8StringEncoding
                                                          error:nil];
    NSString *devicereadyJs = [NSString stringWithFormat:@"var readyEvent = document.createEvent('Events');"\
                    @"readyEvent.initEvent('deviceready');"\
                    @"document.dispatchEvent(readyEvent);"];
    
    @try {
        [jsContext evaluateScript:script];
        
        /**
         *  加载自定义插件js
         */
        NSString *webViewPluginsPath = [[NSBundle mainBundle] pathForResource:@"webViewPlugins.js" ofType:nil];
        if (webViewPluginsPath) {
            NSString *webViewPluginsJs = [[NSString alloc] initWithContentsOfFile:webViewPluginsPath
                                                                         encoding:NSUTF8StringEncoding
                                                                            error:nil];
            [jsContext evaluateScript:webViewPluginsJs];
        }
        
        [jsContext evaluateScript:devicereadyJs];
    } @catch (NSException *exception) {
        NSAssert(NO, @"%@", exception);
    }
}

- (void)setupWebPageFromWho {
    CGRect statusBarViewRect = [[UIApplication sharedApplication] statusBarFrame];
    float heightPadding = statusBarViewRect.size.height;
    if (self.navigationController) {
        heightPadding = statusBarViewRect.size.height + self.navigationController.navigationBar.frame.size.height;
    }
    [self.webView insertSubview:self.webPageFromWho belowSubview:self.webView.scrollView];
    self.webView.scrollView.contentInset = UIEdgeInsetsMake(heightPadding, 0.0, 0.0, 0.0);
    self.webView.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(heightPadding, 0, 0, 0);
    self.webView.scrollView.contentOffset = CGPointMake(0, -heightPadding);
    
    __weak typeof(self) weakself = self;
    [self.webPageFromWho mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(5);
        make.top.equalTo(weakself.view.mas_top).offset(74);
        make.width.equalTo(weakself.view.mas_width).offset(-10);
        make.height.mas_equalTo(20);
    }];
}

// 强制旋转到人像模式
- (void)rotateToPortrait {
    NSNumber *value = [NSNumber numberWithInt:UIDeviceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
}

- (BOOL)beforePopViewController {
    [self rotateToPortrait];
    return YES;
}

- (NSURLRequest *)requestForURL:(NSString *)URLString {
    NSURLRequest *request = nil;
    URLString = [URLString lowercaseString];
    if ([URLString length] > 0) {
        NSURL *url = nil;
        if([URLString hasPrefix:kFileProtocol]) { // 如果'file://'开头的字符串则加载bundle中的文件
            NSRange range = [URLString rangeOfString:kFileProtocol];
            NSString *fileName = [URLString substringFromIndex:range.length];
            url = [[NSBundle mainBundle] URLForResource:fileName withExtension:nil];
        } else if ([URLString hasPrefix:kHttpProtocol] || [URLString hasPrefix:kHttpsProtocol]) {
            url = [NSURL URLWithString:URLString];
        }
        if (url) {
            request = [NSURLRequest requestWithURL:url];
        }
    }
    return request;
}

- (void)destroyWebView {
    [self.webView loadHTMLString:@"" baseURL:nil];
    if ([self.webView isLoading]) {
        [self.webView stopLoading];
    }
    self.webView.delegate = nil;
    [self.webView removeFromSuperview];
    self.webView = nil;
}

#pragma mark - Getters and Setters

- (TCWebView *)webView {
    if (!_webView) {
        _webView = [[TCWebView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:_webView];
        _webView.backgroundColor = kWebViewBackgroundColor;
        _webView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        _webView.swipeDelegate = self;
        _progressProxy = [[NJKWebViewProgress alloc] init];
        _webView.delegate = _progressProxy;
        _progressProxy.webViewProxyDelegate = self;
        _progressProxy.progressDelegate = self;
        [self setupWebPageFromWho];
    }
    return _webView;
}

- (NJKWebViewProgressView *)progressView {
    if (!_progressView) {
        CGRect navigaitonBarBounds = self.navigationController.navigationBar.bounds;
        CGFloat progressBarY = 0;
        if (![UIApplication sharedApplication].statusBarHidden) {
            progressBarY += [UIApplication sharedApplication].statusBarFrame.size.height;
        }
        if (self.navigationController && !self.navigationController.navigationBar.hidden) {
            progressBarY += self.navigationController.navigationBar.frame.size.height;
        }
        CGRect barFrame = CGRectMake(0, progressBarY, navigaitonBarBounds.size.width, kProgressBarHeight);
        _progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
        _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        _progressView.hidden = YES;
    }
    return _progressView;
}

- (UILabel *)webPageFromWho {
    if (!_webPageFromWho) {
        _webPageFromWho = [[UILabel alloc] init];
        _webPageFromWho.numberOfLines = 2;
        _webPageFromWho.textColor = [UIColor grayColor];
        _webPageFromWho.textAlignment = NSTextAlignmentCenter;
        _webPageFromWho.font = [UIFont systemFontOfSize:12];
    }
    return _webPageFromWho;
}

- (UIBarButtonItem *)backBarButtonItem {
    if (!_backBarButtonItem) {
        NSString *title = [self defaultBackTitle];
        CGSize boudingSize = [title tc_boundingSizeWithFont:[self navigationBarBackButtonFont]
                                             constraintSize:CGSizeMake(kBackButtonMaxWidth, kBackButtonHeight)];
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
        [backButton setFrame:CGRectMake(0, 0, boudingSize.width + kBackButtonArrowWidth, kBackButtonHeight)];
        [backButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [backButton setExclusiveTouch:YES];
        UIImage *barButtonImage = [UIImage imageNamed:[self defaultBackButtonIcon]];
        [backButton setImage:barButtonImage forState:UIControlStateNormal];
        [backButton setTitle:title forState:UIControlStateNormal];
        [backButton setTintColor:[self navigationBarBackTintColor]];
        backButton.titleLabel.font = [self navigationBarBackButtonFont];
        [backButton sizeToFit];
        CGRect frame = backButton.frame;
        UIView *backButtonContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [backButtonContainer addSubview:backButton];
        _backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButtonContainer];
    }
    return _backBarButtonItem;
}

- (UIBarButtonItem *)closeBarButtonItem {
    if (!_closeBarButtonItem) {
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [closeButton addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
        [closeButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [closeButton setExclusiveTouch:YES];
        [closeButton setTitle:[self defaultCloseTitle] forState:UIControlStateNormal];
        [closeButton setTintColor:[self navigationBarBackTintColor]];
        closeButton.titleLabel.font = [self navigationBarBackButtonFont];
        [closeButton sizeToFit];
        CGRect frame = closeButton.frame;
        UIView *closeButtonContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [closeButtonContainer addSubview:closeButton];
        _closeBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:closeButtonContainer];
    }
    return _closeBarButtonItem;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wundeclared-selector"
#pragma clang diagnostic ignored"-Warc-performSelector-leaks"
- (UIFont *)navigationBarBackButtonFont {
    UIFont *navigationBarBackButtonFont = [UIFont boldSystemFontOfSize:17];
    SEL rc_navigationBarBackButtonFont = @selector(rc_navigationBarBackButtonFont);
    if ([self respondsToSelector:rc_navigationBarBackButtonFont]) {
        navigationBarBackButtonFont = [self performSelector:rc_navigationBarBackButtonFont];
    }
    return navigationBarBackButtonFont;
}

- (NSString *)defaultBackButtonIcon {
    NSString *defaultBackButtonIcon = @"barbuttonicon_back";
    SEL rc_defaultBackButtonIcon = @selector(rc_defaultBackButtonIcon);
    if ([self respondsToSelector:rc_defaultBackButtonIcon]) {
        defaultBackButtonIcon = [self performSelector:rc_defaultBackButtonIcon];
    }
    return defaultBackButtonIcon;
}

- (NSString *)defaultBackTitle {
    NSString *defaultBackTitle = @"返回";
    SEL rc_defaultBackTitle = @selector(rc_defaultBackTitle);
    if ([self respondsToSelector:rc_defaultBackTitle]) {
        defaultBackTitle = [self performSelector:rc_defaultBackTitle];
    }
    return defaultBackTitle;
}

- (NSString *)defaultCloseTitle {
    NSString *defaultCloseTitle = @"关闭";
    SEL rc_defaultCloseTitle = @selector(rc_defaultCloseTitle);
    if ([self respondsToSelector:rc_defaultCloseTitle]) {
        defaultCloseTitle = [self performSelector:rc_defaultCloseTitle];
    }
    return defaultCloseTitle;
}

- (UIColor *)navigationBarBackTintColor {
    UIColor *navigationBarBackTintColor = [UIColor colorWithRed:252.0f / 255 green:61.0f / 255 blue:57.0f / 255 alpha:1];
    SEL rc_navigationBarBackTintColor = @selector(rc_navigationBarBackTintColor);
    if ([self respondsToSelector:rc_navigationBarBackTintColor]) {
        navigationBarBackTintColor = [self performSelector:rc_navigationBarBackTintColor];
    }
    return navigationBarBackTintColor;
}
#pragma clang diagnostic pop

- (UIView *)leftView {
    if (!_leftView) {
        _leftView = [[UIView alloc] init];
        _leftView.backgroundColor = [UIColor clearColor];
    }
    return _leftView;
}

- (TCPluginProxy *)pluginProxy {
    if (!_pluginProxy) {
        _pluginProxy = [[TCPluginProxy alloc] initWithWebViewController:self];
    }
    return _pluginProxy;
}

- (void)dealloc {
    [_pluginProxy unloadPlugins];
    _pluginProxy = nil;
    [self destroyWebView];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (toInterfaceOrientation != UIInterfaceOrientationPortrait) { // 横屏
        double delayInSeconds = 0.01;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            CGRect frame = self.view.superview.frame;
            frame.origin.y -= 12;
            frame.size.height += 12;
            self.view.superview.frame = frame;
        });
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
}

@end
