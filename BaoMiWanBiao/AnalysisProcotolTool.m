//
//  AnalysisProcotolTool.m
//  ManridyBleDemo
//
//  Created by 莫福见 on 16/9/14.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "AnalysisProcotolTool.h"
#import "manridyModel.h"
#import "NSStringTool.h"
#import "ClockModel.h"

@implementation AnalysisProcotolTool

//解析设置时间数据（00|80）
+ (manridyModel *)analysisSetTimeData:(NSData *)data WithHeadStr:(NSString *)head
{
    manridyModel *model = [[manridyModel alloc] init];
    model.receiveDataType = ReturnModelTypeSetTimeModel;
    
    if ([head isEqualToString:@"00"]) {
        NSData *timeData = [data subdataWithRange:NSMakeRange(1, 7)];
        NSString *timeStr = [NSStringTool ConvertToNSStringWithNSData:timeData];
        model.setTimeModel.time = timeStr;
        model.isReciveDataRight = ResponsEcorrectnessDataRgith;
        
        //        XXFLog(@"设定了时间为：%@\n%@",timeStr,model.setTimeModel.time);
    }else if ([head isEqualToString:@"80"]) {
        model.isReciveDataRight = ResponsEcorrectnessDataFail;
    }
    
    return model;
}

//解析闹钟数据 (01|81)
+ (manridyModel *)analysisClockData:(NSData *)data WithHeadStr:(NSString *)head
{
    manridyModel *model = [[manridyModel alloc] init];
    model.receiveDataType = ReturnModelTypeClockModel;
    
    if ([head isEqualToString:@"01"]) {
        const unsigned char *hexBytes = [data bytes];
        
        for (int index = 1; index <= 5; index ++) {
            //第一个闹钟
            NSString *clock = [NSString stringWithFormat:@"%02x", hexBytes[index + 1]];
            if ([clock isEqualToString:@"01"] || [clock isEqualToString:@"02"]) {
                NSData *timeData = [data subdataWithRange:NSMakeRange(5 + index * 2, 2)];
                NSString *timeStr = [NSStringTool ConvertToNSStringWithNSData:timeData];
                NSMutableString *mutTimeStr = [NSMutableString stringWithString:timeStr];
                [mutTimeStr insertString:@":" atIndex:2];
                
//                NSDictionary *dic = @{clock:timeStr};
                ClockModel *clockModel = [[ClockModel alloc] init];
                clockModel.ID = index;
                clockModel.time = mutTimeStr;
                if ([clock isEqualToString:@"01"]) {
                    clockModel.isOpen = 1;
                }else if ([clock isEqualToString:@"02"]) {
                    clockModel.isOpen = 0;
                }
                [model.clockModelArr addObject:clockModel];
            }
        }
        XXFLog(@"闹钟的数据为 == %@",model.clockModelArr);
        model.isReciveDataRight = ResponsEcorrectnessDataRgith;
    }else if ([head isEqualToString:@"81"]) {
        model.isReciveDataRight = ResponsEcorrectnessDataFail;
    }
    
    return model;
}

//解析获取运动信息的数据（03|83）
+ (manridyModel *)analysisGetSportData:(NSData *)data WithHeadStr:(NSString *)head
{
    manridyModel *model = [[manridyModel alloc] init];
    model.receiveDataType = ReturnModelTypeSportModel;
    
    if ([head isEqualToString:@"03"]) {
        NSData *stepData = [data subdataWithRange:NSMakeRange(2, 3)];
        int stepValue = [NSStringTool parseIntFromData:stepData];
        //        XXFLog(@"今日步数 = %d",stepValue);
        NSString *stepStr = [NSString stringWithFormat:@"%d",stepValue];
        
        NSData *mileageData = [data subdataWithRange:NSMakeRange(5, 3)];
        int mileageValue = [NSStringTool parseIntFromData:mileageData];
        //        XXFLog(@"今日里程数 = %d",mileageValue);
        NSString *mileageStr = [NSString stringWithFormat:@"%d",mileageValue];
        
        NSData *kcalData = [data subdataWithRange:NSMakeRange(8, 3)];
        int kcalValue = [NSStringTool parseIntFromData:kcalData];
        //        XXFLog(@"卡路里 = %d",kcalValue);
        NSString *kCalStr = [NSString stringWithFormat:@"%d",kcalValue];
        
        model.sportModel.stepNumber = stepStr;
        model.sportModel.mileageNumber = mileageStr;
        model.sportModel.kCalNumber = kCalStr;
        model.isReciveDataRight = ResponsEcorrectnessDataRgith;
        
        
    }else if ([head isEqualToString:@"83"]) {
        model.isReciveDataRight = ResponsEcorrectnessDataFail;
    }
    
    return model;
}

