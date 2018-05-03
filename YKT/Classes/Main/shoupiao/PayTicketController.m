//
//  PayTicketController.m
//  YKT
//
//  Created by 周春仕 on 2018/4/13.
//  Copyright © 2018年 周春仕. All rights reserved.
//

#import "PayTicketController.h"
#import "LRMacroDefinitionHeader.h"
#import <AlipaySDK/AlipaySDK.h>
#import "TicketOrderListController.h"
#import "SPayClient.h"
#import "NSString+SPayUtilsExtras.h"
#import "NSDictionary+SPayUtilsExtras.h"
#import "WXApi.h"
@interface PayTicketController ()
@property (weak, nonatomic) IBOutlet UILabel *countDownLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel1;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *startStationLabel;
@property (weak, nonatomic) IBOutlet UILabel *endStationLabel;
@property (weak, nonatomic) IBOutlet UIButton *zfbIcon;
@property (weak, nonatomic) IBOutlet UIButton *wxIcon;
@property (nonatomic, strong) UIButton *preBtn;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger leftTime;
@property (weak, nonatomic) IBOutlet UILabel *bcType;
@end

@implementation PayTicketController

- (NSTimer *)timer{
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countDown) userInfo:nil repeats:YES];
    }
    return _timer;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"支付";
    [self popOut];
    self.preBtn = self.zfbIcon;
    [self requestData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(paySuccess) name:@"ALIPAYSUCCESS" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(payFail) name:@"ALIPAYFAIL" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(WXpayResult:) name:@"wxPaySucceed" object:nil];
    // Do any additional setup after loading the view from its nib.
}

- (void)requestData{
    NSString *url = self.isBC ? @"eBusiness/bc/findBcOrderInfoDetail.do" : @"member/order/findBusOrderInfoDetail.do";
    [[KRMainNetTool sharedKRMainNetTool] sendRequstWith:url params:@{@"orderId":self.orderId} withModel:nil waitView:self.view complateHandle:^(id showdata, NSString *error) {
        if (showdata) {
            NSDictionary *dic = showdata[0];
            self.priceLabel.text = [NSString stringWithFormat:@"￥%.2f",[dic[@"totalPrice"] floatValue]];
            if (self.isBC) {
                self.bcType.hidden = NO;
                if ([dic[@"journeyType"] isEqualToString:@"1"]) {
                    self.bcType.text = @"单程";
                    self.timeLabel1.hidden = YES;
                }
                else {
                    self.bcType.text = @"往返";
                    self.timeLabel1.hidden = NO;
                    self.timeLabel1.text = self.journeyEndTime;
                }
                self.timeLabel.text = self.journeyStartTime;
                self.startStationLabel.text = dic[@"startPointName"];
                self.endStationLabel.text = dic[@"endPointName"];
            }
            else {
                NSString *timeStr = dic[@"busTime"];
                self.timeLabel.text = [NSString stringWithFormat:@"%@-%@-%@",[timeStr substringWithRange:NSMakeRange(0, 4)],[timeStr substringWithRange:NSMakeRange(4, 2)],[timeStr substringWithRange:NSMakeRange(6, 2)] ];
                self.startStationLabel.text = dic[@"sellStationName"];
                self.endStationLabel.text = dic[@"endStationName"];
            }
            NSInteger leftTime = labs([dic[@"leftTime"] integerValue]);
            self.leftTime = leftTime;
            self.countDownLabel.text = [NSString stringWithFormat:@"请在%@内支付哦否则将关闭",[self changeTime:leftTime]];
            [self.timer fire];
        }
    }];
}

