//
//  EditPassengerController.h
//  YKT
//
//  Created by 周春仕 on 2018/4/16.
//  Copyright © 2018年 周春仕. All rights reserved.
//

#import "BaseViewController.h"
typedef void (^saveBlock)(void);
@interface EditPassengerController : BaseViewController
@property (nonatomic, strong) NSDictionary *dic;
@property (nonatomic, strong) saveBlock block;
@end
