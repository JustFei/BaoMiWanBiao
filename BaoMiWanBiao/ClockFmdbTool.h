//
//  ClockFmdbTool.h
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/8/23.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

@class ClockModel;
@interface ClockFmdbTool : NSObject

//插入模型数据
- (BOOL)insertModel:(ClockModel *)model;

/** 查询数据,如果 传空 默认会查询表中所有数据 */
- (NSArray *)queryData;

/** 删除数据,如果 传空 默认会删除表中所有数据 */
- (BOOL)deleteData:(NSInteger )deleteSql;

/** 修改数据 */
- (BOOL)modifyData:(NSInteger )modifySqlID model:(ClockModel *)modifySqlModel;

- (instancetype)initWithPath: (NSString *)path;

@end
