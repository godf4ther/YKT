//
//  WriteOrderViewController.m
//  YKT
//
//  Created by 周春仕 on 2018/4/21.
//  Copyright © 2018年 周春仕. All rights reserved.
//

#import "WriteOrderViewController.h"
#import "LRMacroDefinitionHeader.h"
#import "PassengerListViewController.h"
#import "UIImageView+WebCache.h"
#import "AFNetworking.h"
#import "PayTicketController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import "MANaviRoute.h"
#import "CommonUtility.h"

static const NSInteger RoutePlanningPaddingEdge                    = 20;
@interface WriteOrderViewController ()<UIScrollViewDelegate,MAMapViewDelegate,AMapSearchDelegate>
@property (nonatomic, strong) NSDateFormatter *formatter;
@property (weak, nonatomic) IBOutlet UILabel *linkmanLabel;
@property (nonatomic, strong) NSDictionary *linkmanDic;
@property (weak, nonatomic) IBOutlet UILabel *numLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *allPrice;
@property (weak, nonatomic) IBOutlet UILabel *detail;
@property (weak, nonatomic) IBOutlet UIView *markContainer;
@property (nonatomic, strong) NSMutableArray *markBtnArr;
@property (weak, nonatomic) IBOutlet UITextView *markDetail;
@property (nonatomic, strong) NSArray *carArr;
@property (nonatomic, strong) NSMutableArray *orlBusInfoList;
@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) AMapSearchAPI *search;
@property (nonatomic, strong) AMapRoute *route;

@property (nonatomic, strong) MAPointAnnotation *startAnnotation;
@property (nonatomic, strong) MAPointAnnotation *destinationAnnotation;

@property (nonatomic, strong) NSString *valuationMileage;
@property (nonatomic, assign) NSInteger duration;

/* 用于显示当前路线方案. */
@property (nonatomic) MANaviRoute * naviRoute;

@end

@implementation WriteOrderViewController

