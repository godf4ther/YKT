//
//  EidtTicketOrderController.m
//  YKT
//
//  Created by 周春仕 on 2018/4/13.
//  Copyright © 2018年 周春仕. All rights reserved.
//

#import "EidtTicketOrderController.h"
#import "PassengerListViewController.h"
#import "TickerOrderPeople.h"
#import "LRMacroDefinitionHeader.h"
#import "PayTicketController.h"
#import "AFNetworking.h"
#import "IQKeyboardManager.h"
#import "webViewController.h"
@interface EidtTicketOrderController ()<UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *startStation;
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UILabel *endStation;
@property (weak, nonatomic) IBOutlet UILabel *carNum;
@property (weak, nonatomic) IBOutlet UILabel *startTime;
@property (weak, nonatomic) IBOutlet UILabel *position;
@property (weak, nonatomic) IBOutlet UILabel *unitPrice;
@property (weak, nonatomic) IBOutlet UIView *passengerContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *passengerViewHeight;
@property (weak, nonatomic) IBOutlet UILabel *remainNum;
@property (weak, nonatomic) IBOutlet UITextField *pickTicketPeoeleField;
@property (weak, nonatomic) IBOutlet UITextField *pickTicketPhoneField;
@property (weak, nonatomic) IBOutlet UILabel *actualPrice;
@property (weak, nonatomic) IBOutlet UILabel *PriceMath;
@property (weak, nonatomic) IBOutlet UILabel *AllPrice;
@property (nonatomic, strong) NSMutableArray *passengerArr;
@property (nonatomic, strong) NSMutableArray *passengerViewArr;
@end

@implementation EidtTicketOrderController

- (NSMutableArray *)passengerViewArr {
    if (!_passengerViewArr) {
        _passengerViewArr = [NSMutableArray array];
    }
    return _passengerViewArr;
}

- (NSMutableArray *)passengerArr {
    if (!_passengerArr) {
        _passengerArr = [NSMutableArray array];
    }
    return _passengerArr;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [IQKeyboardManager sharedManager].enable = NO;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [IQKeyboardManager sharedManager].enable = YES;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self popOut];
    self.navigationItem.title = @"填写订单";
    [self setValues];
    // Do any additional setup after loading the view from its nib.
}

- (void)setValues {
    self.startStation.text = self.ticketDic[@"SellStationName"];
    self.time.text = self.ticketDic[@"BusDate"];
    self.endStation.text = self.ticketDic[@"RouteEndStationName"];
    self.carNum.text = [NSString stringWithFormat:@"%@次",self.ticketDic[@"BusId"]];
    self.startTime.text = self.ticketDic[@"BusStartTime"];
    self.position.text = self.ticketDic[@"CheckGateName"];
    self.unitPrice.text = [NSString stringWithFormat:@"￥%.2f",[self.ticketDic[@"FullPrice"] floatValue]];
    self.remainNum.text = [NSString stringWithFormat:@"余票%ld涨，每单限购5张",[self.ticketDic[@"SaleSeatQuantity"] integerValue]];
    self.passengerContainer.layer.masksToBounds = YES;
    for (int i = 0; i < 5; i ++) {
        TickerOrderPeople *peopleView = [[TickerOrderPeople alloc] initWithFrame:CGRectMake(0, 85 * i, SIZEWIDTH, 85)];
        [self.passengerContainer addSubview:peopleView];
        [self.passengerViewArr addObject:peopleView];
    }
}

