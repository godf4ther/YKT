//
//  WritePassengerController.h
//  YKT
//
//  Created by 周春仕 on 2018/5/4.
//  Copyright © 2018年 周春仕. All rights reserved.
//

#import "BaseViewController.h"
typedef void (^WritePassengerBlock) (NSDictionary *);
@interface WritePassengerController : BaseViewController
@property (nonatomic, strong) WritePassengerBlock block;
@end
