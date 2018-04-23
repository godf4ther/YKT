//
//  PassengerListViewController.m
//  YKT
//
//  Created by 周春仕 on 2018/4/13.
//  Copyright © 2018年 周春仕. All rights reserved.
//

#import "PassengerListViewController.h"
#import "PassengerCell.h"
#import "LRMacroDefinitionHeader.h"
#import "EditPassengerController.h"
@interface PassengerListViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArr;

@end

@implementation PassengerListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self popOut];
    self.navigationItem.title = @"选择乘客";
    self.tableView.rowHeight = 75;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"PassengerCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"PassengerCell"];
    if (self.isSelect) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(sure)];
    }
    [self requesetData:NO];
    // Do any additional setup after loading the view from its nib.
}

- (void)requesetData:(BOOL)isNewAdd {
    [[KRMainNetTool sharedKRMainNetTool] sendRequstWith:@"member/linkman/findLinkman.do" params:nil withModel:nil waitView:self.view complateHandle:^(id showdata, NSString *error) {
        if (showdata) {
            self.dataArr = showdata;
            if (isNewAdd) {
                [self.selectArr addObject:@(NO)];
            }
            else {
                if (!self.selectArr) {
                    NSMutableArray *arr = [NSMutableArray array];
                    for (int i = 0; i < self.dataArr.count; i ++) {
                        [arr addObject:@(NO)];
                    }
                    self.selectArr = arr;
                }
            }
            [self.tableView reloadData];
        }
    }];
}

- (void)sure{
    BOOL isReady = NO;
    NSMutableArray *muArr = [NSMutableArray array];
    for (int i = 0; i < self.selectArr.count; i++) {
        if ([self.selectArr[i] boolValue]) {
            [muArr addObject:self.dataArr[i]];
            isReady = YES;
        }
    }
    if (muArr.count > 5) {
        [self showHUDWithText:@"最多选择5个"];
        return;
    }
    if (isReady) {
        self.block(muArr);
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)add:(UIButton *)sender {
    EditPassengerController *editVC = [EditPassengerController new];
    editVC.block = ^{
        [self requesetData:YES];
    };
    [self.navigationController pushViewController:editVC animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    PassengerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PassengerCell" forIndexPath:indexPath];
    NSDictionary *dic = self.dataArr[indexPath.row];
    cell.nameLabel.text = [NSString stringWithFormat:@"联系人：%@",dic[@"passengerName"]];
    cell.isDefaultBtn.backgroundColor = [dic[@"isDefault"] integerValue] == 0 ? [UIColor lightGrayColor] : ThemeColor;
    cell.cardNum.text = [NSString stringWithFormat:@"身份证：%@",dic[@"idCard"]];
    cell.block = ^(BOOL select) {
        [self.selectArr replaceObjectAtIndex:indexPath.row withObject:@(select)];
    };
    if (!self.isSelect) {
        cell.gouBtnWidth.constant = 0;
    }
    else {
        cell.gouBtn.selected = [self.selectArr[indexPath.row] boolValue];
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isSingleSelect) {
        self.sblock(self.dataArr[indexPath.row]);
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        EditPassengerController *editVC = [EditPassengerController new];
        editVC.dic = self.dataArr[indexPath.row];
        editVC.block = ^{
            [self requesetData:NO];
        };
        [self.navigationController pushViewController:editVC animated:YES];
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
