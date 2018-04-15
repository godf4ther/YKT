//
//  TicketCell.h
//  YKT
//
//  Created by 周春仕 on 2018/4/12.
//  Copyright © 2018年 周春仕. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TicketCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UILabel *carNum;
@property (weak, nonatomic) IBOutlet UILabel *start;
@property (weak, nonatomic) IBOutlet UILabel *end;
@property (weak, nonatomic) IBOutlet UILabel *price;
@property (weak, nonatomic) IBOutlet UILabel *remainSeat;

@end
