//
//  NeedToKownController.m
//  YKT
//
//  Created by 周春仕 on 2018/4/24.
//  Copyright © 2018年 周春仕. All rights reserved.
//

#import "NeedToKownController.h"

@interface NeedToKownController ()

@end

@implementation NeedToKownController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"包车说明";
    [self popOut];
    // Do any additional setup after loading the view from its nib.
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
