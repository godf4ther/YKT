//
//  TicketListController.m
//  YKT
//
//  Created by 周春仕 on 2018/4/12.
//  Copyright © 2018年 周春仕. All rights reserved.
//

#import "TicketListController.h"
#import "TicketCell.h"
@interface TicketListController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *centerBtn;
@property (nonatomic, strong) NSArray *dataArr;
@end

@implementation TicketListController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self popOut];
    self.tableView.rowHeight = 70;
    [self.tableView registerNib:[UINib nibWithNibName:@"TicketCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"TicketCell"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)lastDay:(UIButton *)sender {
}
- (IBAction)nextDay:(UIButton *)sender {
}
- (IBAction)centerDayChoose:(UIButton *)sender {
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TicketCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TicketCell" forIndexPath:indexPath];
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
