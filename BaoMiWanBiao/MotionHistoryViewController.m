//
//  MotionHistoryViewController.m
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/8/3.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "MotionHistoryViewController.h"
#import "JBBarChartView.h"
#import "JBBarChartFooterView.h"

// Numerics
CGFloat const kJBBarChartViewControllerChartHeight = 250.0f;
CGFloat const kJBBarChartViewControllerChartPadding = 10.0f;
CGFloat const kJBBarChartViewControllerChartHeaderHeight = 80.0f;
CGFloat const kJBBarChartViewControllerChartHeaderPadding = 20.0f;
CGFloat const kJBBarChartViewControllerChartFooterHeight = 25.0f;
CGFloat const kJBBarChartViewControllerChartFooterPadding = 5.0f;
CGFloat const kJBBarChartViewControllerBarPadding = 1.0f;

@interface MotionHistoryViewController () <UIScrollViewDelegate , JBBarChartViewDelegate , JBBarChartViewDataSource>

/**
 *  日期文本
 */
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

/**
 *  每日平均步数
 */
@property (weak, nonatomic) IBOutlet UILabel *averageStep;

/**
 *  柱状图最底层的View
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

/**
 *  柱状图底部的scrollView
 */
@property (weak, nonatomic) UIScrollView *barScrollView;

@property (nonatomic, strong) NSArray *chartData;
@property (nonatomic, strong) NSArray *monthlySymbols;

// Buttons
- (void)chartToggleButtonPressed:(id)sender;

@end

@implementation MotionHistoryViewController

#pragma mark - Alloc/Init

- (id)init
{
    self = [super init];
    if (self)
    {
        [self initFakeData];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self initFakeData];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self initFakeData];
    }
    return self;
}

- (void)dealloc
{
    self.jbBarView.delegate = nil;
    self.jbBarView.dataSource = nil;
}

#pragma mark - Date
//将数据在这里处理
- (void)initFakeData
{
    //柱状图item的数据内容 -- _charData
    NSMutableArray *mutableChartData = [NSMutableArray array];
    for (int i=0; i<31; i++)
    {
        //NSInteger delta = (kJBBarChartViewControllerNumBars - labs((kJBBarChartViewControllerNumBars - i) - i)) + 2;
        int value = (arc4random() % 20) + 1;
        [mutableChartData addObject:[NSNumber numberWithInt:value]];
        
    }
    self.chartData = [NSArray arrayWithArray:mutableChartData];
    self.monthlySymbols = [[[NSDateFormatter alloc] init] shortMonthSymbols];
}

#pragma mark - 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.barScrollView.contentSize = CGSizeMake(4 * self.view.frame.size.width , 0);
    self.jbBarView.backgroundColor = [UIColor yellowColor];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //柱状图是否显性
    [self.jbBarView setState:JBChartViewStateExpanded];
}

#pragma mark - JBBarChartViewDelegate && JBBarChartViewDataSource

#pragma mark -JBBarChartViewDelegate
/**
 *  设置每个柱的高度
 *
 *  @param barChartView 柱状图View
 *  @param index        索引
 *
 *  @return 高度
 */
- (CGFloat)barChartView:(JBBarChartView *)barChartView heightForBarViewAtIndex:(NSUInteger)index
{
    return [[self.chartData objectAtIndex:index] floatValue];
}

//设置每个item的颜色
- (UIColor *)barChartView:(JBBarChartView *)barChartView colorForBarViewAtIndex:(NSUInteger)index
{
    return (index % 2 == 0) ? [UIColor blueColor] : [UIColor greenColor];
}

//选中的时候，被选中的item的颜色变化 -- 这里的白色，但是实际是渐变的白色
- (UIColor *)barSelectionColorForBarChartView:(JBBarChartView *)barChartView
{
    return [UIColor whiteColor];
}

//每个item之间的距离
- (CGFloat)barPaddingForBarChartView:(JBBarChartView *)barChartView
{
    //    return kJBBarChartViewControllerBarPadding;
    return 30.0f;
}

#pragma mark -JBBarChartViewDataSource
/**
 *  设置柱状图有多少个柱
 *
 *  @param barChartView 柱状图View
 *
 *  @return 柱数
 */
