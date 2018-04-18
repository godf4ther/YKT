//
//  MyOrderListCell.h
//  YKT
//
//  Created by 周春仕 on 2018/4/17.
//  Copyright © 2018年 周春仕. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyOrderListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *orderNo;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *price;
@property (weak, nonatomic) IBOutlet UILabel *busId;
@property (weak, nonatomic) IBOutlet UILabel *busTime;
@property (weak, nonatomic) IBOutlet UILabel *startStation;
@property (weak, nonatomic) IBOutlet UILabel *endStation;
@property (weak, nonatomic) IBOutlet UIView *container;
@property (weak, nonatomic) IBOutlet UILabel *orderType;
@property (weak, nonatomic) IBOutlet UIImageView *carIcon;

@end
