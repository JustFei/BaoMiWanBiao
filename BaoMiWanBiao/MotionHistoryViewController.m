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
#import "MotionFmdbTool.h"
#import "MotionDailyDataModel.h"

// Numerics
CGFloat const kJBBarChartViewControllerChartHeight = 250.0f;
CGFloat const kJBBarChartViewControllerChartPadding = 10.0f;
CGFloat const kJBBarChartViewControllerChartHeaderHeight = 80.0f;
CGFloat const kJBBarChartViewControllerChartHeaderPadding = 20.0f;
CGFloat const kJBBarChartViewControllerChartFooterHeight = 25.0f;
CGFloat const kJBBarChartViewControllerChartFooterPadding = 5.0f;
CGFloat const kJBBarChartViewControllerBarPadding = 1.0f;

@interface MotionHistoryViewController () <UIScrollViewDelegate , JBBarChartViewDelegate , JBBarChartViewDataSource>
{
    NSMutableArray *_stepArr ;
    NSMutableArray *_kCalArr ;
    NSMutableArray *_bpmArr ;
    NSMutableArray *_mileageArr ;
}
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
 *  柱状图底部的标签
 */
@property (weak, nonatomic) IBOutlet UIView *barViewFootView;
/**
 *  周一
 */
@property (weak, nonatomic) IBOutlet UILabel *monLabel;
/**
 *  周二
 */
@property (weak, nonatomic) IBOutlet UILabel *tuesLabel;
/**
 *  周三
 */
@property (weak, nonatomic) IBOutlet UILabel *wedLabel;
/**
 *  周四
 */
@property (weak, nonatomic) IBOutlet UILabel *thurLabel;
/**
 *  周五
 */
@property (weak, nonatomic) IBOutlet UILabel *friLabel;
/**
 *  周六
 */
@property (weak, nonatomic) IBOutlet UILabel *satLabel;
/**
 *  周天
 */
@property (weak, nonatomic) IBOutlet UILabel *sunLabel;
/**
 *  上一周按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *beforeWeekButton;
/**
 *  下一周按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *afterWeekButton;

/**
 *  柱状图数据源
 */
@property (strong, nonatomic) NSArray *chartData;
@property (strong, nonatomic) NSArray *monthlySymbols;

@property (strong, nonatomic) MotionFmdbTool *fmTool;

@property (strong, nonatomic) MotionDailyDataModel *motionModel;

@property (nonatomic, strong) NSDate *currentDate;


@end

@implementation MotionHistoryViewController

#pragma mark - Alloc/Init

- (id)init
{
    self = [super init];
    if (self)
    {
//        [self initFakeData];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
//        [self initFakeData];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
//        [self initFakeData];
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
    for (int i=0; i<7; i++)
    {
        //NSInteger delta = (kJBBarChartViewControllerNumBars - labs((kJBBarChartViewControllerNumBars - i) - i)) + 2;
        int value = (arc4random() % 20) + 1;
        [mutableChartData addObject:[NSNumber numberWithInt:value]];
        
    }
    self.chartData = [NSArray arrayWithArray:mutableChartData];
    self.monthlySymbols = [[[NSDateFormatter alloc] init] weekdaySymbols];
}

#pragma mark - 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationController.title = @"历史记录";
    
    //设置footView的边框和颜色
    self.barViewFootView.backgroundColor = [UIColor whiteColor];
    self.barViewFootView.layer.borderWidth = 1.0f;
    self.barViewFootView.layer.borderColor = [UIColor colorWithRed:213.0 / 255.0 green:215.0 / 255.0 blue:220.0 / 255.0 alpha:1].CGColor;

    /**
     *  获取当前周的日期
     */
    self.currentDate = [NSDate date];
    [self getWeekBeginAndEnd:self.currentDate];
    
    //关闭下一周按钮的可点击
    self.afterWeekButton.enabled = NO;

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //设置barView的边框和颜色
    self.barChart.layer.borderWidth = 1.0f;
    self.barChart.layer.borderColor = [UIColor colorWithRed:215.0 / 255.0 green:215.0 / 255.0 blue:218.0 / 255.0 alpha:1.0].CGColor;
    //柱状图是否显性
    [self.jbBarView setState:JBChartViewStateExpanded];
}

