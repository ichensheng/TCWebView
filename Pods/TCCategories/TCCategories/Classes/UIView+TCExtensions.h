//
//  UIView+TCExtentions.h
//  TCCategories
//
//  Created by 陈 胜 on 16/5/24.
//  Copyright © 2016年 陈胜. All rights reserved.
//

#import <UIKit/UIKit.h>

// 边框
typedef NS_OPTIONS(NSInteger, TCBorderPosition) {
    TCBorderPositionTop     = 1,        // 0x0001
    TCBorderPositionBottom  = 1 << 1,   // 0x0010
    TCBorderPositionLeft    = 1 << 2,   // 0x0100
    TCBorderPositionRight   = 1 << 3,   // 0x1000
    TCBorderPositionAll     = 0xf       // 0x1111
};

@interface UIView (TCExtensions)

/**
 *  UIView尺寸位置设置快捷属性方法
 */
@property (nonatomic) CGFloat top;
@property (nonatomic) CGFloat bottom;
@property (nonatomic) CGFloat left;
@property (nonatomic) CGFloat right;
@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;
@property (nonatomic) CGFloat centerX;
@property (nonatomic) CGFloat centerY;
@property (nonatomic) CGPoint origin;
@property (nonatomic) CGSize  size;

/**
 *  设置UIView圆角
 *
 *  @param corners 圆角
 *  @param size    圆角大小
 */
- (void)tc_setRoundedCorners:(UIRectCorner)corners radius:(CGSize)size;

/**
 *  递归查找子view
 *
 *  @param recurse 判断查找结构block，&stop = YES，表示停止查找
 *
 *  @return 查找结果
 */
- (UIView *)tc_findViewRecursively:(BOOL(^)(UIView* subview, BOOL* stop))recurse;

/**
 *  设置UIView的边框
 *
 *  @param borderPos   边框位置
 *  @param borderColor 边框颜色
 *  @param borderWidth 边框宽度
 */
- (void)tc_setBorder:(TCBorderPosition)borderPos borderColor:(UIColor *)borderColor borderWidth:(CGFloat)borderWidth;

/**
 *  默认颜色默认宽度的UIView的边框
 *
 *  @param borderPos   边框位置
 */
- (void)tc_setBorder:(TCBorderPosition)borderPos;

/**
 *  设置图标圆角
 *
 *  @param radius 圆角弧度
 */
- (void)tc_setCornerWithRadius:(CGFloat)radius;

/**
 *  设置图标圆角，默认5.0f的圆角
 */
- (void)tc_setCornerForImageView;

/**
 *  设置按钮圆角，默认6.0f的圆角
 */
- (void)tc_setCornerForButton;

/**
 *  毛玻璃效果
 *
 *  @param extra YES：UIBlurEffectStyleExtraLight，NO：UIBlurEffectStyleLight
 */
- (void)tc_addBlurEffect:(BOOL)extra;

@end
