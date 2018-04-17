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
#import "StationChooseController.h"
#import "DateChooseController.h"
#import "KRUserInfo.h"
#import "PopupView.h"
#import "PassengerListViewController.h"
#import "LoginViewController.h"
#import "BaseNaviViewController.h"
#import "TicketOrderListController.h"
@interface SaleTicketMainController ()
@property (weak, nonatomic) IBOutlet UILabel *startStation;
@property (weak, nonatomic) IBOutlet UILabel *endStation;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIButton *oldAddress1;
@property (weak, nonatomic) IBOutlet UIButton *oldAddress2;
@property (weak, nonatomic) IBOutlet UIButton *oldAddress3;
@property (weak, nonatomic) IBOutlet UIButton *oldAddress4;
@property (nonatomic, strong) NSDateFormatter *formatter;
@property (nonatomic, strong) NSDictionary *startStationDic;
@property (nonatomic, strong) NSDictionary *endStationDic;
@property (nonatomic, strong) NSString *currentDate;
@property (nonatomic, strong) UIBarButtonItem *rightItem;
@end

@implementation SaleTicketMainController

- (NSDateFormatter *)formatter{
    if (!_formatter) {
        _formatter = [[NSDateFormatter alloc] init];
        [_formatter setDateFormat:@"yyyy-MM-dd"];
    }
    return _formatter;
}

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
    _rightItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"rightItem"] style:UIBarButtonItemStyleDone target:self action:@selector(showPopView)];
    self.navigationItem.rightBarButtonItem = _rightItem;
    NSDate *todayDate = [NSDate date];
    self.dateLabel.text = [self.formatter stringFromDate:todayDate];
    self.currentDate = self.dateLabel.text;
    NSDictionary *userInfoDic = [self getFromDefaultsWithKey:@"USERINFO"];
    [[KRUserInfo sharedKRUserInfo] setValuesForKeysWithDictionary:userInfoDic];
    [self setHisStation];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)showPopView {
    [PopupView addCellWithIcon:nil text:@"常用乘客" action:^{
        if (![KRUserInfo sharedKRUserInfo].memberId) {
            LoginViewController *loginVC = [LoginViewController new];
            BaseNaviViewController *navi = [[BaseNaviViewController alloc] initWithRootViewController:loginVC];
            [self presentViewController:navi animated:YES completion:nil];
        }
        else {
            PassengerListViewController *listVC = [PassengerListViewController new];
            listVC.isSelect = NO;
            [self.navigationController pushViewController:listVC animated:YES];
        }
    }];
    [PopupView addCellWithIcon:nil text:@"我的订单" action:^{
        if (![KRUserInfo sharedKRUserInfo].memberId) {
            LoginViewController *loginVC = [LoginViewController new];
            BaseNaviViewController *navi = [[BaseNaviViewController alloc] initWithRootViewController:loginVC];
            [self presentViewController:navi animated:YES completion:nil];
        }
        else {
            TicketOrderListController *listVC = [TicketOrderListController new];
            [self.navigationController pushViewController:listVC animated:YES];
        }
    }];
    [PopupView popupViewInPosition:ShowRight];
}

- (void)setHisStation{
    NSArray *hisStation = [self getFromDefaultsWithKey:@"HIS_STATION"];
    NSInteger num = hisStation.count;
    self.oldAddress1.hidden = num < 1;
    self.oldAddress2.hidden = num < 2;
    self.oldAddress3.hidden = num < 3;
    self.oldAddress4.hidden = num < 4;
    if (!self.oldAddress1.hidden) {
        NSDictionary *startStation = hisStation[num-1][@"startStation"];
        NSDictionary *endStation = hisStation[num-1][@"endStation"];
        [self.oldAddress1 setTitle:[NSString stringWithFormat:@"%@ - %@",startStation[@"StationName"],endStation[@"StationName"]] forState:UIControlStateNormal];
    }
    if (!self.oldAddress2.hidden) {
        NSDictionary *startStation = hisStation[num-2][@"startStation"];
        NSDictionary *endStation = hisStation[num-2][@"endStation"];
        [self.oldAddress2 setTitle:[NSString stringWithFormat:@"%@ - %@",startStation[@"StationName"],endStation[@"StationName"]] forState:UIControlStateNormal];
    }
    if (!self.oldAddress3.hidden) {
        NSDictionary *startStation = hisStation[num-3][@"startStation"];
        NSDictionary *endStation = hisStation[num-3][@"endStation"];
        [self.oldAddress3 setTitle:[NSString stringWithFormat:@"%@ - %@",startStation[@"StationName"],endStation[@"StationName"]] forState:UIControlStateNormal];
    }
    if (!self.oldAddress4.hidden) {
        NSDictionary *startStation = hisStation[num-4][@"startStation"];
        NSDictionary *endStation = hisStation[num-4][@"endStation"];
        [self.oldAddress4 setTitle:[NSString stringWithFormat:@"%@ - %@",startStation[@"StationName"],endStation[@"StationName"]] forState:UIControlStateNormal];
    }
}


