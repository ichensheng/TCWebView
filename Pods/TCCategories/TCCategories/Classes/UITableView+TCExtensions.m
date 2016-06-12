//
//  UITableView+TCExtensions.m
//  TCCategories
//
//  Created by 陈 胜 on 16/5/24.
//  Copyright © 2016年 陈胜. All rights reserved.
//

#import "UITableView+TCExtensions.h"

@implementation UITableView (TCExtensions)

/**
 *  隐藏多余的cell线条
 */
- (void)tc_hideExtraCellLine {
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    self.tableFooterView = view;
}

/**
 *  滚动到顶部
 */
- (void)tc_scrollToTop {
    if ([self visibleCells].count > 0) {
        [self scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                    atScrollPosition:UITableViewScrollPositionTop
                            animated:YES];
    }
}

@end
