//
//  CityController.m
//  YKT
//
//  Created by 周春仕 on 2018/4/21.
//  Copyright © 2018年 周春仕. All rights reserved.
//

#import "CityController.h"
#import "LRMacroDefinitionHeader.h"
@interface CityController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITextField *cityField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArr;
@property (nonatomic, strong) NSArray *orlDataArr;
@property (nonatomic, strong) NSArray *indexArr;
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
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)editChange:(UITextField *)sender {
    NSMutableArray *Muarr = [NSMutableArray array];
    for (NSDictionary *dic in self.orlDataArr) {
        NSMutableString *mustr = [NSMutableString stringWithString:dic[@"name"]];
        CFStringTransform((CFMutableStringRef) mustr, NULL, kCFStringTransformMandarinLatin, NO);
        CFStringTransform((CFMutableStringRef) mustr, NULL, kCFStringTransformStripDiacritics, NO);
        NSString *pinYin = [mustr capitalizedString];
        NSString *predix = [pinYin substringToIndex:1];
        if ([sender.text rangeOfString:dic[@"name"]].location != NSNotFound|| [predix isEqualToString:sender.text] || [predix.lowercaseString isEqualToString:sender.text]) {
            [Muarr addObject:dic];
        }
    }
    if (Muarr.count == 0) {
        self.dataArr = nil;
        self.indexArr = nil;
        [self.tableView reloadData];
    }
    else {
        [self sorting:Muarr];
        [self.tableView reloadData];
    }
}

- (void)requestData {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"paramName":@"cityJsonList",@"token":[KRUserInfo sharedKRUserInfo].token}];
    [[KRMainNetTool sharedKRMainNetTool] sendRequstWith:@"eBusiness/bc/getPositionInfoByGD.do" params:params withModel:nil waitView:self.view complateHandle:^(id showdata, NSString *error) {
        if (showdata) {
            self.orlDataArr = showdata;
            [self sorting:showdata];
            [self.tableView reloadData];
        }
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.dataArr[section][@"data"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
        cell.textLabel.font = [UIFont systemFontOfSize:HEIGHT(32)];
        cell.textLabel.textColor = ColorRgbValue(0x333333);
    }
    cell.textLabel.text = self.dataArr[indexPath.section][@"data"][indexPath.row][@"name"];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return self.dataArr[section][@"prefix"];
}

- (nullable NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    return self.indexArr;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.block(self.dataArr[indexPath.section][@"data"][indexPath.row]);
    [self.navigationController popViewControllerAnimated:YES];
}



-(void)sorting:(NSArray *)arr{
    
    NSMutableArray *indexArr = [[NSMutableArray alloc] init];
    NSMutableArray *dataArr = [[NSMutableArray alloc] init];
    for(int i='A';i<='Z';i++)
    {
        NSString *str = [NSString stringWithFormat:@"%c",i];
        NSMutableArray *data = [NSMutableArray array];
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        for (NSDictionary *dic in arr) {
            NSMutableString *mustr = [NSMutableString stringWithString:dic[@"name"]];
            CFStringTransform((CFMutableStringRef) mustr, NULL, kCFStringTransformMandarinLatin, NO);
            CFStringTransform((CFMutableStringRef) mustr, NULL, kCFStringTransformStripDiacritics, NO);
            NSString *pinYin = [mustr capitalizedString];
            NSString *predix = [pinYin substringToIndex:1];
            if ([predix isEqualToString:str]) {
                [data addObject:dic];
            }
        }
        if (data.count > 0) {
            params[@"prefix"] = str;
            params[@"data"] = data;
        }
        if ([params allKeys].count > 0) {
            [indexArr addObject:str];
            [dataArr addObject:params];
        }
    }
    self.indexArr = indexArr;
    self.dataArr = dataArr;
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
