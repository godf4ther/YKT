//
//  DateChooseController.h
//  YKT
//
//  Created by 周春仕 on 2018/4/13.
//  Copyright © 2018年 周春仕. All rights reserved.
//

#import "BaseViewController.h"
typedef void (^chooseBlock)(NSString *);
@interface DateChooseController : BaseViewController
@property (nonatomic, strong) chooseBlock block;
@property (nonatomic, strong) NSString *currentDate;
@property (nonatomic, strong) NSString *selectDate;
@end
