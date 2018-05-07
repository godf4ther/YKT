//
//  MXController.m
//  YKT
//
//  Created by 周春仕 on 2018/4/27.
//  Copyright © 2018年 周春仕. All rights reserved.
//

#import "MXController.h"

@interface MXController ()
@property (weak, nonatomic) IBOutlet UILabel *topPrice;
@property (weak, nonatomic) IBOutlet UILabel *rightPrice;
@property (weak, nonatomic) IBOutlet UILabel *returnFeeLabel;
@property (weak, nonatomic) IBOutlet UIView *container;

@end

@implementation MXController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self popOut];
    self.navigationItem.title = @"明细";
    self.topPrice.text = self.price;
    self.rightPrice.text = self.rightPriceStr;
    if (![self cheakIsNull:self.returnFeeStr]) {
        self.returnFeeLabel.text = self.returnFeeStr;
        self.container.hidden = NO;
    }
    // Do any additional setup after loading the view from its nib.
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
