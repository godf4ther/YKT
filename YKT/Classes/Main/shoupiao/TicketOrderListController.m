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
#import "TicketOrderDetaialController.h"
#import "BcDetailController.h"
#import "MJRefresh.h"
@interface TicketOrderListController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (weak, nonatomic) IBOutlet UILabel *noDataLabel;
@end

@implementation TicketOrderListController

- (NSMutableArray *)dataArr {
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}

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
    self.tableView.estimatedRowHeight = 190;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView registerNib:[UINib nibWithNibName:@"MyOrderListCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"MyOrderListCell"];
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self requestData];
    }];
    // Do any additional setup after loading the view from its nib.
}

- (void)requestData {
    [[KRMainNetTool sharedKRMainNetTool] sendRequstWith:@"eBusiness/bc/findOrderInfoByCondition.do" params:nil withModel:nil waitView:self.view complateHandle:^(id showdata, NSString *error) {
        [self.tableView.mj_header endRefreshing];
        if (showdata) {
            NSArray *arr = showdata;
            [self.dataArr removeAllObjects];
            if (arr.count == 0) {
                self.noDataLabel.hidden = NO;
            }
            NSMutableArray *muarr1 = [NSMutableArray array];
            NSMutableArray *muarr2 = [NSMutableArray array];
            for (NSDictionary *dic in arr) {
                if ([dic[@"isFinish"] isEqualToString:@"0"]) {
                    [muarr1 addObject:dic];
                }
                else {
                    [muarr2 addObject:dic];
                }
            }
            if (muarr1.count != 0) {
                [self.dataArr addObject:@{@"title":@"待处理",@"data":muarr1}];
            }
            if (muarr2.count != 0) {
                [self.dataArr addObject:@{@"title":@"已完成",@"data":muarr2}];
            }
            [self.tableView reloadData];
        }
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataArr[section][@"data"] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.dataArr[section][@"title"];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MyOrderListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyOrderListCell" forIndexPath:indexPath];
    NSDictionary *dic = self.dataArr[indexPath.section][@"data"][indexPath.row];
    cell.orderNo.text = dic[@"organName"];
    cell.orderType.text = dic[@"orderTypeName"];
    if ([cell.orderType.text isEqualToString:@"汽车票"]) {
        cell.statusLabel.text = dic[@"busStatusName"];
        cell.busId.hidden = NO;
        cell.carIcon.hidden = NO;
        cell.busId.text = dic[@"busId"];
        NSInteger status = [dic[@"busStatus"] integerValue];
        if (status == 0) {
            cell.price.text = [NSString stringWithFormat:@"￥%.2f",[dic[@"totalPrice"] floatValue]];
        }
        else if (status == 2) {
            cell.price.text = @"￥0.00";
        }
        else if (status == 3 || status == 5) {
            cell.price.text = [NSString stringWithFormat:@"￥%.2f",[dic[@"totalPrice"] floatValue] - [dic[@"returnFee"] floatValue]];
        }
        else {
            cell.price.text = [NSString stringWithFormat:@"￥%.2f",[dic[@"tradePrice"] floatValue]];
        }
        if ([dic[@"busTime"] length] == 8) {
            cell.busTime.text = [NSString stringWithFormat:@"%@-%@-%@",[dic[@"busTime"] substringWithRange:NSMakeRange(0, 4)],[dic[@"busTime"] substringWithRange:NSMakeRange(4, 2)],[dic[@"busTime"] substringWithRange:NSMakeRange(6, 2)]];
        }
        else if ([dic[@"busTime"] length] >= 12) {
            cell.busTime.text = [NSString stringWithFormat:@"%@-%@-%@  %@:%@",[dic[@"busTime"] substringWithRange:NSMakeRange(0, 4)],[dic[@"busTime"] substringWithRange:NSMakeRange(4, 2)],[dic[@"busTime"] substringWithRange:NSMakeRange(6, 2)],[dic[@"busTime"] substringWithRange:NSMakeRange(8, 2)],[dic[@"busTime"] substringWithRange:NSMakeRange(10, 2)]];
        }
        cell.startStation.text = dic[@"sellStationName"];
        cell.endStation.text = dic[@"endStationName"];
        cell.busIdHeight.constant = 25;
    }
    else {
        NSInteger status = [dic[@"bcStatus"] integerValue];
        if (status == -1) {
            cell.price.text = @"￥0.00";
        }
        else if (status == 1) {
            cell.price.text = [NSString stringWithFormat:@"￥%.2f",[dic[@"totalPrice"] floatValue]];
        }
        else if (status == 9) {
            cell.price.text = [NSString stringWithFormat:@"￥%.2f",[dic[@"totalPrice"] floatValue] - [dic[@"returnFee"] floatValue]];
        }
        else {
            cell.price.text = [NSString stringWithFormat:@"￥%.2f",[dic[@"tradePrice"] floatValue]];
        }
        cell.statusLabel.text = dic[@"bcStatusName"];
        if ([dic[@"journeyType"] isEqualToString:@"1"]) {
            cell.busId.hidden = YES;
            cell.carIcon.hidden = YES;
            cell.busTime.text = dic[@"journeyStartTime"];
            cell.busIdHeight.constant = 0;
        }
        else {
            cell.busId.hidden = NO;
            cell.carIcon.hidden = NO;
            cell.busId.text = dic[@"journeyStartTime"];
            cell.busTime.text = dic[@"journeyEndTime"];
            cell.busIdHeight.constant = 25;
        }
        cell.startStation.text = dic[@"startPointName"];
        cell.endStation.text = dic[@"endPointName"];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *dic = self.dataArr[indexPath.section][@"data"][indexPath.row];
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
