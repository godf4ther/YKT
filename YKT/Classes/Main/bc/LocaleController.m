//
//  LocaleController.m
//  YKT
//
//  Created by 周春仕 on 2018/4/19.
//  Copyright © 2018年 周春仕. All rights reserved.
//

#import "LocaleController.h"
#import "LRMacroDefinitionHeader.h"
#import "LocaleCell.h"
#import "CityController.h"
@interface LocaleController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewHeight;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UITextField *addressField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArr;
@end

@implementation LocaleController

- (NSMutableArray *)dataArr {
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setHidden:NO];
}
- (IBAction)editChange:(UITextField *)sender {
    [self requestData];
}
- (IBAction)cancelAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)chooseCity:(id)sender {
    CityController *cityVC = [CityController new];
    cityVC.block = ^(NSDictionary *dic) {
        self.selectCityDic = dic;
        self.cityLabel.text = dic[@"name"];
    };
    [self.navigationController pushViewController:cityVC animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *arr = [self getFromDefaultsWithKey:@"addressHis"];
    [self.dataArr addObjectsFromArray:arr];
    self.topViewHeight.constant = navHight;
    [self.tableView registerNib:[UINib nibWithNibName:@"LocaleCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"LocaleCell"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 70;
    [self.addressField becomeFirstResponder];
    // Do any additional setup after loading the view f rom its nib.
}

- (void)requestData {
    [[KRMainNetTool sharedKRMainNetTool] sendRequstWith:@"eBusiness/bc/getInputtipsByGD.do" params:@{@"city":self.selectCityDic[@"name"],@"keywords":self.addressField.text,@"location":self.selectCityDic[@"center"],@"token":[KRUserInfo sharedKRUserInfo].token} withModel:nil complateHandle:^(id showdata, NSString *error) {
        if (showdata) {
            [self.dataArr removeAllObjects];
            NSArray *arr = [self getFromDefaultsWithKey:@"addressHis"];
            [self.dataArr addObjectsFromArray:arr];
            [self.dataArr addObjectsFromArray:showdata];
            [self.tableView reloadData];
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LocaleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LocaleCell" forIndexPath:indexPath];
    NSDictionary *dic = self.dataArr[indexPath.row];
    cell.titleLabel.text = dic[@"name"];
    cell.addressLabel.text = dic[@"district"];
    if ([[dic allKeys] containsObject:@"isHistory"]) {
        cell.iconImage.image = [UIImage imageNamed:@"首页闹钟"];
    }
    else {
        cell.iconImage.image = [UIImage imageNamed:@"地址图标"];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:self.dataArr[indexPath.row]];
    dic[@"isHistory"] = @"YES";
    NSMutableArray *Muarr = [NSMutableArray arrayWithArray:[self getFromDefaultsWithKey:@"addressHis"]];
    if (![Muarr containsObject:dic]) {
        [Muarr insertObject:dic atIndex:0];
    }
    [self saveToUserDefaultsWithKey:@"addressHis" Value:Muarr];
    self.block(dic);
    [self.navigationController popViewControllerAnimated:YES];
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
