//
//  ClockFmdbTool.m
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/8/23.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "ClockFmdbTool.h"
#import "ClockModel.h"

@interface ClockFmdbTool ()
{
    NSString *_username;
}
@end

@implementation ClockFmdbTool

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
        
        DeBugLog(@"运动信息数据库路径 == %@", filepath);
        
        if ([_fmdb open]) {
            DeBugLog(@"数据库打开成功");
        }
        
        //创建表
        [_fmdb executeUpdate:[NSString stringWithFormat:@"create table if not exists ClockData(id integer primary key, time text, isopen bool);"]];
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
- (BOOL)insertModel:(ClockModel *)model
{
    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO ClockData(time, isopen) VALUES ('%@', '%d');", model.time, model.isOpen];
    
    BOOL result = [_fmdb executeUpdate:insertSql];
    if (result) {
        DeBugLog(@"插入数据成功");
    }else {
        DeBugLog(@"插入数据失败");
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
- (NSArray *)queryData {
    
    NSString *queryString = [NSString stringWithFormat:@"SELECT * FROM ClockData;"];
    
    NSMutableArray *arrM = [NSMutableArray array];
    FMResultSet *set = [_fmdb executeQuery:queryString];
    
    while ([set next]) {
        
        ClockModel *model = [[ClockModel alloc] init];
        
        model.time = [set stringForColumn:@"time"];
        model.isOpen = [set boolForColumn:@"isopen"];
        model.ID = [set intForColumn:@"id"];
        
        DeBugLog(@"闹钟时间 == %@，是否打开 == %d, id == %ld",model.time , model.isOpen , (long)model.ID);
        
        [arrM addObject:model];
    }
    
    DeBugLog(@"查询成功");
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
- (BOOL)modifyData:(NSInteger )modifySqlID model:(ClockModel *)modifySqlModel
{
    NSString *modifySqlTime = [NSString stringWithFormat:@"update ClockData set time = ? , isopen = ? where id = ?" ];
    BOOL result = result = [_fmdb executeUpdate:modifySqlTime, modifySqlModel.time, [NSNumber numberWithBool:modifySqlModel.isOpen], [NSNumber numberWithInteger:modifySqlID]];
    
    if (result) {
        DeBugLog(@"修改成功");
    }else {
        DeBugLog(@"修改失败");
    }
    
    return result;
}

//删除数据
- (BOOL)deleteData:(NSInteger )deleteSql
{
    BOOL result;
    
    if (deleteSql == 4) {
        result =  [_fmdb executeUpdate:@"DELETE FROM ClockData"];
    }else {
        NSString *deleteSqlStr = [NSString stringWithFormat:@"DELETE FROM ClockData WHERE id = ?"];
        
        result = [_fmdb executeUpdate:deleteSqlStr,[NSNumber numberWithInteger:deleteSql]];
    }
    
    if (result) {
        DeBugLog(@"删除成功");
    }else {
        DeBugLog(@"删除失败");
    }
    
    return result;
}

@end
