//
//  SleepDailyDataModel.h
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/8/23.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SleepDailyDataModel : NSObject

/**
 *  今日日期
 */
@property (nonatomic , copy) NSString *date;

/**
 *  总的睡眠时间
 */
@property (copy , nonatomic) NSString *sumSleepTime;

/**
 *  深度睡眠时间
 */
@property (copy , nonatomic) NSString *deepSleepTime;

/**
 *  浅度睡眠时间
 */
@property (copy , nonatomic) NSString *lowSleepTime;

+ (instancetype)modelWithDate:(NSString *)date sumSleepTime:(NSString *)sumSleepTime deepSleepTime:(NSString *)deepSleepTime lowSleepTime:(NSString *)lowSleepTime;

@end
