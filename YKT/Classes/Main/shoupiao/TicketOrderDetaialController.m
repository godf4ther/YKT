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
#import "MXController.h"
#import "TicketListController.h"
#import "webViewController.h"
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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pwdContainerHeight;
@property (nonatomic, strong) NSArray *passengerArr;
@property (weak, nonatomic) IBOutlet UIView *passengerContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *passengerHeight;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (nonatomic, assign) BOOL isLS;
@property (weak, nonatomic) IBOutlet UILabel *payType;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelBtnWidth;
@property (nonatomic, strong) NSDictionary *data;
@property (weak, nonatomic) IBOutlet UIView *pwdContainer;
@property (weak, nonatomic) IBOutlet UIView *codeContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *codeContainerHeight;
@end

@implementation TicketOrderDetaialController
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self requestData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self popOut];
    self.navigationItem.title = @"订单详情";
    LRViewBorderRadius(self.statusLabel, 5, 1, ThemeColor);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GQSUCCESS:) name:@"GAIQIANSUCCESS" object:nil];
    // Do any additional setup after loading the view from its nib.
}

- (void)GQSUCCESS:(NSNotification *)notification {
    self.orderId = notification.object;
    [self requestData];
}

- (void)requestData{
    NSString *url = @"member/order/findBusOrderInfoDetail.do";
    [[KRMainNetTool sharedKRMainNetTool] sendRequstWith:url params:@{@"orderId":self.orderId} withModel:nil waitView:self.view complateHandle:^(id showdata, NSString *error) {
        if (showdata) {
            NSDictionary *dic = showdata[0];
            self.data = dic;
            NSInteger status = [dic[@"busStatus"] integerValue];
            if (status == 0) {
                self.priceLabel.text = [NSString stringWithFormat:@"￥%.2f",[dic[@"totalPrice"] floatValue]];
            }
            else if (status == 2) {
                self.priceLabel.text = @"￥0.00";
            }
            else if (status == 3 || status == 5) {
                self.priceLabel.text = [NSString stringWithFormat:@"￥%.2f",([dic[@"totalPrice"] floatValue] - [dic[@"returnFee"] floatValue])];
            }
            else {
                self.priceLabel.text = [NSString stringWithFormat:@"￥%.2f",[dic[@"tradePrice"] floatValue]];
            }
            NSString *busTime = dic[@"busTime"];
            self.busTime.text = [NSString stringWithFormat:@"%@-%@-%@  %@:%@",[busTime substringWithRange:NSMakeRange(0, 4)],[busTime substringWithRange:NSMakeRange(4, 2)],[busTime substringWithRange:NSMakeRange(6, 2)],[busTime substringWithRange:NSMakeRange(8, 2)],[busTime substringWithRange:NSMakeRange(10, 2)]];
            self.startStation.text = dic[@"sellStationName"];
            self.endStation.text = dic[@"endStationName"];
            self.pwdLabel.text = dic[@"billGetId"];
            self.orderNo.text = dic[@"outTradeNo"];
            self.orderTime.text = dic[@"operatorTime"];
            self.pickPeople.text = [NSString stringWithFormat:@"取票人：%@",dic[@"gettkMan"]];
            self.pickPhone.text = dic[@"gettkPhone"];
            self.statusLabel.text = dic[@"busStatusName"];
            self.isLS = [dic[@"busKind"] integerValue] == 1;
            NSString *statusStr = dic[@"busStatus"];
            self.cancelBtnWidth.constant = SIZEWIDTH / 2;
            if ([statusStr isEqualToString:@"0"] || [statusStr isEqualToString:@"2"]|| [statusStr isEqualToString:@"3"]|| [statusStr isEqualToString:@"7"]) {
                self.pwdContainer.hidden = YES;
                self.codeContainer.hidden = YES;
                self.pwdContainerHeight.constant = 0;
                self.codeContainerHeight.constant = 0;
            }
            else {
                self.pwdContainer.hidden = NO;
                self.codeContainer.hidden = NO;
                self.pwdContainerHeight.constant = 48;
                self.codeContainerHeight.constant = 48;
            }
            if ([statusStr isEqualToString:@"0"]) {
                [self.cancelBtn setTitle:@"取消订单" forState:UIControlStateNormal];
                [self.sureBtn setTitle:@"去支付" forState:UIControlStateNormal];
            }
            else if ([statusStr isEqualToString:@"1"]) {
                [self.cancelBtn setTitle:@"退票" forState:UIControlStateNormal];
                [self.sureBtn setTitle:@"改签" forState:UIControlStateNormal];
                if ([dic[@"isReturn"] integerValue] == 1  && [dic[@"isCharge"] integerValue] == 0) {
                    self.cancelBtnWidth.constant = SIZEWIDTH;
                    self.sureBtn.hidden = YES;
                }
                else if ([dic[@"isReturn"] integerValue] == 0 && [dic[@"isCharge"] integerValue] == 1) {
                    self.cancelBtnWidth.constant = 0;
                    self.cancelBtn.hidden = YES;
                }
                else if ([dic[@"isReturn"] integerValue] == 0 && [dic[@"isCharge"] integerValue] == 0) {
                    self.bottomHeight.constant = 0;
                    self.bottomView.hidden = YES;
                }
            }
            else {
                self.bottomHeight.constant = 0;
                self.bottomView.hidden = YES;
            }
            if ([dic[@"payType"] isEqualToString:@""]) {
                self.payType.text = @"未支付";
            }
            else {
                NSString *payType = dic[@"payType"];
                if ([payType isEqualToString:@"1"]) {
                    self.payType.text = @"支付宝";
                }
                else if ([payType isEqualToString:@"2"]) {
                    self.payType.text = @"银联";
                }
                else if ([payType isEqualToString:@"3"]) {
                    self.payType.text = @"微信";
                }
                else if ([payType isEqualToString:@"4"]) {
                    self.payType.text = @"小步云公交卡";
                }
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
        detailLabel.text = self.isLS ? @"流水发班" : [NSString stringWithFormat:@"%@ 座位号：%@",ticketType,dic[@"seatNo"]];
        [container addSubview:detailLabel];
        [detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
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
    webViewController *webViewVC = [webViewController new];
    [self.navigationController pushViewController:webViewVC animated:YES];
}
- (IBAction)cancelAction:(UIButton *)sender {
    if ([sender.titleLabel.text isEqualToString:@"取消订单"]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否确认取消订单" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[KRMainNetTool sharedKRMainNetTool] sendRequstWith:@"member/order/cancelOrder.do" params:@{@"orderId":self.orderId} withModel:nil waitView:self.view complateHandle:^(id showdata, NSString *error) {
                if (!error) {
                    [self showHUDWithText:@"取消成功"];
                    [self requestData];
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
        payVC.paySuccessBack = YES;
        [self.navigationController pushViewController:payVC animated:YES];
    }
    else if ([sender.titleLabel.text isEqualToString:@"改签"]) {
        TicketListController *ticketList = [TicketListController new];
        ticketList.orderId = self.orderId;
        NSString *busTime = self.data[@"busTime"];
        ticketList.centerDate = [NSString stringWithFormat:@"%@-%@-%@",[busTime substringWithRange:NSMakeRange(0, 4)],[busTime substringWithRange:NSMakeRange(4, 2)],[busTime substringWithRange:NSMakeRange(6, 2)]];
        ticketList.startStationDic = @{@"StationName":self.data[@"sellStationName"],@"StationId":self.data[@"sellStationId"]};
        ticketList.endStationDic = @{@"StationName":self.data[@"endStationName"],@"StationId":self.data[@"endStationId"]};
        ticketList.isGQ = YES;
        [self.navigationController pushViewController:ticketList animated:YES];
    }
    else if ([sender.titleLabel.text isEqualToString:@"评价"]) {
        
    }
}
- (IBAction)goMX:(UIButton *)sender {
    MXController *mxVC = [MXController new];
    mxVC.price = self.priceLabel.text;
    NSInteger status = [self.data[@"busStatus"] integerValue];
    if (status == 0) {
        mxVC.rightPriceStr = [NSString stringWithFormat:@"￥%.2f（未支付）",[self.data[@"totalPrice"] floatValue]];
    }
    else if (status == 2) {
        mxVC.rightPriceStr = [NSString stringWithFormat:@"￥%.2f（已取消）",[self.data[@"totalPrice"] floatValue]];
    }
    else if (status == 3 || status == 5) {
        mxVC.rightPriceStr = [NSString stringWithFormat:@"￥%.2f",[self.data[@"tradePrice"] floatValue]];
        mxVC.returnFeeStr = [NSString stringWithFormat:@"-￥%.2f",[self.data[@"returnFee"] floatValue]];
    }
    else {
        mxVC.rightPriceStr = [NSString stringWithFormat:@"￥%.2f",[self.data[@"tradePrice"] floatValue]];
    }
    [self.navigationController pushViewController:mxVC animated:YES];
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
