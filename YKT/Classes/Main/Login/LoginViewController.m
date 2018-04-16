//
//  LoginViewController.m
//  YKT
//
//  Created by 周春仕 on 2018/4/16.
//  Copyright © 2018年 周春仕. All rights reserved.
//

#import "LoginViewController.h"
#import "KRMainNetTool.h"
#import "KRUserInfo.h"
@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"登录";
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)login:(id)sender {
    [[KRMainNetTool sharedKRMainNetTool] sendRequstWith:@"member/login/login4App.do" params:@{@"mobile":@"18072250018",@"password":@"123"} withModel:nil waitView:self.view complateHandle:^(id showdata, NSString *error) {
        if (showdata) {
            [self saveToUserDefaultsWithKey:@"USERINFO" Value:showdata];
            [[KRUserInfo sharedKRUserInfo] setValuesForKeysWithDictionary:showdata];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
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
