//
//  CityController.m
//  YKT
//
//  Created by 周春仕 on 2018/4/21.
//  Copyright © 2018年 周春仕. All rights reserved.
//

#import "CityController.h"
#import "LRMacroDefinitionHeader.h"
@interface CityController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *cityField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSDictionary *data;
@property (nonatomic, strong) NSDictionary *orlData;
@property (nonatomic, strong) NSArray *indexArr;
@property (nonatomic, strong) NSArray *orlIndexArr;
@end

@implementation CityController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setHidden:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self requestData];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.sectionFooterHeight = 0.1;
    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"header"];
    [self.tableView setSectionIndexColor:ThemeColor];
    [self.tableView setSeparatorColor:COLOR(236, 236, 236, 1)];
    [self.cityField becomeFirstResponder];
    // Do any additional setup after loading the view from its nib.
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

- (IBAction)editChange:(UITextField *)sender {
    if (sender.text.length == 0) {
        self.data = self.orlData;
        self.indexArr = self.orlIndexArr;
        [self.tableView reloadData];
    }
    else if (sender.text.length == 1) {
//        NSString *match = @"(^[\u4e00-\u9fa5]+$)";
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@", match];
//        BOOL isChinese = [predicate evaluateWithObject:self];
//        if (isChinese) {
//            for (NSString *key in self.orlData) {
//                
//            }
//        }
//        else {
//            for (NSString *key in self.orlData.allKeys) {
//                if ([key isEqualToString:sender.text.uppercaseString]) {
//                    self.data = @{key:self.orlData[key]};
//                    self.indexArr = @[key];
//                    [self.tableView reloadData];
//                }
//            }
//        }
    }
    else {
        NSMutableDictionary *dic = self.orlData.mutableCopy;
        for (NSString *key in dic) {
            NSMutableArray *arr = [dic[key] mutableCopy];
            for (NSDictionary *city in arr) {
                if (![city[@"name"] containsString:sender.text]) {
                    [arr removeObject:city];
                }
            }
        }
        self.data = dic;
        [self.tableView reloadData];
    }
}

- (void)requestData {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"paramName":@"cityJsonList",@"token":[KRUserInfo sharedKRUserInfo].token}];
    [[KRMainNetTool sharedKRMainNetTool] sendRequstWith:@"eBusiness/bc/getPositionInfoByGD.do" params:params withModel:nil waitView:self.view complateHandle:^(id showdata, NSString *error) {
        if (showdata) {
            [self sorting:showdata];
            [self.tableView reloadData];
        }
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.data.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSString *prefix = self.indexArr[section];
    return [self.data[prefix] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
        cell.textLabel.font = [UIFont systemFontOfSize:HEIGHT(32)];
        cell.textLabel.textColor = ColorRgbValue(0x333333);
    }
    NSString *prefix = self.indexArr[indexPath.section];
    cell.textLabel.text = self.data[prefix][indexPath.row][@"name"];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return self.indexArr[section];
}

- (nullable NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    return self.indexArr;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *prefix = self.indexArr[indexPath.section];
    self.block(self.data[prefix][indexPath.row]);
    [self.navigationController popViewControllerAnimated:YES];
}



-(void)sorting:(NSArray *)arr{
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    for (NSDictionary *dic in arr) {
        
        NSMutableString *mustr = [NSMutableString stringWithString:dic[@"name"]];
        CFStringTransform((CFMutableStringRef) mustr, NULL, kCFStringTransformMandarinLatin, NO);
        CFStringTransform((CFMutableStringRef) mustr, NULL, kCFStringTransformStripDiacritics, NO);
        NSString *pinYin = [mustr capitalizedString];
        NSString *predix = [pinYin substringToIndex:1];
        NSMutableArray *citys = data[predix];
        if (citys.count) {
            [citys addObject:dic];
            data[predix] = citys;
        }
        else {
            data[predix] = @[dic].mutableCopy;
        }
    }
    
    
    NSArray *indexArr = [data.allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    self.indexArr = indexArr;
    self.orlIndexArr = indexArr;
    self.data = data;
    self.orlData = data;
}




- (IBAction)cancel:(UIButton *)sender {
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
