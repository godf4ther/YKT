//
//  PassengerListViewController.h
//  YKT
//
//  Created by 周春仕 on 2018/4/13.
//  Copyright © 2018年 周春仕. All rights reserved.
//

#import "BaseViewController.h"
typedef void (^sureBlock) (NSArray *);
typedef void (^singleBlock) (NSDictionary *);
@interface PassengerListViewController : BaseViewController
@property (nonatomic, assign) BOOL isSelect;
@property (nonatomic, strong) NSMutableArray *selectArr;
@property (nonatomic, strong) sureBlock block;
@property (nonatomic, strong) singleBlock sblock;
@property (nonatomic, assign) BOOL isSingleSelect;
@end
