//
//  UIImageView+TCExtensions.h
//  TCCategories
//
//  Created by 陈 胜 on 16/6/20.
//  Copyright © 2016年 陈胜. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (TCExtensions)

/**
 *  设置图片，带圆角，头像默认5像素圆角
 *
 *  @param image  头像图片
 *  @param radius 头像大小
 */
- (void)tc_setHeaderImage:(UIImage *)image withSize:(CGSize)size;

/**
 *  设置图片，带圆角
 *
 *  @param radius 圆角半径
 *  @param image  图片
 *  @param size   圆角图片大小
 */
- (void)tc_setImageWithRadius:(CGFloat)radius image:(UIImage *)image size:(CGSize)size;

/**
 *  设置圆角，大概5像素
 */
- (void)tc_setCorner;

@end
