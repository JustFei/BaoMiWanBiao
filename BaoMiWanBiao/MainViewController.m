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
#import "BLEConnectViewController.h"
#import "BLETool.h"
#import "BLEConnectView.h"
#import "ListView.h"

@interface MainViewController ()
{
    BOOL showListView;
}
@property (nonatomic ,weak) ListView *listView;

@property (nonatomic ,weak) BLEConnectView *connectView;

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
//    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    __weak typeof(self) weakSelf = self;
    self.connectView.hiddenSelfCallBack = ^void {
        [weakSelf.connectView removeFromSuperview];
    };
    
    if ([BLETool shareInstance].connectState == kBLEstateDisConnected) {
        [self.view bringSubviewToFront:self.connectView];
    }else {
        [self.connectView removeFromSuperview];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 按钮点击事件
/**
 *  左划进入列表ViewController
 *
 */
- (void)listAction
{
    if (showListView) {
        [UIView animateWithDuration:0.2 animations:^{
            self.listView.frame = CGRectMake(0, 0, 200, self.view.frame.size.height);
        }];
        showListView = !showListView;
    }else {
        [UIView animateWithDuration:0.2 animations:^{
            self.listView.frame = CGRectMake(-200, 0, 200, self.view.frame.size.height);
        }];
        showListView = !showListView;
    }
    
}

/**
 *  搜索腕表按钮
 */
- (void)searchWatchAction
{
    BLEConnectViewController *vc = [[BLEConnectViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    [self.tabBarController setHidesBottomBarWhenPushed:YES];
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

#pragma mark - 懒加载
- (ListView *)listView
{
    if (!_listView) {
        ListView *view = [[ListView alloc] initWithFrame:CGRectMake(-200, 0, 200, self.view.frame.size.height)];
        view.backgroundColor = [UIColor redColor];
        
        [self.view addSubview:view];
        _listView = view;
    }
    
    return _listView;
}

- (BLEConnectView *)connectView
{
    if (!_connectView) {
        BLEConnectView *view = [[BLEConnectView alloc] initWithFrame:self.view.frame];
        view.backgroundColor = [UIColor whiteColor];
        
        [self.view addSubview:view];
        _connectView = view;
    }
    
    return _connectView;
}

@end
