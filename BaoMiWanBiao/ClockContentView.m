//
//  ClockContentView.m
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/8/23.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "ClockContentView.h"
#import "ClockTableViewCell.h"
#import "ClockModel.h"
#import "ClockFmdbTool.h"

@interface ClockContentView () <UITableViewDelegate,UITableViewDataSource,UIPickerViewDelegate,UIPickerViewDataSource>
{
    NSMutableArray *_hArr;
    NSMutableArray *_mArr;
    
    NSMutableArray *_clockDataSource;
    
}

@property (weak, nonatomic) UIImageView *headImageView;

@property (weak, nonatomic) UITableView *clockTableView;

@property (weak, nonatomic) UIView *timePickView;
@property (weak, nonatomic) UIPickerView *timePicker;

@property (strong, nonatomic) ClockFmdbTool *fmTool;

@property (strong, nonatomic) ClockModel *clockModel;

@end

@implementation ClockContentView

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    //小时和分钟选择器上的数字
    _hArr = [NSMutableArray array];
    _mArr = [NSMutableArray array];
    for (NSInteger h = 0; h < 24; h ++) {
        [_hArr addObject:[NSString stringWithFormat:@"%02ld",h]];
    }
    for (NSInteger m = 0; m < 60; m ++) {
        [_mArr addObject:[NSString stringWithFormat:@"%02ld",m]];
    }
    
    self.headImageView.frame = CGRectMake(self.center.x - 52.5, 131, 105, 105);
    self.headImageView.image = [UIImage imageNamed:@"clock"];
    
    self.clockTableView.frame = CGRectMake(0, 294, self.frame.size.width, self.frame.size.height - 230);
    self.clockTableView.backgroundColor = [UIColor whiteColor];
    
    self.timePickView.frame = CGRectMake(0, self.frame.size.height , self.frame.size.width, 235);
    self.timePicker.frame = CGRectMake(0, 30, self.frame.size.width, self.timePickView.frame.size.height - 30);
    
     _clockDataSource = [NSMutableArray arrayWithArray:[self.fmTool queryData]];
    if (_clockDataSource.count >=3) {
        self.closeAddBlck();
    }
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _clockDataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ClockTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"clockcell"];
    ClockModel *model = _clockDataSource[indexPath.row];
    cell.clockTime.text = model.time;
    [cell.clockButton setSelected:model.isOpen];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ClockTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    NSString *timeStr = cell.clockTime.text;
    NSInteger hInt = [[timeStr substringToIndex:2] integerValue];
    NSInteger mInt = [[timeStr substringFromIndex:3] integerValue];
    
    [self presentTimePickerWithHInt:hInt MInt:mInt];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle ==UITableViewCellEditingStyleDelete) {//如果编辑样式为删除样式
        
        if (indexPath.row<[_clockDataSource count]) {
            
            
            ClockModel *model = _clockDataSource[indexPath.row];
            [self.fmTool deleteData:model.time];
            NSLog(@"%@",model.time);
            
            [_clockDataSource removeObjectAtIndex:indexPath.row];//移除数据源的数据
            
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];//移除tableView中的数据
        }
    }
}

#pragma mark - UIPickerViewDelegate && UIPickerViewDataSource
//返回选择器的列数
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0) {
        return _hArr.count;
    }
    return _mArr.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component == 0) {
        return _hArr[row];
    }
    return _mArr[row];
}

#pragma mark - 点击事件
//取消按钮
- (void)cancelEditClockPicker
{
    [UIView animateWithDuration:0.5 animations:^{
        self.timePickView.frame = CGRectMake(0, self.frame.size.height , self.frame.size.width, 235);
    }];
}

//保存按钮,将闹钟的数据保存到数据库
- (void)saveEditClockPicker
{
    NSInteger hrow = [self.timePicker selectedRowInComponent:0];
    NSString *hValue = _hArr[hrow];
    
    NSInteger mrow = [self.timePicker selectedRowInComponent:1];
    NSString *mValue = _mArr[mrow];
    
    NSString *timeStr = [NSString stringWithFormat:@"%@:%@",hValue,mValue];
    
    self.clockModel.time = timeStr;
    self.clockModel.isOpen = YES;
    [self.fmTool insertModel:self.clockModel];
    
    _clockDataSource = [NSMutableArray arrayWithArray:[self.fmTool queryData]];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.timePickView.frame = CGRectMake(0, self.frame.size.height , self.frame.size.width, 235);
        [self.clockTableView reloadData];
    }];
    
}

#pragma mark - 懒加载
- (UIImageView *)headImageView
{
    if (!_headImageView) {
        UIImageView *view = [[UIImageView alloc] init];
        
        [self addSubview:view];
        _headImageView = view;
    }
    
    return _headImageView;
}

- (UITableView *)clockTableView
{
    if (!_clockTableView) {
        UITableView *tbview = [[UITableView alloc] init];
        tbview.alwaysBounceVertical = NO;
        
        tbview.delegate = self;
        tbview.dataSource = self;
        
        [tbview registerNib:[UINib nibWithNibName:@"ClockTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"clockcell"];
        
        [self addSubview:tbview];
        _clockTableView = tbview;
    }
    
    return _clockTableView;
}

- (UIPickerView *)timePicker
{
    if (!_timePicker) {
        UIPickerView *pView = [[UIPickerView alloc] init];
        
        pView.delegate =self;
        pView.dataSource = self;
        
        [self.timePickView addSubview:pView];
        _timePicker = pView;
    }
    
    return _timePicker;
}

- (UIView *)timePickView
{
    if (!_timePickView) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor grayColor];
        
        //取消按钮配置
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelButton.frame = CGRectMake(10, 0, 80, 30);
        [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [cancelButton setTitleColor:UIColorFromRGBWithAlpha(0x2c91f4, 1) forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(cancelEditClockPicker) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:cancelButton];
        
        UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        saveButton.frame = CGRectMake(self.frame.size.width - 90, 0, 80, 30);
        [saveButton setTitle:@"保存" forState:UIControlStateNormal];
        [saveButton setTitleColor:UIColorFromRGBWithAlpha(0x2c91f4, 1) forState:UIControlStateNormal];
        [saveButton addTarget:self action:@selector(saveEditClockPicker) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:saveButton];
        
        [self addSubview:view];
        _timePickView = view;
    }
    
    return _timePickView;
}

- (ClockFmdbTool *)fmTool
{
    if (!_fmTool) {
        ClockFmdbTool *tool = [[ClockFmdbTool alloc] initWithPath:@"xxf"];
        
        _fmTool = tool;
    }
    
    return _fmTool;
}

//运动数据模型
- (ClockModel *)clockModel
{
    if (!_clockModel) {
        _clockModel = [[ClockModel alloc] init];
    }
    
    return _clockModel;
}

#pragma mark - 公用方法
- (void)presentTimePickerWithHInt:(NSInteger )hInt MInt:(NSInteger )mInt
{
    [self.timePicker selectRow:hInt inComponent:0 animated:NO];
    [self.timePicker selectRow:mInt inComponent:1 animated:NO];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.timePickView.frame = CGRectMake(0, self.frame.size.height - 235, self.frame.size.width, 235);
    }];
}

@end
