//
//  TCLogger.m
//  TCWebView
//
//  Created by 陈 胜 on 16/5/24.
//  Copyright © 2016年 陈胜. All rights reserved.
//

#import "TCLogger.h"

@implementation TCLogger

/**
 *  调试日志
 *
 *  @param command 参数
 */
- (void)debug:(TCPluginCommand *)command {
    NSLog(@"%@", command.arguments[0]);
}

@end
