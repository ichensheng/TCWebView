//
//  TCWebView.h
//  TCWebView
//
//  Created by 陈 胜 on 16/5/24.
//  Copyright © 2016年 陈胜. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCWebView : UIWebView

/**
 *  嵌入css样式表
 *
 *  @param css 样式表
 */
- (void)injectCSS:(NSString *)css;

@end
