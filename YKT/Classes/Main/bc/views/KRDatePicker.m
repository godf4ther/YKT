//
//  KRDatePicker.m
//  YL_Healthy
//
//  Created by 周春仕 on 2018/3/14.
//  Copyright © 2018年 曾洪磊. All rights reserved.
//

#import "KRDatePicker.h"
@interface KRDatePicker()
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;


@end
@implementation KRDatePicker

- (void)awakeFromNib{
    [super awakeFromNib];
    NSDate *currentDate = [NSDate date];
    self.datePicker.minimumDate = currentDate;
    self.frame = [UIScreen mainScreen].bounds;
}
- (IBAction)cancel:(UIButton *)sender {
    [self removeFromSuperview];
}
- (IBAction)sure:(UIButton *)sender {
    self.block(self.datePicker.date);
    [self removeFromSuperview];
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self removeFromSuperview];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
