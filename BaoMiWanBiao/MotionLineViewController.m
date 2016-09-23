//
//  MotionLineViewController.m
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/8/1.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "MotionLineViewController.h"
#import <MapKit/MapKit.h>
#import "BLETool.h"
#import "MotionFmdbTool.h"
#import "AnalysisProcotolTool.h"
#import "WGS84TOGJ02.h"
#import "GPSDayGroupModel.h"

@interface MotionLineViewController () <MKMapViewDelegate, BleReceiveDelegate, UITableViewDelegate, UITableViewDataSource>
{
    CLLocationCoordinate2D _point[2];
    CLLocationCoordinate2D _pointStart;
    CLLocationCoordinate2D _pointEnd;
    BOOL showList;//是否弹出下拉列表
}
/**
 *  地图视图
 */
//@property (nonatomic, weak) MKMapView *;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;


/**
 *  划线
 */
@property (nonatomic, strong) MKPolyline *myPolyline;

/** 位置数组 */
@property (nonatomic, strong) NSMutableArray *locationArrayM;

@property (nonatomic, strong) BLETool *mybleTool;

@property (nonatomic, strong) MotionFmdbTool *myFmTool;

@property (nonatomic, strong) NSArray *currentLocationArr;

@property (nonatomic, strong) UIButton *switchHistoryButton;

@property (weak, nonatomic) IBOutlet UILabel *currentMotionLineLabel;

@property (weak, nonatomic) IBOutlet UIButton *beforeButton;

@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@property (nonatomic ,weak) UITableView *timeTableView;

@property (nonatomic ,strong) NSDate *senddate;
@property (nonatomic ,copy) NSString *currentDateStr;

@end

@implementation MotionLineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createUI];
    
    self.mybleTool = [BLETool shareInstance];
    self.mybleTool.receiveDelegate = self;
    // 设置代理
    self.mapView.delegate = self;
    
    //获取历史数据，应该放在连接刚开始的时候
    [self.mybleTool writeGPSToPeripheral];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    self.currentMotionLineLabel.text = @"今天";
    self.nextButton.enabled = NO;
    showList = NO; //默认不显示下拉框
}

- (void)createUI
{
    self.switchHistoryButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 30)];
    self.switchHistoryButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.switchHistoryButton setTitle:@"查看历史" forState:UIControlStateNormal];
    [self.switchHistoryButton setTitle:@"查看当前" forState:UIControlStateSelected];
    [self.switchHistoryButton setTintColor:[UIColor whiteColor]];
    [self.switchHistoryButton addTarget:self action:@selector(switchHistory:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.switchHistoryButton];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:self.switchHistoryButton];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    //经纬度
    CLLocationCoordinate2D coordinate2D = {[AnalysisProcotolTool shareInstance].staticLat, [AnalysisProcotolTool shareInstance].staticLon};
    _pointStart = coordinate2D;
    
    //比例尺,比例值越小越精确
    MKCoordinateSpan span = {0.01, 0.01};
    //范围
    MKCoordinateRegion region = {coordinate2D, span};
    
    //设置范围
    [self.mapView setRegion:region animated:YES];
    
    //标注自身位置
    [self.mapView setShowsUserLocation:YES];
    
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dropdown)];
    [self.currentMotionLineLabel setUserInteractionEnabled:YES];
    [self.currentMotionLineLabel addGestureRecognizer:tapGes];
}

- (void)getDataFromDBWithTime:(NSString *)dateTime
{
    NSString *time = [dateTime substringFromIndex:5];
    time = [time stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
    DeBugLog(@"查询时间%@",time);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSDate *date = [NSDate date];
//        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//        [formatter setDateFormat:@"MM/dd"];
//        NSString *time = [formatter stringFromDate:date];
        
        self.currentLocationArr = [self.myFmTool queryGPSDataWithDayTime:time];
        DeBugLog(@"%@",self.currentLocationArr);
        [self.timeTableView reloadData];
    });
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.currentLocationArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"motionlinecell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"motionlinecell"];
    }
    
    GPSDayGroupModel *model = self.currentLocationArr[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@-%@",model.startTime ,model.endTime];
    
    return cell;
}

#pragma mark - 点击事件
//切换历史|当前
- (void)switchHistory:(UIButton *)sender
{
    if (!sender.selected) {
        //载入历史数据
        [sender setSelected:YES];
        DeBugLog(@"切换到历史数据");
    }else {
        //载入当前数据
        [sender setSelected:NO];
        DeBugLog(@"切换到当前数据");
    }
}

//前一段数据
- (IBAction)beforeAction:(UIButton *)sender
{
    self.senddate = [NSDate dateWithTimeInterval:-24*60*60 sinceDate:self.senddate];//前一天
    self.currentMotionLineLabel.text = [self setDateLabelText];
    self.nextButton.enabled = YES;
    
    [self getDataFromDBWithTime:self.currentMotionLineLabel.text];
}


//后一段数据
- (IBAction)nextAction:(UIButton *)sender
{
    self.senddate = [NSDate dateWithTimeInterval:24*60*60 sinceDate:self.senddate];//后一天
    NSString *currentDayStr = [self setDateLabelText];
    
    if ([currentDayStr isEqualToString:self.currentDateStr]) {
        self.nextButton.enabled = NO;
        self.currentMotionLineLabel.text = @"今天";
    }else {
        self.currentMotionLineLabel.text = currentDayStr;
    }
    
    [self getDataFromDBWithTime:currentDayStr];
}

