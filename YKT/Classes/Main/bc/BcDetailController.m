//
//  BcDetailController.m
//  YKT
//
//  Created by 周春仕 on 2018/4/23.
//  Copyright © 2018年 周春仕. All rights reserved.
//

#import "BcDetailController.h"
#import "LRMacroDefinitionHeader.h"
#import "RefundController.h"
#import "PayTicketController.h"
@interface BcDetailController ()
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *allPrice;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel1;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel2;
@property (weak, nonatomic) IBOutlet UILabel *bcType;
@property (weak, nonatomic) IBOutlet UILabel *orderNum;
@property (weak, nonatomic) IBOutlet UILabel *linkman;
@property (weak, nonatomic) IBOutlet UILabel *linkmanPhone;
@property (weak, nonatomic) IBOutlet UILabel *orderTime;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *sureBtn;
@property (weak, nonatomic) IBOutlet UIView *bottomVIew;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomHeight;
@property (weak, nonatomic) IBOutlet UILabel *startPlace;
@property (weak, nonatomic) IBOutlet UILabel *endPlace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *startPlaceTop;

@end

@implementation BcDetailController
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self requestData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"订单详情";
    [self popOut];
    // Do any additional setup after loading the view from its nib.
}

- (void)requestData {
    [[KRMainNetTool sharedKRMainNetTool] sendRequstWith:@"eBusiness/bc/findBcOrderInfoDetail.do" params:@{@"orderId":self.orderId} withModel:nil waitView:self.view complateHandle:^(id showdata, NSString *error) {
        if (showdata) {
            NSDictionary *dic = showdata[0];
            self.statusLabel.text = dic[@"statusName"];
            self.allPrice.text = [NSString stringWithFormat:@"￥%@",dic[@"totalPrice"]];
            if ([dic[@"journeyType"] isEqualToString:@"1"]) {
                self.timeLabel2.hidden = YES;
                self.bcType.text = @"单程";
                self.startPlaceTop.constant = 10;
            }
            else {
                self.timeLabel2.hidden = NO;
                self.bcType.text = @"往返";
                self.timeLabel2.text = self.journeyEndTime;
            }
            self.timeLabel1.text = self.journeyStartTime;
            self.startPlace.text = dic[@"startPointName"];
            self.endPlace.text = dic[@"endPointName"];
            self.orderNum.text = dic[@"orderCode"];
            self.orderTime.text = dic[@"operatorTime"];
            self.linkman.text = dic[@"orderPerson"];
            self.linkmanPhone.text = dic[@"orderPersonPhone"];
            NSString *status = dic[@"status"];
            if ([status isEqualToString:@"0"]) {
                [self.cancelBtn setTitle:@"取消订单" forState:UIControlStateNormal];
                [self.sureBtn setTitle:@"去支付" forState:UIControlStateNormal];
            }
            else if ([status isEqualToString:@"1"]) {
                [self.cancelBtn setTitle:@"退款" forState:UIControlStateNormal];
                [self.sureBtn setTitle:@"评价" forState:UIControlStateNormal];
            }
            else {
                self.bottomHeight.constant = 0;
                self.bottomVIew.hidden = YES;
            }
        }
    }];
}

- (IBAction)goExplain:(id)sender {
}
- (IBAction)cancel:(UIButton *)sender {
    if ([sender.titleLabel.text isEqualToString:@"取消订单"]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否确认取消订单" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[KRMainNetTool sharedKRMainNetTool] sendRequstWith:@"eBusiness/bc/cancelBcOrderInfo.do" params:@{@"ids":self.orderId} withModel:nil waitView:self.view complateHandle:^(id showdata, NSString *error) {
                if (!error) {
                    [self showHUDWithText:@"取消成功"];
                    [self performSelector:@selector(popOutAction) withObject:nil afterDelay:1.0];
                }
            }];
        }];
        [alert addAction:cancelAction];
        [alert addAction:sureAction];
        [self presentViewController:alert animated:YES completion:nil];
        
    }
    else if ([sender.titleLabel.text isEqualToString:@"退款"]) {
        RefundController *refundVC = [RefundController new];
        refundVC.orderId = self.orderId;
        refundVC.isBC = YES;
        [self.navigationController pushViewController:refundVC animated:YES];
    }
}
- (IBAction)sure:(UIButton *)sender {
    if ([sender.titleLabel.text isEqualToString:@"去支付"]) {
        PayTicketController *payVC = [PayTicketController new];
        payVC.orderId = self.orderId;
        payVC.journeyStartTime = self.journeyStartTime;
        payVC.journeyEndTime = self.journeyEndTime;
        payVC.isBC = YES;
        [self.navigationController pushViewController:payVC animated:YES];
    }
    else if ([sender.titleLabel.text isEqualToString:@"评价"]) {
        
    }
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
