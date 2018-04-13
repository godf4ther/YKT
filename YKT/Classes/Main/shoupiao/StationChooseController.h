//
//  StationChooseController.h
//  YKT
//
//  Created by 周春仕 on 2018/4/13.
//  Copyright © 2018年 周春仕. All rights reserved.
//

#import "BaseViewController.h"

@interface StationChooseController : BaseViewController
@property (nonatomic, strong) NSString *startStationId;
@property (nonatomic, strong) NSString *type;//0出发城市，1到达城市
@end
