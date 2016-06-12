//
//  UICollectionView+TCExtensions.m
//  TCCategories
//
//  Created by 陈 胜 on 16/5/24.
//  Copyright © 2016年 陈胜. All rights reserved.
//

#import "UICollectionView+TCExtensions.h"

@implementation UICollectionView (TCExtensions)

/**
 *  滚动到顶部
 */
- (void)tc_scrollToTop {
    if ([self visibleCells].count > 0) {
        [self scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                     atScrollPosition:UICollectionViewScrollPositionTop
                             animated:YES];
    }
}

@end