- (void)popOutAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)chooseStartStation:(id)sender {
    StationChooseController *chooseVC = [StationChooseController new];
    chooseVC.type = @"0";
    chooseVC.block = ^(NSDictionary *dic) {
        self.startStationDic = dic;
        self.startStation.text = dic[@"StationName"];
        self.startStation.textColor = [UIColor blackColor];
        [KRUserInfo sharedKRUserInfo].startStationDic = dic;
    };
    [self.navigationController pushViewController:chooseVC animated:YES];
}
- (IBAction)chooseEndStation:(id)sender {
    if (!self.startStationDic) {
        [self showHUDWithText:@"请先选择出发城市"];
        return;
    }
    StationChooseController *chooseVC = [StationChooseController new];
    chooseVC.type = @"1";
    chooseVC.startStationId = self.startStationDic[@"StationId"];
    chooseVC.block = ^(NSDictionary *dic) {
        self.endStationDic = dic;
        self.endStation.text = dic[@"StationName"];
        self.endStation.textColor = [UIColor blackColor];
    };
    [self.navigationController pushViewController:chooseVC animated:YES];
}
- (IBAction)chooseDate:(id)sender {
    if (!self.startStationDic) {
        [self showHUDWithText:@"请先选择出发城市"];
        return;
    }
    DateChooseController *dateVC = [DateChooseController new];
    dateVC.currentDate = self.currentDate;
    dateVC.selectDate = self.dateLabel.text;
    dateVC.sellDay = [self.startStationDic[@"sellDay"] integerValue];
    dateVC.block = ^(NSString *date) {
        self.dateLabel.text = date;
    };
    [self.navigationController pushViewController:dateVC animated:YES];
}


- (IBAction)searchNow:(UIButton *)sender {
    if (!self.startStationDic || !self.endStationDic) {
        return;
    }
    NSMutableArray *hisArr = [NSMutableArray arrayWithArray:[self getFromDefaultsWithKey:@"HIS_STATION"]];
    if (hisArr.count == 4) {
        [hisArr removeObjectAtIndex:0];
    }
    [hisArr addObject:@{@"startStation":self.startStationDic,@"endStation":self.endStationDic}];
    [self saveToUserDefaultsWithKey:@"HIS_STATION" Value:hisArr];
    [self setHisStation];
    TicketListController *ticketList = [TicketListController new];
    ticketList.currentDate = self.currentDate;
    ticketList.centerDate = self.dateLabel.text;
    ticketList.startStationDic = self.startStationDic;
    ticketList.endStationDic = self.endStationDic;
    [self.navigationController pushViewController:ticketList animated:YES];
}
- (IBAction)hisBtnClick:(UIButton *)sender {
    NSInteger tag = sender.tag;
    NSArray *hisStation = [self getFromDefaultsWithKey:@"HIS_STATION"];
    NSDictionary *startStation = hisStation[hisStation.count - tag][@"startStation"];
    NSDictionary *endStation = hisStation[hisStation.count - tag][@"endStation"];
    self.startStation.text = startStation[@"StationName"];
    self.startStation.textColor = [UIColor blackColor];
    self.endStation.text = endStation[@"StationName"];
    self.endStation.textColor = [UIColor blackColor];
    self.startStationDic = startStation;
    self.endStationDic = endStation;
    [KRUserInfo sharedKRUserInfo].startStationDic = startStation;
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
