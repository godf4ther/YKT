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
@interface TicketOrderListController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArr;
@end

@implementation TicketOrderListController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self popOut];
    self.navigationItem.title = @"我的订单";
    self.tableView.rowHeight = 190;
    [self.tableView registerNib:[UINib nibWithNibName:@"MyOrderListCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"MyOrderListCell"];
    [self requestData];
    // Do any additional setup after loading the view from its nib.
}

- (void)requestData {
    [[KRMainNetTool sharedKRMainNetTool] sendRequstWith:@"eBusiness/bc/findOrderInfoByCondition.do" params:nil withModel:nil waitView:self.view complateHandle:^(id showdata, NSString *error) {
        if (showdata) {
            
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
    return cell;
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
