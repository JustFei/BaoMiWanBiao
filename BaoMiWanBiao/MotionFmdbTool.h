//
//  MotionFmdbTool.h
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/8/22.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

@class MotionDailyDataModel;
@class GPSDailyDataModel;

typedef enum : NSUInteger {
    SQLTypeMotion = 0,
    SQLTypeGPS,
} SQLType;

@interface MotionFmdbTool : NSObject

- (instancetype)initWithPath:(NSString *)path withSQLType:(SQLType)sqlType;

#pragma mark - 运动信息数据库操作
//插入模型数据
- (BOOL)insertModel:(MotionDailyDataModel *)model;

//查询数据,如果 传空 默认会查询表中所有数据
- (NSArray *)queryDate:(NSString *)querySql;

//删除数据,如果 传空 默认会删除表中所有数据
//- (BOOL)deleteData:(NSString *)deleteSql;

//修改数据
- (BOOL)modifyData:(NSString *)modifySqlDate model:(MotionDailyDataModel *)modifySqlModel;

#pragma mark - GPS信息数据库操作
//插入gps模型数据
- (BOOL)insertGPSModel:(GPSDailyDataModel *)model;

//查询数据
- (NSArray *)queryGPSDataWithDayTime:(NSString *)dayTime;

@end
