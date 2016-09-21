//
//  GPSDailyDataModel.m
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/9/21.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "GPSDailyDataModel.h"

@implementation GPSDailyDataModel


+ (instancetype)modelWithGPSTime:(NSString *)gpsTime dayTime:(NSString *)dayTime locationState:(NSInteger)locationState currentPackage:(NSInteger)currentPackage sumPackage:(NSInteger)sumPackage lon:(float)lon lat:(float)lat
{
    GPSDailyDataModel *model = [[GPSDailyDataModel alloc] init];
    
    model.gpsTime = gpsTime;
    model.dayTime = dayTime;
    model.locationState = locationState;
    model.currentPackage = currentPackage;
    model.sumPackage = sumPackage;
    model.lon = lon;
    model.lat = lat;
    
    return model;
}

@end
