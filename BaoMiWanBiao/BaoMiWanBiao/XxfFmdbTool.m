//
//  XxfFmdbTool.m
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/7/30.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "XxfFmdbTool.h"
#import "PasswordNoteModel.h"
#import "PasswordNoteMainModel.h"

@implementation XxfFmdbTool

static FMDatabase *_fmdb;

- (instancetype)initWithPath: (NSString *)path
{
    self = [super init];
    if (self) {
        NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",path]];
        _fmdb = [FMDatabase databaseWithPath:filePath];
        
        NSLog(@"filePath == %@",filePath);
        
        if (![_fmdb open]) {
            NSLog(@"数据库开启失败");
        }
        
#warning 必须先打开数据库才能创建表。。。否则提示数据库没有打开
        //[_fmdb executeUpdate:@"CREATE TABLE IF NOT EXISTS t_modals(id INTEGER PRIMARY KEY, name TEXT NOT NULL, age INTEGER NOT NULL, ID_No INTEGER NOT NULL);"];
        /**
         *  创建数据库表单
         *
         *  @param key  主键  用indexPath.row来作为主键
         *  @param text 名称
         *  @param text 账户
         *  @param text 密码
         *  @param text 备注
         *  @param bool 是否加密
         *
         */
        [_fmdb executeUpdate:@"create table if not exists PasswordNoteTable(id integer primary key, name text, account text, password text, memorandum text, isEncrypt bool);"];
    }
    return self;
}

/**
 *  插入数据
 *
 *  @param model 插入的model
 *
 *  @return 是否插入成功
 */
- (BOOL)insertModel:(PasswordNoteModel *)model {
    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO PasswordNoteTable(name, account, password, memorandum, isEncrypt) VALUES ('%@', '%@', '%@', '%@', '%d');", model.name, model.account, model.password, model.memorandum, model.isEncrypt];
    return [_fmdb executeUpdate:insertSql];
}

/**
 *  查找数据
 *
 *  @param querySql 查找的关键字
 *
 *  @return 返回所有查找的结果
 */
- (NSArray *)queryData:(NSString *)querySql {
    
    if (querySql == nil) {
        querySql = @"SELECT * FROM PasswordNoteTable;";
    }
    
    NSMutableArray *arrM = [NSMutableArray array];
    FMResultSet *set = [_fmdb executeQuery:querySql];
    
    while ([set next]) {
        
        NSString *name = [set stringForColumn:@"name"];
        NSString *isEncrypt = [set stringForColumn:@"isEncrypt"];
        
        PasswordNoteMainModel *model = [[PasswordNoteMainModel alloc] init];
        
        model.name = name;
        model.isEncrypt = isEncrypt.integerValue;
        
        NSLog(@"%@---%d",name ,model.isEncrypt);
        
        [arrM addObject:model];
    }
    
    NSLog(@"查询成功");
    return arrM;
}

- (BOOL)deleteData:(NSString *)deleteSql {
    
    //如果传入nil，就直接return掉
    if (deleteSql == nil) {
//        deleteSql = @"DELETE FROM PasswordNoteTable";
        return 0;
    }
    
    return [_fmdb executeUpdate:deleteSql];
}

@end
