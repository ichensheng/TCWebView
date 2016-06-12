//
//  TCPlugin.m
//  TCWebView
//
//  Created by 陈 胜 on 16/5/24.
//  Copyright © 2016年 陈胜. All rights reserved.
//

#import "TCPlugin.h"

@interface TCPlugin()

@property (nonatomic, weak, readwrite) TCWebViewController *webViewController;

@end

@implementation TCPlugin

/**
 *  使用当前UIWebView对象构造插件，直接暴露到全局对象里
 *
 *  @param RCWebViewController RCWebViewController对象
 *
 *  @return 插件对象
 */
- (instancetype)initWithWebViewController:(TCWebViewController *)webViewController {
    if (self = [super init]) {
        _webViewController = webViewController;
    }
    return self;
}

/**
 *  回调JS
 *
 *  @param command    参数封装
 *  @param parameters 回调参数
 */
- (void)callback:(TCPluginCommand *)command
      parameters:(NSArray *)parameters {
    
    NSString *callbackID = command.callbackID;
    if (callbackID) {
        JSContext *jsContext = [self.webViewController.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
        JSValue *WebViewJSBridge = jsContext[kWebViewJSBridge];
        if (parameters) {
            [WebViewJSBridge[@"callback"] callWithArguments:@[callbackID, parameters]];
        } else {
            [WebViewJSBridge[@"callback"] callWithArguments:@[callbackID]];
        }
    }
}

/**
 *  插件卸载时调用
 */
- (void)dispose {
    _webViewController = nil;
}

@end
