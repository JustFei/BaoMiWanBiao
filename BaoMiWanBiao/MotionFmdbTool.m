//
//  MotionFmdbTool.m
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/8/22.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "MotionFmdbTool.h"
#import "MotionDailyDataModel.h"
#import "GPSDailyDataModel.h"
#import "GPSDayGroupModel.h"

@interface MotionFmdbTool ()
{
    NSString *_username;
}
@end

@implementation MotionFmdbTool

static FMDatabase *_fmdb;


/**
 *  创建数据库文件
 *
 *  @param path 数据库名字，以用户名+MotionData命名
 *
 */
- (instancetype)initWithPath:(NSString *)path withSQLType:(SQLType)sqlType
{
    self = [super init];
    
    if (self) {
        NSString *filepath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.sqlite",path]];
        _fmdb = [FMDatabase databaseWithPath:filepath];
        _username = path;
        
        DeBugLog(@"运动信息数据库路径 == %@", filepath);
        
        if ([_fmdb open]) {
            DeBugLog(@"数据库打开成功");
        }
        switch (sqlType) {
            case SQLTypeMotion:
                [_fmdb executeUpdate:[NSString stringWithFormat:@"create table if not exists MotionData(id integer primary key, date text, step text, kCal text, mileage text, bpm text);"]];
                break;
            case SQLTypeGPS:
                [_fmdb executeUpdate:[NSString stringWithFormat:@"create table if not exists GPSData(id integer primary key, gpsTime text, dayTime text, locationState integer, currentPackage integer, sumPackage integer, lon float, lat float);"]];
                break;
            default:
                break;
        }
    }
    
    return self;
}

/**
 *  插入数据模型
 *
 *  @param model 运动数据模型
 *
 *  @return 是否成功
 */
- (BOOL)insertModel:(MotionDailyDataModel *)model
{
    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO MotionData(date, step, kCal, mileage, bpm) VALUES ('%@', '%@', '%@', '%@', '%@');", model.date, model.step, model.kCal, model.mileage, model.bpm];
    
    BOOL result = [_fmdb executeUpdate:insertSql];
    if (result) {
        DeBugLog(@"插入Motion数据成功");
    }else {
        DeBugLog(@"插入Motion数据失败");
    }
    return result;
}

/**
 *  查找数据
 *
 *  @param querySql 查找的关键字
 *
 *  @return 返回所有查找的结果
 */
- (NSArray *)queryDate:(NSString *)querySql {
    
    NSString *queryString;
    
    if (querySql == nil) {
        queryString = [NSString stringWithFormat:@"SELECT * FROM MotionData;"];
    }else {
        //这里一定不能将？用需要查询的日期代替掉
        queryString = [NSString stringWithFormat:@"SELECT * FROM MotionData where date = ?;"];
    }
    
    NSMutableArray *arrM = [NSMutableArray array];
    FMResultSet *set = [_fmdb executeQuery:queryString ,querySql];
    
    while ([set next]) {
        
        NSString *step = [set stringForColumn:@"step"];
        NSString *kCal = [set stringForColumn:@"kCal"];
        NSString *mileage = [set stringForColumn:@"mileage"];
        NSString *bpm = [set stringForColumn:@"bpm"];
        
        MotionDailyDataModel *model = [[MotionDailyDataModel alloc] init];
        
        model.date = querySql;
        model.step = step;
        model.kCal = kCal;
        model.mileage = mileage;
        model.bpm = bpm;
        
        DeBugLog(@"%@的数据：步数=%@，卡路里=%@，里程=%@，心率=%@",querySql ,step ,kCal ,mileage ,bpm);
        
        [arrM addObject:model];
    }
    
    DeBugLog(@"Motion查询成功");
    return arrM;
}

/**
 *  修改数据内容
 *
 *  @param modifySqlDate  需要修改的日期
 *  @param modifySqlModel 需要修改的模型内容
 *
 *  @return 是否修改成功
 */
