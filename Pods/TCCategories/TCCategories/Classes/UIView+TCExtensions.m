//
//  UIView+TCExtentions.m
//  TCCategories
//
//  Created by 陈 胜 on 16/5/24.
//  Copyright © 2016年 陈胜. All rights reserved.
//

#import "UIView+TCExtensions.h"
#import <QuartzCore/QuartzCore.h>
#import "Masonry.h"
#import "JRSwizzle.h"
#import <objc/runtime.h>
#import "UIApplication+TCExtensions.h"
#import "UITableViewController+TCExtensions.h"

static const NSInteger kBorderTopTag = 100100;      // 上边框tag
static const NSInteger kBorderRightTag = 100101;    // 右边框tag
static const NSInteger kBorderBottomTag = 100102;   // 下边框tag
static const NSInteger kBorderLeftTag = 100103;     // 左边框tag

static CGFloat kDefaultBorderWidth = 0.5f;          // 边框默认宽度

@implementation UIView (RHExtentions)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSError *error;
        BOOL result = [[self class] jr_swizzleMethod:@selector(addSubview:)
                                          withMethod:@selector(tc_addSubview:)
                                               error:&error];
        if (!result || error) {
            NSLog(@"Can't swizzle methods - %@", [error description]);
        }
    });
}

- (void)tc_addSubview:(UIView *)view {
    [self tc_addSubview:view];
    if ([view isKindOfClass:NSClassFromString(@"UISearchDisplayControllerContainerView")]) {
        for (UIView *subview in view.subviews) {
            for (UIView *view in subview.subviews) {
                if ([view isKindOfClass:NSClassFromString(@"_UISearchDisplayControllerDimmingView")]) {
                    UIViewController *currentController = [[UIApplication sharedApplication] tc_currentViewController];
                    if ([currentController performSelector:@selector(isShowSearchGuideView)]) {
                        UIControl *dimmingView = (UIControl *)view;
                        UIView *dimmingSuperView = (UIView *)subview;
                        // 将默认遮罩移到屏幕之外
                        dimmingView.top = 10000;
                        BOOL added = NO;
                        for (UIView *v in dimmingSuperView.subviews) {
                            if ([v isKindOfClass:[TCSearchGuideView class]]) {
                                added = YES;
                            }
                        }
                        TCSearchGuideView *searchGuideView = [currentController performSelector:@selector(searchGuideView)];
                        searchGuideView.hidden = NO;
                        if (!added) {
                            [dimmingSuperView addSubview:searchGuideView];
                        }
                    }
                    return;
                }
            }
        }
    }
}

- (void)tc_setRoundedCorners:(UIRectCorner)corners radius:(CGSize)size {
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:corners cornerRadii:size];
    
    CAShapeLayer *maskLayer = [CAShapeLayer new];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    
    self.layer.mask = maskLayer;
}

- (UIView *)tc_findViewRecursively:(BOOL(^)(UIView *subview, BOOL *stop))recurse {
    for (UIView *subview in self.subviews) {
        BOOL stop = NO;
        if (recurse(subview, &stop)) {
            return [subview tc_findViewRecursively:recurse];
        } else if (stop) {
            return subview;
        }
    }
    
    return nil;
}

