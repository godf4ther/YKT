//
//  webViewController.m
//  YKT
//
//  Created by 周春仕 on 2018/4/24.
//  Copyright © 2018年 周春仕. All rights reserved.
//

#import "webViewController.h"

@interface webViewController ()

@end

@implementation webViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self popOut];
    self.navigationItem.title = @"购票需知";
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://test.bnx666.com/wap/huasky/ticket-notice.html"]];
    [webView loadRequest:request];
    [self.view addSubview:webView];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