- (NSDateFormatter *)formatter{
    if (!_formatter) {
        _formatter = [[NSDateFormatter alloc] init];
        [_formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    }
    return _formatter;
}

- (NSMutableArray *)markBtnArr {
    if (!_markBtnArr) {
        _markBtnArr = [NSMutableArray array];
    }
    return _markBtnArr;
}

- (NSMutableArray *)orlBusInfoList {
    if (!_orlBusInfoList) {
        _orlBusInfoList = [NSMutableArray array];
    }
    return _orlBusInfoList;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    [self popOut];
    self.scrollView.delegate = self;
    self.navigationItem.title = @"订单填写";
    [self setAMap];
    // Do any additional setup after loading the view from its nib.
}

- (void)setAMap {
    MAMapView *_mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    _mapView.showsCompass = NO; // 设置成NO表示关闭指南针；YES表示显示指南针
    _mapView.delegate = self;;
    _mapView.userTrackingMode = MAUserTrackingModeFollow;
    self.mapView = _mapView;
    
    MAPointAnnotation *startAnnotation = [[MAPointAnnotation alloc] init];
    CLLocationCoordinate2D startCoordinate = {[self.journeyStartDic[@"latitude"] doubleValue],[self.journeyStartDic[@"longitude"] doubleValue]};
    startAnnotation.coordinate = startCoordinate;
    startAnnotation.title = @"起点";
    self.startAnnotation = startAnnotation;
    CLLocationCoordinate2D endCoordinate = {[self.journeyEndDic[@"latitude"] doubleValue],[self.journeyEndDic[@"longitude"] doubleValue]};
    MAPointAnnotation *destinationAnnotation = [[MAPointAnnotation alloc] init];
    destinationAnnotation.coordinate = endCoordinate;
    destinationAnnotation.title = @"终点";
    self.destinationAnnotation = destinationAnnotation;
    [self.mapView addAnnotation:startAnnotation];
    [self.mapView addAnnotation:destinationAnnotation];
    [self.view insertSubview:_mapView atIndex:0];
    
    self.search = [[AMapSearchAPI alloc] init];
    self.search.delegate = self;
    [self searchRoutePlanningDrive];
}

#pragma mark - do search
- (void)searchRoutePlanningDrive
{
    AMapDrivingRouteSearchRequest *navi = [[AMapDrivingRouteSearchRequest alloc] init];
    
    navi.requireExtension = YES;
    //    navi.strategy = 5;
    /* 出发点. */
    navi.origin = [AMapGeoPoint locationWithLatitude:self.startAnnotation.coordinate.latitude
                                           longitude:self.startAnnotation.coordinate.longitude];
    /* 目的地. */
    navi.destination = [AMapGeoPoint locationWithLatitude:self.destinationAnnotation.coordinate.latitude
                                                longitude:self.destinationAnnotation.coordinate.longitude];
    
    [self.search AMapDrivingRouteSearch:navi];
}

#pragma mark - AMapSearchDelegate
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{
    NSLog(@"Error: %@", error);
}

/* 路径规划搜索回调. */
- (void)onRouteSearchDone:(AMapRouteSearchBaseRequest *)request response:(AMapRouteSearchResponse *)response
{
    if (response.route == nil)
    {
        return;
    }
    
    self.route = response.route;
    if (response.count > 0)
    {
        [self presentCurrentCourse];
    }
}

/* 展示当前路线方案. */
- (void)presentCurrentCourse
{
    
    self.valuationMileage = [NSString stringWithFormat:@"%.1f",self.route.paths[0].distance / 1000.0];
    self.duration = self.route.paths[0].duration;
    [self requestData];    MANaviAnnotationType type = MANaviAnnotationTypeDrive;
    self.naviRoute = [MANaviRoute naviRouteForPath:self.route.paths[0] withNaviType:type showTraffic:YES startPoint:[AMapGeoPoint locationWithLatitude:self.startAnnotation.coordinate.latitude longitude:self.startAnnotation.coordinate.longitude] endPoint:[AMapGeoPoint locationWithLatitude:self.destinationAnnotation.coordinate.latitude longitude:self.destinationAnnotation.coordinate.longitude]];
    [self.naviRoute addToMapView:self.mapView];
    
    /* 缩放地图使其适应polylines的展示. */
    [self.mapView setVisibleMapRect:[CommonUtility mapRectForOverlays:self.naviRoute.routePolylines]
                        edgePadding:UIEdgeInsetsMake(RoutePlanningPaddingEdge, RoutePlanningPaddingEdge, 354 , RoutePlanningPaddingEdge)
                           animated:YES];
}


- (void)popOutAction {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)requestData {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"isHighWay"] = @"0";
    params[@"journeyStartTime"] = self.journeyStartTime;
    if ([self.journeyType isEqualToString:@"1"]) {
        NSDate *endDate = [NSDate dateWithTimeInterval:self.duration sinceDate:[self.formatter dateFromString:self.journeyStartTime]];
        params[@"journeyEndTime"] = [self.formatter stringFromDate:endDate];
    }
    else {
        params[@"journeyEndTime"] = self.journeyEndTime;
    }
    params[@"journeyType"] = self.journeyType;
    params[@"valuationMileage"] = self.valuationMileage;
    [[KRMainNetTool sharedKRMainNetTool] sendRequstWith:@"eBusiness/bc/findAllVehicleType.do" params:params withModel:nil waitView:self.view complateHandle:^(id showdata, NSString *error) {
        if (showdata) {
            self.carArr = showdata;
            [self setUp];
        }
    }];
}

