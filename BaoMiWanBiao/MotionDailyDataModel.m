//
//  MotionDailyDataModel.m
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/8/22.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "MotionDailyDataModel.h"

@implementation MotionDailyDataModel

+ (instancetype)modelWith: (NSString *)date step:(NSString *)step kCal:(NSString *)kCal mileage:(NSString *)mileage bpm:(NSString *)bpm
{
    MotionDailyDataModel *model = [[MotionDailyDataModel alloc] init];
    model.date = date;
    model.step = step;
    model.kCal = kCal;
    model.mileage = mileage;
    model.bpm = bpm;
    
    return model;
}

@end
