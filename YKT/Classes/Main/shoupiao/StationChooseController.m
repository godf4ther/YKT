//
//  StationChooseController.m
//  YKT
//
//  Created by 周春仕 on 2018/4/13.
//  Copyright © 2018年 周春仕. All rights reserved.
//

#import "StationChooseController.h"
#import "LRMacroDefinitionHeader.h"
@interface StationChooseController ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArr;
@property (nonatomic, strong) NSArray *orlDataArr;
@property (nonatomic, strong) NSArray *indexArr;
@end

@implementation StationChooseController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self popOut];
    self.navigationItem.title = [self.type isEqualToString:@"0"] ? @"出发":@"到达";
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.sectionFooterHeight = 0.1;
    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"header"];
    [self.tableView setSectionIndexColor:ThemeColor];
    [self.tableView setSeparatorColor:COLOR(236, 236, 236, 1)];
    self.searchBar.delegate = self;
    [self requestData];
    // Do any additional setup after loading the view from its nib.
}

- (void)requestData{
    NSDictionary *parmas;
    NSString *url;
    if ([self.type isEqualToString:@"1"]) {
        parmas = @{@"startStationId":self.startStationId,@"stationName":self.searchBar.text};
        url = @"endStation/findEndStation.do";
    }
    else {
        url = @"startStation/findStartStation.do";
    }
    [[KRMainNetTool sharedKRMainNetTool] sendRequstWith:url params:parmas withModel:nil waitView:self.view complateHandle:^(id showdata, NSString *error) {
        if (showdata) {
            if ([self.type isEqualToString:@"1"]) {
                NSMutableArray *muArr = [NSMutableArray array];
                for (NSDictionary *dic in showdata) {
                    [muArr addObject:dic[@"prefix"]];
                }
                self.dataArr = showdata;
                self.indexArr = muArr;
            }
            else{
                self.orlDataArr = showdata;
                [self sorting:showdata];
            }
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
    if ([self.type isEqualToString:@"1"]) {
        cell.textLabel.text = self.dataArr[indexPath.section][@"data"][indexPath.row][@"StationName"];
    }
    else{
        cell.textLabel.text = self.dataArr[indexPath.section][@"data"][indexPath.row][@"stationName"];
    }
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
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if ([self.type isEqualToString:@"1"]) {
        dic[@"StationId"] = self.dataArr[indexPath.section][@"data"][indexPath.row][@"StationId"];
        dic[@"StationName"] = self.dataArr[indexPath.section][@"data"][indexPath.row][@"StationName"];
    }
    else {
        [dic addEntriesFromDictionary:self.dataArr[indexPath.section][@"data"][indexPath.row]];
        dic[@"StationId"] = self.dataArr[indexPath.section][@"data"][indexPath.row][@"id"];
        dic[@"StationName"] = self.dataArr[indexPath.section][@"data"][indexPath.row][@"stationName"];
    }
    self.block(dic);
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if ([self.type isEqualToString:@"1"]) {
        [self requestData];
    }
    else {
        if ([searchBar.text isEqualToString:@""]) {
            [self sorting:self.orlDataArr];
            [self.tableView reloadData];
        }
        else{
            NSMutableArray *Muarr = [NSMutableArray array];
            for (NSDictionary *dic in self.orlDataArr) {
                NSMutableString *mustr = [NSMutableString stringWithString:dic[@"stationName"]];
                CFStringTransform((CFMutableStringRef) mustr, NULL, kCFStringTransformMandarinLatin, NO);
                CFStringTransform((CFMutableStringRef) mustr, NULL, kCFStringTransformStripDiacritics, NO);
                NSString *pinYin = [mustr capitalizedString];
                NSString *predix = [pinYin substringToIndex:1];
                if ([searchBar.text rangeOfString:dic[@"stationName"]].location != NSNotFound|| [predix isEqualToString:searchBar.text] || [predix.lowercaseString isEqualToString:searchBar.text]) {
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
    }
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
            NSMutableString *mustr = [NSMutableString stringWithString:dic[@"stationName"]];
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
