//
//  BCHomeController.m
//  YKT
//
//  Created by 周春仕 on 2018/4/19.
//  Copyright © 2018年 周春仕. All rights reserved.
//

#import "BCHomeController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import "LRMacroDefinitionHeader.h"
#import "LocaleController.h"
#import "LoginViewController.h"
#import "KRDatePicker.h"
#import "WriteOrderViewController.h"
#import <AMapSearchKit/AMapSearchKit.h>

@interface BCHomeController ()<MAMapViewDelegate,AMapSearchDelegate>
@property (weak, nonatomic) IBOutlet UIButton *oneWayBtn;
@property (weak, nonatomic) IBOutlet UIButton *twoWayBtn;
@property (weak, nonatomic) IBOutlet UITextField *startTimeField;
@property (weak, nonatomic) IBOutlet UITextField *endTimeField;
@property (weak, nonatomic) IBOutlet UITextField *startPlaceLabel;
@property (weak, nonatomic) IBOutlet UITextField *endPlaceLabel;
@property (weak, nonatomic) IBOutlet UIView *bottomContainer;
@property (weak, nonatomic) IBOutlet UIView *btnsContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *endContainerHeight;
@property (nonatomic, strong) UIButton *preBtn;
@property (weak, nonatomic) IBOutlet UIView *endContainer;
@property (weak, nonatomic) IBOutlet UIButton *gpsBtn;
@property (nonatomic, strong) NSDateFormatter *formatter;
@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) MAAnnotationView *userLocationAnnotationView;//定位点图标
@property (nonatomic, strong) MAPointAnnotation *pointAnnotation; //大头针参数
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, assign) BOOL isFirst;//初始化话定位
@property (nonatomic, strong) AMapSearchAPI *search;
@property (nonatomic, strong) NSDictionary *journeyStartDic;
@property (nonatomic, strong) NSDictionary *selectCityDic;
@end

@implementation BCHomeController

- (NSDateFormatter *)formatter{
    if (!_formatter) {
        _formatter = [[NSDateFormatter alloc] init];
        [_formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    return _formatter;
}

- (UIActivityIndicatorView *)indicatorView {
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] init];
        _indicatorView.tintColor = [UIColor blackColor];
    }
    return _indicatorView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self popOut];
    [self setAMap];
    LRViewBorderRadius(self.bottomContainer, 10, 0, [UIColor whiteColor]);
    LRViewBorderRadius(self.btnsContainer, 20, 0, [UIColor whiteColor]);
    LRViewBorderRadius(self.oneWayBtn, 15, 0, [UIColor whiteColor]);
    LRViewBorderRadius(self.twoWayBtn, 15, 0, [UIColor whiteColor]);
    LRViewBorderRadius(self.gpsBtn, 4, 0, [UIColor whiteColor]);
    self.endContainer.layer.masksToBounds = YES;
    self.endContainerHeight.constant = 0;
    self.preBtn = self.oneWayBtn;
    // Do any additional setup after loading the view from its nib.
}

- (void)setAMap {
    [AMapServices sharedServices].enableHTTPS = YES;
    [AMapServices sharedServices].apiKey = @"e2d80843aa7c9ca3eea2379fe8b6d5c3";
    MAMapView *_mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    _mapView.showsUserLocation = YES;
    _mapView.userTrackingMode = MAUserTrackingModeFollow;
    _mapView.showsCompass = NO; // 设置成NO表示关闭指南针；YES表示显示指南针
    _mapView.delegate = self;
    MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
    [pointAnnotation setLockedScreenPoint:CGPointMake(SIZEWIDTH / 2, (SIZEHEIGHT - navHight) / 2 - 17.5)];
    [pointAnnotation setLockedToScreen:YES];
    self.pointAnnotation = pointAnnotation;
    [_mapView addAnnotation:pointAnnotation];
    [_mapView selectAnnotation:pointAnnotation animated:YES];
    self.mapView = _mapView;
    [self.view insertSubview:_mapView atIndex:0];
    self.search = [[AMapSearchAPI alloc] init];
    self.search.delegate = self;

}
- (IBAction)typeChoose:(UIButton *)sender {
    self.preBtn.backgroundColor = [UIColor whiteColor];
    [self.preBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    sender.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [sender setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.preBtn = sender;
    if ([sender.titleLabel.text isEqualToString:@"单程"]) {
        self.endContainerHeight.constant = 0;
    }
    else {
        self.endContainerHeight.constant = 45;
    }
}
- (IBAction)gpsAction:(UIButton *)sender {
    if(self.mapView.userLocation.updating && self.mapView.userLocation.location) {
        [self.mapView setCenterCoordinate:self.mapView.userLocation.location.coordinate animated:YES];
    }
}

#pragma mark -------------- MAMapDelegate -------------

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    /* 自定义userLocation对应的annotationView. */
    if ([annotation isKindOfClass:[MAUserLocation class]])
    {
        static NSString *userLocationStyleReuseIndetifier = @"userLocationStyleReuseIndetifier";
        MAAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:userLocationStyleReuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation
                                                          reuseIdentifier:userLocationStyleReuseIndetifier];
        }

        annotationView.image = [UIImage imageNamed:@"userPosition"];

        self.userLocationAnnotationView = annotationView;

        return annotationView;
    }
    else if ([annotation isKindOfClass:[MAPointAnnotation class]]) {
        static NSString *pointReuseIdentifier = @"pointReuseIdentifier";
        MAPinAnnotationView *annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIdentifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIdentifier];
            annotationView.canShowCallout            = YES;
            annotationView.draggable                 = YES;
            annotationView.image = [UIImage imageNamed:@"location"];
