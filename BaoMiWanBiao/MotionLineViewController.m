//
//  MotionLineViewController.m
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/8/1.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "MotionLineViewController.h"
#import <MapKit/MapKit.h>
#import "BLETool.h"

@interface MotionLineViewController () <MKMapViewDelegate, BleReceiveDelegate>
{
    CLLocationCoordinate2D _point[2];
    CLLocationCoordinate2D _pointStart;
    CLLocationCoordinate2D _pointEnd;
}
/**
 *  地图视图
 */
@property (nonatomic, weak) MKMapView *mapView;

/**
 *  划线
 */
@property (nonatomic, strong) MKPolyline *myPolyline;

/** 位置数组 */
@property (nonatomic, strong) NSMutableArray *locationArrayM;

@property (nonatomic, strong) BLETool *mybleTool;



@end

@implementation MotionLineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.mybleTool = [BLETool shareInstance];
    self.mybleTool.receiveDelegate = self;
    
    [self.mybleTool writeGPSToPeripheral];
    
    //纬度：1102401032；经度：1122237700
    //114.004556,22.666567
    //22.6665300000,114.0045810000
    //41b54e62 42e3fcdd
    //651817898
    //41b54d8a 42e3fd04
    
    // 设置代理
    self.mapView.delegate = self;
    
    //自定义的一些地理位置信息
    
    
#if 0
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
#endif
    
    
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

#pragma mark - BleReceiveDelegate
- (void)receiveDataWithModel:(manridyModel *)manridyModel
{
    if (!_pointStart.longitude && !_pointStart.latitude) {
        _pointStart = CLLocationCoordinate2DMake(manridyModel.gpsModel.lat, manridyModel.gpsModel.lon);
    }else {
        _pointStart = _pointEnd;
        _pointEnd = CLLocationCoordinate2DMake(manridyModel.gpsModel.lat, manridyModel.gpsModel.lon);
    }
    
    _point[0] = _pointStart;
    _point[1] = _pointEnd;
    
    self.myPolyline = [MKPolyline polylineWithCoordinates:_point count:2];
    [self.mapView addOverlay:self.myPolyline];
}


#pragma mark - 懒加载
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
//    XXFLog(@"did failed locate,error is %@",[error localizedDescription]);
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
//        XXFLog(@"与上一位置点的距离为:%f",distance);
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
