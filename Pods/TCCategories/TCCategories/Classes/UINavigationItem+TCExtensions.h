//
//  UINavigationItem+TCExtensions.h
//  TCCategories
//
//  Created by 陈 胜 on 16/5/24.
//  Copyright © 2016年 陈胜. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationItem (TCExtensions)

- (void)tc_setLeftBarButtonItems:(NSArray *)leftBarButtonItems;
- (void)tc_setRightBarButtonItems:(NSArray *)rightBarButtonItems;
- (void)tc_setLeftBarButtonItem:(UIBarButtonItem *)leftBarButtonItem;
- (void)tc_setRightBarButtonItem:(UIBarButtonItem *)rightBarButtonItem;

@end
