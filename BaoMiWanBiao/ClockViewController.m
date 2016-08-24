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
    NSDate *nowDate = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    NSString *nowStr = [formatter stringFromDate:nowDate];

    NSInteger hInt = [[nowStr substringToIndex:2] integerValue];
    NSInteger mInt = [[nowStr substringFromIndex:3] integerValue];
    [self.clockView.clockTableView setAllowsSelection:NO];
    
    [self.clockView presentAddTimePickerWithHInt:hInt MInt:mInt];
}

#pragma mark - 懒加载
- (ClockContentView *)clockView
{
    if (!_clockView) {
        ClockContentView *view = [[ClockContentView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64)];
        view.closeAddBlock = ^void()
        {
            self.navigationItem.rightBarButtonItem.enabled = NO;
        };
        
        view.openAddBlock = ^void()
        {
            self.navigationItem.rightBarButtonItem.enabled = YES;
        };
        
        self.view = view;
        _clockView = view;
    }
    
    return _clockView;
}

@end
