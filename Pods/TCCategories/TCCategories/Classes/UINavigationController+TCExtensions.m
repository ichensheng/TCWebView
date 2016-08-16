//
//  UINavigationController+TCExtensions.m
//  TCCategories
//
//  Created by 陈 胜 on 16/5/24.
//  Copyright © 2016年 陈胜. All rights reserved.
//

#import "UINavigationController+TCExtensions.h"
#import "JRSwizzle.h"
#import <objc/runtime.h>

@interface UINavigationController()<UINavigationControllerDelegate>

@end

@implementation UINavigationController (TCExtensions)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSError *error;
        BOOL result = [[self class] jr_swizzleMethod:@selector(viewDidLoad)
                                          withMethod:@selector(tc_viewDidLoad)
                                               error:&error];
        if (!result || error) {
            NSLog(@"Can't swizzle methods - %@", [error description]);
        }
        
        result = [[self class] jr_swizzleMethod:@selector(pushViewController:animated:)
                                     withMethod:@selector(tc_pushViewController:animated:)
                                          error:&error];
        if (!result || error) {
            NSLog(@"Can't swizzle methods - %@", [error description]);
        }
        
        result = [[self class] jr_swizzleMethod:@selector(popViewControllerAnimated:)
                                     withMethod:@selector(tc_popViewControllerAnimated:)
                                          error:&error];
        if (!result || error) {
            NSLog(@"Can't swizzle methods - %@", [error description]);
        }
    });
}

- (void)tc_viewDidLoad {
    [self tc_viewDidLoad];
    self.delegate = self;
}

- (void)tc_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.viewControllers.count > 0) { // 只有最外层控制器才显示tabBar
        viewController.hidesBottomBarWhenPushed = YES;
    }
    [self tc_pushViewController:viewController animated:animated];
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.interactivePopGestureRecognizer.delegate = nil;
    }
}

- (UIViewController *)tc_popViewControllerAnimated:(BOOL)animated {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if ([[self.viewControllers lastObject] respondsToSelector:@selector(tc_beforePopViewController)]) {
        if ([[self.viewControllers lastObject] performSelector:@selector(tc_beforePopViewController)]) {
#pragma clang diagnostic pop
            return [self tc_popViewControllerAnimated:animated];
        } else {
            NSLog(@"beforePopViewController返回的值为NO，pop失败！");
            return nil;
        }
    } else {
        return [self tc_popViewControllerAnimated:animated];
    }
}

#pragma mark - UINavigationControllerDelegate

/**
 *  push stack里只有一个view controller时，
 *  如果interactivePopGestureRecognizer为YES，
 *  则会偶尔导致push view controller冻结住，只有切换到桌面再回来才会跳转到对应的页面的问题
 */
- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animate {
    
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        if (self.viewControllers.count > 1) {
            BOOL enabled = YES;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
            if ([viewController respondsToSelector:@selector(tc_interactivePopGestureRecognizer)]) {
                enabled = (BOOL) [viewController performSelector:@selector(tc_interactivePopGestureRecognizer)];
            }
#pragma clang diagnostic pop
            self.interactivePopGestureRecognizer.enabled = enabled;
        } else {
            self.interactivePopGestureRecognizer.enabled = NO;
        }
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [self.topViewController supportedInterfaceOrientations];
}

- (BOOL)shouldAutorotate {
    return [self.topViewController shouldAutorotate];
}

@end
