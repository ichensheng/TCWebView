//
//  TCLogger.h
//  TCWebView
//
//  Created by 陈 胜 on 16/5/24.
//  Copyright © 2016年 陈胜. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCPlugin.h"

@protocol TCLoggerExport <JSExport>

- (void)debug:(TCPluginCommand *)command;

@end

@interface TCLogger : TCPlugin <TCLoggerExport>

@end
