//
//  WritePassengerController.m
//  YKT
//
//  Created by 周春仕 on 2018/5/4.
//  Copyright © 2018年 周春仕. All rights reserved.
//

#import "WritePassengerController.h"
#import "PassengerListViewController.h"
#import "LRMacroDefinitionHeader.h"
@interface WritePassengerController ()
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *phoneField;
@property (weak, nonatomic) IBOutlet UITextField *idCardField;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) NSArray *hisArr;
@property (nonatomic, strong) NSArray *passArr;
@end

@implementation WritePassengerController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"填写选择乘车人";
    [self popOut];
    [self requestData];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(sure)];
    self.hisArr = [self getFromDefaultsWithKey:@"HisBCPassenger"];
    if (self.hisArr.count > 0) {
        [self setScrollViewUI];
    }
    // Do any additional setup after loading the view from its nib.
}

- (void)requestData {
    [[KRMainNetTool sharedKRMainNetTool] sendRequstWith:@"member/linkman/findLinkman.do" params:nil withModel:nil waitView:self.view complateHandle:^(id showdata, NSString *error) {
        if (showdata) {
            self.passArr = showdata;
        }
    }];
}

- (void)setScrollViewUI{
    UIView *container = [[UIView alloc] init];
    container.backgroundColor = [UIColor whiteColor];
    [self.scrollView addSubview:container];
    [container mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.equalTo(self.scrollView);
        make.centerX.equalTo(self.scrollView.mas_centerX);
    }];
    UIView *temp;
    for (int i = 0; i < self.hisArr.count; i ++) {
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:13];
        label.backgroundColor = [UIColor whiteColor];
        label.textColor = ColorRgbValue(0x333333);
        NSString *str = [NSString stringWithFormat:@"%@(%@)",self.hisArr[i][@"passengerName"],self.hisArr[i][@"mobile"]];
        label.text = str;
        label.textAlignment = NSTextAlignmentLeft;
        label.tag = i;
        label.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(select:)];
        [label addGestureRecognizer:tap];
        [container addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(container).offset(12);
            make.right.equalTo(container);
            make.height.mas_equalTo(48);
            if (i == 0) {
                make.top.equalTo(container).offset(1);
            }
            else {
                make.top.equalTo(temp.mas_bottom).offset(1);
            }
            if (i == self.hisArr.count - 1) {
                make.bottom.equalTo(container);
            }
        }];
        temp = label;
    }
}

- (void)select:(UITapGestureRecognizer *)sender{
    self.block(self.hisArr[sender.view.tag]);
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)sure{
    if ([self cheakIsNull:self.nameField.text]) {
        [self showHUDWithText:@"请填写姓名"];
        return;
    }
    if (![self cheakPhoneNumber:self.phoneField.text]) {
        [self showHUDWithText:@"请填写正确手机号"];
        return;
    }
    if (![self accurateVerifyIDCardNumber:self.idCardField.text]) {
        [self showHUDWithText:@"请填写正确身份证号"];
        return;
    }
    BOOL needAdd = YES;
    for (NSDictionary *dic in self.passArr) {
        if ([dic[@"idCard"] isEqualToString:self.idCardField.text]) {
            needAdd = NO;
            break;
        }
    }
    if (needAdd) {
        [[KRMainNetTool sharedKRMainNetTool] sendRequstWith:@"member/linkman/saveLinkman.do" params:@{@"idCard":self.idCardField.text,@"mobile":self.phoneField.text,@"name":self.nameField.text,@"passengerType":@3,@"isDefault":@0} withModel:nil waitView:self.view complateHandle:^(id showdata, NSString *error) {
            if (!error) {
                NSDictionary *dic = @{@"mobile":self.phoneField.text,@"passengerName":self.nameField.text};
                NSMutableArray *muArr = [NSMutableArray arrayWithArray:[self getFromDefaultsWithKey:@"HisBCPassenger"]];
                if (![muArr containsObject:dic]) {
                    [muArr insertObject:dic atIndex:0];
                }
                [self saveToUserDefaultsWithKey:@"HisBCPassenger" Value:muArr];
                self.block(dic);
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
    }
    else {
        NSDictionary *dic = @{@"mobile":self.phoneField.text,@"passengerName":self.nameField.text};
        NSMutableArray *muArr = [NSMutableArray arrayWithArray:[self getFromDefaultsWithKey:@"HisBCPassenger"]];
        if (![muArr containsObject:dic]) {
            [muArr insertObject:dic atIndex:0];
        }
        [self saveToUserDefaultsWithKey:@"HisBCPassenger" Value:muArr];
        self.block(dic);
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    
    
    
}


- (IBAction)choosePassenger:(UIButton *)sender {
    PassengerListViewController *listVC = [PassengerListViewController new];
    listVC.sblock = ^(NSDictionary *dic) {
        self.nameField.text = dic[@"passengerName"];
        self.phoneField.text = dic[@"mobile"];
        self.idCardField.text = dic[@"idCard"];
    };
    listVC.isSingleSelect = YES;
    listVC.isSelect = YES;
    [self.navigationController pushViewController:listVC animated:YES];
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
