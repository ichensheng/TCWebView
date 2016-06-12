//
//  UIImage+TCExtensions.h
//  TCCategories
//
//  Created by 陈 胜 on 16/5/24.
//  Copyright © 2016年 陈胜. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (TCExtensions)

- (UIImage *)tc_scaleToSize:(CGSize)size;
- (UIImage *)tc_scaleToRatio:(CGFloat)ratio;
- (UIImage *)tc_scaleToFitSize:(CGSize)fitSize;
+ (UIImage *)tc_QRCodeForString:(NSString *)string
                       withSize:(CGFloat)size;
+ (UIImage *)tc_QRCodeForString:(NSString *)string
                       withSize:(CGFloat)size
                      fillColor:(UIColor *)color;
+ (UIImage *)imageNamed:(NSString *)name withColor:(UIColor *)color;

@end
