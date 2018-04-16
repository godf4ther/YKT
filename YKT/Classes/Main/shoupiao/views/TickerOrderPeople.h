//
//  TickerOrderPeople.h
//  YKT
//
//  Created by 周春仕 on 2018/4/13.
//  Copyright © 2018年 周春仕. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^deleteBlock)(void);
typedef void (^gouBlock)(NSInteger,BOOL);
@interface TickerOrderPeople : UIView
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *idCard;
@property (weak, nonatomic) IBOutlet UIButton *gou1;
@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UIButton *gou2;
@property (weak, nonatomic) IBOutlet UILabel *label2;
@property (nonatomic, strong) deleteBlock deblock;
@property (nonatomic, strong) gouBlock gblock;
@end
