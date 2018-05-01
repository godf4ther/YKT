//
//  TicketListController.h
//  YKT
//
//  Created by 周春仕 on 2018/4/12.
//  Copyright © 2018年 周春仕. All rights reserved.
//

#import "BaseViewController.h"

@interface TicketListController : BaseViewController
@property (nonatomic, strong) NSDictionary *startStationDic;
@property (nonatomic, strong) NSDictionary *endStationDic;
@property (nonatomic, strong) NSString *centerDate;
@property (nonatomic, strong) NSString *currentDate;
@property (nonatomic, assign) BOOL isGQ;
@property (nonatomic, strong) NSString *orderId;
@end