- (void)tc_setBorder:(TCBorderPosition)borderPos borderColor:(UIColor *)borderColor borderWidth:(CGFloat)borderWidth {
    if ((borderPos & TCBorderPositionAll) == TCBorderPositionAll) {
        self.layer.borderColor = borderColor.CGColor;
        self.layer.borderWidth = borderWidth;
        return;
    }
    
    __weak typeof(self) weakself = self;
    if ((borderPos & TCBorderPositionTop) == TCBorderPositionTop) {
        UIView *border = [self findBorder:TCBorderPositionTop];
        if (border) {
            [border mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(borderWidth);
            }];
        } else {
            border  = [[UIView alloc] init];
            [self addSubview:border];
            [border mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(0);
                make.top.mas_equalTo(0);
                make.width.equalTo(weakself.mas_width);
                make.height.mas_equalTo(borderWidth);
            }];
        }
        border.backgroundColor = borderColor;
    }
    
    if ((borderPos & TCBorderPositionRight) == TCBorderPositionRight) {
        UIView *border = [self findBorder:TCBorderPositionRight];
        if (border) {
            [border mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(borderWidth);
            }];
        } else {
            border  = [[UIView alloc] init];
            [self addSubview:border];
            [border mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(0);
                make.top.mas_equalTo(0);
                make.width.mas_equalTo(borderWidth);
                make.height.mas_equalTo(weakself.mas_height);
            }];
        }
        border.backgroundColor = borderColor;
    }
    
    if ((borderPos & TCBorderPositionBottom) == TCBorderPositionBottom) {
        UIView *border = [self findBorder:TCBorderPositionBottom];
        if (border) {
            [border mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(borderWidth);
            }];
        } else {
            border  = [[UIView alloc] init];
            [self addSubview:border];
            [border mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(0);
                make.bottom.mas_equalTo(0);
                make.width.equalTo(weakself.mas_width);
                make.height.mas_equalTo(borderWidth);
            }];
        }
        border.backgroundColor = borderColor;
    }
    
    if ((borderPos & TCBorderPositionLeft) == TCBorderPositionLeft) {
        UIView *border = [self findBorder:TCBorderPositionLeft];
        if (border) {
            [border mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(borderWidth);
            }];
        } else {
            border  = [[UIView alloc] init];
            [self addSubview:border];
            [border mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(0);
                make.top.mas_equalTo(0);
                make.width.mas_equalTo(borderWidth);
                make.height.mas_equalTo(weakself.mas_height);
            }];
        }
        border.backgroundColor = borderColor;
    }
}

- (void)tc_setBorder:(TCBorderPosition)borderPos {
    UIColor *defaultBorderColor = [UIColor colorWithRed:(210) / 255.0 green:(210) / 255.0 blue:(210) / 255.0 alpha:(1)];
    [self tc_setBorder:borderPos borderColor:defaultBorderColor borderWidth:kDefaultBorderWidth];
}

- (UIView *)findBorder:(TCBorderPosition)position {
    return [self tc_findViewRecursively:^BOOL(UIView *subview, BOOL *stop) {
        switch (subview.tag) {
            case kBorderTopTag:
            case kBorderRightTag:
            case kBorderBottomTag:
            case kBorderLeftTag:
                return YES;
            default:
                break;
        }
        return NO;
    }];
}

/**
 *  设置图标圆角
 *
 *  @param radius 圆角弧度
 */
- (void)tc_setCornerWithRadius:(CGFloat)radius {
    CALayer *layer  = self.layer;
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:radius];
}

/**
 *  设置图标圆角，默认5.0f的圆角
 */
- (void)tc_setCornerForImageView {
    [self tc_setCornerWithRadius:5.0f];
}

/**
 *  设置按钮圆角，默认6.0f的圆角
 */
- (void)tc_setCornerForButton {
    [self tc_setCornerWithRadius:6.0f];
}

- (CGFloat)top {
    return self.frame.origin.y;
}

- (void)setTop:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setBottom:(CGFloat)bottom {
    CGRect frame = self.frame;
    frame.origin.y = bottom - frame.size.height;
    self.frame = frame;
}

- (CGFloat)left {
    return self.frame.origin.x;
}

- (void)setLeft:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)right {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setRight:(CGFloat)right {
    CGRect frame = self.frame;
    frame.origin.x = right - frame.size.width;
    self.frame = frame;
}

- (CGFloat)width {
    return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)height {
    return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGFloat)centerX {
    return self.center.x;
}

- (void)setCenterX:(CGFloat)centerX {
    self.center = CGPointMake(centerX, self.center.y);
}

- (CGFloat)centerY {
    return self.center.y;
}

- (void)setCenterY:(CGFloat)centerY {
    self.center = CGPointMake(self.center.x, centerY);
}

- (CGPoint)origin {
    return self.frame.origin;
}

- (void)setOrigin:(CGPoint)origin {
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGSize)size {
    return self.frame.size;
}

- (void)setSize:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

/**
 *  毛玻璃效果
 *
 *  @param extra YES：UIBlurEffectStyleExtraLight，NO：UIBlurEffectStyleLight
 */
- (void)tc_addBlurEffect:(BOOL)extra {
    self.backgroundColor = [UIColor clearColor];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        UIBlurEffect *blur;
        if (extra) {
            blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
        } else {
            blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        }
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blur];
        effectView.frame = self.bounds;
        [self insertSubview:effectView atIndex:0];
    } else {
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:self.bounds];
        [self setClipsToBounds:YES];
        [self insertSubview:toolbar atIndex:0];
    }
}

@end
