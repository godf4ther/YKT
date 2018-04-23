//
//  BcDetailController.h
//  YKT
//
//  Created by 周春仕 on 2018/4/23.
//  Copyright © 2018年 周春仕. All rights reserved.
//

#import "BaseViewController.h"

@interface BcDetailController : BaseViewController
@property (nonatomic, copy) NSString *orderId;
@property (nonatomic, strong) NSString *journeyStartTime;
@property (nonatomic, strong) NSString *journeyEndTime;
@end
