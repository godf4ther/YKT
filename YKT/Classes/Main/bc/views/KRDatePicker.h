//
//  KRDatePicker.h
//  YL_Healthy
//
//  Created by 周春仕 on 2018/3/14.
//  Copyright © 2018年 曾洪磊. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^sureBlock)(NSDate *);
@interface KRDatePicker : UIView
@property (nonatomic, strong) sureBlock block;
@end