- (BOOL)modifyData:(NSString *)modifySqlDate model:(MotionDailyDataModel *)modifySqlModel
{
    if (modifySqlDate == nil) {
        DeBugLog(@"传入的日期为空，不能修改");
        
        return NO;
    }
    
    BOOL modifyResult;
    
    if (modifySqlModel.bpm == nil) {
        NSString *modifySql = [NSString stringWithFormat:@"update MotionData set step = ?, kCal = ?, mileage = ? where date = ?" ];
        
        modifyResult = [_fmdb executeUpdate:modifySql, modifySqlModel.step, modifySqlModel.kCal, modifySqlModel.mileage, modifySqlDate];
    }else {
        NSString *modifySql = [NSString stringWithFormat:@"update MotionData set bpm = ? where date = ?" ];
        
        modifyResult = [_fmdb executeUpdate:modifySql, modifySqlModel.bpm, modifySqlDate];
    }
    
    if (modifyResult) {
        DeBugLog(@"Motion数据修改成功");
    }else {
        DeBugLog(@"Motion数据修改失败");
    }
    
    return modifyResult;
}

//gpsTime text, dayTime text, locationState text, currentPackage integer, sumPackage integer, lon float, lat float

#pragma mark - GPS信息数据库操作
//插入gps模型数据
- (BOOL)insertGPSModel:(GPSDailyDataModel *)model
{
    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO GPSData(gpsTime, dayTime, locationState, currentPackage, sumPackage, lon, lat) VALUES ('%@', '%@', '%ld', '%ld', '%ld', '%f', '%f');", model.gpsTime, model.dayTime, model.locationState, model.currentPackage, model.sumPackage, model.lon, model.lat];
    
    BOOL result = [_fmdb executeUpdate:insertSql];
    if (result) {
        DeBugLog(@"插入GPS数据成功");
    }else {
        DeBugLog(@"插入GPS数据失败");
    }
    return result;
    
}

//查询数据
- (NSArray *)queryGPSDataWithDayTime:(NSString *)dayTime
{
    NSString *queryString;
    
    if (dayTime == nil) {
        queryString = [NSString stringWithFormat:@"SELECT * FROM GPSData;"];
    }else {
        //这里一定不能将？用需要查询的日期代替掉
        queryString = [NSString stringWithFormat:@"SELECT * FROM GPSData where dayTime = ?;"];
    }
    
    NSMutableArray *arrM = [NSMutableArray array];
    FMResultSet *set = [_fmdb executeQuery:queryString ,dayTime];
    
    GPSDayGroupModel *model = [[GPSDayGroupModel alloc] init];
    
    while ([set next]) {
        
        DeBugLog(@"%d",[set intForColumn:@"locationState"]);
        
        if ([set intForColumn:@"locationState"] == 0) {
            
            
            model.startTime = [set stringForColumn:@"gpsTime"];
            NSString *lat = [set stringForColumn:@"lat"];
            NSString *lon = [set stringForColumn:@"lon"];
            [model.GPSArr addObject:[NSString stringWithFormat:@"%@,%@",lat ,lon]];
        }
        
        if ([set intForColumn:@"locationState"] == 1) {
            if (model.startTime != nil) {
                
                NSString *lat = [set stringForColumn:@"lat"];
                NSString *lon = [set stringForColumn:@"lon"];
                [model.GPSArr addObject:[NSString stringWithFormat:@"%@,%@",lat ,lon]];
            }
        }
        
        if ([set intForColumn:@"locationState"] == 2) {
            if (model.startTime != nil) {
                
                model.endTime = [set stringForColumn:@"gpsTime"];
                NSString *lat = [set stringForColumn:@"lat"];
                NSString *lon = [set stringForColumn:@"lon"];
                [model.GPSArr addObject:[NSString stringWithFormat:@"%@,%@",lat ,lon]];
                
                [arrM addObject:model];
                model = nil;
            }
        }
    }
    
    DeBugLog(@"GPS查询成功");
    return arrM;
    
}

@end
