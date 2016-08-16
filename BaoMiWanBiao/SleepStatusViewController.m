//
//  SleepStatusViewController.m
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/8/16.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "SleepStatusViewController.h"

@interface SleepStatusViewController ()
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

@end

@implementation SleepStatusViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //navigationBar的设置
    self.navigationItem.title = @"睡眠状态";
    self.navigationController.navigationBar.backgroundColor = [UIColor colorWithRed:78.0 / 255.0 green:140.0 / 255.0 blue:243.0 / 255.0 alpha:1];
    //左侧返回按键设置
    UIBarButtonItem *leftBackItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
    self.navigationItem.leftBarButtonItem = leftBackItem;
    
    //当天label的text设置
//    NSString *date = [self setDateLabelText];
    self.afterDayButton.enabled = NO;
    self.dateLabel.text = @"今天";
}

/**
 *  获取当前日期
 */
- (NSString *)setDateLabelText
{
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    
    [dateformatter setDateFormat:@"YYYY-MM-dd"];
    
    NSString *  locationString=[dateformatter stringFromDate:self.senddate];
    
    NSLog(@"locationString:%@",locationString);
    
    return locationString;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  前一天按钮事件
 */
- (IBAction)beforeDayAction:(UIButton *)sender {
    
    self.senddate = [NSDate dateWithTimeInterval:-24*60*60 sinceDate:self.senddate];//前一天
    self.dateLabel.text = [self setDateLabelText];
    self.afterDayButton.enabled = YES;
}

/**
 *  后一天按钮事件
 */
- (IBAction)afterDayAction:(UIButton *)sender {
    
    if (self.senddate == [NSDate date]) {
        return;
    }
    self.senddate = [NSDate dateWithTimeInterval:26*60*60 sinceDate:self.senddate];//后一天
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
}
- (IBAction)historyAction:(UIButton *)sender {
}

//推出当前界面
- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSDate *)senddate
{
    if (!_senddate) {
        NSDate *date = [NSDate date];
        
        _senddate = date;
    }
    
    return _senddate;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
