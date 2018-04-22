//
//  ViewController.m
//  YKT
//
//  Created by 周春仕 on 2018/4/12.
//  Copyright © 2018年 周春仕. All rights reserved.
//

#import "ViewController.h"
#import "SaleTicketMainController.h"
#import "BaseNaviViewController.h"
#import "BCHomeController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)shoupiao:(id)sender {
    SaleTicketMainController *vc = [SaleTicketMainController new];
    BaseNaviViewController *navi = [[BaseNaviViewController alloc] initWithRootViewController:vc];
    [self presentViewController:navi animated:YES completion:nil];
}
- (IBAction)logout:(id)sender {
    
}
- (IBAction)baoche:(id)sender {
    BCHomeController *vc = [BCHomeController new];
    BaseNaviViewController *navi = [[BaseNaviViewController alloc] initWithRootViewController:vc];
    [self presentViewController:navi animated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
