//
//  DateChooseController.m
//  YKT
//
//  Created by 周春仕 on 2018/4/13.
//  Copyright © 2018年 周春仕. All rights reserved.
//

#import "DateChooseController.h"
#import "CalenderView.h"
#import "LRMacroDefinitionHeader.h"
@interface DateChooseController ()<CalenderViewDelete>
@property (nonatomic, strong) NSString *chooseDate;
@property (nonatomic, strong) NSDateFormatter *formatter;
@end

@implementation DateChooseController
- (NSDateFormatter *)formatter{
    if (!_formatter) {
        _formatter = [[NSDateFormatter alloc] init];
        [_formatter setDateFormat:@"yyyy-MM-dd"];
    }
    return _formatter;
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:ThemeColor Size:CGSizeMake(SIZEWIDTH, 88)] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self popOut];
    self.navigationItem.title = @"日期选择";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(sure)];
    self.chooseDate = self.selectDate;
    CalenderView *view = [[CalenderView alloc] initWithFrame:self.view.frame startDay:self.currentDate endDay:[self limitDate]];
    view.selectedDate = self.selectDate;
    view.delegate = self;
    view.yearMonthFormat = @"%zd年%02zd月";
    view.actvityColor = YES;
    view.showWeekBottomLine = YES;
    [self.view addSubview:view];
    // Do any additional setup after loading the view.
}

- (NSString *)limitDate{
    NSDate *currentDate = [self.formatter dateFromString:self.currentDate];
    NSDate *limitDate = [NSDate dateWithTimeInterval:24*60*60*(self.sellDay - 1) sinceDate:currentDate];
    NSString *limitDateStr = [self.formatter stringFromDate:limitDate];
    return limitDateStr;
}

- (void)calenderView:(NSIndexPath *)indexPath dateString:(NSString *)dateString{
    self.chooseDate = dateString;
}

- (void)sure{
    self.block(self.chooseDate);
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
