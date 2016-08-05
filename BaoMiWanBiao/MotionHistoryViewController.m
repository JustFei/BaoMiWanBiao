//
//  MotionHistoryViewController.m
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/8/3.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "MotionHistoryViewController.h"
#import "JBBarChartView.h"

@interface MotionHistoryViewController ()

/**
 *  日期文本
 */
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

/**
 *  每日平均步数
 */
@property (weak, nonatomic) IBOutlet UILabel *averageStep;

/**
 *  柱状图
 */
@property (weak, nonatomic) IBOutlet UIView *barChart;

/**
 *  里程文本
 */
@property (weak, nonatomic) IBOutlet UILabel *mileageNum;

/**
 *  步数文本
 */
@property (weak, nonatomic) IBOutlet UILabel *stepsNum;

/**
 *  卡路里文本
 */
@property (weak, nonatomic) IBOutlet UILabel *kcalNum;

/**
 *  柱状图
 */
@property (weak, nonatomic) JBBarChartView *jbBarView;

@end

@implementation MotionHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    
}

- (JBBarChartView *)jbBarView
{
    if (!_jbBarView) {
        JBBarChartView *view = [[JBBarChartView alloc] initWithFrame:self.barChart.bounds];
        
        view.delegate = self;
        view.dataSource = self;
        
        view.headerPadding = 20.f;
        view.minimumValue = 0.0f;
        view.inverted = NO;
        view.backgroundColor = [UIColor blueColor];
        
        [self.barChart addSubview:view];
        _jbBarView = view;
    }
    
    return _jbBarView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
