//
//  ClockViewController.m
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/8/23.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "ClockViewController.h"
#import "ClockContentView.h"

@interface ClockViewController ()

@property (weak, nonatomic) ClockContentView *clockView;

@end

@implementation ClockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"add"] style:UIBarButtonItemStylePlain target:self action:@selector(addClock)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    self.clockView.backgroundColor = [UIColor whiteColor];
//    self.navigationController.navigationBar.translucent = NO;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 点击事件
- (void)addClock
{
    [self.clockView presentTimePickerWithHInt:00 MInt:00];
}

#pragma mark - 懒加载
- (ClockContentView *)clockView
{
    if (!_clockView) {
        ClockContentView *view = [[ClockContentView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64)];
        view.closeAddBlck = ^void()
        {
            self.navigationItem.rightBarButtonItem.enabled = NO;
        };
        
        self.view = view;
        _clockView = view;
    }
    
    return _clockView;
}

@end
