//
//  TicketOrderDetaialController.m
//  YKT
//
//  Created by 周春仕 on 2018/4/13.
//  Copyright © 2018年 周春仕. All rights reserved.
//

#import "TicketOrderDetaialController.h"
#import "LRMacroDefinitionHeader.h"
#import "CodeController.h"
#import "PayTicketController.h"
#import "RefundController.h"
@interface TicketOrderDetaialController ()
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *busTime;
@property (weak, nonatomic) IBOutlet UILabel *startStation;
@property (weak, nonatomic) IBOutlet UILabel *endStation;
@property (weak, nonatomic) IBOutlet UILabel *pwdLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderNo;
@property (weak, nonatomic) IBOutlet UILabel *orderTime;
@property (weak, nonatomic) IBOutlet UILabel *pickPeople;
@property (weak, nonatomic) IBOutlet UILabel *pickPhone;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *sureBtn;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomHeight;
@property (nonatomic, strong) NSArray *passengerArr;
@property (weak, nonatomic) IBOutlet UIView *passengerContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *passengerHeight;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@end

@implementation TicketOrderDetaialController
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self requestData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self popOut];
    self.navigationItem.title = @"订单详情";
    LRViewBorderRadius(self.statusLabel, 5, 1, ThemeColor);
    
    // Do any additional setup after loading the view from its nib.
}

- (void)requestData{
    [[KRMainNetTool sharedKRMainNetTool] sendRequstWith:@"member/order/findBusOrderInfoDetail.do" params:@{@"orderId":self.orderId} withModel:nil waitView:self.view complateHandle:^(id showdata, NSString *error) {
        if (showdata) {
            NSDictionary *dic = showdata[0];
            self.priceLabel.text = [NSString stringWithFormat:@"￥%.2f",[dic[@"totalPrice"] floatValue]];
            NSString *busTime = dic[@"busTime"];
            self.busTime.text = [NSString stringWithFormat:@"%@-%@-%@",[busTime substringWithRange:NSMakeRange(0, 4)],[busTime substringWithRange:NSMakeRange(4, 2)],[busTime substringWithRange:NSMakeRange(6, 2)] ];
            self.startStation.text = dic[@"sellStationName"];
            self.endStation.text = dic[@"endStationName"];
            self.pwdLabel.text = dic[@"billGetId"];
            self.orderNo.text = dic[@"outTradeNo"];
            NSString *operatorTime = dic[@"operatorTime"];
            self.orderTime.text = [NSString stringWithFormat:@"%@-%@-%@ %@:%@:%@",[operatorTime substringWithRange:NSMakeRange(0, 4)],[operatorTime substringWithRange:NSMakeRange(4, 2)],[operatorTime substringWithRange:NSMakeRange(6, 2)],[operatorTime substringWithRange:NSMakeRange(8, 2)],[operatorTime substringWithRange:NSMakeRange(10, 2)],[operatorTime substringWithRange:NSMakeRange(12, 2)]];
            self.pickPeople.text = [NSString stringWithFormat:@"取票人：%@",dic[@"gettkMan"]];
            self.pickPhone.text = dic[@"gettkPhone"];
            self.statusLabel.text = dic[@"busStatusName"];
            NSString *status = dic[@"busStatus"];
            if ([status isEqualToString:@"0"]) {
                [self.cancelBtn setTitle:@"取消订单" forState:UIControlStateNormal];
                [self.sureBtn setTitle:@"去支付" forState:UIControlStateNormal];
            }
            else if ([status isEqualToString:@"1"]) {
                [self.cancelBtn setTitle:@"退票" forState:UIControlStateNormal];
                [self.cancelBtn setTitle:@"评价" forState:UIControlStateNormal];
            }
            else {
                self.bottomHeight.constant = 0;
                self.bottomView.hidden = YES;
            }
        }
    }];
    [[KRMainNetTool sharedKRMainNetTool] sendRequstWith:@"member/order/findOrderSeat.do" params:@{@"orderId":self.orderId} withModel:nil complateHandle:^(id showdata, NSString *error) {
        if (showdata) {
            self.passengerArr = showdata;
            [self setPassengerUI];
        }
    }];
}

- (void)setPassengerUI{
    UIView *temp;
    self.passengerHeight.constant = 60 * self.passengerArr.count;
    for (int i = 0; i < self.passengerArr.count; i ++) {
        UIView *container = [[UIView alloc] init];
        container.backgroundColor = [UIColor whiteColor];
        [self.passengerContainer addSubview:container];
        [container mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.passengerContainer);
            make.height.mas_equalTo(60);
            if (i == 0) {
                make.top.equalTo(self.passengerContainer);
            }
            else {
                make.top.equalTo(temp.mas_bottom);
            }
        }];
        temp = container;
        NSDictionary *dic = self.passengerArr[i];
        UILabel *nameLabel = [[UILabel alloc] init];
        nameLabel.font = [UIFont systemFontOfSize:14];
        nameLabel.text = dic[@"linkmanName"];
        [container addSubview:nameLabel];
        [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(container).offset(12);
            make.top.equalTo(container).offset(10);
        }];
        UILabel *detailLabel = [[UILabel alloc] init];
        detailLabel.font = [UIFont systemFontOfSize:12];
        NSString *ticketType;
        if ([dic[@"ticketType"] isEqualToString:@"1"]) {
            ticketType = @"全票";
        }
        if ([dic[@"ticketType"] isEqualToString:@"2"]) {
            ticketType = @"半票";
        }
        if ([dic[@"ticketType"] isEqualToString:@"3"]) {
            ticketType = @"全票（携童）";
        }
        detailLabel.text = [NSString stringWithFormat:@"%@ 座位号：%@",ticketType,dic[@"seatNo"]];
        [container addSubview:detailLabel];
        [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(nameLabel.mas_right).offset(12);
            make.centerY.equalTo(nameLabel.mas_centerY);
        }];
        UILabel *idCardLabel = [[UILabel alloc] init];
        idCardLabel.font = [UIFont systemFontOfSize:12];
        idCardLabel.text = [NSString stringWithFormat:@"身份证%@",dic[@"linkmanCredit"]];
        [container addSubview:idCardLabel];
        [idCardLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(container).offset(12);
            make.bottom.equalTo(container).offset(-10);
        }];
    }
}


- (IBAction)goCode:(UITapGestureRecognizer *)sender {
    CodeController *codeVC = [CodeController new];
    codeVC.outTradeNo = self.orderNo.text;
    codeVC.billGetId = self.pwdLabel.text;
    [self.navigationController pushViewController:codeVC animated:YES];
}
- (IBAction)goExplain:(id)sender {
}
- (IBAction)cancelAction:(UIButton *)sender {
    if ([sender.titleLabel.text isEqualToString:@"取消订单"]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否确认取消订单" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[KRMainNetTool sharedKRMainNetTool] sendRequstWith:@"member/order/cancelOrder.do" params:@{@"orderId":self.orderId} withModel:nil waitView:self.view complateHandle:^(id showdata, NSString *error) {
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
    else if ([sender.titleLabel.text isEqualToString:@"退票"]) {
        RefundController *refundVC = [RefundController new];
        refundVC.orderId = self.orderId;
        [self.navigationController pushViewController:refundVC animated:YES];
    }
}
- (IBAction)sureAction:(UIButton *)sender {
    if ([sender.titleLabel.text isEqualToString:@"去支付"]) {
        PayTicketController *payVC = [PayTicketController new];
        payVC.orderId = self.orderId;
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
