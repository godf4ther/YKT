//
//  KRMainNetTool.m
//  Dntrench
//
//  Created by kupurui on 16/10/19.
//  Copyright © 2016年 CoderDX. All rights reserved.
//

#import "KRMainNetTool.h"
#import "AFNetworking.h"
#import <UIKit/UIKit.h>
#define baseURL @"http://116.62.10.65:7070/"
#import "MBProgressHUD.h"
#import "MBProgressHUD+KR.h"
@implementation KRMainNetTool
singleton_implementation(KRMainNetTool)
//不需要上传文件的接口方法
- (void)sendRequstWith:(NSString *)url params:(NSDictionary *)dic withModel:(Class)model complateHandle:(void (^)(id showdata, NSString *error))complet {
    [self sendRequstWith:url params:dic withModel:model waitView:nil complateHandle:complet];
    
}
//上传文件的接口方法
- (void)upLoadData:(NSString *)url params:(NSDictionary *)param andData:(NSArray *)array complateHandle:(void (^)(id, NSString *))complet {
    [self upLoadData:url params:param andData:array waitView:nil complateHandle:complet];
}
//需要显示加载动画的接口方法 不上传文件
- (void)sendRequstWith:(NSString *)url params:(NSDictionary *)dic withModel:(Class)model waitView:(UIView *)waitView complateHandle:(void(^)(id showdata,NSString *error))complet {
    //拼接网络请求url
    
    NSString *path = [NSString stringWithFormat:@"%@%@",baseURL,url];
    if ([url hasPrefix:@"http"]) {
        path = [NSString stringWithFormat:@"%@",url];
    } else {
        path = [NSString stringWithFormat:@"%@%@",baseURL,url];
    }
    //定义需要加载动画的HUD
    __block MBProgressHUD *HUD;
    if (waitView != nil) {
        //如果view不为空就添加到view上
        HUD = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
        HUD.bezelView.backgroundColor = [UIColor blackColor];
        HUD.contentColor = [UIColor whiteColor];
        HUD.removeFromSuperViewOnHide = YES;
        

        
    }
    //开始网络请求
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer.timeoutInterval = 10.f;
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:dic];
    if (self.isGet) {
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.responseSerializer =  [AFJSONResponseSerializer serializer];
        [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    }
    [manager POST:path parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        //请求成功，隐藏HUD并销毁
        self.isGet = NO;
        [HUD hideAnimated:YES];
        NSDictionary *response = nil;
        if ([responseObject isKindOfClass:[NSData class]]) {
            response = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        } else {
            response = responseObject;
        }
        BOOL state = [response[@"success"] boolValue];
        //判断返回的状态，200即为服务器查询成功，500服务器查询失败
        if (state) {
            if (model == nil) {
                if (response) {
                    complet(response[@"result"],nil);
                } else {
                    [MBProgressHUD showError:response[@"message"] toView:waitView];
                    complet(nil,response[@"message"]);
                }
                
            } else {
                complet([self getModelArrayWith:response[@"result"] andModel:model],nil);
            }
        } else {
            [MBProgressHUD showError:response[@"message"] toView:waitView];
            complet(nil,response[@"message"]);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        self.isGet = NO;
        //网络请求失败，隐藏HUD，服务器响应失败。网络问题 或者服务器崩溃
        [HUD hideAnimated:YES];
        if (waitView.tag != 10001) {
            [MBProgressHUD showError:@"网络错误" toView:waitView];
        }
        
        complet(nil,@"网络错误");
    }];
}

//需要显示加载动画的接口方法 上传文件
- (void)upLoadData:(NSString *)url params:(NSDictionary *)param andData:(NSArray *)array waitView:(UIView *)waitView complateHandle:(void(^)(id showdata,NSString *error))complet {
    //拼接网络请求url
    NSString *path = [NSString stringWithFormat:@"%@%@",baseURL,url];
    //定义需要加载动画的HUD
    __block MBProgressHUD *HUD;
    if (!waitView) {
         HUD = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
        HUD.bezelView.backgroundColor = [UIColor blackColor];
        HUD.contentColor = [UIColor whiteColor];
        HUD.removeFromSuperViewOnHide = YES;
    }
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer.timeoutInterval = 10.f;
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:param];
    
    
    if (self.isGet) {
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.responseSerializer =  [AFJSONResponseSerializer serializer];
        [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    }
    [manager POST:path parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        //通过遍历传过来的上传数据的数组，把每一个数据拼接到formData对象上
        for (NSDictionary *data in array) {
            [formData appendPartWithFileData:data[@"data"] name:data[@"name"] fileName:@"up-file.png" mimeType:@"image/jpeg"];
        }
        
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        //请求成功，隐藏HUD并销毁
        _isGet = NO;
        [HUD hideAnimated:YES];
        NSDictionary *response = nil;
        if ([responseObject isKindOfClass:[NSData class]]) {
            response = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        } else {
            response = responseObject;
        }
        NSNumber *num = response[@"status"];
        //判断返回的状态，200即为服务器查询成功，500服务器查询失败
        if ([num longLongValue] == 200) {
            if ([self.isShow isEqualToString:@"1"]) {
                //[waitView hideBubble];
            }
            if (response[@"data"]) {
                complet(response[@"data"],nil);
            } else {
                complet(@"修改成功",nil);
            }
            
        } else {
            [MBProgressHUD showError:response[@"msg"] toView:waitView];
            complet(nil,response[@"msg"]);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        _isGet = NO;
        //网络请求失败，隐藏HUD，服务器响应失败。网络问题 或者服务器崩溃
        [HUD hideAnimated:YES];
        [MBProgressHUD showError:@"网络错误" toView:waitView];
        complet(nil,@"网络错误");
    }];
}
//把模型数据传入返回模型数据的数组
- (NSArray *)getModelArrayWith:(NSArray *)array andModel:(Class)modelClass {
    NSMutableArray *mut = [NSMutableArray array];
    //遍历模型数据 用KVC给创建每个模型类的对象并赋值过后放进数组
    for (NSDictionary *dic in array) {
        id model = [modelClass new];
        [model setValuesForKeysWithDictionary:dic];
        [mut addObject:model];
    }
    return [mut copy];
}

@end