- (void)setUp {
    self.scrollView.pagingEnabled = YES;
    self.scrollView.contentSize = CGSizeMake((SIZEWIDTH - 24) * self.carArr.count, 145);
    for (int i = 0; i < self.carArr.count; i ++) {
        NSDictionary *dic = self.carArr[i];
        NSMutableDictionary *busiInfo = @{@"journeyEndTime":self.journeyEndTime,@"journeyStartTime":self.journeyStartTime,@"rentVehicleTypeId":dic[@"id"],@"rentVehicleTypeName":dic[@"rentVehicleTypeName"],@"vehicleNum":@"0"}.mutableCopy;
        [self.orlBusInfoList addObject:busiInfo];
        UIView *container = [[UIView alloc] initWithFrame:CGRectMake((SIZEWIDTH - 24)*i, 0, SIZEWIDTH - 24, 145)];
        [self.scrollView addSubview:container];
        UILabel *title = [[UILabel alloc] init];
        title.text = dic[@"rentVehicleTypeName"];
        title.font = [UIFont systemFontOfSize:16];
        [container addSubview:title];
        [title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(container.mas_centerX);
            make.top.equalTo(container).offset(15);
        }];
        UILabel *detail = [[UILabel alloc] init];
        detail.text = [NSString stringWithFormat:@"座位%ld座，大件行李0件",[dic[@"seatNum"] integerValue]];
        detail.font = [UIFont systemFontOfSize:14];
        detail.textColor = [UIColor lightGrayColor];
        [container addSubview:detail];
        [detail mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(container.mas_centerX);
            make.top.equalTo(title.mas_bottom).offset(10);
        }];
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [container addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(container.mas_centerX);
            make.top.equalTo(detail.mas_bottom).offset(15);
            make.width.mas_equalTo(100);
            make.height.mas_equalTo(40);
        }];
        [imageView sd_setImageWithURL:[NSURL URLWithString:dic[@"picUrl"]]];
        UILabel *price = [[UILabel alloc] init];
        price.text = [NSString stringWithFormat:@"￥%.2f",[dic[@"price"] floatValue]];
        price.font = [UIFont systemFontOfSize:14];
        price.textColor = [UIColor lightGrayColor];
        [container addSubview:price];
        [price mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(container.mas_centerX);
            make.top.equalTo(imageView.mas_bottom);
        }];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger index = scrollView.contentOffset.x / (SIZEWIDTH - 24);
    self.numLabel.text = self.orlBusInfoList[index][@"vehicleNum"];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)linkMan:(id)sender {
    PassengerListViewController *listVC = [PassengerListViewController new];
    listVC.sblock = ^(NSDictionary *dic) {
        self.linkmanDic = dic;
        self.linkmanLabel.text = dic[@"mobile"];
    };
    listVC.isSingleSelect = YES;
    [self.navigationController pushViewController:listVC animated:YES];
}
- (IBAction)remark:(id)sender {
    self.markContainer.hidden = NO;
}
- (IBAction)shuoming:(id)sender {
}
- (IBAction)delete:(UIButton *)sender {
    NSInteger num = self.numLabel.text.integerValue;
    if (num == 0) {
        return;
    }
    num --;
    self.numLabel.text = [NSString stringWithFormat:@"%ld",num];
    [self math];
}
- (IBAction)add:(UIButton *)sender {
    NSInteger num = self.numLabel.text.integerValue;
    num ++;
    self.numLabel.text = [NSString stringWithFormat:@"%ld",num];
    [self math];
}
- (IBAction)submit:(UIButton *)sender {
    if (self.linkmanDic.count == 0) {
        [self showHUDWithText:@"请选择联系人"];
        return;
    }
    [self showLoadingHUD];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSMutableArray *busInfoList = [NSMutableArray array];
    for (NSMutableDictionary *info in self.orlBusInfoList) {
        if ([info[@"vehicleNum"] integerValue] != 0) {
            [busInfoList addObject:info];
        }
    }
    NSData *jsonData1 = [NSJSONSerialization dataWithJSONObject:busInfoList options:NSJSONWritingPrettyPrinted
                                                         error:nil];
    NSString *jsonString1 =[[NSString alloc] initWithData:jsonData1 encoding:NSUTF8StringEncoding];
    params[@"busInfoList"] = jsonString1;
    params[@"buyType"] = @"4";
    params[@"endPointCity"] = self.journeyEndDic[@"city"];
    params[@"endPointName"] = self.journeyEndDic[@"name"];
    params[@"endPointCityCode"] = self.journeyEndDic[@"adcode"];
    params[@"endXAxial"] = self.journeyEndDic[@"longitude"];
    params[@"endYAxial"] = self.journeyEndDic[@"latitude"];;
    params[@"journeyType"] = self.journeyType;
    params[@"largeBaggageCount"] = @"0";
    params[@"orderAnnotation"] = self.markDetail.text;
    params[@"orderPerson"] = self.linkmanDic[@"passengerName"];
    params[@"orderPersonPhone"] = self.linkmanDic[@"mobile"];
    params[@"pessangeCount"] = @"1";
    params[@"startPointCity"] = self.journeyStartDic[@"city"];
    params[@"startPointName"] = self.journeyStartDic[@"name"];
    params[@"startPointCityCode"] = self.journeyStartDic[@"adcode"];
    params[@"startXAxial"] = self.journeyStartDic[@"longitude"];
    params[@"startYAxial"] = self.journeyStartDic[@"latitude"];
    params[@"token"] = [KRUserInfo sharedKRUserInfo].token;
    params[@"totalFee"] = [self.allPrice.text substringFromIndex:1];
    params[@"valuationMileage"] = self.valuationMileage;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://116.62.10.65:7070/eBusiness/bc/saveBcOrderInfo.do"] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:15.0];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    NSMutableString *paraString = [NSMutableString string];
    for (NSString *key in [params allKeys]) {
        [paraString appendFormat:@"&%@=%@",key,params[key]];
    }
    [paraString deleteCharactersInRange:NSMakeRange(0, 1)];
    [request setHTTPBody:[paraString dataUsingEncoding:NSUTF8StringEncoding]];
    // 初始化AFManager
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration: [NSURLSessionConfiguration defaultSessionConfiguration]];
    AFJSONResponseSerializer *serializer = [AFJSONResponseSerializer serializer];
    serializer.acceptableContentTypes = [NSSet setWithObjects:
                                         @"text/plain",
                                         @"application/json",
                                         @"text/html", nil];
    manager.responseSerializer = serializer;
    // 构建请求任务
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id _Nullable responseObject, NSError * _Nullable error) {
        [self hideHUD];
        if (error) {
            [self showHUDWithText:@"网络错误"];
        } else {
            NSDictionary *dic = responseObject;
            if ([dic[@"success"] boolValue]) {
                PayTicketController *payVC = [PayTicketController new];
                payVC.orderId = dic[@"result"][@"orderId"];
                payVC.isBC = YES;
                payVC.journeyStartTime = self.journeyStartTime;
                payVC.journeyEndTime = self.journeyEndTime;
                [self.navigationController pushViewController:payVC animated:YES];
            }
            else {
                [self showHUDWithText:dic[@"message"]];
            }
        }
    }];
    // 发起请求
    [dataTask resume];
}
- (IBAction)cancelMark:(UIButton *)sender {
    self.markContainer.hidden = YES;
}
- (IBAction)sureMark:(UIButton *)sender {
    self.markContainer.hidden = YES;
}
- (IBAction)markBtnAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        sender.backgroundColor = ThemeColor;
    }
    else {
        sender.backgroundColor = [UIColor lightGrayColor];
    }
}

