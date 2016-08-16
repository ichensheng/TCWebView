//
//  UIImageView+TCExtensions.m
//  TCCategories
//
//  Created by 陈 胜 on 16/6/20.
//  Copyright © 2016年 陈胜. All rights reserved.
//

#import "UIImageView+TCExtensions.h"
#import "Masonry.h"
#import "UIImage+TCExtensions.h"

@implementation UIImageView (TCExtensions)

/**
 *  设置图片，带圆角，头像默认5像素圆角
 *
 *  @param image  头像图片
 *  @param radius 头像大小
 */
- (void)tc_setHeaderImage:(UIImage *)image withSize:(CGSize)size {
    [self tc_setImageWithRadius:5.0f image:image size:size];
}

/**
 *  设置图片，带圆角
 *
 *  @param radius 圆角半径
 *  @param image  图片
 *  @param size   圆角图片大小
 */
- (void)tc_setImageWithRadius:(CGFloat)radius image:(UIImage *)image size:(CGSize)size {
    self.image = [image tc_cornerImageWithRadius:radius size:size];
}

/**
 *  设置圆角，大概5像素
 */
- (void)tc_setCorner {
    UIImageView *cornerImageView = [[UIImageView alloc] initWithImage:[self tc_cornerImage]];
    [self addSubview:cornerImageView];
    __weak typeof(self) weakSelf = self;
    [cornerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakSelf);
    }];
}

/**
 *  返回圆角底图
 */
- (UIImage *)tc_cornerImage {
    UIImage *radiusImage = [UIImage imageNamed:@"CornerRadius"];
    return [radiusImage resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)
                                       resizingMode:UIImageResizingModeStretch];
}

@end
