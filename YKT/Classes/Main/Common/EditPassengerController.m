//
//  EditPassengerController.m
//  YKT
//
//  Created by 周春仕 on 2018/4/16.
//  Copyright © 2018年 周春仕. All rights reserved.
//

#import "EditPassengerController.h"
#import "LRMacroDefinitionHeader.h"
@interface EditPassengerController ()
@property (weak, nonatomic) IBOutlet UIButton *btn1;
@property (weak, nonatomic) IBOutlet UIButton *btn2;
@property (weak, nonatomic) IBOutlet UIButton *btn3;
@property (weak, nonatomic) IBOutlet UITextField *realName;
@property (weak, nonatomic) IBOutlet UITextField *phoneField;
@property (weak, nonatomic) IBOutlet UITextField *cardField;
@property (nonatomic, strong) UIButton *preBtn;
@property (weak, nonatomic) IBOutlet UIButton *isDefaultBtn;
@end

@implementation EditPassengerController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"编辑常用乘客";
    [self popOut];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(save)];
    if (self.dic) {
        self.realName.text = self.dic[@"passengerName"];
        self.phoneField.text = self.dic[@"mobile"];
        self.cardField.text = self.dic[@"idCard"];
        self.isDefaultBtn.selected = [self.dic[@"isDefault"] integerValue] == 1;
        NSInteger type = [self.dic[@"passengerType"] integerValue];
        for (int i = 1; i <= 3; i ++) {
            if (i == type) {
                LRViewBorderRadius([self.view viewWithTag:i], 0, 1, ThemeColor);
                [self.view viewWithTag:i].backgroundColor = COLOR(243, 245, 249, 1);
                [[self.view viewWithTag:i] setTitleColor:ThemeColor forState:UIControlStateNormal];
                self.preBtn = [self.view viewWithTag:i];
            }
            else {
                LRViewBorderRadius([self.view viewWithTag:i], 0, 1, [UIColor lightGrayColor]);
                LRViewBorderRadius([self.view viewWithTag:i], 0, 1, [UIColor lightGrayColor]);
            }
        }
    }
    else {
        LRViewBorderRadius(self.btn1, 0, 1, ThemeColor);
        self.btn1.backgroundColor = COLOR(243, 245, 249, 1);
        [self.btn1 setTitleColor:ThemeColor forState:UIControlStateNormal];
        LRViewBorderRadius(self.btn2, 0, 1, [UIColor lightGrayColor]);
        LRViewBorderRadius(self.btn3, 0, 1, [UIColor lightGrayColor]);
        self.preBtn = self.btn1;
    }
    // Do any additional setup after loading the view from its nib.
}

- (void)save {
    [self.view endEditing:YES];
    if ([self cheakIsNull:self.realName.text]) {
        [self showHUDWithText:@"请输入真实姓名"];
        return;
    }
    if (![self cheakPhoneNumber:self.phoneField.text]) {
        [self showHUDWithText:@"请输入正确手机号"];
        return;
    }
//    if (![self accurateVerifyIDCardNumber:self.cardField.text]) {
//        [self showHUDWithText:@"请输入正确身份证号"];
//        return;
//    }
    NSDictionary *params;
    NSString *url;
    if (self.dic) {
        url = @"member/linkman/updateLinkman.do";
        params = @{@"idCard":self.cardField.text,@"linkmanId":self.dic[@"id"],@"mobile":self.phoneField.text,@"name":self.realName.text,@"passengerType":@(self.preBtn.tag),@"isDefault":self.isDefaultBtn.selected ? @(1):@(0)};
    }
    else {
        url = @"member/linkman/saveLinkman.do";
        params = @{@"idCard":self.cardField.text,@"mobile":self.phoneField.text,@"name":self.realName.text,@"passengerType":@(self.preBtn.tag),@"isDefault":self.isDefaultBtn.selected ? @(1):@(0)};
    }
    [[KRMainNetTool sharedKRMainNetTool] sendRequstWith:url params:params withModel:nil waitView:self.view complateHandle:^(id showdata, NSString *error) {
        if (!error) {
            self.block();
            [self showHUDWithText:@"保存成功"];
            [self performSelector:@selector(popOutAction) withObject:nil afterDelay:1.0];
        }
    }];
}
- (IBAction)typeChoose:(UIButton *)sender {
    if (self.preBtn == sender) {
        return;
    }
    LRViewBorderRadius(self.preBtn, 0, 1, [UIColor lightGrayColor]);
    self.preBtn.backgroundColor = [UIColor whiteColor];
    [self.preBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    LRViewBorderRadius(sender, 0, 1, ThemeColor);
    sender.backgroundColor = COLOR(243, 245, 249, 1);
    [sender setTitleColor:ThemeColor forState:UIControlStateNormal];
    self.preBtn = sender;
}
- (IBAction)defaultAction:(UIButton *)sender {
    sender.selected = !sender.selected;
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
