//
//  MiMaBenContentView.h
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/7/29.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XxfFmdbTool.h"

@interface MiMaBenContentView : UIView

/**
 *  tableView 数据源
 */
@property (nonatomic ,strong)NSMutableArray *mimaArr;

/**
 *  密码本的TableView
 */
@property (nonatomic ,weak)UITableView *mimabenTableView;

/**
 *  数据库操作工具
 */
@property (nonatomic ,strong)XxfFmdbTool *sqlTool;

@end
