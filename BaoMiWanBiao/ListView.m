//
//  ListView.m
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/9/2.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "ListView.h"

@interface ListView () <UITableViewDelegate, UITableViewDataSource>
{
    NSArray *_listArr;
}


@property (nonatomic ,weak) UITableView *listTableView;

@property (nonatomic ,weak) UIImageView *headImageView;

@end

@implementation ListView

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _listArr = @[@"个人信息",@"账户详情",@"我的腕表",@"版本查看"];
    
    self.headImageView.frame = CGRectMake(50, 50, 100, 100);
    self.headImageView.layer.cornerRadius = self.headImageView.frame.size.height / 2;
    
    self.listTableView.frame = CGRectMake(0, 200, self.frame.size.width, 200);
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _listArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"listCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (!cell) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    cell.textLabel.text = _listArr[indexPath.row];
    
    return cell;
}


#pragma mark - 懒加载
- (UIImageView *)headImageView
{
    if (!_headImageView) {
        UIImageView *view = [[UIImageView alloc] init];
        //设置用户头像的圆形
        view.backgroundColor = UIColorFromRGBWithAlpha(0x2c91F4, 1);
        
        [self addSubview:view];
        _headImageView = view;
    }
    
    return _headImageView;
}

- (UITableView *)listTableView
{
    if (!_listTableView) {
        UITableView *view = [[UITableView alloc] init];
        view.backgroundColor = [UIColor whiteColor];
        
        view.delegate = self;
        view.dataSource = self;
        
        [self addSubview:view];
        _listTableView = view;
    }
    
    return  _listTableView;
}

@end
