//
//  TCWebViewController.h
//  TCWebView
//
//  Created by 陈 胜 on 16/5/24.
//  Copyright © 2016年 陈胜. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCWebView.h"

static NSString * const kFileProtocol = @"file://";     // 打开本地文件
static NSString * const kHttpProtocol = @"http://";     // 打开http协议的网页
static NSString * const kHttpsProtocol = @"https://";   // 打开https协议的网页

@class JSContext;
@interface TCWebViewController : UIViewController

@property (nonatomic, strong, readonly) TCWebView *webView;

- (instancetype)initWithURL:(NSString *)URLString;
+ (instancetype)instanceWithURL:(NSString *)URLString;
- (instancetype)initWithHTML:(NSString *)html;

@end
