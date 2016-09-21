//
//  SleepStatusViewController.m
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/8/16.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "SleepStatusViewController.h"
#import "SleepHistoryViewController.h"
#import "SleepDailyDataModel.h"
#import "SleepFmdbTool.h"
#import "BLETool.h"
#import "manridyBleDevice.h"

@interface SleepStatusViewController () <BleReceiveDelegate>
/**
 *  前一天按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *beforeDayButton;

/**
 *  后一天按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *afterDayButton;

/**
 *  日期文本
 */
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

/**
 *  当前睡眠状态文本
 */
@property (weak, nonatomic) IBOutlet UILabel *sleepStatusLabel;

/**
 *  睡眠总时间文本
 */
@property (weak, nonatomic) IBOutlet UILabel *sleepTimeSumLabel;

/**
 *  深睡眠时间文本
 */
@property (weak, nonatomic) IBOutlet UILabel *fallSleepTimeLabel;

/**
 *  浅睡眠时间文本
 */
@property (weak, nonatomic) IBOutlet UILabel *shallowSleepTimeLabel;

@property (nonatomic ,strong) NSDate *  senddate;

@property (strong, nonatomic) SleepFmdbTool *fmTool;

@property (strong, nonatomic) SleepDailyDataModel *SleepModel;

@property (nonatomic ,strong) BLETool *mybleTool;

@property (nonatomic ,copy) NSString *currentDateStr;

@end

@implementation SleepStatusViewController

#pragma mark - 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mybleTool = [BLETool shareInstance];
    self.mybleTool.receiveDelegate = self;
    
    //navigationBar的设置
    self.navigationItem.title = @"睡眠状态";
    //左侧返回按键设置
    UIBarButtonItem *leftBackItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
    self.navigationItem.leftBarButtonItem = leftBackItem;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    //当天label的text设置
    self.afterDayButton.enabled = NO;
    self.dateLabel.text = @"今天";
    
    [self getDataFromDB];
    //如果当前有连接的设备，就寻找特征
    if (self.mybleTool.currentDev.peripheral) {
        //写入获取运动的信息
        [self.mybleTool writeSleepRequestToperipheral:SleepDataHistoryData];
    }
    
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"YYYY-MM-dd"];
    NSDate *currentDate = [NSDate date];
    self.currentDateStr = [dateformatter stringFromDate:currentDate];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    
    self.senddate = nil;
}

/**
 *  从数据库中获取数据，如果蓝牙处在非连接状态下，就从数据库获取数据
 */
- (void)getDataFromDB
{
    NSDate *todayDate = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    
    NSString *todayString = [formatter stringFromDate:todayDate];
    
    DeBugLog(@"todayString == %@",todayString);
    
    [self searchFromDataBaseWithDate:todayString];
}

/**
 *  获取当前日期
 */
- (NSString *)setDateLabelText
{
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    
    [dateformatter setDateFormat:@"YYYY-MM-dd"];
    
    NSString *  locationString=[dateformatter stringFromDate:self.senddate];
    
    DeBugLog(@"locationString:%@",locationString);
    
    return locationString;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 点击事件
/**
 *  前一天按钮事件
 */
- (IBAction)beforeDayAction:(UIButton *)sender {
    
    self.senddate = [NSDate dateWithTimeInterval:-24*60*60 sinceDate:self.senddate];//前一天
    self.dateLabel.text = [self setDateLabelText];
    self.afterDayButton.enabled = YES;
    //数据库查询
    [self searchFromDataBaseWithDate:self.dateLabel.text];
    
#if 0
    NSString *sumsleep = [NSString stringWithFormat:@"%02dh%02dmin",(arc4random() % 24) + 0 ,(arc4random() % 60) + 0];
    NSString *deepsleep = [NSString stringWithFormat:@"%02dh%02dmin",(arc4random() % 24) + 0 ,(arc4random() % 60) + 0];
    NSString *lowsleep = [NSString stringWithFormat:@"%02dh%02dmin",(arc4random() % 24) + 0 ,(arc4random() % 60) + 0];
    
    self.SleepModel = [SleepDailyDataModel modelWithDate:self.dateLabel.text sumSleepTime:sumsleep deepSleepTime:deepsleep lowSleepTime:lowsleep];
    
    
    [_fmTool insertModel:self.SleepModel];
#endif
}

/**
 *  后一天按钮事件
 */
- (IBAction)afterDayAction:(UIButton *)sender {
    
    self.senddate = [NSDate dateWithTimeInterval:24*60*60 sinceDate:self.senddate];//后一天
    NSString *currentDayStr = [self setDateLabelText];
    
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"YYYY-MM-dd"];
    NSDate *currentDate = [NSDate date];
    NSString *currentDateString = [dateformatter stringFromDate:currentDate];
    if ([currentDayStr isEqualToString:currentDateString]) {
        self.afterDayButton.enabled = NO;
        self.dateLabel.text = @"今天";
    }else {
        self.dateLabel.text = currentDayStr;
    }
    
    //按照当天的日期来查询数据库
    [self searchFromDataBaseWithDate:currentDayStr];
}


