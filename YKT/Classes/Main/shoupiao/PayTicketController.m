//
//  PayTicketController.m
//  YKT
//
//  Created by 周春仕 on 2018/4/13.
//  Copyright © 2018年 周春仕. All rights reserved.
//

#import "PayTicketController.h"
#import "LRMacroDefinitionHeader.h"
@interface PayTicketController ()
@property (weak, nonatomic) IBOutlet UILabel *countDownLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *startStationLabel;
@property (weak, nonatomic) IBOutlet UILabel *endStationLabel;
@property (weak, nonatomic) IBOutlet UIButton *zfbIcon;
@property (weak, nonatomic) IBOutlet UIButton *wxIcon;
@property (nonatomic, strong) UIButton *preBtn;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger leftTime;
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
    // Do any additional setup after loading the view from its nib.
}

- (void)requestData{
    [[KRMainNetTool sharedKRMainNetTool] sendRequstWith:@"member/order/findBusOrderInfoDetail.do" params:@{@"orderId":self.orderId} withModel:nil waitView:self.view complateHandle:^(id showdata, NSString *error) {
        if (showdata) {
            NSDictionary *dic = showdata[0];
            self.priceLabel.text = [NSString stringWithFormat:@"￥%.2f",[dic[@"totalPrice"] floatValue]];
            NSString *timeStr = dic[@"busTime"];
            self.timeLabel.text = [NSString stringWithFormat:@"%@-%@-%@",[timeStr substringWithRange:NSMakeRange(0, 4)],[timeStr substringWithRange:NSMakeRange(4, 2)],[timeStr substringWithRange:NSMakeRange(6, 2)] ];
            self.startStationLabel.text = dic[@"sellStationName"];
            self.endStationLabel.text = dic[@"endStationName"];
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
    //获取支付宝支付参数
//    [KRMainNetTool sharedKRMainNetTool] sendRequstWith:@"" params:<#(NSDictionary *)#> withModel:<#(__unsafe_unretained Class)#> complateHandle:<#^(id showdata, NSString *error)complet#>
}
- (IBAction)cancelAction:(id)sender {
    [[KRMainNetTool sharedKRMainNetTool] sendRequstWith:@"member/order/cancelOrder.do" params:@{@"orderId":self.orderId} withModel:nil waitView:self.view complateHandle:^(id showdata, NSString *error) {
        if (!error) {
            [self showHUDWithText:@"取消成功"];
            [self.navigationController popToViewController:self.navigationController.viewControllers[self.navigationController.viewControllers.count - 3] animated:YES];
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
