//
//  ViewController.m
//  TCWebView
//
//  Created by 陈 胜 on 16/6/12.
//  Copyright © 2016年 陈胜. All rights reserved.
//

#import "ViewController.h"
#import "TCWebViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)openBaidu:(UIButton *)sender {
    TCWebViewController *webViewController = [[TCWebViewController alloc] initWithURL:@"http://www.baidu.com"];
    [self.navigationController pushViewController:webViewController animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
