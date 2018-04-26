//
//  TicketOrderListController.m
//  YKT
//
//  Created by 周春仕 on 2018/4/17.
//  Copyright © 2018年 周春仕. All rights reserved.
//

#import "TicketOrderListController.h"
#import "MyOrderListCell.h"
#import "LRMacroDefinitionHeader.h"
#import "PayTicketController.h"
#import "TicketOrderDetaialController.h"
#import "BcDetailController.h"
@interface TicketOrderListController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArr;
@end

@implementation TicketOrderListController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    [self requestData];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self popOut];
    self.navigationItem.title = @"我的订单";
    self.tableView.rowHeight = 190;
    [self.tableView registerNib:[UINib nibWithNibName:@"MyOrderListCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"MyOrderListCell"];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)requestData {
    [[KRMainNetTool sharedKRMainNetTool] sendRequstWith:@"eBusiness/bc/findOrderInfoByCondition.do" params:nil withModel:nil waitView:self.view complateHandle:^(id showdata, NSString *error) {
        if (showdata) {
            self.dataArr = showdata;
            [self.tableView reloadData];
        }
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MyOrderListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyOrderListCell" forIndexPath:indexPath];
    NSDictionary *dic = self.dataArr[indexPath.row];
    cell.orderNo.text = dic[@"organName"];
    cell.statusLabel.text = dic[@"statusName"];
    cell.price.text = [NSString stringWithFormat:@"￥%.2f",[dic[@"totalPrice"] floatValue]];
    cell.orderType.text = dic[@"orderTypeName"];
    if ([cell.orderType.text isEqualToString:@"汽车票"]) {
        cell.busId.hidden = NO;
        cell.carIcon.hidden = NO;
        cell.busId.text = dic[@"busId"];
        cell.busTime.text = [NSString stringWithFormat:@"%@-%@-%@",[dic[@"busTime"] substringWithRange:NSMakeRange(0, 4)],[dic[@"busTime"] substringWithRange:NSMakeRange(4, 2)],[dic[@"busTime"] substringWithRange:NSMakeRange(6, 2)]];
        cell.startStation.text = dic[@"sellStationName"];
        cell.endStation.text = dic[@"endStationName"];
    }
    else {
        if ([dic[@"journeyType"] isEqualToString:@"1"]) {
            cell.busId.hidden = YES;
            cell.carIcon.hidden = YES;
            cell.busTime.text = dic[@"journeyStartTime"];
        }
        else {
            cell.busId.hidden = NO;
            cell.carIcon.hidden = NO;
            cell.busId.text = dic[@"journeyStartTime"];
            cell.busTime.text = dic[@"journeyEndTime"];
        }
        cell.startStation.text = dic[@"startPointName"];
        cell.endStation.text = dic[@"endPointName"];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *dic = self.dataArr[indexPath.row];
    if ([dic[@"orderTypeName"] isEqualToString:@"汽车票"]) {
        TicketOrderDetaialController *detailVC = [TicketOrderDetaialController new];
        detailVC.orderId = dic[@"id"];
        [self.navigationController pushViewController:detailVC animated:YES];
    }
    else {
        BcDetailController *bcDetailVC = [BcDetailController new];
        bcDetailVC.orderId = dic[@"id"];
        bcDetailVC.journeyStartTime = dic[@"journeyStartTime"];
        bcDetailVC.journeyEndTime = dic[@"journeyEndTime"];
        [self.navigationController pushViewController:bcDetailVC animated:YES];
    }
    
}

- (void)popOutAction {
    [self.navigationController popToRootViewControllerAnimated:YES];
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
