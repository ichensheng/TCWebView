//
//  UICollectionViewController+TCExtensions.m
//  TCCategories
//
//  Created by 陈 胜 on 16/6/15.
//  Copyright © 2016年 陈胜. All rights reserved.
//

#import "UICollectionViewController+TCExtensions.h"

@implementation UICollectionViewController (TCExtensions)

/**
 *  滚动到顶部
 */
- (void)tc_scrollToTop {
    if (self.navigationController) {
        [self.collectionView setContentOffset:CGPointMake(0, -64) animated:YES];
    } else {
        [self.collectionView setContentOffset:CGPointMake(0, -44) animated:YES];
    }
}

@end
