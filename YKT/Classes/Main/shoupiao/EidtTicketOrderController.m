//
//  EidtTicketOrderController.m
//  YKT
//
//  Created by 周春仕 on 2018/4/13.
//  Copyright © 2018年 周春仕. All rights reserved.
//

#import "EidtTicketOrderController.h"

@interface EidtTicketOrderController ()
@property (weak, nonatomic) IBOutlet UILabel *startStation;
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UILabel *endStation;
@property (weak, nonatomic) IBOutlet UILabel *carNum;
@property (weak, nonatomic) IBOutlet UILabel *startTime;
@property (weak, nonatomic) IBOutlet UILabel *position;
@property (weak, nonatomic) IBOutlet UILabel *unitPrice;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *passengerViewHeight;
@property (weak, nonatomic) IBOutlet UILabel *remainNum;
@property (weak, nonatomic) IBOutlet UITextField *pickTicketPeoeleField;
@property (weak, nonatomic) IBOutlet UITextField *pickTicketPhoneField;
@property (weak, nonatomic) IBOutlet UILabel *actualPrice;
@property (weak, nonatomic) IBOutlet UILabel *PriceMath;
@property (weak, nonatomic) IBOutlet UILabel *AllPrice;
@end

@implementation EidtTicketOrderController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self popOut];
    self.navigationItem.title = @"填写订单";
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)needToKnow:(UIButton *)sender {
}
- (IBAction)addPassenger:(UIButton *)sender {
}
- (IBAction)chooseDiscountCoupon:(id)sender {
}
- (IBAction)submitOrder:(UIButton *)sender {
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
