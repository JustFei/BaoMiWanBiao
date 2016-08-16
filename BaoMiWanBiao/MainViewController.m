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

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/**
 *  左划进入列表ViewController
 *  备忘：还没有做约束
 */
- (IBAction)listAction:(UIButton *)sender {
}

/**
 *  搜索腕表界面
 *
 */
- (IBAction)searchWatch:(UIButton *)sender {
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
}

/**
 *  文件夹
 *
 */
- (IBAction)file:(UIButton *)sender {
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
