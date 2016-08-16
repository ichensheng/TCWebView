//
//  UITableViewController+TCExtensions.m
//  TCCategories
//
//  Created by 陈 胜 on 16/5/24.
//  Copyright © 2016年 陈胜. All rights reserved.
//

#import "UITableViewController+TCExtensions.h"
#import "JRSwizzle.h"
#import <objc/runtime.h>
#import "UIView+TCExtensions.h"
#import "UITableView+TCExtensions.h"
#import "Masonry.h"

/**
 *  tableview分隔线颜色
 */
#ifndef kTableViewSeparatorColor
#define kTableViewSeparatorColor [UIColor colorWithRed:225.0f / 255 green:225.0f / 255 blue:225.0f / 255 alpha:1]
#endif

NSString const * kShowSearchGuideView = @"showSearchGuideView";
NSString const * kSearchGuideView = @"searchGuideView";
NSString const * kSearchBar = @"searchBar";
NSString const * kSearchDisplayController = @"searchDisplayController";

@implementation UITableViewController (TCExtensions)

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
        
        result = [[self class] jr_swizzleMethod:@selector(viewDidAppear:)
                                     withMethod:@selector(tc_viewDidAppear:)
                                          error:&error];
        if (!result || error) {
            NSLog(@"Can't swizzle methods - %@", [error description]);
        }
    });
}

- (void)tc_viewDidLoad {
    [self tc_viewDidLoad];
    self.clearsSelectionOnViewWillAppear = NO;
    self.tableView.separatorColor = kTableViewSeparatorColor;
}

- (void)tc_viewDidAppear:(BOOL)animated {
    self.tableView.showsVerticalScrollIndicator = NO;
    [self tc_viewDidAppear:animated];
    self.tableView.showsVerticalScrollIndicator = YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length > 0) {
        self.searchGuideView.hidden = YES;
    } else {
        self.searchGuideView.hidden = NO;
    }
}

/**
 *  添加搜索条
 */
- (void)tc_addSearchBar {
    self.searchBar = [[UISearchBar alloc] init];
    [self.searchBar sizeToFit];
    self.searchBar.delegate = self;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    self.searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
#pragma clang diagnostic pop
    self.searchDisplayController.searchResultsDataSource = self;
    self.searchDisplayController.searchResultsDelegate = self;
    self.searchDisplayController.delegate = self;
    self.searchDisplayController.searchResultsTableView.tableFooterView = [[UIView alloc] init];
    self.tableView.tableHeaderView = self.searchBar;
}

/**
 *  滚动到顶部
 */
- (void)tc_scrollToTop {
    if (self.navigationController) {
        [self.tableView setContentOffset:CGPointMake(0, -64) animated:YES];
    } else {
        [self.tableView setContentOffset:CGPointMake(0, -44) animated:YES];
    }
}

#pragma mark - Getters and Setters

- (void)setShowSearchGuideView:(BOOL)showSearchGuideView {
    if (showSearchGuideView) {
        self.searchGuideView = [[TCSearchGuideView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
        self.searchGuideView.delegate = self;
        UIViewController *viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        if ([viewController isKindOfClass:[UITabBarController class]]) {
            self.searchGuideView.tabBarController = (UITabBarController *)viewController;
        }
    }
    objc_setAssociatedObject(self, &kShowSearchGuideView, @(showSearchGuideView), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)isShowSearchGuideView {
    NSValue *value = objc_getAssociatedObject(self, &kShowSearchGuideView);
    BOOL showed = NO;
    [value getValue:&showed];
    return showed;
}

- (void)setSearchGuideView:(TCSearchGuideView *)searchGuideView {
    objc_setAssociatedObject(self, &kSearchGuideView, searchGuideView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)searchGuideView {
    return objc_getAssociatedObject(self, &kSearchGuideView);
}

- (void)setSearchBar:(UISearchBar *)searchBar {
    objc_setAssociatedObject(self, &kSearchBar, searchBar, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)searchBar {
    return objc_getAssociatedObject(self, &kSearchBar);
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (void)setSearchDisplayController:(UISearchDisplayController *)searchDisplayController {
    objc_setAssociatedObject(self, &kSearchDisplayController, searchDisplayController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
#pragma clang diagnostic pop

- (NSString *)searchDisplayController {
    return objc_getAssociatedObject(self, &kSearchDisplayController);
}

#pragma mark - TCSearchGuideViewDelegate

- (void)searchGuideViewTapped:(TCSearchGuideView *)searchGuideView {
    if (self.searchGuideView.tabBarController) {
        self.searchGuideView.tabBarController.tabBar.hidden = YES;
    }
    [self.searchBar resignFirstResponder];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    if (self.searchGuideView.tabBarController) {
        self.searchGuideView.tabBarController.tabBar.hidden = NO;
    }
    self.searchGuideView.hidden = YES;
}

@end

@implementation TCSearchGuideView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self tc_addBlurEffect:NO];
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.alwaysBounceVertical = YES;
        _scrollView.backgroundColor = [UIColor clearColor];
        [self addSubview:_scrollView];
        
        /**
         * guide view点击事件
         */
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(searchGuideViewTapped:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)searchGuideViewTapped:(UITapGestureRecognizer *)event{
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchGuideViewTapped:)]) {
        [self.delegate searchGuideViewTapped:self];
    }
}

@end