- (IBAction)needToKnow:(UIButton *)sender {
    webViewController *webViewVC = [webViewController new];
    [self.navigationController pushViewController:webViewVC animated:YES];
}
- (IBAction)addPassenger:(UIButton *)sender {
    PassengerListViewController *passengerVC = [PassengerListViewController new];
    passengerVC.isSelect = YES;
    passengerVC.block = ^(NSArray *passengerArr) {
        for (NSDictionary *dic in passengerArr) {
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            params[@"needInsurance"] = @"0";
            params[@"passengerCardType"] = @"身份证";
            params[@"passengerIDCard"] = dic[@"idCard"];
            params[@"passengerName"] = dic[@"passengerName"];
            params[@"passengerPhone"] = dic[@"mobile"];
            params[@"passengerSex"] = @"男";
            params[@"ticketType"] = [dic[@"passengerType"] integerValue] == 3 ? @"1" : @"2";
            CGFloat ticketPrice = [self.ticketDic[@"FullPrice"] floatValue];
            params[@"ticketPrice"] = [dic[@"passengerType"] integerValue] == 3 ? [NSString stringWithFormat:@"%.2f",ticketPrice] : [NSString stringWithFormat:@"%.2f",ticketPrice / 2];
            params[@"passengerType"] = dic[@"passengerType"];
            [self.passengerArr addObject:params];
        }
        [self setUpPassengerUI];
        
    };
    [self.navigationController pushViewController:passengerVC animated:YES];
}

- (void)setUpPassengerUI {
    self.passengerViewHeight.constant = 85 * self.passengerArr.count;
    if (self.passengerArr.count == 0) {
        self.pickTicketPeoeleField.text = nil;
        self.pickTicketPhoneField.text = nil;
        return;
    }
    self.pickTicketPeoeleField.text = self.passengerArr[0][@"passengerName"];
    self.pickTicketPhoneField.text = self.passengerArr[0][@"passengerPhone"];
    for (int i = 0; i < self.passengerArr.count; i ++) {
        TickerOrderPeople *peopleView = self.passengerViewArr[i];
        NSMutableDictionary *dic = self.passengerArr[i];
        peopleView.name.text = dic[@"passengerName"];
        peopleView.idCard.text = [self ensureIDNumber:dic[@"passengerIDCard"]];
        peopleView.deblock = ^{
            [self.passengerArr removeObjectAtIndex:i];
            [self setUpPassengerUI];
        };
        peopleView.gblock = ^(NSInteger type, BOOL select) {
            if (type == 1) {
                if (select) {
                    dic[@"ticketType"] = @"3";
                }
                else {
                    dic[@"ticketType"] = @"1";
                }
            }
            else {
                if (select) {
                    dic[@"ticketType"] = @"2";
                    CGFloat ticketPrice = [self.ticketDic[@"FullPrice"] floatValue];
                    dic[@"ticketPrice"] = [NSString stringWithFormat:@"%.2f",ticketPrice / 2];
                }
                else {
                    dic[@"ticketType"] = @"1";
                    CGFloat ticketPrice = [self.ticketDic[@"FullPrice"] floatValue];
                    dic[@"ticketPrice"] = [NSString stringWithFormat:@"%.2f",ticketPrice];
                }
                [self mathPrice];
            }
        };
        if ([[KRUserInfo sharedKRUserInfo].startStationDic[@"isHalf"] boolValue] && [dic[@"passengerType"] integerValue] != 3) {
            peopleView.gou2.hidden = NO;
            peopleView.label2.hidden = NO;
            peopleView.gou2.selected = YES;
            if ([dic[@"ticketType"] integerValue] == 2) {
                peopleView.gou2.selected = YES;
            }
            else {
                peopleView.gou2.selected = NO;
            }
        }
        else {
            peopleView.gou2.hidden = YES;
            peopleView.label2.hidden = YES;
        }
        if ([[KRUserInfo sharedKRUserInfo].startStationDic[@"isChildren"] boolValue] && [dic[@"passengerType"] integerValue] == 3) {
            peopleView.gou1.hidden = NO;
            peopleView.label1.hidden = NO;
            if ([dic[@"ticketType"] integerValue] == 3) {
                peopleView.gou1.selected = YES;
            }
            else {
                peopleView.gou1.selected = NO;
            }
        }
        else {
            peopleView.gou1.hidden = YES;
            peopleView.label1.hidden = YES;
        }
    }
    [self mathPrice];
}

