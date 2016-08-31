//
//  MainViewController.m
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/8/16.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "MainViewController.h"
#import "MiBaoXiangViewController.h"
#import "MiMaBenViewController.h"
#import "MotionStatusViewController.h"
#import "SleepStatusViewController.h"
#import "ClockViewController.h"
#import "FolderViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //navigationbar左右按钮的配置
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"list"] style:UIBarButtonItemStylePlain target:self action:@selector(listAction)];
    self.navigationItem.leftBarButtonItem = leftButton;
    
    UIBarButtonItem *rightButton1 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search"] style:UIBarButtonItemStylePlain target:self action:nil];
    rightButton1.enabled = NO;
    UIBarButtonItem *rightButton2 = [[UIBarButtonItem alloc] initWithTitle:@"搜索腕表" style:UIBarButtonItemStylePlain target:self action:@selector(searchWatchAction)];
    self.navigationItem.rightBarButtonItems = @[rightButton2,rightButton1];
    
    //使用系统自带的返回手势（需要从最左边开始滑动）
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/**
 *  左划进入列表ViewController
 *
 */
- (void)listAction
{
    
}

/**
 *  搜索腕表按钮
 */
- (void)searchWatchAction
{
    
}

/**
 *  密保箱
 *
 */
- (IBAction)secretBox:(UIButton *)sender {
    
    MiBaoXiangViewController *vc = [[MiBaoXiangViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

/**
 *  密码本
 *
 */
- (IBAction)sexretText:(id)sender {
    
    MiMaBenViewController *vc = [[MiMaBenViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

/**
 *  运动状态
 *
 */
- (IBAction)motionStatus:(UIButton *)sender {
    
    MotionStatusViewController *vc = [[MotionStatusViewController alloc] initWithNibName:@"MotionStatusViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

/**
 *  睡眠状态
 *
 */
- (IBAction)sleepStatus:(UIButton *)sender {
    
    SleepStatusViewController *vc = [[SleepStatusViewController alloc] initWithNibName:@"SleepStatusViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

/**
 *  智能闹钟
 *
 */
- (IBAction)smartAclock:(UIButton *)sender {
    
    ClockViewController *vc = [[ClockViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

/**
 *  文件夹
 *
 */
- (IBAction)file:(UIButton *)sender {
    
    FolderViewController *vc = [[FolderViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
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
