//
//  SleepDailyDataModel.m
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/8/23.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "SleepDailyDataModel.h"

@implementation SleepDailyDataModel

+ (instancetype)modelWithDate:(NSString *)date sumSleepTime:(NSString *)sumSleepTime deepSleepTime:(NSString *)deepSleepTime lowSleepTime:(NSString *)lowSleepTime
{
    SleepDailyDataModel *model = [[SleepDailyDataModel alloc] init];
    
    model.date = date;
    model.sumSleepTime = sumSleepTime;
    model.deepSleepTime = deepSleepTime;
    model.lowSleepTime = lowSleepTime;
    
    return model;
}

@end