- (NSString *)strChange:(NSString *)str {
    NSString *str1 = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSString *str2 = [str1 stringByReplacingOccurrencesOfString:@" " withString:@""];
    return str2;
}

- (void)math {
    NSInteger index = self.scrollView.contentOffset.x / (SIZEWIDTH - 24);
    self.orlBusInfoList[index][@"vehicleNum"] = self.numLabel.text;
    NSMutableString *Mustr = [NSMutableString string];
    CGFloat allPrice = 0.0;
    for (NSMutableDictionary *info in self.orlBusInfoList) {
        if ([info[@"vehicleNum"] integerValue] != 0) {
            [Mustr appendFormat:@"%@%@辆,",info[@"rentVehicleTypeName"],info[@"vehicleNum"]];
        }
        NSInteger index = [self.orlBusInfoList indexOfObject:info];
        allPrice += ([info[@"vehicleNum"] integerValue] * [self.carArr[index][@"price"] floatValue]);
    }
    self.allPrice.text = [NSString stringWithFormat:@"￥%.2f",allPrice];
    self.detail.text = Mustr;
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation {
    if ([annotation isKindOfClass:[MAPointAnnotation class]]) {
        static NSString *routePlanningCellIdentifier = @"RoutePlanningCellIdentifier";
        
        MAAnnotationView *poiAnnotationView = (MAAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:routePlanningCellIdentifier];
        if (poiAnnotationView == nil)
        {
            poiAnnotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation
                                                             reuseIdentifier:routePlanningCellIdentifier];
            poiAnnotationView.canShowCallout = NO;
        }
        if ([annotation.title isEqualToString:@"起点"]) {
            poiAnnotationView.image = [UIImage imageNamed:@"startPoint"];
        }
        else if ([annotation.title isEqualToString:@"终点"]) {
            poiAnnotationView.image = [UIImage imageNamed:@"endPoint"];
        }
        return poiAnnotationView;
        
    }
    return nil;
}


- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id<MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[LineDashPolyline class]])
    {
        MAPolylineRenderer *polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:((LineDashPolyline *)overlay).polyline];
        polylineRenderer.lineWidth = 7;
        polylineRenderer.lineDashType = kMALineDashTypeSquare;
        polylineRenderer.strokeColor = ThemeColor;
        
        return polylineRenderer;
    }
    if ([overlay isKindOfClass:[MANaviPolyline class]])
    {
        MANaviPolyline *naviPolyline = (MANaviPolyline *)overlay;
        MAPolylineRenderer *polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:naviPolyline.polyline];
        
        polylineRenderer.lineWidth = 7;
        
        if (naviPolyline.type == MANaviAnnotationTypeWalking)
        {
            polylineRenderer.strokeColor = ThemeColor;
        }
        else if (naviPolyline.type == MANaviAnnotationTypeRailway)
        {
            polylineRenderer.strokeColor = ThemeColor;
        }
        else
        {
            polylineRenderer.strokeColor = ThemeColor;
        }
        
        return polylineRenderer;
    }
    if ([overlay isKindOfClass:[MAMultiPolyline class]])
    {
        MAMultiColoredPolylineRenderer * polylineRenderer = [[MAMultiColoredPolylineRenderer alloc] initWithMultiPolyline:overlay];
        
        polylineRenderer.lineWidth = 7;
        polylineRenderer.strokeColor = ThemeColor;
        
        return polylineRenderer;
    }
    
    return nil;
}




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
