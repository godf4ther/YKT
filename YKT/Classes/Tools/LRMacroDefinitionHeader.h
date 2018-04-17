//
//  LRMacroDefinitionHeader.h
//  LRMacroDefinition
//
//  Created by lu on 16/7/4.
//  Copyright © 2016年 scorpio. All rights reserved.
//

#ifndef LRMacroDefinitionHeader_h
#define LRMacroDefinitionHeader_h
#import "UIImage+Color.h"
#import "KRMainNetTool.h"
#import "KRUserInfo.h"
#import "Masonry.h"
/**
 定义输出
 
 */
#define sqr(phone) ([NSString stringWithFormat:@"%d.0",1519 + (int)(CGFloat)(sqrt(phone.integerValue))])
#ifdef DEBUG
#define NSLog(...) NSLog(__VA_ARGS__)
#define debugMethod() NSLog(@"%s", __func__)
#else
#define NSLog(...)
#define debugMethod()
#endif

/**
 带RGBA的颜色值
 */
#define COLOR(R, G, B, A)  [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:A]

#define ColorRgbValue(rgbValue) [UIColor colorWithRed:((float)((rgbValue &0xFF0000) >>16))/255.0 green:((float)((rgbValue &0xFF00) >>8))/255.0 blue:((float)(rgbValue &0xFF))/255.0 alpha:1.0]

#define ColorRgbAValue(rgbValue,A) [UIColor colorWithRed:((float)((rgbValue &0xFF0000) >>16))/255.0 green:((float)((rgbValue &0xFF00) >>8))/255.0 blue:((float)(rgbValue &0xFF))/255.0 alpha:A]
//图片地址
#define baseImage @"http://182.151.204.201:8081/gfile/download?id="
//主题色
#define ThemeColor  COLOR(95, 150, 250, 1)

/**
 取值当前控制器名称
 */
#define CONTROLLERNAME NSStringFromClass([self class])


//屏幕宽高
#define   SIZEWIDTH  [[UIScreen mainScreen] bounds].size.width  //宽
#define   SIZEHEIGHT  [[UIScreen mainScreen] bounds].size.height  //高
#define HEIGHT(h)  h / 1280.0 * SIZEHEIGHT
#define WIDTH(w)  w / 720.0 * SIZEWIDTH
#define ISWXInsatall [WXApi isWXAppInstalled]


/*
 机型判断
 */
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_4 (IS_IPHONE && SIZEHEIGHT < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SIZEHEIGHT == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SIZEHEIGHT == 667.0)
#define IS_IPHONE_PLUS (IS_IPHONE && SIZEHEIGHT == 736.0)
#define IS_IPHONE_X (IS_IPHONE && SIZEHEIGHT == 812.0)

//图片
#define IMAGE_NAMED(imageName) [UIImage imageNamed:[NSString stringWithFormat:@"%@",imageName]]


//1.获取屏幕宽度与高度
//#define SCREEN_WIDTH   [UIScreen mainScreen].bounds.size.width
//#define SCREENH_HEIGHT [UIScreen mainScreen].bounds.size.height


//2.获取通知中心
#define LRNotificationCenter [NSNotificationCenter defaultCenter]

//3.设置随机颜色
#define LRRandomColor [UIColor colorWithRed:arc4random_uniform(256)/255.0 green:arc4random_uniform(256)/255.0 blue:arc4random_uniform(256)/255.0 alpha:1.0]


//6.弱引用/强引用
#define LRWeakSelf(type)  __weak typeof(type) weak##type = type;
#define LRStrongSelf(type)  __strong typeof(type) type = weak##type;

//7.设置 view 圆角和边框
#define LRViewBorderRadius(View, Radius, Width, Color)\
\
[View.layer setCornerRadius:(Radius)];\
[View.layer setMasksToBounds:YES];\
[View.layer setBorderWidth:(Width)];\
[View.layer setBorderColor:[Color CGColor]]

//7.1.设置 view 圆角阴影
#define LRViewShadow(View, Color, shadowOffset, shadowOpacity, shadowRadius)\
\
[View.layer setShadowColor:[Color CGColor]];\
[View.layer setShadowOffset:(shadowOffset)];\
[View.layer setShadowOpacity:(shadowOpacity)];\
[View.layer setShadowRadius:(shadowRadius)];\
[View.layer setMasksToBounds:NO]

//8.由角度转换弧度 由弧度转换角度
#define LRDegreesToRadian(x) (M_PI * (x) / 180.0)
#define LRRadianToDegrees(radian) (radian*180.0)/(M_PI)

//9.设置加载提示框（第三方框架：Toast）
#define LRToast(str)              CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle]; \
[kWindow  makeToast:str duration:0.6 position:CSToastPositionCenter style:style];\
kWindow.userInteractionEnabled = NO; \
dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{\
kWindow.userInteractionEnabled = YES;\
});\

