//
//  PayTicketController.h
//  YKT
//
//  Created by 周春仕 on 2018/4/13.
//  Copyright © 2018年 周春仕. All rights reserved.
//

#import "BaseViewController.h"

@interface PayTicketController : BaseViewController
@property (nonatomic, copy) NSString *orderId;
@property (nonatomic, assign) BOOL isBC;
@property (nonatomic, strong) NSString *journeyStartTime;
@property (nonatomic, strong) NSString *journeyEndTime;
@property (nonatomic, assign) BOOL popTwoView;
@end
