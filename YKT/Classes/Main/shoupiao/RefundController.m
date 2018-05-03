//
//  RefundController.m
//  YKT
//
//  Created by 周春仕 on 2018/4/13.
//  Copyright © 2018年 周春仕. All rights reserved.
//

#import "RefundController.h"
#import "LRMacroDefinitionHeader.h"
@interface RefundController ()
@property (weak, nonatomic) IBOutlet UILabel *money;
@property (nonatomic, strong) NSString *totalCharge;
@end

@implementation RefundController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"退款";
    [self popOut];
    [self requestData];
    // Do any additional setup after loading the view from its nib.
}

- (void)requestData {
    [[KRMainNetTool sharedKRMainNetTool] sendRequstWith:self.isBC ? @"eBusiness/bc/calculateCharge.do":@"member/order/getReturnOrderCharge.do" params:@{@"orderId":self.orderId} withModel:nil waitView:self.view complateHandle:^(id showdata, NSString *error) {
        if (showdata) {
            NSDictionary *dic = showdata;
            if (self.isBC) {
                self.money.text = [NSString stringWithFormat:@"￥%@",dic[@"totalFee"]];
            }
            else {
                self.money.text = [NSString stringWithFormat:@"￥%@",dic[@"totalCharge"]];
                self.totalCharge = dic[@"totalCharge"];
            }
        }
    }];
}
- (IBAction)cancel:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)refund:(UIButton *)sender {
    [[KRMainNetTool sharedKRMainNetTool] sendRequstWith:self.isBC ? @"eBusiness/bc/cancelBcOrderInfo.do":@"member/order/returnOrder.do" params:self.isBC ? @{@"ids":self.orderId}:@{@"orderId":self.orderId,@"charge":self.totalCharge} withModel:nil waitView:self.view complateHandle:^(id showdata, NSString *error) {
        if (!error) {
            [self showHUDWithText:@"退款成功"];
            [self performSelector:@selector(popOutAction) withObject:nil afterDelay:1.0];
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