- (void)getWeekBeginAndEnd:(NSDate *)newDate
{
    //获取当前周的开始和结束日期
    int currentWeek = 0;
    NSTimeInterval appendDay = 24 * 60 * 60;
    NSTimeInterval secondsPerDay1 = 24 * 60 * 60 * (abs(currentWeek)*7);
    if (currentWeek > 0)
    {
        newDate = [newDate dateByAddingTimeInterval:+secondsPerDay1];//目标时间
    }else{
        newDate = [newDate dateByAddingTimeInterval:-secondsPerDay1];//目标时间
    }
    
    double interval = 0;
    NSDate *beginDate = nil;
    NSDate *endDate = nil;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setFirstWeekday:2];//设定周一为周首日
    BOOL ok = [calendar rangeOfUnit:NSWeekCalendarUnit startDate:&beginDate interval:&interval forDate:newDate];
    if (ok) {
        endDate = [beginDate dateByAddingTimeInterval:interval - 1];
    }else {
        return;
    }
    
    NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
    [myDateFormatter setDateFormat:@"yyyy/MM/dd"];
    
    //周一到周天的文本显示
    self.monLabel.text = [[myDateFormatter stringFromDate:beginDate] substringWithRange:NSMakeRange(5, 5)];
    self.tuesLabel.text = [[myDateFormatter stringFromDate:[beginDate dateByAddingTimeInterval:+appendDay]] substringWithRange:NSMakeRange(5, 5)];
    self.wedLabel.text = [[myDateFormatter stringFromDate:[beginDate dateByAddingTimeInterval:+ appendDay * 2]] substringWithRange:NSMakeRange(5, 5)];
    self.thurLabel.text = [[myDateFormatter stringFromDate:[beginDate dateByAddingTimeInterval:+ appendDay * 3]] substringWithRange:NSMakeRange(5, 5)];
    self.friLabel.text = [[myDateFormatter stringFromDate:[beginDate dateByAddingTimeInterval:+ appendDay * 4]] substringWithRange:NSMakeRange(5, 5)];
    self.satLabel.text = [[myDateFormatter stringFromDate:[beginDate dateByAddingTimeInterval:+appendDay * 5]] substringWithRange:NSMakeRange(5, 5)];
    self.sunLabel.text = [[myDateFormatter stringFromDate:endDate] substringWithRange:NSMakeRange(5, 5)];
    
    self.dateLabel.text = [self.monLabel.text stringByAppendingString:[NSString stringWithFormat:@"-%@",self.sunLabel.text]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
    
    NSArray *dateArr = @[[dateFormatter stringFromDate:beginDate],[dateFormatter stringFromDate:[beginDate dateByAddingTimeInterval:+appendDay]],[dateFormatter stringFromDate:[beginDate dateByAddingTimeInterval:+ appendDay * 2]],[dateFormatter stringFromDate:[beginDate dateByAddingTimeInterval:+ appendDay * 3]],[dateFormatter stringFromDate:[beginDate dateByAddingTimeInterval:+ appendDay * 4]],[dateFormatter stringFromDate:[beginDate dateByAddingTimeInterval:+ appendDay * 5]],[dateFormatter stringFromDate:endDate]];
    
    [self getWeekDataWith:dateArr];
    
}

#pragma mark - 数据库操作
#pragma mark -搜索操作
- (void)getWeekDataWith:(NSArray *)weekDateArr
{
    _stepArr = [NSMutableArray array];
    _kCalArr = [NSMutableArray array];
    _bpmArr = [NSMutableArray array];
    _mileageArr = [NSMutableArray array];
    
    for (NSString *dateStr in weekDateArr) {
        NSLog(@"%@",dateStr);//08/22(不符合我们存储的2016-08-22的日期格式，所以查询不到数据，此处做剪切)
        
        
            NSArray *dateArr = [self.fmTool queryDate:dateStr];
            
            NSLog(@"%ld",(unsigned long)dateArr.count);
            if (dateArr) {
                MotionDailyDataModel *model = dateArr.firstObject;
                
                //如果有数据就添加到数据源里面，没有数据就填充0
                if (model) {
                    [_stepArr addObject:model.step];
                    [_kCalArr addObject:model.kCal];
                    [_bpmArr addObject:model.bpm];
                    [_mileageArr addObject:model.mileage];
                }else {
                    [_stepArr addObject:@0];
                    [_kCalArr addObject:@0];
                    [_bpmArr addObject:@0];
                    [_mileageArr addObject:@0];
                }
            }else {
                NSLog(@"这天没有数据");
            }
        }
    NSLog(@"stepCount = %ld,kcalCount = %ld,bpmCount = %ld,mileageCount = %ld", (unsigned long)_stepArr.count, (unsigned long)_kCalArr.count, (unsigned long)_bpmArr.count,(unsigned long)_mileageArr.count);
//    self.chartData = _stepArr;
//    [self.jbBarView reloadDataAnimated:YES];
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
    return [[_stepArr objectAtIndex:index] floatValue];
}

