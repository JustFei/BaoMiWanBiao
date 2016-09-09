//
//  MotionStatusViewController.m
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/8/1.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "MotionStatusViewController.h"
#import "MotionHistoryViewController.h"
#import "MotionLineViewController.h"
#import "MotionFmdbTool.h"
#import "MotionDailyDataModel.h"
#import "BabyBluetooth.h"
#import "CBPeripheralSingleton.h"

@interface MotionStatusViewController () <BleWriteDelegate>
{
    BabyBluetooth *baby;
}

@property (nonatomic ,strong) UIAlertAction *secureTextAlertAction;

/**
 *  日期文本
 */
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

/**
 *  今日步数
 */
@property (weak, nonatomic) IBOutlet UILabel *currentWalkNum;

/**
 *  目标步数
 */
@property (weak, nonatomic) IBOutlet UILabel *targetWalkNum;

/**
 *  设置目标步数按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *setTargetButton;

/**
 *  里程数文本
 */
@property (weak, nonatomic) IBOutlet UILabel *mileageNum;

/**
 *  卡路里数文本
 */
@property (weak, nonatomic) IBOutlet UILabel *kcalNum;

/**
 *  心率数文本
 */
@property (weak, nonatomic) IBOutlet UILabel *bpmNum;

/**
 *  前一天的按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *beforeButton;

/**
 *  后一天的按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *afterButton;

@property (nonatomic ,strong) NSDate *  senddate;

@property (nonatomic ,strong) MotionFmdbTool *fmTool;

@property (nonatomic ,strong) MotionDailyDataModel *MotionModel;

@property (nonatomic ,strong) CBPeripheralSingleton *peripheralSing;

@end

@implementation MotionStatusViewController

- (void)viewDidLoad {
    self.navigationItem.title = @"运动状态";
    
    [BLETool shareInstance].writeDelegate = self;
    
    //右侧运动轨迹按键设置
    UIBarButtonItem *rightLineItem = [[UIBarButtonItem alloc] initWithTitle:@"运动轨迹" style:UIBarButtonItemStylePlain target:self action:@selector(pushToLineVC)];
    self.navigationItem.rightBarButtonItem = rightLineItem;
    
    //左侧返回按键设置
    UIBarButtonItem *leftBackItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
    self.navigationItem.leftBarButtonItem = leftBackItem;
    
    self.dateLabel.text = @"今天";
    self.afterButton.enabled = NO;
    
    self.peripheralSing = [CBPeripheralSingleton sharePeripheral];
    
    NSLog(@"存储的\n连接设备 = %@\n write = %@\n notify = %@",self.peripheralSing.device.deviceName ,self.peripheralSing.device.writeCharacteristic.UUID ,self.peripheralSing.device.notifyCharacteristic.UUID);
    
    
    //如果当前有连接的设备，就寻找特征
    if (self.peripheralSing.device.peripheral) {
        //写入获取运动的信息
        [[BLETool shareInstance] writeDataToPeripheral:kSportString];
    }
    
    [self getDataFromDB];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    
    self.senddate = nil;
}

#pragma mark - BleWriteDelegate
- (void)receiveData:(NSData *)data
{
    if ([data bytes]!=nil) {
        const unsigned char *hexBytesLight = [data bytes];
        
        NSString *Str1 = [NSString stringWithFormat:@"%02x", hexBytesLight[0]];
        NSLog(@"标识符 = %@",Str1);
        
        //运动数据解析
        if ([Str1 isEqualToString:@"03"]) {
            NSData *stepData = [data subdataWithRange:NSMakeRange(2, 3)];
            int stepValue = [self parseIntFromData:stepData];
            NSLog(@"今日步数 = %d",stepValue);
            NSString *stepStr = [NSString stringWithFormat:@"%d",stepValue];
            self.currentWalkNum.text = stepStr;
            
            NSData *mileageData = [data subdataWithRange:NSMakeRange(5, 3)];
            int mileageValue = [self parseIntFromData:mileageData];
            NSLog(@"今日里程数 = %d",mileageValue);
            NSString *mileageStr = [NSString stringWithFormat:@"%d",mileageValue];
            self.mileageNum.text = mileageStr;
            
            NSData *kcalData = [data subdataWithRange:NSMakeRange(8, 3)];
            int kcalValue = [self parseIntFromData:kcalData];
            NSLog(@"卡路里 = %d",kcalValue);
            NSString *kCalStr = [NSString stringWithFormat:@"%d",kcalValue];
            self.kcalNum.text = kCalStr;
            
            self.MotionModel = [MotionDailyDataModel modelWith:self.dateLabel.text step:stepStr kCal:kCalStr mileage:mileageStr bpm:nil];
            
            
            [_fmTool insertModel:self.MotionModel];
            
        }
        
        if ([Str1 isEqualToString:@"0A"]) {
            
        }
    }
}

//NSString转换为NSdata，这样就省去了一个一个字节去写入
- (NSData *)hexToBytes:(NSString *)str
{
    NSMutableData* data = [NSMutableData data];
    int idx;
    for (idx = 0; idx+2 <= str.length; idx+=2) {
        NSRange range = NSMakeRange(idx, 2);
        NSString* hexStr = [str substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [data appendBytes:&intValue length:1];
    }
    return data;
}

//补充内容，因为没有三个字节转int的方法，这里补充一个通用方法,16进制转换成10进制
- (unsigned)parseIntFromData:(NSData *)data{
    
    NSString *dataDescription = [data description];
    NSString *dataAsString = [dataDescription substringWithRange:NSMakeRange(1, [dataDescription length]-2)];
    
    unsigned intData = 0;
    NSScanner *scanner = [NSScanner scannerWithString:dataAsString];
    [scanner scanHexInt:&intData];
    return intData;
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
    
    NSLog(@"todayString == %@",todayString);
    
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
    
    NSLog(@"locationString:%@",locationString);
    
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
    self.afterButton.enabled = YES;
    //数据数据库中查询
    [self searchFromDataBaseWithDate:self.dateLabel.text];

    //插入数据
#if 0
    NSString *step = [NSString stringWithFormat:@"%d",(arc4random() % 10000) + 5000];
    NSString *kCal = [NSString stringWithFormat:@"%d",(arc4random() % 1000) + 500];
    NSString *mileage = [NSString stringWithFormat:@"%d",(arc4random() % 5000) + 2500];
    NSString *bpm = [NSString stringWithFormat:@"%d",(arc4random() % 110) + 60];
    
    self.MotionModel = [MotionDailyDataModel modelWith:self.dateLabel.text step:step kCal:kCal mileage:mileage bpm:bpm];
    
    
    [_fmTool insertModel:self.MotionModel];
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
        self.afterButton.enabled = NO;
        self.dateLabel.text = @"今天";
    }else {
        self.dateLabel.text = currentDayStr;
    }
    
    //按照当天的日期来查询数据库
    [self searchFromDataBaseWithDate:currentDayStr];
}

/**
 *  设置目标步数按钮事件
 */
