//
//  XxfFmdbTool.h
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/7/30.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

@class PasswordNoteModel;
@interface XxfFmdbTool : NSObject

//插入模型数据
+ (BOOL)insertModel:(PasswordNoteModel *)model;

/** 查询数据,如果 传空 默认会查询表中所有数据 */
//+ (NSArray *)queryData:(NSString *)querySql;

/** 删除数据,如果 传空 默认会删除表中所有数据 */
//+ (BOOL)deleteData:(NSString *)deleteSql;

/** 修改数据 */
//+ (BOOL)modifyData:(NSString *)modifySql;

@end
