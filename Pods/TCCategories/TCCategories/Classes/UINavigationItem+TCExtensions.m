//
//  UINavigationItem+TCExtensions.m
//  TCCategories
//
//  Created by 陈 胜 on 16/5/24.
//  Copyright © 2016年 陈胜. All rights reserved.
//

#import "UINavigationItem+TCExtensions.h"

static const CGFloat kSpacerWidth = -6.5; // 导航条左右按钮往两端移动的距离

@implementation UINavigationItem (TCExtensions)

- (void)tc_setLeftBarButtonItems:(NSArray *)leftBarButtonItems {
    if (leftBarButtonItems.count == 0) {
        return;
    }
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        UIBarButtonItem *firstBarButtonItem = [leftBarButtonItems firstObject];
        if (firstBarButtonItem.title) {
            [self setLeftBarButtonItems:leftBarButtonItems];
        } else {
            UIBarButtonItem *negativeSpacer =
            [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                          target:nil
                                                          action:nil];
            negativeSpacer.width = kSpacerWidth;
            NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:leftBarButtonItems];
            [mutableArray insertObject:negativeSpacer atIndex:0];
            [self setLeftBarButtonItems:mutableArray];
        }
    } else {
        [self setLeftBarButtonItems:leftBarButtonItems];
    }
}

- (void)tc_setRightBarButtonItems:(NSArray *)rightBarButtonItems {
    if (rightBarButtonItems.count == 0) {
        return;
    }
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        UIBarButtonItem *firstBarButtonItem = [rightBarButtonItems firstObject];
        if (firstBarButtonItem.title) {
            [self setRightBarButtonItems:rightBarButtonItems];
        } else {
            UIBarButtonItem *negativeSpacer =
            [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                          target:nil
                                                          action:nil];
            negativeSpacer.width = kSpacerWidth;
            NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:rightBarButtonItems];
            [mutableArray insertObject:negativeSpacer atIndex:0];
            [self setRightBarButtonItems:mutableArray];
        }
    } else {
        [self setRightBarButtonItems:rightBarButtonItems];
    }
}

- (void)tc_setLeftBarButtonItem:(UIBarButtonItem *)leftBarButtonItem {
    [self tc_setLeftBarButtonItems:@[leftBarButtonItem]];
}

- (void)tc_setRightBarButtonItem:(UIBarButtonItem *)rightBarButtonItem {
    [self tc_setRightBarButtonItems:@[rightBarButtonItem]];
}

@end