//设置每个item的颜色
- (UIColor *)barChartView:(JBBarChartView *)barChartView colorForBarViewAtIndex:(NSUInteger)index
{
    if (index == 4) {
//        return [UIColor colorWithRed:212.0 / 255.0 green:233.0 / 255.0 blue:255.0 / 255.0 alpha:1];
    }
    
//    return [UIColor colorWithRed:78.0 / 255.0 green:140.0 / 255.0 blue:243.0 / 255.0 alpha:1];
    return [UIColor colorWithRed:212.0 / 255.0 green:233.0 / 255.0 blue:255.0 / 255.0 alpha:1];
}

//选中的时候，被选中的item的颜色变化 -- 这里的白色，但是实际是渐变的白色
- (UIColor *)barSelectionColorForBarChartView:(JBBarChartView *)barChartView
{
    return [UIColor colorWithRed:78.0 / 255.0 green:140.0 / 255.0 blue:243.0 / 255.0 alpha:1];
//    return [UIColor blackColor];
}

//每个item之间的距离
- (CGFloat)barPaddingForBarChartView:(JBBarChartView *)barChartView
{
    //    return kJBBarChartViewControllerBarPadding;
    return 31.0f;
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
    return _stepArr.count;
}

//选中其中一个item时走的方法
- (void)barChartView:(JBBarChartView *)barChartView didSelectBarAtIndex:(NSUInteger)index touchPoint:(CGPoint)touchPoint
{
    NSNumber *stepValue = [_stepArr objectAtIndex:index];
    NSNumber *mileageValue = [_mileageArr objectAtIndex:index];
    NSNumber *kcalValue = [_kCalArr objectAtIndex:index];
    
    self.stepsNum.text = [NSString stringWithFormat:@"%d",[stepValue intValue]];
    self.mileageNum.text = [NSString stringWithFormat:@"%d",[mileageValue intValue]];
    self.kcalNum.text = [NSString stringWithFormat:@"%d",[kcalValue intValue]];
}

//#pragma mark - UIScrollViewDelegate

#pragma mark - 懒加载
- (JBBarChartView *)jbBarView
{
    if (!_jbBarView) {
        JBBarChartView *view = [[JBBarChartView alloc] initWithFrame:CGRectMake(10, 0, [UIScreen mainScreen].bounds.size.width - 20, [UIScreen mainScreen].bounds.size.width * 227 / 320)];
        
        view.delegate = self;
        view.dataSource = self;

        //设置
        view.headerPadding = 20.f;
        view.minimumValue = 0.0f;
        
        //设置NO为视图为从上至下
        view.inverted = NO;
        view.backgroundColor = [UIColor whiteColor];
        
        [self.barChart addSubview:view];
        _jbBarView = view;
        
        [_jbBarView reloadData];
    }
    
    return _jbBarView;
}

- (MotionFmdbTool *)fmTool
{
    if (!_fmTool) {
        NSString *userPhone = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserName"];
        MotionFmdbTool *tool = [[MotionFmdbTool alloc] initWithPath:userPhone];
        
        _fmTool = tool;
    }
    
    return  _fmTool;
}

- (MotionDailyDataModel *)motionModel
{
    if (_motionModel) {
        MotionDailyDataModel *model = [[MotionDailyDataModel alloc] init];
        
        _motionModel = model;
    }
    
    return _motionModel;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 点击时间
- (IBAction)beforeButtonAction:(UIButton *)sender {
    
    self.afterWeekButton.enabled = YES;
    self.currentDate = [self.currentDate dateByAddingTimeInterval: - 7 * 24 * 60 * 60];
    
    //UI改变
    [self getWeekBeginAndEnd:self.currentDate];
    //刷新数据源
//    [self initFakeData];
    [self.jbBarView setState:JBChartViewStateCollapsed animated:YES callback:^{
        [self.jbBarView reloadData];
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.jbBarView setState:JBChartViewStateExpanded animated:YES];
    });
}

- (IBAction)afterButtonAction:(UIButton *)sender {
    
    self.currentDate = [self.currentDate dateByAddingTimeInterval: + 7 * 24 * 60 * 60];
    
    //判断currentDate是不是今天
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY/MM/dd"];
    NSString *currentDateString = [formatter stringFromDate:self.currentDate];
    
    if ([currentDateString isEqualToString:[formatter stringFromDate:[NSDate date]]]) {
        self.afterWeekButton.enabled = NO;
    }
    
    //UI改变
    [self getWeekBeginAndEnd:self.currentDate];
    //刷新数据源
    [self initFakeData];
    [self.jbBarView setState:JBChartViewStateCollapsed animated:YES callback:^{
        [self.jbBarView reloadData];
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.jbBarView setState:JBChartViewStateExpanded animated:YES];
    });
    
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
