//
//  TCPluginCommand.h
//  TCWebView
//
//  Created by 陈 胜 on 16/5/24.
//  Copyright © 2016年 陈胜. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCPluginCommand : NSObject

@property (nonatomic, readonly) NSString *className;    // 插件实现类名
@property (nonatomic, readonly) NSString *methodName;   // 调用方法名
@property (nonatomic, readonly) NSArray *arguments;     // 调用参数
@property (nonatomic, readonly) NSString *callbackID;   // JS端回调函数ID

/**
 *  JS调用Native端的参数封装
 *
 *  @param className   Native类名
 *  @param methodsName Native方法名
 *  @param arguments   方法参数
 *  @param callbackId  JS端回调函数ID
 *
 *  @return RCPluginCommand
 */
- (instancetype)initWithClassName:(NSString *)className
                       methodName:(NSString *)methodsName
                        arguments:(NSArray *)arguments
                       callbackID:(NSString *)callbackID;

/**
 *  JS调用Native端的参数封装
 *
 *  @param className   Native类名
 *  @param methodsName Native方法名
 *  @param arguments   方法参数
 *
 *  @return RCPluginCommand
 */
- (instancetype)initWithClassName:(NSString *)className
                       methodName:(NSString *)methodsName
                        arguments:(NSArray *)arguments;

/**
 *  JS调用Native端的参数封装
 *
 *  @param className   Native类名
 *  @param methodsName Native方法名
 *
 *  @return RCPluginCommand
 */
- (instancetype)initWithClassName:(NSString *)className
                       methodName:(NSString *)methodsName;

@end