- (IBAction)historyAction:(UIButton *)sender {
    
    SleepHistoryViewController *vc = [[SleepHistoryViewController alloc] initWithNibName:@"SleepHistoryViewController" bundle:nil];
    
    [self.navigationController pushViewController:vc animated:YES];
}

//推出当前界面
- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - BleReceiveDelegate
- (void)receiveSleepInfoWithModel:(manridyModel *)manridyModel
{
    if (manridyModel.isReciveDataRight) {
        if (manridyModel.receiveDataType == ReturnModelTypeSleepModel) {
            
            if ([self.dateLabel.text isEqualToString:@"今天"]) {
                self.sleepTimeSumLabel.text = [NSString stringWithFormat:@"%d",(manridyModel.sleepModel.deepSleep.intValue + manridyModel.sleepModel.lowSleep.intValue)];
                self.fallSleepTimeLabel.text = manridyModel.sleepModel.deepSleep;
                self.shallowSleepTimeLabel.text = manridyModel.sleepModel.lowSleep;
                
                self.SleepModel = [SleepDailyDataModel modelWithDate:self.currentDateStr sumSleepTime:[NSString stringWithFormat:@"%d",(manridyModel.sleepModel.deepSleep.intValue + manridyModel.sleepModel.lowSleep.intValue)] deepSleepTime:manridyModel.sleepModel.deepSleep lowSleepTime:manridyModel.sleepModel.lowSleep];
                
                //查询数据库
                NSArray *dataArr = [self.fmTool queryDate:self.currentDateStr];
                if (dataArr.count == 0) {
                    //插入数据
                    [self.fmTool insertModel:self.SleepModel];
                }else {
                    [self.fmTool modifyData:self.currentDateStr model:self.SleepModel];
                }
            }
        }
    }
}

#pragma mark - 数据库操作
#pragma mark -搜索操作
- (void)searchFromDataBaseWithDate:(NSString *)dateStr
{
    NSArray *dateArr = [self.fmTool queryDate:dateStr];
    
    DeBugLog(@"%ld",(unsigned long)dateArr.count);
    if (dateArr.count != 0 ) {
        self.SleepModel = dateArr.firstObject;
        
        self.sleepTimeSumLabel.text = self.SleepModel.sumSleepTime;
        self.fallSleepTimeLabel.text = self.SleepModel.deepSleepTime;
        self.shallowSleepTimeLabel.text = self.SleepModel.lowSleepTime;
    }else {
        DeBugLog(@"这天没有数据");
        self.sleepTimeSumLabel.text = @"0";
        self.fallSleepTimeLabel.text = @"0";
        self.shallowSleepTimeLabel.text = @"0";
    }
}

#pragma mark - 懒加载
- (NSDate *)senddate
{
    if (!_senddate) {
        NSDate *date = [NSDate date];
        
        _senddate = date;
    }
    
    return _senddate;
}

//数据库操作工具
- (SleepFmdbTool *)fmTool
{
    if (!_fmTool) {
        NSString *userPhone = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserName"];
        SleepFmdbTool *tool = [[SleepFmdbTool alloc] initWithPath:userPhone];
        
        _fmTool = tool;
    }
    
    return _fmTool;
}

//运动数据模型
- (SleepDailyDataModel *)SleepModel
{
    if (!_SleepModel) {
        _SleepModel = [[SleepDailyDataModel alloc] init];
    }
    
    return _SleepModel;
}

@end
