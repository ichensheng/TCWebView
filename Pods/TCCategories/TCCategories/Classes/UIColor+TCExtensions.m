//
//  UIColor+TCExtensions.m
//  TCCategories
//
//  Created by 陈 胜 on 16/5/28.
//  Copyright © 2016年 陈胜. All rights reserved.
//

#import "UIColor+TCExtensions.h"

@implementation UIColor (TCExtensions)

/**
 *  生成随机颜色
 *
 *  @return UIColor
 */
+ (UIColor *)tc_randomColor {
    CGFloat red = arc4random() % 100 / 100.0;
    CGFloat green = arc4random() % 100 / 100.0;
    CGFloat blue = arc4random() % 100 / 100.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:1];
}

@end