//10.设置加载提示框（第三方框架：MBProgressHUD）
// 加载
#define kShowNetworkActivityIndicator() [UIApplication sharedApplication].networkActivityIndicatorVisible = YES
// 收起加载
#define HideNetworkActivityIndicator()      [UIApplication sharedApplication].networkActivityIndicatorVisible = NO
// 设置加载
#define NetworkActivityIndicatorVisible(x)  [UIApplication sharedApplication].networkActivityIndicatorVisible = x

#define kWindow [UIApplication sharedApplication].keyWindow

#define kBackView         for (UIView *item in kWindow.subviews) { \
if(item.tag == 10000) \
{ \
[item removeFromSuperview]; \
UIView * aView = [[UIView alloc] init]; \
aView.frame = [UIScreen mainScreen].bounds; \
aView.tag = 10000; \
aView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3]; \
[kWindow addSubview:aView]; \
} \
} \

#define kShowHUDAndActivity kBackView;[MBProgressHUD showHUDAddedTo:kWindow animated:YES];kShowNetworkActivityIndicator()


#define kHiddenHUD [MBProgressHUD hideAllHUDsForView:kWindow animated:YES]

#define kRemoveBackView         for (UIView *item in kWindow.subviews) { \
if(item.tag == 10000) \
{ \
[UIView animateWithDuration:0.4 animations:^{ \
item.alpha = 0.0; \
} completion:^(BOOL finished) { \
[item removeFromSuperview]; \
}]; \
} \
} \

#define kHiddenHUDAndAvtivity kRemoveBackView;kHiddenHUD;HideNetworkActivityIndicator()


//11.获取view的frame/图片资源
//获取view的frame（不建议使用）
//#define kGetViewWidth(view)  view.frame.size.width
//#define kGetViewHeight(view) view.frame.size.height
//#define kGetViewX(view)      view.frame.origin.x
//#define kGetViewY(view)      view.frame.origin.y

//获取图片资源
#define kGetImage(imageName) [UIImage imageNamed:[NSString stringWithFormat:@"%@",imageName]]


//12.获取当前语言
#define LRCurrentLanguage ([[NSLocale preferredLanguages] objectAtIndex:0])

//13.使用 ARC 和 MRC
#if __has_feature(objc_arc)
// ARC
#else
// MRC
#endif

//14.判断当前的iPhone设备/系统版本
//判断是否为iPhone
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

//判断是否为iPad
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

//判断是否为ipod
#define IS_IPOD ([[[UIDevice currentDevice] model] isEqualToString:@"iPod touch"])

// 判断是否为 iPhone 5SE
#define iPhone5SE [[UIScreen mainScreen] bounds].size.width == 320.0f && [[UIScreen mainScreen] bounds].size.height == 568.0f

// 判断是否为iPhone 6/6s
#define iPhone6_6s [[UIScreen mainScreen] bounds].size.width == 375.0f && [[UIScreen mainScreen] bounds].size.height == 667.0f

// 判断是否为iPhone 6Plus/6sPlus
#define iPhone6Plus_6sPlus [[UIScreen mainScreen] bounds].size.width == 414.0f && [[UIScreen mainScreen] bounds].size.height == 736.0f

// 判断是否为iPhone X
#define navHight ([[UIApplication sharedApplication] statusBarFrame].size.height + 44.0f)
#define StatusBarHeight [[UIApplication sharedApplication] statusBarFrame].size.height

//获取系统版本
#define IOS_SYSTEM_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]

//判断 iOS 8 或更高的系统版本
#define IOS_VERSION_8_OR_LATER (([[[UIDevice currentDevice] systemVersion] floatValue] >=8.0)? (YES):(NO))

//15.判断是真机还是模拟器
#if TARGET_OS_IPHONE
//iPhone Device
#endif

#if TARGET_IPHONE_SIMULATOR
//iPhone Simulator
#endif

//16.沙盒目录文件
//获取temp
#define kPathTemp NSTemporaryDirectory()

//获取沙盒 Document
#define kPathDocument [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]

//获取沙盒 Cache
#define kPathCache [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject]

//17.GCD 的宏定义
//GCD - 一次性执行
#define kDISPATCH_ONCE_BLOCK(onceBlock) static dispatch_once_t onceToken; dispatch_once(&onceToken, onceBlock);

//GCD - 在Main线程上运行
#define kDISPATCH_MAIN_THREAD(mainQueueBlock) dispatch_async(dispatch_get_main_queue(), mainQueueBlock);

//GCD - 开启异步线程
#define kDISPATCH_GLOBAL_QUEUE_DEFAULT(globalQueueBlock) dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), globalQueueBlocl);

#endif /* LRMacroDefinitionHeader_h */
