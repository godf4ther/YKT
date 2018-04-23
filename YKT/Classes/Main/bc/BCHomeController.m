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
@interface BCHomeController ()<MAMapViewDelegate>
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

@end

@implementation BCHomeController

- (NSDateFormatter *)formatter{
    if (!_formatter) {
        _formatter = [[NSDateFormatter alloc] init];
        [_formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    }
    return _formatter;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self popOut];
    [self setAMap];
    NSDictionary *userInfoDic = [self getFromDefaultsWithKey:@"USERINFO"];
    [[KRUserInfo sharedKRUserInfo] setValuesForKeysWithDictionary:userInfoDic];
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
    [pointAnnotation setLockedScreenPoint:CGPointMake(self.view.center.x, self.view.center.y - 52.5)];
    [pointAnnotation setLockedToScreen:YES];
    [_mapView addAnnotation:pointAnnotation];
    [_mapView selectAnnotation:pointAnnotation animated:YES];
    self.mapView = _mapView;
    [self.view insertSubview:_mapView atIndex:0];
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
        }

        return annotationView;
    }

    return nil;
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
    LocaleVC.block = ^(NSDictionary *dic) {
        self.startPlaceLabel.text = dic[@"name"];
    };
    [self.navigationController pushViewController:LocaleVC animated:YES];
}
- (IBAction)chooseEndAddress:(id)sender {
    WriteOrderViewController *writeVC = [WriteOrderViewController new];
    writeVC.journeyEndTime = @"2018-04-24 14:25:19";
    writeVC.journeyStartTime = self.startTimeField.text;
    if ([self.preBtn.titleLabel.text isEqualToString:@"单程"]) {
        writeVC.journeyType = @"1";
    }
    else {
        writeVC.journeyType = @"2";
    }
    [self.navigationController pushViewController:writeVC animated:YES];
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
