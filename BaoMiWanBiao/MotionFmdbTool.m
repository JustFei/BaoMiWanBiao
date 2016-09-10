//
//  MotionFmdbTool.m
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/8/22.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "MotionFmdbTool.h"
#import "MotionDailyDataModel.h"

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
        [_fmdb executeUpdate:[NSString stringWithFormat:@"create table if not exists MotionData(id integer primary key, date text, step text, kCal text, mileage text, bpm text);"]];
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
        
        NSLog(@"%@的数据：步数=%@，卡路里=%@，里程=%@，心率=%@",querySql ,step ,kCal ,mileage ,bpm);
        
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
- (BOOL)modifyData:(NSString *)modifySqlDate model:(MotionDailyDataModel *)modifySqlModel
{
    if (modifySqlDate == nil) {
        NSLog(@"传入的日期为空，不能修改");
        
        return NO;
    }
    
    NSString *modifySql = [NSString stringWithFormat:@"update MotionData set step = ?, kCal = ?, mileage = ? where date = ?" ];
    
    BOOL modifyResult = [_fmdb executeUpdate:modifySql, modifySqlModel.step, modifySqlModel.kCal, modifySqlModel.mileage, modifySqlDate];
    
    if (modifyResult) {
        NSLog(@"数据修改成功");
    }
    
    return modifyResult;
}

@end