//            annotationView.rightCalloutAccessoryView = self.indicatorView;
        }
        return annotationView;
    }

    return nil;
}

- (void)mapView:(MAMapView *)mapView didAnnotationViewCalloutTapped:(MAAnnotationView *)view{
    if (![KRUserInfo sharedKRUserInfo].memberId) {
        LoginViewController *loginVC = [LoginViewController new];
        [self.navigationController pushViewController:loginVC animated:YES];
        return;
    }
    LocaleController *LocaleVC = [LocaleController new];
    LocaleVC.selectCityDic = self.selectCityDic;
    LocaleVC.block = ^(NSDictionary *dic) {
        self.startPlaceLabel.text = dic[@"name"];
        self.journeyStartDic = dic;
        CLLocationCoordinate2D coordinate = {[dic[@"latitude"] doubleValue],[dic[@"longitude"] doubleValue]};
        [self.mapView setCenterCoordinate:coordinate  animated:YES];
        [self.pointAnnotation setTitle:dic[@"name"]];
    };
    [self.navigationController pushViewController:LocaleVC animated:YES];
}




- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
    if (!updatingLocation && self.userLocationAnnotationView != nil)
    {
        [UIView animateWithDuration:0.1 animations:^{

            double degree = userLocation.heading.trueHeading - self.mapView.rotationDegree;
            self.userLocationAnnotationView.transform = CGAffineTransformMakeRotation(degree * M_PI / 180.f );

        }];
    }
    if (!self.isFirst) {
        self.isFirst = YES;
        CLLocationCoordinate2D coordinate = userLocation.coordinate;
        MACoordinateSpan span = {0.01,0.01};
        MACoordinateRegion region = {coordinate,span};
        mapView.region = region;
        [self searchReGeocodeWithCoordinate:userLocation.coordinate];
    }
    
}


- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    [self searchReGeocodeWithCoordinate:mapView.centerCoordinate];
}

- (void)searchReGeocodeWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];
    
    regeo.location                    = [AMapGeoPoint locationWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    regeo.requireExtension            = YES;
    
    [self.search AMapReGoecodeSearch:regeo];
}


#pragma mark - AMapSearchDelegate
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{
    NSLog(@"Error: %@", error);
}

