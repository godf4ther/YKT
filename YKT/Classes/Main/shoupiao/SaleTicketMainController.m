//
//  SaleTicketMainController.m
//  YKT
//
//  Created by 周春仕 on 2018/4/12.
//  Copyright © 2018年 周春仕. All rights reserved.
//

#import "SaleTicketMainController.h"
#import "LRMacroDefinitionHeader.h"
#import "TicketListController.h"
@interface SaleTicketMainController ()
@property (weak, nonatomic) IBOutlet UILabel *startStation;
@property (weak, nonatomic) IBOutlet UILabel *endStation;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIButton *oldAddress1;
@property (weak, nonatomic) IBOutlet UIButton *oldAddress2;
@property (weak, nonatomic) IBOutlet UIButton *oldAddress3;
@property (weak, nonatomic) IBOutlet UIButton *oldAddress4;

@end

@implementation SaleTicketMainController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:COLOR(98, 143, 246, 1) Size:CGSizeMake(SIZEWIDTH, 88)] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor] Size:CGSizeMake(SIZEWIDTH, 88)] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTintColor:[UIColor blackColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]}];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self popOut];
    self.navigationItem.title = @"汽车票";
    // Do any additional setup after loading the view from its nib.
}

- (void)popOutAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)searchNow:(UIButton *)sender {
    TicketListController *ticketList = [TicketListController new];
    [self.navigationController pushViewController:ticketList animated:YES];
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
