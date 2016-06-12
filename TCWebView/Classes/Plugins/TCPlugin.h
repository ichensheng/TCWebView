//
//  TCPlugin.h
//  TCWebView
//
//  Created by 陈 胜 on 16/5/24.
//  Copyright © 2016年 陈胜. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCWebViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "TCPluginCommand.h"

static NSString * const kWebViewJSBridge = @"RuahoWebViewJSBridge";

@interface TCPlugin : NSObject

@property (nonatomic, weak, readonly) TCWebViewController *webViewController;

/**
 *  使用当前UIWebView对象构造插件，直接暴露到全局对象里
 *
 *  @param RCWebViewController RCWebViewController对象
 *
 *  @return 插件对象
 */
- (instancetype)initWithWebViewController:(TCWebViewController *)webViewController;

/**
 *  回调JS
 *
 *  @param command    参数封装
 *  @param parameters 回调参数
 */
- (void)callback:(TCPluginCommand *)command
      parameters:(NSArray *)parameters;

/**
 *  插件卸载时调用
 */
- (void)dispose;

@end
