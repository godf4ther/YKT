//
//  CityController.h
//  YKT
//
//  Created by 周春仕 on 2018/4/21.
//  Copyright © 2018年 周春仕. All rights reserved.
//

#import "BaseViewController.h"
typedef void (^CityBlock)(NSDictionary *dic);
@interface CityController : BaseViewController
@property (nonatomic, strong) CityBlock block;
@end
