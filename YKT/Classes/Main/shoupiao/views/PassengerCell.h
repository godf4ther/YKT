//
//  PassengerCell.h
//  YKT
//
//  Created by 周春仕 on 2018/4/13.
//  Copyright © 2018年 周春仕. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^selectBlock)(BOOL);
@interface PassengerCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *gouBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *gouBtnWidth;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *isDefaultBtn;
@property (weak, nonatomic) IBOutlet UILabel *cardNum;
@property (nonatomic, strong) selectBlock block;
@property (nonatomic, assign) BOOL isSingle;
@end
