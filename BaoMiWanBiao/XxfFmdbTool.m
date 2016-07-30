//
//  XxfFmdbTool.m
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/7/30.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "XxfFmdbTool.h"
#import "PasswordNoteModel.h"

@implementation XxfFmdbTool

static FMDatabase *_fmdb;

- (instancetype)initWithPath: (NSString *)path
{
    self = [super init];
    if (self) {
        NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"/DB/%@",path]];
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

+ (BOOL)insertModal:(PasswordNoteModel *)model {
    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO t_modals(name, account, password, memorandum) VALUES ('%@', '%@', '%@', '%@');", model.name, model.account, model.password, model.memorandum];
    return [_fmdb executeUpdate:insertSql];
}

+ (BOOL)deleteData:(NSString *)deleteSql {
    
    if (deleteSql == nil) {
        deleteSql = @"DELETE FROM t_modals";
    }
    
    return [_fmdb executeUpdate:deleteSql];
}

@end