- (void)countDown{
    self.leftTime -- ;
    if (self.leftTime) {
        self.countDownLabel.text = [NSString stringWithFormat:@"请在%@内支付哦否则将关闭",[self changeTime:self.leftTime]];
    }
    else {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (NSString *)changeTime:(NSInteger)leftTime{
    NSInteger min = leftTime / 60;
    NSInteger second = leftTime  % 60;
    return [NSString stringWithFormat:@"%02ld:%02ld",min,second];
}


- (IBAction)chooseZfb:(id)sender {
    self.preBtn.selected = NO;
    self.zfbIcon.selected = YES;
    self.preBtn = self.zfbIcon;
}
- (IBAction)chooseWx:(id)sender {
    self.preBtn.selected = NO;
    self.wxIcon.selected = YES;
    self.preBtn = self.wxIcon;
}
- (IBAction)payAction:(UIButton *)sender {
    if (self.preBtn == self.zfbIcon) {
        //获取支付宝支付参数
        NSString *url = self.isBC ? @"eBusiness/bc/orderAliPrepay4AppBc.do" : @"member/order/orderAliPrepay4App.do";
        if (self.isBC) {
            [KRMainNetTool sharedKRMainNetTool].isSB = YES;
        }
        [[KRMainNetTool sharedKRMainNetTool] sendRequstWith:url params:@{@"orderId":self.orderId} withModel:nil waitView:self.view complateHandle:^(id showdata, NSString *error) {
            if (showdata) {
                NSString *appScheme = @"ALIYKT";
                NSString * orderString = self.isBC ? showdata :showdata[@"payInfo"];
                [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
                    NSLog(@"reslut = %@",resultDic);
                    NSString * memo = resultDic[@"memo"];
                    NSLog(@"===memo:%@", memo);
                    if ([resultDic[@"resultStatus"] isEqualToString:@"9000"]) {
                        [self paySuccess];
                    }else{
                        [self payFail];
                    }
                    
                }];
            }
        }];
    }
    else {
        NSString *url = self.isBC ? @"eBusiness/bc/orderSwiftPrepay.do" : @"member/order/orderSwiftPrepay.do";
        if (self.isBC) {
            [KRMainNetTool sharedKRMainNetTool].isSB = YES;
        }
        [[KRMainNetTool sharedKRMainNetTool] sendRequstWith:url params:@{@"orderId":self.orderId} withModel:nil waitView:self.view complateHandle:^(id showdata, NSString *error) {
            if (showdata) {
                NSData *jsonData;
                if (self.isBC) {
                    jsonData = [showdata dataUsingEncoding:NSUTF8StringEncoding];
                }
                else {
                    jsonData = [showdata[@"payInfo"] dataUsingEncoding:NSUTF8StringEncoding];
                }
                NSError *err;
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                    options:NSJSONReadingMutableContainers
                                                                      error:&err];
                BOOL isInstalled=[WXApi isWXAppInstalled];

                if (isInstalled) {
                    NSMutableString *stamp  = [dic objectForKey:@"timestamp"];
                    //调起微信支付
                    PayReq* req             = [[PayReq alloc] init];
                    req.openID              = [dic objectForKey:@"appid"];
                    req.partnerId           = [dic objectForKey:@"partnerid"];
                    req.prepayId            = [dic objectForKey:@"prepayid"];
                    req.nonceStr            = [dic objectForKey:@"noncestr"];
                    req.timeStamp           = [stamp intValue];
                    req.package             = [dic objectForKey:@"package"];
                    req.sign                = [dic objectForKey:@"sign"];
                    //self.isReturn = YES;
                    [WXApi sendReq:req];
                }else{
                    [self showHUDWithText:@"请安装微信后才能快捷支付"];
                }
            }
        }];
    }
}

- (void)paySuccess {
    [self showHUDWithText:@"支付成功"];
    if (self.paySuccessBack) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        [self goList];
    }
}

- (void)payFail {
    [self showHUDWithText:@"支付失败"];
}

-(NSString *)URLDecodedString:(NSString *)str
{
    NSString *decodedString=(__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (__bridge CFStringRef)str, CFSTR(""), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    
    return decodedString;
}

- (void)goList {
    TicketOrderListController *orderList = [TicketOrderListController new];
    [self.navigationController pushViewController:orderList animated:YES];
}

- (IBAction)cancelAction:(id)sender {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否确认取消订单" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[KRMainNetTool sharedKRMainNetTool] sendRequstWith:self.isBC ? @"eBusiness/bc/cancelBcOrderInfo.do":@"member/order/cancelOrder.do" params:self.isBC ? @{@"ids":self.orderId}:@{@"orderId":self.orderId} withModel:nil waitView:self.view complateHandle:^(id showdata, NSString *error) {
            if (!error) {
                [self showHUDWithText:@"取消成功"];
//                [self.navigationController popToViewController:self.navigationController.viewControllers[self.navigationController.viewControllers.count - 3] animated:YES];
                [self performSelector:@selector(popOutAction) withObject:nil afterDelay:1.0];
            }
        }];
    }];
    [alert addAction:cancelAction];
    [alert addAction:sureAction];
    [self presentViewController:alert animated:YES completion:nil];
    
    

}

-(void)WXpayResult:(NSNotification*)sender{
    NSDictionary *dic = sender.userInfo;
    if ([dic[@"pay"] isEqualToString:@"1"]) {
        [self paySuccess];
    } else {
        [self payFail];
    }
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
