//
//  MotionLineViewController.m
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/8/1.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "MotionLineViewController.h"
#import <MapKit/MapKit.h>

@interface MotionLineViewController () <MKMapViewDelegate>

/**
 *  地图视图
 */
@property (weak, nonatomic) MKMapView *mapView;

/**
 *  划线
 */
@property (strong, nonatomic) MKPolyline *myPolyline;

/** 位置数组 */
@property (nonatomic, strong) NSMutableArray *locationArrayM;

@end

@implementation MotionLineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 设置代理
    self.mapView.delegate = self;
    
    //自定义的一些地理位置信息
    NSString *thePath = @"106.73293,10.79871|106.73229,10.79841|106.7318,10.79832|106.73164,10.79847|106.73156,10.7988|106.73106,10.79886|106.73057,10.79877|106.73002,10.79866|106.72959,10.79875|106.72935,10.7992|106.7293,10.79971|106.72925,10.80015|106.72942,10.80046|106.72981,10.80058|106.73037,10.8007|106.73067,10.80072|106.7311,10.80076|106.7315,10.80079|106.73194,10.80082|106.73237,10.80086|106.73265,10.80098|106.73269,10.80153|106.7327,10.80207|106.73257,10.80243|106.73718,10.79941|106.73445,10.79946|106.73144,10.79885|106.72987,10.8005|106.73192,10.79991|106.72383,10.79827|106.71543,10.80086|106.70957,10.80121|106.70507,10.79834|106.70121,10.79432|106.69603,10.79158|106.69322,10.78911|106.69196,10.78785|106.68768,10.78355|106.68539,10.7812|106.68336,10.7791|106.67048,10.78377|106.64864,10.78319|106.6499,10.77949|106.63697,10.77439|106.6447,10.77936|106.65804,10.76279|106.66792,10.76805|106.68191,10.77516|106.68336,10.77241|106.68319,10.77622|106.67482,10.78149|106.67095,10.78193|106.65217,10.78641|";
    
    NSArray *array = [thePath componentsSeparatedByString:@"|"];
    CLLocationCoordinate2D pointToUse[2];
    
    for (NSInteger i = 0; i < (array.count - 2); i++) {
        NSString *str = array[i];
        NSArray *temp = [str componentsSeparatedByString:@","];
        
        NSString *lon = temp[0];
        NSString *lat = temp[1];
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([lat doubleValue], [lon doubleValue]);
        pointToUse[0] = coordinate;
        
        NSString *str2 = array[i + 1];
        NSArray *temp2 = [str2 componentsSeparatedByString:@","];
        NSString *lon2 = temp2[0];
        NSString *lat2 = temp2[1];
        CLLocationCoordinate2D coordinate2 = CLLocationCoordinate2DMake([lat2 doubleValue], [lon2 doubleValue]);
        pointToUse[1] = coordinate2;
        
        self.myPolyline = [MKPolyline polylineWithCoordinates:pointToUse count:2];
        [self.mapView addOverlay:self.myPolyline];
    }
    
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    MKPolylineRenderer *renderer;
    
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
        
        renderer.strokeColor = [UIColor redColor];
        renderer.lineWidth = 5;
    }
    
    return renderer;
}

- (MKMapView *)mapView
{
    if (!_mapView) {
        MKMapView *view = [[MKMapView alloc] initWithFrame:self.view.bounds];
        
        [self.view addSubview: view];
        _mapView = view;
    }
    
    return _mapView;
}

///**
// *  定位失败会调用该方法
// *
// *  @param error 错误信息
// */
//- (void)didFailToLocateUserWithError:(NSError *)error
//{
//    NSLog(@"did failed locate,error is %@",[error localizedDescription]);
//}
//
///**
// *  用户位置更新后，会调用此函数
// *  @param userLocation 新的用户位置
// */
//- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
//{
//    // 如果此时位置更新的水平精准度大于10米，直接返回该方法
//    // 可以用来简单判断GPS的信号强度
//    if (userLocation.location.horizontalAccuracy > kCLLocationAccuracyNearestTenMeters) {
//        return;
//    }
//}
//
///**
// *  用户方向更新后，会调用此函数
// *  @param userLocation 新的用户位置
// */
//- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
//{
//    // 动态更新我的位置数据
//    [self.mapView updateLocationData:userLocation];
//}
//
///**
// *  开始记录轨迹
// *
// *  @param userLocation 实时更新的位置信息
// */
//- (void)recordTrackingWithUserLocation:(BMKUserLocation *)userLocation
//{
//    if (self.preLocation) {
//        // 计算本次定位数据与上次定位数据之间的距离
//        CGFloat distance = [userLocation.location distanceFromLocation:self.preLocation];
//        self.statusView.distanceWithPreLoc.text = [NSString stringWithFormat:@"%.3f",distance];
//        NSLog(@"与上一位置点的距离为:%f",distance);
//        
//        // (5米门限值，存储数组画线) 如果距离少于 5 米，则忽略本次数据直接返回方法
//        if (distance < 5) {
//            return;
//        }
//    }
//    
//    // 2. 将符合的位置点存储到数组中（第一直接来到这里）
//    [self.locationArrayM addObject:userLocation.location];
//    self.preLocation = userLocation.location;
//    
//    // 3. 绘图
//    [self drawWalkPolyline];
//}
//
///**
// *  绘制轨迹路线
// */
//- (void)drawWalkPolyline
//{
//    // 轨迹点数组个数
//    NSUInteger count = self.locationArrayM.count;
//    
//    // 动态分配存储空间
//    // BMKMapPoint是个结构体：地理坐标点，用直角地理坐标表示 X：横坐标 Y：纵坐标
//    BMKMapPoint *tempPoints = new BMKMapPoint[count];
//    
//    // 遍历数组
//    [self.locationArrayM enumerateObjectsUsingBlock:^(CLLocation *location, NSUInteger idx, BOOL *stop) {
//        BMKMapPoint locationPoint = BMKMapPointForCoordinate(location.coordinate);
//        tempPoints[idx] = locationPoint;
//    }
//     }];
//    
//    //移除原有的绘图，避免在原来轨迹上重画
//    if (self.polyLine) {
//        [self.mapView removeOverlay:self.polyLine];
//    }
//    
//    // 通过points构建BMKPolyline
//    self.polyLine = [BMKPolyline polylineWithPoints:tempPoints count:count];
//    
//    //添加路线,绘图
//    if (self.polyLine) {
//        [self.mapView addOverlay:self.polyLine];
//    }
//    
//    // 清空 tempPoints 临时数组
//    delete []tempPoints;
//    
//    // 根据polyline设置地图范围
//    [self mapViewFitPolyLine:self.polyLine];
//}


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
