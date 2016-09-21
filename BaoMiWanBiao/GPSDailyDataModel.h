//
//  GPSDailyDataModel.h
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/9/21.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GPSDailyDataModel : NSObject

//gps上的时间
@property (nonatomic ,copy) NSString *gpsTime;

//数据的日期，用来区分每天的数据
@property (nonatomic ,copy) NSString *dayTime;

//位置状态，0：起点，1：过程，2：终点
@property (nonatomic ,assign) NSInteger locationState;

//当前包数
@property (nonatomic ,assign) NSInteger currentPackage;

//总包数
@property (nonatomic ,assign) NSInteger sumPackage;

//经度
@property (nonatomic ,assign) float lon;

//纬度
@property (nonatomic ,assign) float lat;


+ (instancetype)modelWithGPSTime:(NSString *)gpsTime dayTime:(NSString *)dayTime locationState:(NSInteger)locationState currentPackage:(NSInteger)currentPackage sumPackage:(NSInteger)sumPackage lon:(float)lon lat:(float)lat;

@end