//解析获取运动信息清零的数据（04|84）
+ (manridyModel *)analysisSportZeroData:(NSData *)data WithHeadStr:(NSString *)head
{
    manridyModel *model = [[manridyModel alloc] init];
    model.receiveDataType =  ReturnModelTypeSportZeroModel;
    
    if ([head isEqualToString:@"04"]) {
        model.sportZero = SportZeroSuccess;
        model.isReciveDataRight = ResponsEcorrectnessDataRgith;
    }else if ([head isEqualToString:@"84"]) {
        model.isReciveDataRight = ResponsEcorrectnessDataFail;
        model.sportZero = SportZeroFail;
    }
    
    return model;
}

//解析用户信息的数据（06|86）
+ (manridyModel *)analysisUserInfoData:(NSData *)data WithHeadStr:(NSString *)head
{
    manridyModel *model = [[manridyModel alloc] init];
    model.receiveDataType = ReturnModelTypeUserInfoModel;
    
    if ([head isEqualToString:@"06"]) {
        NSData *weight = [data subdataWithRange:NSMakeRange(1, 1)];
        int weightValue = [NSStringTool parseIntFromData:weight];
        NSString *weightStr = [NSString stringWithFormat:@"%d",weightValue];
        
        NSData *height = [data subdataWithRange:NSMakeRange(2, 1)];
        int heightValue = [NSStringTool parseIntFromData:height];
        NSString *heightStr = [NSString stringWithFormat:@"%d",heightValue];
        
        model.userInfoModel.weight = weightStr;
        model.userInfoModel.height = heightStr;
        model.isReciveDataRight = ResponsEcorrectnessDataRgith;
        
    }else if ([head isEqualToString:@"86"]) {
        model.isReciveDataRight = ResponsEcorrectnessDataFail;
    }
    
    return model;
}

//解析运动目标的数据（07|87）
+ (manridyModel *)analysisSportTargetData:(NSData *)data WithHeadStr:(NSString *)head
{
    manridyModel *model = [[manridyModel alloc] init];
    model.receiveDataType = ReturnModelTypeSportTargetModel;
    
    if ([head isEqualToString:@"07"]) {
        NSData *target = [data subdataWithRange:NSMakeRange(2, 3)];
        int targetValue = [NSStringTool parseIntFromData:target];
        NSString *targetStr = [NSString stringWithFormat:@"%d",targetValue];
        
        model.isReciveDataRight = ResponsEcorrectnessDataRgith;
        
        model.sportTargetModel.sportTargetNumber = targetStr;
        
    }else if ([head isEqualToString:@"87"]) {
        model.isReciveDataRight = ResponsEcorrectnessDataFail;
    }
    
    return model;
}

//解析心率开关的数据（09|89）
+ (manridyModel *)analysisHeartStateData:(NSData *)data WithHeadStr:(NSString *)head
{
    manridyModel *model = [[manridyModel alloc] init];
    model.receiveDataType = ReturnModelTypeHeartRateStateModel;
    
    if ([head isEqualToString:@"09"]) {
        model.isReciveDataRight = ResponsEcorrectnessDataRgith;
    }else if ([head isEqualToString:@"89"]) {
        model.isReciveDataRight = ResponsEcorrectnessDataFail;
    }
    
    return model;
}

