//
//  MiMaBenContentView.m
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/7/29.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "MiMaBenContentView.h"
#import "MiMaTableViewCell.h"
#import "AddMiMaViewController.h"
#import "AppDelegate.h"
#import "PasswordNoteMainModel.h"

@interface MiMaBenContentView ()<UITableViewDelegate, UITableViewDataSource >

/**
 *  底部tabbarView
 */
@property (nonatomic ,weak)UIView *tabbarView;

@end

@implementation MiMaBenContentView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.mimabenTableView.backgroundColor = [UIColor whiteColor];
        self.tabbarView.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

#pragma mark - UITableViewDetegate && UITableViewDataSource
- (NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  self.mimaArr.count;
}

- (NSInteger )numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MiMaTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mimacell"];
    
    PasswordNoteMainModel *model = self.mimaArr[indexPath.row];
    
    cell.appName.text = model.name;
    cell.isJiami.hidden = !model.isEncrypt;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

#pragma mark - 点击事件
//添加密码按钮的点击事件
- (void)addNewMima
{
    AddMiMaViewController *addMiMaVC = [[AddMiMaViewController alloc] init];
    
    //通过该方法获取到当前View的控制器
    UIViewController *VC = [self findViewController:self];
    [VC.navigationController pushViewController:addMiMaVC animated:YES];
}

#pragma mark - 懒加载
//密码本的tableView
- (UITableView *)mimabenTableView
{
    if (!_mimabenTableView) {
        UITableView *tbView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 50) style:UITableViewStylePlain];
        tbView.backgroundColor = [UIColor whiteColor];
        tbView.delegate = self;
        tbView.dataSource = self;
        
        [self addSubview:tbView];
        [tbView registerNib:[UINib nibWithNibName:@"MiMaTableViewCell" bundle:nil ] forCellReuseIdentifier:@"mimacell"];
        
        _mimabenTableView = tbView;
    }
    
    return _mimabenTableView;
}

//底部的tabbarView
- (UIView *)tabbarView
{
    if (!_tabbarView) {
        UIView *tabView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 50, self.frame.size.width, 50)];
        
        //设置添加密码账号按钮
        UIButton *newInfoButton = [[UIButton alloc] initWithFrame:CGRectMake(12, 9.5, self.frame.size.width - 24, 50 - 19)];
        [newInfoButton setTitle:@"记录新的密码账号" forState:UIControlStateNormal];
        [newInfoButton setTintColor:[UIColor whiteColor]];
        [newInfoButton setBackgroundColor:[UIColor colorWithRed:0 green:137.0 / 255.0 blue:252.0 / 255.0 alpha:1]];
        [newInfoButton addTarget:self action:@selector(addNewMima) forControlEvents:UIControlEventTouchUpInside];
        
        [tabView addSubview:newInfoButton];
        [self addSubview:tabView];
        _tabbarView = tabView;
    }
    
    return _tabbarView;
}

//显示密码项数据
- (NSMutableArray *)mimaArr
{
    if (!_mimaArr) {
        _mimaArr = [NSMutableArray array];
    }
    
    return _mimaArr;
}

- (XxfFmdbTool *)sqlTool
{
    if (!_sqlTool) {
        XxfFmdbTool *tool = [[XxfFmdbTool alloc] initWithPath:@"accountInfo.sqlite"];
        
        _sqlTool = tool;
    }
    
    return _sqlTool;
}

#pragma mark - 获取当前View的控制器的方法
- (UIViewController *)findViewController:(UIView *)sourceView
{
    id target=sourceView;
    while (target) {
        target = ((UIResponder *)target).nextResponder;
        if ([target isKindOfClass:[UIViewController class]]) {
            break;
        }
    }
    return target;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