- (void)mathPrice {
    NSMutableString *stringM = [NSMutableString stringWithFormat:@"￥"];
    CGFloat totalPrice = 0.00;
//    CGFloat ticketPrice = [self.ticketDic[@"FullPrice"] floatValue];
    for (NSMutableDictionary *dic in self.passengerArr) {
        totalPrice += [dic[@"ticketPrice"] floatValue];
        NSInteger index = [self.passengerArr indexOfObject:dic];
        [stringM appendFormat:@"%@%@",index == 0 ? @"":@"+",dic[@"ticketPrice"]];
    }
    self.actualPrice.text = [NSString stringWithFormat:@"￥%.2f",totalPrice];
    self.AllPrice.text = [NSString stringWithFormat:@"总额：￥%.2f",totalPrice];
    self.PriceMath.text = stringM;
}

- (IBAction)submitOrder:(UIButton *)sender {
    if (self.passengerArr.count == 0) {
        [self showHUDWithText:@"请选择乘客"];
        return;
    }
    if ([self cheakIsNull:self.pickTicketPeoeleField.text]) {
        [self showHUDWithText:@"请输入取票人"];
        return;
    }
    if (![self cheakPhoneNumber:self.pickTicketPhoneField.text]) {
        [self showHUDWithText:@"请输入取票手机号"];
        return;
    }
    [self showLoadingHUD];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"busInfo"] = [self changeStr:@{@"busDate":self.ticketDic[@"BusDate"],@"busId":self.ticketDic[@"BusId"],@"busKind":self.ticketDic[@"BusKind"],@"busStartTime":self.ticketDic[@"BusStartTime"],@"buyType":@4,@"checkGate":self.ticketDic[@"CheckGateName"],@"endStationId":self.ticketDic[@"StationId"],@"endStationName":self.ticketDic[@"RouteEndStationName"],@"fullTicketPrice":self.ticketDic[@"FullPrice"],@"halfTicketPrice":self.ticketDic[@"HalfPrice"],@"routeName":self.ticketDic[@"RouteName"],@"startStationId":self.ticketDic[@"SellStationId"],@"startStationName":self.ticketDic[@"SellStationName"],@"vehicleTypeName":self.ticketDic[@"VehicleTypeName"]}];
    params[@"gettkMan"] = self.pickTicketPeoeleField.text;
    params[@"gettkPhone"] = self.pickTicketPhoneField.text;
    params[@"passengers"] = [self changeStr:self.passengerArr];
    params[@"token"] = [KRUserInfo sharedKRUserInfo].token;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://116.62.10.65:7070/member/order/makeOrder.do"] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:15.0];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    NSMutableString *paraString = [NSMutableString string];
    for (NSString *key in [params allKeys]) {
        [paraString appendFormat:@"&%@=%@",key,params[key]];
    }
    [paraString deleteCharactersInRange:NSMakeRange(0, 1)];
    [request setHTTPBody:[paraString dataUsingEncoding:NSUTF8StringEncoding]];
    // 初始化AFManager
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration: [NSURLSessionConfiguration defaultSessionConfiguration]];
    AFJSONResponseSerializer *serializer = [AFJSONResponseSerializer serializer];
    serializer.acceptableContentTypes = [NSSet setWithObjects:
                                         @"text/plain",
                                         @"application/json",
                                         @"text/html", nil];
    manager.responseSerializer = serializer;
    // 构建请求任务
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id _Nullable responseObject, NSError * _Nullable error) {
        [self hideHUD];
        if (error) {
            [self showHUDWithText:@"网络错误"];
        } else {
            NSDictionary *dic = responseObject;
            if ([dic[@"success"] boolValue]) {
                PayTicketController *payVC = [PayTicketController new];
                payVC.orderId = dic[@"result"][@"orderId"];
                [self.navigationController pushViewController:payVC animated:YES];
            }
            else {
                [self showHUDWithText:dic[@"message"]];
            }
        }
    }];
    // 发起请求
    [dataTask resume];
}

- (NSString *)changeStr:(id)value {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:value options:NSJSONWritingPrettyPrinted
                                                         error:nil];
    NSString *jsonString =[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString *str = [jsonString stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *str1 = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return str1;
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
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
