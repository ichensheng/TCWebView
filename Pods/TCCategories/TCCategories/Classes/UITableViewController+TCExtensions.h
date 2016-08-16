//
//  UITableViewController+TCExtensions.h
//  TCCategories
//
//  Created by 陈 胜 on 16/5/24.
//  Copyright © 2016年 陈胜. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TCSearchGuideViewDelegate;
@interface TCSearchGuideView : UIView

@property (nonatomic, weak) id<TCSearchGuideViewDelegate> delegate;
@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UITabBarController *tabBarController; // 可以为空

@end

@protocol TCSearchGuideViewDelegate <NSObject>

- (void)searchGuideViewTapped:(TCSearchGuideView *)searchGuideView;

@end

@interface UITableViewController (TCExtensions) <UISearchBarDelegate, UISearchDisplayDelegate, TCSearchGuideViewDelegate>

@property (nonatomic, assign, getter=isShowSearchGuideView) BOOL showSearchGuideView; // 默认不显示searchGuideView
@property (nonatomic, strong) TCSearchGuideView *searchGuideView;
@property (nonatomic, strong) UISearchBar *searchBar;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
@property (nonatomic, strong) UISearchDisplayController *searchDisplayController;
#pragma clang diagnostic pop

/**
 *  添加搜索条
 */
- (void)tc_addSearchBar;

/**
 *  滚动到顶部
 */
- (void)tc_scrollToTop;

@end