/* 逆地理编码回调. */
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    AMapReGeocode *ReGeocode = response.regeocode;
    self.navigationItem.title = ReGeocode.addressComponent.city;
    if (ReGeocode.aois.count > 0) {
        AMapAOI *ob = (AMapAOI *)ReGeocode.aois[0];
        [self.pointAnnotation setTitle:ob.name];
        self.startPlaceLabel.text = ob.name;
        NSDictionary *dic = @{@"city":ReGeocode.addressComponent.city,@"adcode":ReGeocode.addressComponent.adcode,@"location":[NSString stringWithFormat:@"%f,%f",ob.location.longitude,ob.location.latitude],@"longitude":[NSString stringWithFormat:@"%f",ob.location.longitude],@"latitude":[NSString stringWithFormat:@"%f",ob.location.latitude],@"name":ob.name};
        self.journeyStartDic = dic;
        self.selectCityDic = @{@"name":ReGeocode.addressComponent.city,@"center":[NSString stringWithFormat:@"%f,%f",ob.location.longitude,ob.location.latitude]};
    }
    else if (ReGeocode.pois.count > 0){
        AMapPOI *ob = (AMapPOI *)ReGeocode.pois[0];
        [self.pointAnnotation setTitle:ob.name];
        self.startPlaceLabel.text = ob.name;
        NSDictionary *dic = @{@"city":ReGeocode.addressComponent.city,@"adcode":ReGeocode.addressComponent.adcode,@"location":[NSString stringWithFormat:@"%f,%f",ob.location.longitude,ob.location.latitude],@"longitude":[NSString stringWithFormat:@"%f",ob.location.longitude],@"latitude":[NSString stringWithFormat:@"%f",ob.location.latitude],@"name":ob.name};
        self.journeyStartDic = dic;
        self.selectCityDic = @{@"name":ReGeocode.addressComponent.city,@"center":[NSString stringWithFormat:@"%f,%f",ob.location.longitude,ob.location.latitude]};
    }
    else {

    }
    
}


- (IBAction)chooseStartTime:(id)sender {
    KRDatePicker *picker = [[NSBundle mainBundle] loadNibNamed:@"KRDatePicker" owner:self options:nil].lastObject;
    picker.block = ^(NSDate *date) {
        NSString *dateStr = [self.formatter stringFromDate:date];
        self.startTimeField.text = dateStr;
    };
    [[UIApplication sharedApplication].keyWindow addSubview:picker];
}
- (IBAction)chooseEndTime:(id)sender {
    KRDatePicker *picker = [[NSBundle mainBundle] loadNibNamed:@"KRDatePicker" owner:self options:nil].lastObject;
    picker.block = ^(NSDate *date) {
        NSString *dateStr = [self.formatter stringFromDate:date];
        self.endTimeField.text = dateStr;
    };
    [[UIApplication sharedApplication].keyWindow addSubview:picker];
}
- (IBAction)chooseStartAddress:(id)sender {
    if (![KRUserInfo sharedKRUserInfo].memberId) {
        LoginViewController *loginVC = [LoginViewController new];
        [self.navigationController pushViewController:loginVC animated:YES];
        return;
    }
    LocaleController *LocaleVC = [LocaleController new];
    LocaleVC.selectCityDic = self.selectCityDic;
    LocaleVC.block = ^(NSDictionary *dic) {
        self.startPlaceLabel.text = dic[@"name"];
        self.journeyStartDic = dic;
        CLLocationCoordinate2D coordinate = {[dic[@"latitude"] doubleValue],[dic[@"longitude"] doubleValue]};
        [self.mapView setCenterCoordinate:coordinate  animated:YES];
        [self.pointAnnotation setTitle:dic[@"name"]];
    };
    [self.navigationController pushViewController:LocaleVC animated:YES];
}
- (IBAction)chooseEndAddress:(id)sender {
    if (!self.isFirst) {
        return;
    }
    if (![KRUserInfo sharedKRUserInfo].memberId) {
        LoginViewController *loginVC = [LoginViewController new];
        [self.navigationController pushViewController:loginVC animated:YES];
        return;
    }
    LocaleController *LocaleVC = [LocaleController new];
    if ([self.preBtn.titleLabel.text isEqualToString:@"单程"]) {
        LocaleVC.journeyType = @"1";
        if ([self cheakIsNull:self.startTimeField.text]) {
            [self showHUDWithText:@"请选择起始时间"];
            return;
        }
        LocaleVC.journeyStartTime = self.startTimeField.text;
        LocaleVC.journeyEndTime = @"2018-04-25 14:25:19";
    }
    else {
        LocaleVC.journeyType = @"2";
        if ([self cheakIsNull:self.startTimeField.text]) {
            [self showHUDWithText:@"请选择起始时间"];
            return;
        }
        LocaleVC.journeyStartTime = self.startTimeField.text;
        if ([self cheakIsNull:self.endTimeField.text]) {
            [self showHUDWithText:@"请选择结束时间"];
            return;
        }
        LocaleVC.journeyEndTime = self.endTimeField.text;
    }
    LocaleVC.journeyStartDic = self.journeyStartDic;
    LocaleVC.selectCityDic = self.selectCityDic;
    LocaleVC.isGoSearch = YES;

    
    [self.navigationController pushViewController:LocaleVC animated:YES];
}




- (void)dealloc {
   
}


- (void)popOutAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
