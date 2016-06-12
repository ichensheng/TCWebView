//
//  UIViewController+TCExtensions.h
//  TCCategories
//
//  Created by 陈 胜 on 16/5/24.
//  Copyright © 2016年 陈胜. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (TCExtensions)

@property (nonatomic, copy) NSString *backButtonTitle;                          // 自定义返回按钮的title
@property (nonatomic, assign, getter=isAddedBackButton) BOOL addedBackButton;   // 自己添加了返回按钮

/**
 *  修改返回按钮文字的接口
 *
 *  @param title 返回按钮的title
 */
- (void)tc_adjustBackButtonForTitle:(NSString *)title;

@end