/**
 *  获取当前日期
 */
- (NSString *)setDateLabelText
{
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    
    [dateformatter setDateFormat:@"YYYY-MM-dd"];
    
    NSString *  locationString=[dateformatter stringFromDate:self.senddate];
    
    DeBugLog(@"locationString:%@",locationString);
    
    return locationString;
}

-(void)dropdown{
    //    [textField resignFirstResponder];
    if (showList) {//如果下拉框已显示，什么都不做
        CGRect sf = self.timeTableView.frame;
        
        //把dropdownList放到前面，防止下拉框被别的控件遮住
        [self.view bringSubviewToFront:self.timeTableView];
        
        showList = NO;//显示下拉框
        self.timeTableView.frame = sf;
        [UIView beginAnimations:@"ResizeForKeyBoard1" context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        sf.size.height = 0;
        self.timeTableView.frame = sf;
        
        [UIView commitAnimations];
        //        self.questionTableView.hidden = YES;
        
    }else {//如果下拉框尚未显示，则进行显示
        
        CGRect sf = self.timeTableView.frame;
        
        //把dropdownList放到前面，防止下拉框被别的控件遮住
        [self.view bringSubviewToFront:self.timeTableView];
        self.timeTableView.hidden = NO;
        showList = YES;//显示下拉框
        self.timeTableView.frame = sf;
        [UIView beginAnimations:@"ResizeForKeyBoard" context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        sf.size.height = 200;
        self.timeTableView.frame = sf;
        
        [UIView commitAnimations];
    }
}


- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    MKPolylineRenderer *renderer;
    
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
        
        renderer.strokeColor = [UIColor redColor];
        renderer.lineWidth = 5;
    }
    
    return renderer;
}



#pragma mark - BleReceiveDelegate
- (void)receiveGPSWithModel:(manridyModel *)manridyModel
{
    if (manridyModel.isReciveDataRight == ResponsEcorrectnessDataRgith) {
       if (manridyModel.receiveDataType == ReturnModelTypeGPSCurrentModel) {
//            [self.myFmTool insertGPSModel:manridyModel.gpsDailyModel];
           
            if (_pointStart.longitude && _pointStart.latitude) {
                _pointEnd = CLLocationCoordinate2DMake(manridyModel.gpsDailyModel.lat, manridyModel.gpsDailyModel.lon);
                
                CLLocation *start = [[CLLocation alloc] initWithLatitude:_pointStart.latitude longitude:_pointStart.longitude];
                CLLocation *end = [[CLLocation alloc] initWithLatitude:_pointEnd.latitude longitude:_pointEnd.longitude];
                
                //把真实坐标加密
                if (![WGS84TOGJ02 outOfChina:start])
                {
                    //转换火星坐标
                    start = [WGS84TOGJ02 transformToMars:start];
                }
                
                //把真实坐标加密
                if (![WGS84TOGJ02 outOfChina:end])
                {
                    //转换火星坐标
                    end = [WGS84TOGJ02 transformToMars:end];
                }
                
                _point[0] = start.coordinate;
                _point[1] = end.coordinate;
                
                self.myPolyline = [MKPolyline polylineWithCoordinates:_point count:2];
                [self.mapView addOverlay:self.myPolyline];
                
                //比例尺,比例值越小越精确
                MKCoordinateSpan span = {0.0005, 0.0005};
                //范围
                MKCoordinateRegion region = {end.coordinate, span};
                //设置范围
                [self.mapView setRegion:region animated:YES];
                
                //标注自身位置
                [self.mapView setShowsUserLocation:NO];
                
                
                _pointStart = _pointEnd;
            }else {
                
                _pointStart = CLLocationCoordinate2DMake(manridyModel.gpsDailyModel.lat, manridyModel.gpsDailyModel.lon);
            }
        }
    }
}


#pragma mark - 懒加载
- (UITableView *)timeTableView
{
    if (!_timeTableView) {
        UITableView *view = [[UITableView alloc] initWithFrame:CGRectMake(0, self.mapView.frame.origin.y, self.view.frame.size.width, 0) style:UITableViewStylePlain];
        view.backgroundColor = [UIColor whiteColor];
        
        view.delegate = self;
        view.dataSource = self;
        
        [self.view addSubview:view];
        _timeTableView = view;
    }
    
    return _timeTableView;
}

- (MotionFmdbTool *)myFmTool
{
    if (!_myFmTool) {
        NSString *userPhone = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserName"];
        _myFmTool = [[MotionFmdbTool alloc] initWithPath:userPhone withSQLType:SQLTypeGPS];
    }
    
    return  _myFmTool;
}

//日期中转
- (NSDate *)senddate
{
    if (!_senddate) {
        NSDate *date = [NSDate date];
        
        _senddate = date;
    }
    
    return _senddate;
}

- (NSString *)currentDateStr
{
    if (!_currentDateStr) {
        NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
        [dateformatter setDateFormat:@"YYYY-MM-dd"];
        NSDate *currentDate = [NSDate date];
        _currentDateStr = [dateformatter stringFromDate:currentDate];
    }
    
    return _currentDateStr;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
