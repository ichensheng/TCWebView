//
//  TCPluginProxy.h
//  TCWebView
//
//  Created by 陈 胜 on 16/5/24.
//  Copyright © 2016年 陈胜. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@protocol TCPluginProxyExport <JSExport>

/**
 *  调用插件的方法
 *
 *  @param className  插件类名
 *  @param methodName 方法名
 *  @param arguments  调用参数
 *  @param callbackId JS回调函数ID
 *
 *  @return 方法处理结果，如果没有返回值则返回nil
 */
JSExportAs(execute,
           - (id)execute:(NSString *)className
           methodName:(NSString *)methodName
           arguments:(NSArray *)arguments
           callbackID:(NSString *)callbackID);

@end

@class TCWebViewController;
@interface TCPluginProxy : NSObject <TCPluginProxyExport>

/**
 *  构造插件代理类，JS通过该类调用系统里的插件
 *
 *  @param webViewController RCWebViewController对象
 *
 *  @return RCPluginProxy
 */
- (instancetype)initWithWebViewController:(TCWebViewController *)webViewController;

/**
 *  卸载插件
 */
- (void)unloadPlugins;

@end
