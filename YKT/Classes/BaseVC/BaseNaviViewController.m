//
//  BaseNaviViewController.m
//  AiXiangBan
//
//  Created by 周春仕 on 2017/10/4.
//  Copyright © 2017年 周春仕. All rights reserved.
//

#import "BaseNaviViewController.h"
#import "UIImage+Color.h"
#import "LRMacroDefinitionHeader.h"
@interface BaseNaviViewController ()<UIGestureRecognizerDelegate>


@end

@implementation BaseNaviViewController

+ (void)load{
    UINavigationBar *bar = [UINavigationBar appearance];
    bar.shadowImage=[UIImage new];
    [bar setTintColor:[UIColor blackColor]];
    [bar setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor] Size:CGSizeMake(SIZEWIDTH, 88)] forBarMetrics:UIBarMetricsDefault];
    [bar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]}];
    
}



- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.interactivePopGestureRecognizer.delegate = self;
    self.interactivePopGestureRecognizer.enabled = YES;
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
