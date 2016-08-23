//
//  SleepFmdbTool.m
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/8/23.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "SleepFmdbTool.h"
#import "SleepDailyDataModel.h"

@interface SleepFmdbTool ()
{
    NSString *_username;
}
@end

@implementation SleepFmdbTool

static FMDatabase *_fmdb;

/**
 *  创建数据库文件
 *
 *  @param path 数据库名字，以用户名+MotionData命名
 *
 */
- (instancetype)initWithPath:(NSString *)path
{
    self = [super init];
    
    if (self) {
        NSString *filepath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.sqlite",path]];
        _fmdb = [FMDatabase databaseWithPath:filepath];
        _username = path;
        
        NSLog(@"运动信息数据库路径 == %@", filepath);
        
        if ([_fmdb open]) {
            NSLog(@"数据库打开成功");
        }
        
        //创建表
        [_fmdb executeUpdate:[NSString stringWithFormat:@"create table if not exists %@SleepData(id integer primary key, date text, sumsleep text, deepsleep text, lowsleep text);",path]];
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
- (BOOL)insertModel:(SleepDailyDataModel *)model
{
    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO %@SleepData(date, sumsleep, deepsleep, lowsleep) VALUES ('%@', '%@', '%@', '%@');", _username, model.date, model.sumSleepTime, model.deepSleepTime, model.lowSleepTime];
    
    BOOL result = [_fmdb executeUpdate:insertSql];
    if (result) {
        NSLog(@"插入数据成功");
    }else {
        NSLog(@"插入数据失败");
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
- (NSArray *)queryData:(NSString *)querySql {
    
    NSString *queryString;
    
    if (querySql == nil) {
        queryString = [NSString stringWithFormat:@"SELECT * FROM %@SleepData;",_username];
    }else {
        //这里一定不能将？用需要查询的日期代替掉
        queryString = [NSString stringWithFormat:@"SELECT * FROM %@SleepData where date = ?;",_username ];
    }
    
    NSMutableArray *arrM = [NSMutableArray array];
    FMResultSet *set = [_fmdb executeQuery:queryString ,querySql];
    
    while ([set next]) {
        
        NSString *sumsleep = [set stringForColumn:@"sumsleep"];
        NSString *deepsleep = [set stringForColumn:@"deepsleep"];
        NSString *lowsleep = [set stringForColumn:@"lowsleep"];
        
        SleepDailyDataModel *model = [[SleepDailyDataModel alloc] init];
        
        model.date = querySql;
        model.sumSleepTime = sumsleep;
        model.deepSleepTime = deepsleep;
        model.lowSleepTime = lowsleep;
        
        NSLog(@"%@的数据：总睡眠时间=%@，深度睡眠时间=%@，浅睡眠时间=%@",querySql ,sumsleep ,deepsleep ,lowsleep );
        
        [arrM addObject:model];
    }
    
    NSLog(@"查询成功");
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
- (BOOL)modifyData:(NSString *)modifySqlDate :(SleepDailyDataModel *)modifySqlModel
{
    if (modifySqlDate == nil) {
        NSLog(@"传入的日期为空，不能修改");
        
        return NO;
    }
    
    NSString *modifySql = [NSString stringWithFormat:@"update %@SleepData set sumsleep = ? deepsleep = ? lowsleep = ? where date = ?",_username ];
    
    return [_fmdb executeUpdate:modifySql, modifySqlModel.sumSleepTime, modifySqlModel.deepSleepTime, modifySqlModel.lowSleepTime, modifySqlDate];
}

@end
