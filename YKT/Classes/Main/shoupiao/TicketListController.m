//
//  TicketListController.m
//  YKT
//
//  Created by 周春仕 on 2018/4/12.
//  Copyright © 2018年 周春仕. All rights reserved.
//

#import "TicketListController.h"
#import "TicketCell.h"
#import "KRMainNetTool.h"
#import "LRMacroDefinitionHeader.h"
#import "DateChooseController.h"
#import "EidtTicketOrderController.h"
#import "LoginViewController.h"
#import "BaseNaviViewController.h"
#import "KRUserInfo.h"
@interface TicketListController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *centerBtn;
@property (nonatomic, strong) NSArray *dataArr;
@property (nonatomic, strong) NSDateFormatter *formatter;
@property (weak, nonatomic) IBOutlet UILabel *noDataLabel;
@property (nonatomic, strong) NSString *sellDayDate;
@property (weak, nonatomic) IBOutlet UIButton *lastDayBtn;
@property (weak, nonatomic) IBOutlet UIButton *nextDayBtn;
@end

@implementation TicketListController

- (NSDateFormatter *)formatter{
    if (!_formatter) {
        _formatter = [[NSDateFormatter alloc] init];
        [_formatter setDateFormat:@"yyyy-MM-dd"];
    }
    return _formatter;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:COLOR(95, 150, 250, 1) Size:CGSizeMake(SIZEWIDTH, 88)] forBarMetrics:UIBarMetricsDefault];
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
    self.navigationItem.title = [NSString stringWithFormat:@"%@ - %@",self.startStationDic[@"StationName"],self.endStationDic[@"StationName"]];
    [self.centerBtn setTitle:[self dateStrChange:self.centerDate] forState:UIControlStateNormal];
    if (!self.isGQ) {
        NSDate *date = [self.formatter dateFromString:self.currentDate];
        NSInteger sellDay = [self.startStationDic[@"sellDay"] integerValue];
        NSDate *sellDayDate = [NSDate dateWithTimeInterval:24*60*60*(sellDay - 1) sinceDate:date];
        self.sellDayDate = [self.formatter stringFromDate:sellDayDate];
        [self cheakDate];
    }
    else {
        self.lastDayBtn.enabled = NO;
        self.nextDayBtn.enabled = NO;
    }
    self.tableView.rowHeight = 70;
    [self.tableView registerNib:[UINib nibWithNibName:@"TicketCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"TicketCell"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self requestData];
    // Do any additional setup after loading the view from its nib.
}



- (void)requestData{
    [[KRMainNetTool sharedKRMainNetTool] sendRequstWith:@"/bus/findBus.do" params:@{@"busDate":self.centerDate,@"startStationId":self.startStationDic[@"StationId"],@"endStationId":self.endStationDic[@"StationId"]} withModel:nil waitView:self.view complateHandle:^(id showdata, NSString *error) {
        if (showdata) {
            self.dataArr = showdata;
            [self.tableView reloadData];
            if (self.dataArr.count == 0) {
                self.noDataLabel.hidden = NO;
            }
            else{
                self.noDataLabel.hidden = YES;
            }
        }
    }];
}

- (IBAction)lastDay:(UIButton *)sender {
    NSDate *date = [self.formatter dateFromString:self.centerDate];
    NSDate *lastDate = [NSDate dateWithTimeInterval:-24*60*60 sinceDate:date];
    self.centerDate = [self.formatter stringFromDate:lastDate];
    [self.centerBtn setTitle:[self dateStrChange:self.centerDate] forState:UIControlStateNormal];
    [self cheakDate];
    [self requestData];
}
- (IBAction)nextDay:(UIButton *)sender {
    NSDate *date = [self.formatter dateFromString:self.centerDate];
    NSDate *nextDate = [NSDate dateWithTimeInterval:24*60*60 sinceDate:date];
    self.centerDate = [self.formatter stringFromDate:nextDate];
    [self.centerBtn setTitle:[self dateStrChange:self.centerDate] forState:UIControlStateNormal];
    [self cheakDate];
    [self requestData];
}
- (IBAction)centerDayChoose:(UIButton *)sender {
    DateChooseController *dateVC = [DateChooseController new];
    dateVC.currentDate = self.currentDate;
    dateVC.selectDate = self.centerDate;
    dateVC.sellDay = [self.startStationDic[@"sellDay"] integerValue];
    dateVC.block = ^(NSString *date) {
        self.centerDate = date;
        [self.centerBtn setTitle:[self dateStrChange:self.centerDate] forState:UIControlStateNormal];
        [self cheakDate];
        [self requestData];
    };
    [self.navigationController pushViewController:dateVC animated:YES];
}
- (NSString *)dateStrChange:(NSString *)date{
    NSString *month = [date substringWithRange:NSMakeRange(5, 2)];
    NSString *day = [date substringWithRange:NSMakeRange(8, 2)];
    return [NSString stringWithFormat:@"%@月%@日",month,day];
}

- (void)cheakDate {
    if ([self.centerDate isEqualToString:self.currentDate]) {
        self.lastDayBtn.enabled = NO;
    }
    else {
        self.lastDayBtn.enabled = YES;
    }
    if ([self.centerDate isEqualToString:self.sellDayDate]) {
        self.nextDayBtn.enabled = NO;
    }
    else {
        self.nextDayBtn.enabled = YES;
    }
    if ([self.startStationDic[@"sellDay"] integerValue] < 1) {
        self.nextDayBtn.enabled = NO;
        self.lastDayBtn.enabled = NO;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TicketCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TicketCell" forIndexPath:indexPath];
    NSDictionary *dic = self.dataArr[indexPath.row];
    cell.time.text = [dic[@"BusStartTime"] substringToIndex:5];
    cell.carNum.text = [NSString stringWithFormat:@"%@次",dic[@"BusId"]];
    cell.start.text = dic[@"SellStationName"];
    cell.end.text = dic[@"StationName"];
    cell.price.text = [NSString stringWithFormat:@"￥%.1f",[dic[@"FullPrice"] floatValue]];
    cell.remainSeat.text = [NSString stringWithFormat:@"余票%ld张",[dic[@"SaleSeatQuantity"] integerValue]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.isGQ) {
        NSDictionary *dic = self.dataArr[indexPath.row];
        NSString *message = [NSString stringWithFormat:@"改签车次:%@次\n%@\n%@ %@\n您是否需要改签此车次",dic[@"BusId"],dic[@"RouteName"],dic[@"BusDate"],dic[@"BusStartTime"]];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            params[@"newBusDate"] = dic[@"BusDate"];
            params[@"newBusId"] = dic[@"BusId"];
            params[@"newBusStartTime"] = dic[@"BusStartTime"];
            params[@"newCheckGate"] = dic[@"CheckGateName"];
            params[@"newEndStationId"] = dic[@"StationId"];
            params[@"newEndStationName"] = dic[@"StationName"];
            params[@"newVehicleTypeName"] = dic[@"VehicleTypeName"];
            params[@"orderId"] = self.orderId;
            [[KRMainNetTool sharedKRMainNetTool] sendRequstWith:@"member/order/changeOrder.do" params:params withModel:nil waitView:self.view complateHandle:^(id showdata, NSString *error) {
                if (showdata) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"GAIQIANSUCCESS" object:showdata[@"orderId"]];
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }];
        }];
        [alert addAction:cancelAction];
        [alert addAction:sureAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
        if (![KRUserInfo sharedKRUserInfo].memberId) {
            LoginViewController *loginVC = [LoginViewController new];
            BaseNaviViewController *navi = [[BaseNaviViewController alloc] initWithRootViewController:loginVC];
            [self presentViewController:navi animated:YES completion:nil];
        }
        else {
            EidtTicketOrderController *editVC = [EidtTicketOrderController new];
            editVC.ticketDic = self.dataArr[indexPath.row];
            [self.navigationController pushViewController:editVC animated:YES];
        }
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
