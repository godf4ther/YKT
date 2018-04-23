//
//  LocaleController.h
//  YKT
//
//  Created by 周春仕 on 2018/4/19.
//  Copyright © 2018年 周春仕. All rights reserved.
//

#import "BaseViewController.h"
typedef void (^addressBlock) (NSDictionary *dic);
@interface LocaleController : BaseViewController
@property (nonatomic, strong) addressBlock block;
@property (nonatomic, strong) NSDictionary *selectCityDic;
@end