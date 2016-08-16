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

@interface MotionStatusViewController ()

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

@property (nonatomic ,strong) NSDate *  senddate;

@end

@implementation MotionStatusViewController

- (void)viewDidLoad {
    self.navigationItem.title = @"运动状态";
    self.navigationController.navigationBar.backgroundColor = [UIColor colorWithRed:78.0 / 255.0 green:140.0 / 255.0 blue:243.0 / 255.0 alpha:1];
    
    //右侧运动轨迹按键设置
    UIBarButtonItem *rightLineItem = [[UIBarButtonItem alloc] initWithTitle:@"运动轨迹" style:UIBarButtonItemStylePlain target:self action:@selector(pushToLineVC)];
    self.navigationItem.rightBarButtonItem = rightLineItem;
    
    //左侧返回按键设置
    UIBarButtonItem *leftBackItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
    self.navigationItem.leftBarButtonItem = leftBackItem;
    
    NSString *date = [self setDateLabelText];
    self.dateLabel.text = date;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
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
#warning 没有实现点击到今天的日期就无法再点击的效果
/**
 *  前一天按钮事件
 */
- (IBAction)beforeDayAction:(UIButton *)sender {
    
    self.senddate = [NSDate dateWithTimeInterval:-24*60*60 sinceDate:self.senddate];//前一天
    self.dateLabel.text = [self setDateLabelText];
}

/**
 *  后一天按钮事件
 */
- (IBAction)afterDayAction:(UIButton *)sender {
    
    if (self.senddate == [NSDate date]) {
        return;
    }
    self.senddate = [NSDate dateWithTimeInterval:26*60*60 sinceDate:self.senddate];//后一天
    self.dateLabel.text = [self setDateLabelText];
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

- (NSDate *)senddate
{
    if (!_senddate) {
        NSDate *date = [NSDate date];
        
        _senddate = date;
    }
    
    return _senddate;
}


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


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    
    self.senddate = nil;
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
