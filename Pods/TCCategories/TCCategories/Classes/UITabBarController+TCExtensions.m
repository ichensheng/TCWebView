//
//  UITabBarController+TCExtensions.m
//  TCCategories
//
//  Created by 陈 胜 on 16/5/24.
//  Copyright © 2016年 陈胜. All rights reserved.
//

#import "UITabBarController+TCExtensions.h"

@implementation UITabBarController (TCExtensions)

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [self.selectedViewController preferredStatusBarStyle];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [self.selectedViewController supportedInterfaceOrientations];
}

- (BOOL)shouldAutorotate {
    return [self.selectedViewController shouldAutorotate];
}

@end
