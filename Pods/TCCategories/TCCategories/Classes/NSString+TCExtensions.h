//
//  NSString+TCExtensions.h
//  TCCategories
//
//  Created by 陈 胜 on 16/5/24.
//  Copyright © 2016年 陈胜. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (TCExtensions)

/**
 *  是否为空字符串
 *
 *  @return 布尔值
 */
- (BOOL)tc_isBlank;

/**
 *  是否为中文
 *
 *  @return 返回判断结果
 */
- (BOOL)tc_isChinese;

/**
 *  获取字符串指定字体的CGRect
 *
 *  @param size 范围，大小不超出该范围
 *  @param font 字体
 *
 *  @return 返回计算之后的CGRect
 */
- (CGSize)tc_boundingSizeWithFont:(UIFont *)font
                   constraintSize:(CGSize)size;

/**
 *  获取字符串指定字体的CGRect
 *
 *  @param size 范围，大小不超出该范围
 *  @param font 字体
 *  @param lineSpacing 行间距
 *
 *  @return 返回计算之后的CGRect
 */
- (CGSize)tc_boundingSizeWithFont:(UIFont *)font
                   constraintSize:(CGSize)size
                      lineSpacing:(CGFloat)lineSpacing;

/**
 *  获取字符串在指定字体和约束size以及显示行数之后的size
 *
 *  @param font 字体
 *  @param size 约束size
 *  @param line 显示行数
 *
 *  @return 真实显示size
 */
- (CGSize)tc_boundingSizeWithFont:(UIFont *)font
                   constraintSize:(CGSize)size
                         showLine:(NSInteger)line;

/**
 *  字符串MD5摘要
 *
 *  @return MD5摘要
 */
- (NSString *)tc_MD5Digest;

/**
 *  生成指定长度的随机字符串
 *
 *  @param length 随机字符串长度
 *
 *  @return 随机字符串
 */
+ (NSString *)tc_randomString:(NSInteger)length;

@end
