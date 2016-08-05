//
//  TCPluginCommand.m
//  TCWebView
//
//  Created by 陈 胜 on 16/5/24.
//  Copyright © 2016年 陈胜. All rights reserved.
//

#import "TCPluginCommand.h"

@implementation TCPluginCommand

/**
 *  JS调用Native端的参数封装
 *
 *  @param className   Native类名
 *  @param methodsName Native方法名
 *  @param arguments   方法参数
 *  @param callbackID  JS端回调函数ID
 *
 *  @return TCPluginCommand
 */
- (instancetype)initWithClassName:(NSString *)className
                       methodName:(NSString *)methodsName
                        arguments:(NSArray *)arguments
                       callbackID:(NSString *)callbackID {
    
    if (self = [super init]) {
        _className = className;
        _methodName = methodsName;
        _arguments = arguments;
        _callbackID = callbackID;
    }
    return self;
}

/**
 *  JS调用Native端的参数封装
 *
 *  @param className   Native类名
 *  @param methodsName Native方法名
 *  @param arguments   方法参数
 *
 *  @return TCPluginCommand
 */
- (instancetype)initWithClassName:(NSString *)className
                       methodName:(NSString *)methodsName
                        arguments:(NSArray *)arguments {
    
    return [self initWithClassName:className
                        methodName:methodsName
                         arguments:arguments
                        callbackID:nil];
}

/**
 *  JS调用Native端的参数封装
 *
 *  @param className   Native类名
 *  @param methodsName Native方法名
 *
 *  @return TCPluginCommand
 */
- (instancetype)initWithClassName:(NSString *)className
                       methodName:(NSString *)methodsName {
    
    return [self initWithClassName:className
                        methodName:methodsName
                         arguments:nil];
}


@end
