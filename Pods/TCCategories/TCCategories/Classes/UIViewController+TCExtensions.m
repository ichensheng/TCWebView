//
//  UIViewController+TCExtensions.m
//  TCCategories
//
//  Created by 陈 胜 on 16/5/24.
//  Copyright © 2016年 陈胜. All rights reserved.
//

#import "UIViewController+TCExtensions.h"
#import "UINavigationItem+TCExtensions.h"
#import "JRSwizzle.h"
#import <objc/runtime.h>
#import "Masonry.h"

static const CGFloat kBackButtonMaxWidth = 150;         // 返回按钮最大宽度
static const CGFloat kBackButtonHeight = 30;            // 返回按钮高度
static const CGFloat kBackButtonArrowWidth = 15;        // 返回箭头宽度

NSString const * kBackButtonTitle = @"backButtonTitle";
NSString const * kAddedBackButton = @"addedBackButton";

@implementation UIViewController (TCExtensions)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSError *error;
        BOOL result = [[self class] jr_swizzleMethod:@selector(viewWillAppear:)
                                          withMethod:@selector(tc_viewWillAppear:)
                                               error:&error];
        if (!result || error) {
            NSLog(@"Can't swizzle methods - %@", [error description]);
        }
    });
}

- (void)tc_viewWillAppear:(BOOL)animated {
    [self tc_viewWillAppear:animated];
    
    if (!self.navigationController) {
        return;
    }
    if (!self.isAddedBackButton) {
        self.addedBackButton = YES;
        [self customBackButton];
    }
}

- (void)tc_adjustBackButtonForTitle:(NSString *)title {
    CGSize boudingSize = [self boundingSizeWithFont:[self navigationBarBackButtonFont]
                                          forString:title
                                     constraintSize:CGSizeMake(kBackButtonMaxWidth, kBackButtonHeight)];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [backButton addTarget:self action:@selector(__tc_back:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setFrame:CGRectMake(0, 0, boudingSize.width + kBackButtonArrowWidth, kBackButtonHeight)];
    [backButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [backButton setExclusiveTouch:YES];
    UIImage *barButtonImage = [UIImage imageNamed:[self defaultBackButtonIcon]];
    [backButton setImage:barButtonImage forState:UIControlStateNormal];
    [backButton setTitle:title forState:UIControlStateNormal];
    [backButton setTintColor:[self navigationBarBackTintColor]];
    backButton.titleLabel.font = [self navigationBarBackButtonFont];;
    [backButton sizeToFit];
    CGRect frame = backButton.frame;
    CGRect containerFrame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    UIView *backButtonContainer = [[UIView alloc] initWithFrame:containerFrame];
    [backButtonContainer addSubview:backButton];
    UIBarButtonItem *backMenuBarButton = [[UIBarButtonItem alloc] initWithCustomView:backButtonContainer];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationItem tc_setLeftBarButtonItems:@[backMenuBarButton]];
        
        // 返回按钮文字居中
        for (UIView *subview in [backButton subviews]) {
            NSString *buttonLabelClass = [NSString stringWithFormat:@"%@%@", @"UIButton", @"Label"];
            if ([NSStringFromClass([subview class]) isEqualToString:buttonLabelClass]) {
                [subview mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.equalTo(backButton);
                }];
                break;
            }
        }
    });
}

#pragma mark - Private Methods

- (void)customBackButton {
    NSInteger count = self.navigationController.viewControllers.count;
    NSArray *classes = @[[UITabBarController class], [UINavigationController class]];
    if (count >= 2 && ![classes containsObject:[self class]]) {
        if (!self.navigationItem.leftBarButtonItem) { // 不覆盖自定义的leftBarButtonItem
            NSString *title = self.backButtonTitle;
            if (!title) {
                UIViewController *preViewController = self.navigationController.viewControllers[count - 2];
                UIBarButtonItem *backBarButtonItem = preViewController.navigationItem.backBarButtonItem;
                title = backBarButtonItem.title ?: preViewController.navigationItem.title;
                if (!title) {
                    title = [self defaultBackTitle];
                }
            }
            [self tc_adjustBackButtonForTitle:title];
        }
    }
}

/**
 *  该方法不能被覆盖，否则点击返回按钮不能返回
 */
- (void)__tc_back:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (CGSize)boundingSizeWithFont:(UIFont *)font
                     forString:(NSString *)string
                constraintSize:(CGSize)size {
    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle};
    return [string boundingRectWithSize:size
                                options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                             attributes:attributes
                                context:nil].size;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wundeclared-selector"
#pragma clang diagnostic ignored"-Warc-performSelector-leaks"
- (UIFont *)navigationBarBackButtonFont {
    UIFont *navigationBarBackButtonFont = [UIFont boldSystemFontOfSize:17];
    SEL rc_navigationBarBackButtonFont = @selector(rc_navigationBarBackButtonFont);
    if ([self respondsToSelector:rc_navigationBarBackButtonFont]) {
        navigationBarBackButtonFont = [self performSelector:rc_navigationBarBackButtonFont];
    }
    return navigationBarBackButtonFont;
}

- (NSString *)defaultBackButtonIcon {
    NSString *defaultBackButtonIcon = @"barbuttonicon_back";
    SEL rc_defaultBackButtonIcon = @selector(rc_defaultBackButtonIcon);
    if ([self respondsToSelector:rc_defaultBackButtonIcon]) {
        defaultBackButtonIcon = [self performSelector:rc_defaultBackButtonIcon];
    }
    return defaultBackButtonIcon;
}

- (NSString *)defaultBackTitle {
    NSString *defaultBackTitle = @"返回";
    SEL rc_defaultBackTitle = @selector(rc_defaultBackTitle);
    if ([self respondsToSelector:rc_defaultBackTitle]) {
        defaultBackTitle = [self performSelector:rc_defaultBackTitle];
    }
    return defaultBackTitle;
}

- (UIColor *)navigationBarBackTintColor {
    UIColor *navigationBarBackTintColor = [UIColor colorWithRed:252.0f / 255 green:61.0f / 255 blue:57.0f / 255 alpha:1];
    SEL rc_navigationBarBackTintColor = @selector(rc_navigationBarBackTintColor);
    if ([self respondsToSelector:rc_navigationBarBackTintColor]) {
        navigationBarBackTintColor = [self performSelector:rc_navigationBarBackTintColor];
    }
    return navigationBarBackTintColor;
}
#pragma clang diagnostic pop

#pragma mark - Getters and Setters

- (void)setBackButtonTitle:(NSString *)title {
    objc_setAssociatedObject(self, &kBackButtonTitle, title, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)backButtonTitle {
    return objc_getAssociatedObject(self, &kBackButtonTitle);
}

- (void)setAddedBackButton:(BOOL)addedBackButton {
    objc_setAssociatedObject(self, &kAddedBackButton, @(addedBackButton), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)isAddedBackButton {
    NSValue *value = objc_getAssociatedObject(self, &kAddedBackButton);
    BOOL added = NO;
    [value getValue:&added];
    return added;
}

@end
