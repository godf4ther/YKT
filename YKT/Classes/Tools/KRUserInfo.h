//
//  KRUserInfo.h
//  Dntrench
//
//  Created by kupurui on 16/10/18.
//  Copyright © 2016年 CoderDX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"
@interface KRUserInfo : NSObject
singleton_interface(KRUserInfo)
@property (nonatomic, copy) NSString *memberId;//会员id
@property (nonatomic, copy) NSString *memberName;//会员名称
@property (nonatomic, copy) NSString *mobile;//手机号码
@property (nonatomic, copy) NSString *regTime;//注册时间
@property (nonatomic, copy) NSString *sex;//性别
@property (nonatomic, copy) NSString *token;//token
@property (nonatomic, strong) NSDictionary *startStationDic;//起点数据
@end
