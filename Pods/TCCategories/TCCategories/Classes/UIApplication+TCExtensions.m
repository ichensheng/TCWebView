//
//  UIApplication+TCExtensions.m
//  TCCategories
//
//  Created by 陈 胜 on 16/5/24.
//  Copyright © 2016年 陈胜. All rights reserved.
//

#import "UIApplication+TCExtensions.h"

@implementation UIApplication (TCExtensions)

- (UIViewController *)tc_currentViewController {
    UIViewController *viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    if ([viewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarController = (UITabBarController *)viewController;
        return [self currentViewController:tabBarController];
    } else if ([viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)viewController;
        return [navigationController topViewController];
    } else {
        return viewController;
    }
}

- (UIViewController *)currentViewController:(UITabBarController *)tabBarController {
    UIViewController *selectedViewController = tabBarController.selectedViewController;
    if ([selectedViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)selectedViewController;
        return [navigationController topViewController];
    } else if ([selectedViewController isKindOfClass:[UITabBarController class]]) {
        return [self currentViewController:(UITabBarController *)selectedViewController];
    } else {
        return selectedViewController;
    }
}

@end