//解析心率的数据（0A|8A）
+ (manridyModel *)analysisHeartData:(NSData *)data WithHeadStr:(NSString *)head
{
    manridyModel *model = [[manridyModel alloc] init];
    model.receiveDataType = ReturnModelTypeHeartRateModel;
    
    if ([head isEqualToString:@"0a"] || [head isEqualToString:@"0A"]) {
        
        const unsigned char *hexBytes = [data bytes];
        
        NSString *TyStr = [NSString stringWithFormat:@"02%x", hexBytes[1]];
        
        if ([TyStr isEqualToString:@"00"]) {
            model.heartRateModel.heartRateState = HeartRateDataLastData;
            
        }else if ([TyStr isEqualToString:@"01"]) {
            NSData *sum = [data subdataWithRange:NSMakeRange(2, 2)];
            int sumVale = [NSStringTool parseIntFromData:sum];
            NSString *sumStr = [NSString stringWithFormat:@"%d",sumVale];
            
            NSData *current = [data subdataWithRange:NSMakeRange(4, 2)];
            int currentVale = [NSStringTool parseIntFromData:current];
            NSString *currentStr = [NSString stringWithFormat:@"%d",currentVale];
            model.heartRateModel.sumDataCount = sumStr;
            model.heartRateModel.currentDataCount = currentStr;
            model.heartRateModel.heartRateState = HeartRateDataHistoryData;
        }
        
        NSData *time = [data subdataWithRange:NSMakeRange(6, 6)];
        NSString *timeStr = [NSString stringWithFormat:@"%@",time];
        
        NSData *Hr = [data subdataWithRange:NSMakeRange(12, 1)];
        int HrVale = [NSStringTool parseIntFromData:Hr];
        NSString *HrStr = [NSString stringWithFormat:@"%d",HrVale];
        
        model.heartRateModel.time = timeStr;
        model.heartRateModel.heartRate = HrStr;
        model.isReciveDataRight = ResponsEcorrectnessDataRgith;
        
    }else if ([head isEqualToString:@"8a"] || [head isEqualToString:@"8A"]) {
        model.isReciveDataRight = ResponsEcorrectnessDataFail;
    }
    
    return model;
}

//解析睡眠的数据（0C|8C）
+ (manridyModel *)analysisSleepData:(NSData *)data WithHeadStr:(NSString *)head
{
    manridyModel *model = [[manridyModel alloc] init];
    model.receiveDataType = ReturnModelTypeSleepModel;
    
    if ([head isEqualToString:@"0c"] || [head isEqualToString:@"0C"]) {
        
        const unsigned char *hexBytes = [data bytes];
        
        NSString *TyStr = [NSString stringWithFormat:@"02%x", hexBytes[1]];
        
        if ([TyStr isEqualToString:@"00"]) {
            model.sleepModel.sleepState = SleepDataLastData;
            
        }else if ([TyStr isEqualToString:@"01"]) {
            NSData *sum = [data subdataWithRange:NSMakeRange(2, 2)];
            int sumVale = [NSStringTool parseIntFromData:sum];
            NSString *sumStr = [NSString stringWithFormat:@"%d",sumVale];
            
            NSData *current = [data subdataWithRange:NSMakeRange(4, 2)];
            int currentVale = [NSStringTool parseIntFromData:current];
            NSString *currentStr = [NSString stringWithFormat:@"%d",currentVale];
            model.sleepModel.sumDataCount = sumStr;
            model.sleepModel.currentDataCount = currentStr;
            model.sleepModel.sleepState = SleepDataHistoryData;
        }
        
        NSData *startTime = [data subdataWithRange:NSMakeRange(4, 5)];
        int startTimeVale = [NSStringTool parseIntFromData:startTime];
        NSString *startTimeStr = [NSString stringWithFormat:@"%d",startTimeVale];
        
        NSData *endTime = [data subdataWithRange:NSMakeRange(9, 5)];
        int endTimeVale = [NSStringTool parseIntFromData:endTime];
        NSString *endTimeStr = [NSString stringWithFormat:@"%d",endTimeVale];
        
        NSData *deepSleep = [data subdataWithRange:NSMakeRange(14, 2)];
        int deepSleepVale = [NSStringTool parseIntFromData:deepSleep];
        NSString *deepSleepStr = [NSString stringWithFormat:@"%d",deepSleepVale];
        
        NSData *lowSleep = [data subdataWithRange:NSMakeRange(16, 2)];
        int lowSleepVale = [NSStringTool parseIntFromData:lowSleep];
        NSString *lowSleepStr = [NSString stringWithFormat:@"%d",lowSleepVale];
        
        model.sleepModel.startTime = startTimeStr;
        model.sleepModel.endTime = endTimeStr;
        model.sleepModel.deepSleep = deepSleepStr;
        model.sleepModel.lowSleep = lowSleepStr;
        model.isReciveDataRight = ResponsEcorrectnessDataRgith;
        
    }else if ([head isEqualToString:@"8c"] || [head isEqualToString:@"8C"]) {
        model.isReciveDataRight = ResponsEcorrectnessDataFail;
    }
    
    return model;
}

@end