- (NSUInteger)numberOfBarsInBarChartView:(JBBarChartView *)barChartView
{
    return self.chartData.count;
}

//选中其中一个item时走的方法
- (void)barChartView:(JBBarChartView *)barChartView didSelectBarAtIndex:(NSUInteger)index touchPoint:(CGPoint)touchPoint
{
    NSNumber *valueNumber = [self.chartData objectAtIndex:index];
    //[self.informationView setValueText:[NSString stringWithFormat:kJBStringLabelDegreesFahrenheit, [valueNumber intValue], kJBStringLabelDegreeSymbol] unitText:nil];
    self.stepsNum.text = [NSString stringWithFormat:@"%d",[valueNumber intValue]];
    self.mileageNum.text = [NSString stringWithFormat:@"%d",[valueNumber intValue]];
    self.kcalNum.text = [NSString stringWithFormat:@"%d",[valueNumber intValue]];
    //[self.informationView setTitleText:kJBStringLabelWorldwideAverage];
    //[self.informationView setHidden:NO animated:YES];
    
    //tooltipView 就是柱状图上方的提示栏，写着月份
//    [self setTooltipVisible:YES animated:YES atTouchPoint:touchPoint];
//    [self.tooltipView setText:[[self.monthlySymbols objectAtIndex:index] uppercaseString]];
}

//#pragma mark - UIScrollViewDelegate

#pragma mark - 懒加载
- (JBBarChartView *)jbBarView
{
    if (!_jbBarView) {
        JBBarChartView *view = [[JBBarChartView alloc] initWithFrame:CGRectMake(0, 0, self.barScrollView.contentSize.width, self.barChart.frame.size.height)];
        
        view.delegate = self;
        view.dataSource = self;

        //设置
        view.headerPadding = 20.f;
        view.minimumValue = 0.0f;
        
        //设置NO为视图为从上至下
        view.inverted = NO;
        view.backgroundColor = [UIColor blueColor];
        
        //设置柱状图底部的标注 “1月-12月”
        JBBarChartFooterView *footerView = [[JBBarChartFooterView alloc] initWithFrame:CGRectMake(kJBBarChartViewControllerChartPadding, ceil(self.view.bounds.size.height * 0.5) - ceil(kJBBarChartViewControllerChartFooterHeight * 0.5), self.view.bounds.size.width - (kJBBarChartViewControllerChartPadding * 2), kJBBarChartViewControllerChartFooterHeight)];
        footerView.padding = 5.0f;
        footerView.leftLabel.text = [[self.monthlySymbols firstObject] uppercaseString];
        footerView.leftLabel.textColor = [UIColor whiteColor];
        footerView.rightLabel.text = [[self.monthlySymbols lastObject] uppercaseString];
        footerView.rightLabel.textColor = [UIColor whiteColor];
        view.footerView = footerView;
        
        [self.barScrollView addSubview:view];
        _jbBarView = view;
        
        [_jbBarView reloadData];
    }
    
    return _jbBarView;
}

- (UIScrollView *)barScrollView
{
    if (!_barScrollView) {
        UIScrollView *view = [[UIScrollView alloc] initWithFrame:self.barChart.bounds];
        
        view.delegate = self;
        view.pagingEnabled = NO;
        view.bounces = NO;
        view.backgroundColor = [UIColor redColor];
        
        [self.barChart addSubview:view];
        _barScrollView = view;
    }
    
    return _barScrollView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Buttons

- (void)chartToggleButtonPressed:(id)sender
{
    UIView *buttonImageView = [self.navigationItem.rightBarButtonItem valueForKey:@"view"];
    buttonImageView.userInteractionEnabled = NO;
    
    //点击改变按钮的状态，以及将按钮旋转
    CGAffineTransform transform = self.jbBarView.state == JBChartViewStateExpanded ? CGAffineTransformMakeRotation(M_PI) : CGAffineTransformMakeRotation(0);
    buttonImageView.transform = transform;
    
    [self.jbBarView setState:self.jbBarView.state == JBChartViewStateExpanded ? JBChartViewStateCollapsed : JBChartViewStateExpanded animated:YES callback:^{
        buttonImageView.userInteractionEnabled = YES;
    }];
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