- (IBAction)setTargetAction:(UIButton *)sender {
    
    [self showSecureTextEntryAlert];
    
}

/**
 *  历史步数按钮事件
 */
- (IBAction)historyAction:(UIButton *)sender {
    
    MotionHistoryViewController *historyVC = [[MotionHistoryViewController alloc] initWithNibName:@"MotionHistoryViewController" bundle:nil];
    [self.navigationController pushViewController:historyVC animated:YES];
    
}

//推送到路线图界面
- (void)pushToLineVC
{
    MotionLineViewController *lineVC = [[MotionLineViewController alloc] init];
    [self.navigationController pushViewController:lineVC animated:YES];
}

//推出当前界面
- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 数据库操作
#pragma mark -搜索操作
- (void)searchFromDataBaseWithDate:(NSString *)dateStr
{
    NSArray *dateArr = [self.fmTool queryData:dateStr];
    
    NSLog(@"%ld",dateArr.count);
    if (dateArr.count != 0 ) {
        self.MotionModel = dateArr.firstObject;
        
        self.currentWalkNum.text = self.MotionModel.step;
        self.mileageNum.text = self.MotionModel.mileage;
        self.kcalNum.text = self.MotionModel.kCal;
        self.bpmNum.text = self.MotionModel.bpm;
    }else {
        NSLog(@"这天没有数据");
        self.currentWalkNum.text = @"0";
        self.mileageNum.text = @"0";
        self.kcalNum.text = @"0";
        self.bpmNum.text = @"0";
    }
}

#pragma mark - 目标输入框
/**
 *  推送出目标输入框
 */
- (void)showSecureTextEntryAlert {
    NSString *title = NSLocalizedString(@"请输入目标步数", nil);
    NSString *message = NSLocalizedString(@"每天适量步数，更益健康~", nil);
    NSString *cancelButtonTitle = NSLocalizedString(@"Cancel", nil);
    NSString *otherButtonTitle = NSLocalizedString(@"确定", nil);
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    // Add the text field for the secure text entry.
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        // Listen for changes to the text field's text so that we can toggle the current
        // action's enabled property based on whether the user has entered a sufficiently
        // secure entry.
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTextFieldTextDidChangeNotification:) name:UITextFieldTextDidChangeNotification object:textField];
        
        textField.keyboardType = UIKeyboardTypeNumberPad;
//        textField.secureTextEntry = YES;
    }];
    
    // Create the actions.
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        NSLog(@"The \"Secure Text Entry\" alert's cancel action occured.");
        
        // Stop listening for text changed notifications.
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:alertController.textFields.firstObject];
    }];
    
    //其他按钮事件-确定按钮事件
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:otherButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        self.targetWalkNum.text = alertController.textFields.firstObject.text;
        
        //退出编辑的两种方式，因为键盘退出有延迟，所以比较一下
        //endEdting有延迟
//        [alertController.textFields.firstObject endEditing:YES];
        
        [alertController.textFields.firstObject resignFirstResponder];
        
        // Stop listening for text changed notifications.
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:alertController.textFields.firstObject];
    }];
    
    // The text field initially has no text in the text field, so we'll disable it.
    otherAction.enabled = NO;
    
    // Hold onto the secure text alert action to toggle the enabled/disabled state when the text changed.
    self.secureTextAlertAction = otherAction;//定义一个全局变量来存储
    
    // Add the actions.
    [alertController addAction:cancelAction];
    [alertController addAction:otherAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)handleTextFieldTextDidChangeNotification:(NSNotification *)notification {
    UITextField *textField = notification.object;
    
    // Enforce a minimum length of >= 5 characters for secure text alerts.
    self.secureTextAlertAction.enabled = textField.text.length >= 1;
}

#pragma mark - 懒加载
//日期中转
- (NSDate *)senddate
{
    if (!_senddate) {
        NSDate *date = [NSDate date];
        
        _senddate = date;
    }
    
    return _senddate;
}

//数据库操作工具
- (MotionFmdbTool *)fmTool
{
    if (!_fmTool) {
        NSString *userPhone = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserName"];
        MotionFmdbTool *tool = [[MotionFmdbTool alloc] initWithPath:userPhone];
        
        _fmTool = tool;
    }
    
    return _fmTool;
}

//运动数据模型
- (MotionDailyDataModel *)MotionModel
{
    if (!_MotionModel) {
        _MotionModel = [[MotionDailyDataModel alloc] init];
    }
    
    return _MotionModel;
}

@end
