//
//  BLEConnectContentView.m
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/9/6.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "BLEConnectContentView.h"
#import "BLECell.h"
#import "MBProgressHUD.h"
#import "MainViewController.h"
#import "BLEConnectViewController.h"
#import "BLETool.h"
#import "manridyBleDevice.h"
#import "ClockFmdbTool.h"
#import "ClockModel.h"
#import "MotionFmdbTool.h"
#import "MotionDailyDataModel.h"
#import "SleepDailyDataModel.h"
#import "SleepFmdbTool.h"


typedef enum{
    ScanStateScaning = 0,
    ScanStateScaned ,
    ScanStateNull   ,
}ScanState;

static dispatch_once_t onceToken;

@interface BLEConnectContentView () <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, BleConnectDelegate, BleDiscoverDelegate, BleReceiveDelegate>
{
    BOOL _blueToothOpen;
    UIButton *_switchButton;
    MBProgressHUD *_hud;
    dispatch_queue_t q;
}

@property (nonatomic ,strong) NSMutableArray *peripheralsArr;

@property (nonatomic ,weak) UITableView *BLEListView;

@property (nonatomic ,weak) UIView *headView;

@property (nonatomic ,strong) NSTimer *scanDeviceTimer;

@property (nonatomic ,strong) NSString *currentDateStr;

@property (nonatomic ,strong) ClockFmdbTool *clockFmdbTool;

@property (nonatomic ,strong) MotionFmdbTool *motionFmdbTool;
@property (nonatomic ,strong) MotionDailyDataModel *MotionModel;

@property (strong, nonatomic) SleepFmdbTool *sleepFmdbTool;
@property (strong, nonatomic) SleepDailyDataModel *SleepModel;

@end

@implementation BLEConnectContentView

- (instancetype)init
{
    self = [super init];
    if (self) {
        q = dispatch_queue_create("chuanXing", NULL);
    }
    return self;
}

- (void)layoutSubviews
{
    self.BLEListView.frame = self.bounds;
    
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"YYYY-MM-dd"];
    NSDate *currentDate = [NSDate date];
    self.currentDateStr = [dateformatter stringFromDate:currentDate];
    
    [BLETool shareInstance].connectDelegate = self;
    [BLETool shareInstance].discoverDelegate = self;
    [BLETool shareInstance].receiveDelegate = self;
}

#pragma mark - UITableViewDelegate && UITableDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.peripheralsArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BLECell *cell = [tableView dequeueReusableCellWithIdentifier:@"bleCell"];
    manridyBleDevice *device = self.peripheralsArr[indexPath.row];
    cell.nameLabel.text = device.deviceName;
    
    onceToken = 0;
//    if (_bleSwitchState) {
//        if (_bleConnectState) {
//            if ([BLETool shareInstance].currentDev != nil) {
//                if ([[BLETool shareInstance].currentDev.peripheral isEqual:device.peripheral]) {
//                    [cell.connectButton setTitle:@"断开连接" forState:UIControlStateNormal];
//                    [cell.connectButton setBackgroundColor:[UIColor grayColor]];
//                }
//            }
//        }
//    }
    
    __weak typeof(cell) weakCell = cell;
    //cell上点击连接的block
    cell.connectActionCallBack = ^void {
        
        //先停止扫描和断开其他链接
        [[BLETool shareInstance] stopScan];
        [[BLETool shareInstance] unConnectDevice];
        
        //显示等待菊花
        _hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
        _hud.mode = MBProgressHUDModeIndeterminate;
        _hud.label.text = @"正在连接";
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[BLETool shareInstance] connectDevice:device];
        });
        
        [weakCell.connectButton setTitle:@"断开连接" forState:UIControlStateNormal];
        [weakCell.connectButton setBackgroundColor:[UIColor grayColor]];
    };
    
    //cell上点击断开连接的block
    cell.cancelActionCallBack = ^void {
        
        //先停止扫描和断开其他链接
        [[BLETool shareInstance] stopScan];
        [[BLETool shareInstance] unConnectDevice];
        
        [weakCell.connectButton setTitle:@"连接" forState:UIControlStateNormal];
        weakCell.connectButton.backgroundColor = UIColorFromRGBWithAlpha(0x2c91F4, 1);
    };
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    self.headView.frame = CGRectMake(0, 0, self.frame.size.width, 44);
    return self.headView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case 101:
            
            break;
        case 102:
        {
            //取消扫描
            [[self findViewController:self].navigationController popViewControllerAnimated:YES];
            BLEConnectViewController *bleVC = (BLEConnectViewController *)[self findViewController:self];
            if (bleVC.hiddenSearchBleViewCallBack) {
                bleVC.hiddenSearchBleViewCallBack();
            }
        }
            break;
            
        default:
            break;
    }
    
}

#pragma mark - 点击事件
- (void)ConnectSwitch
{
    if (_switchButton.isSelected) {
        [_switchButton setSelected:NO];
        
        //断开所有peripheral的连
        [[BLETool shareInstance] unConnectDevice];
        
        //取消扫描
        [[BLETool shareInstance] stopScan];
        
        //移除cell
        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
        
        for (int row = 0; row < self.peripheralsArr.count; row ++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
            [indexPaths addObject:indexPath];
        }
        
        //删除数据源
        [self.peripheralsArr removeAllObjects];
        
        [self.BLEListView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        
        [self.scanDeviceTimer invalidate];
        self.scanDeviceTimer = nil;
        
    }else {
        [self scanDevice];
        
//        if (!_blueToothOpen) {
//        
//            UIAlertView *view = [[UIAlertView alloc ] initWithTitle:@"提示" message:@"请确认设备是否已开启蓝牙" delegate:self cancelButtonTitle:@"去看看！" otherButtonTitles:nil, nil];
//            [view setTag:101];
//            [view show];
//        }else {
//            
//        }
    }
}

- (void)scanDevice
{
    [_switchButton setSelected:YES];
    
    //设置委托后直接可以使用，无需等待CBCentralManagerStatePoweredOn状态
    [[BLETool shareInstance] scanDevice];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[BLETool shareInstance] stopScan];
    });
}

#pragma mark - blelib3Delegate
#pragma mark -BleDiscoverDelegate
- (void)manridyBLEDidDiscoverDeviceWithMAC:(manridyBleDevice *)device
{
    if (![self.peripheralsArr containsObject:device]) {
        [self.peripheralsArr addObject:device];
        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.peripheralsArr.count - 1 inSection:0];
        [indexPaths addObject: indexPath];
        [self.BLEListView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark -BleConnectDelegate
- (void)manridyBLEDidConnectDevice:(manridyBleDevice *)device
{
    [BLETool shareInstance].currentDev = device;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), q, ^{
        [[BLETool shareInstance] writeTimeToPeripheral:[NSDate date]];
    });
        
    _hud.label.text = @"正在同步时间";
}

- (void)manridyBLEDidDisconnectDevice:(manridyBleDevice *)device
{
    self.peripheralsArr = nil;
    [BLETool shareInstance].currentDev = nil;
    
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"bleConnectState"];
}

#pragma mark -BleReceiveDelegate
//时间回调
- (void)receiveSetTimeDataWithModel:(manridyModel *)manridyModel
{
    if (manridyModel.isReciveDataRight == ResponsEcorrectnessDataRgith) {
        if (manridyModel.receiveDataType == ReturnModelTypeSetTimeModel) {
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), q, ^{
                [[BLETool shareInstance] writeClockToPeripheral:ClockDataGetClock withModel:nil];
            });

            _hud.label.text = @"正在同步闹钟";
        }
    }
}

//闹钟回调
- (void)receiveSetClockDataWithModel:(manridyModel *)manridyModel
{
    if (manridyModel.isReciveDataRight) {
        if (manridyModel.receiveDataType == ReturnModelTypeClockModel) {
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), q, ^{
                [[BLETool shareInstance] writeMotionRequestToPeripheral];
            });

            _hud.label.text = @"正在同步运动信息";
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self.clockFmdbTool deleteData:4];
                
                DeBugLog(@"%@",manridyModel.clockModelArr);
                NSArray *clockDataSource = manridyModel.clockModelArr;
                
                for (int index = 0; index < clockDataSource.count; index ++) {
                    
                    ClockModel *model = clockDataSource[index];
                    [self.clockFmdbTool insertModel:model];
                }
            });
            
        }
    }
}

//运动信息回调
- (void)receiveMotionDataWithModel:(manridyModel *)manridyModel
{
    if (manridyModel.isReciveDataRight) {
        if (manridyModel.receiveDataType == ReturnModelTypeSportModel) {
            
            dispatch_once(&onceToken, ^{
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), q, ^{
                    [[BLETool shareInstance] writeHeartRateRequestToPeripheral:HeartRateDataLastData];
                });
            });

            _hud.label.text = @"正在同步心率信息";
            
            self.MotionModel = [MotionDailyDataModel modelWith:self.currentDateStr step:manridyModel.sportModel.stepNumber kCal:manridyModel.sportModel.kCalNumber mileage:manridyModel.sportModel.mileageNumber bpm:nil];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                //查询数据库
                NSArray *dataArr = [self.motionFmdbTool queryDate:self.currentDateStr];
                if (dataArr.count == 0) {
                    //插入数据
                    [self.motionFmdbTool insertModel:self.MotionModel];
                }else {
                    [self.motionFmdbTool modifyData:self.currentDateStr model:self.MotionModel];
                }
            });
            
        }
    }
}

//心率信息回调
- (void)receiveHeartRateDataWithModel:(manridyModel *)manridyModel
{
    if (manridyModel.isReciveDataRight) {
        if (manridyModel.receiveDataType == ReturnModelTypeHeartRateModel) {
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), q, ^{
                [[BLETool shareInstance] writeSleepRequestToperipheral:SleepDataLastData];
            });
            
            
            _hud.label.text = @"正在同步睡眠信息";
            
            self.MotionModel = [MotionDailyDataModel modelWith:self.currentDateStr step:nil kCal:nil mileage:nil bpm:manridyModel.heartRateModel.heartRate];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                //查询数据库
                NSArray *dataArr = [self.motionFmdbTool queryDate:self.currentDateStr];
                if (dataArr.count == 0) {
                    //插入数据
                    [self.motionFmdbTool insertModel:self.MotionModel];
                }else {
                    [self.motionFmdbTool modifyData:self.currentDateStr model:self.MotionModel];
                }
            });
        }
    }
}

//同步睡眠数据
- (void)receiveSleepInfoWithModel:(manridyModel *)manridyModel
{
    if (manridyModel.isReciveDataRight) {
        if (manridyModel.receiveDataType == ReturnModelTypeSleepModel) {
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), q, ^{
                [[BLETool shareInstance] writeGPSToPeripheral];
            });
            
            _hud.label.text = @"正在同步GPS信息";
            
            self.SleepModel = [SleepDailyDataModel modelWithDate:self.currentDateStr sumSleepTime:[NSString stringWithFormat:@"%d",(manridyModel.sleepModel.deepSleep.intValue + manridyModel.sleepModel.lowSleep.intValue)] deepSleepTime:manridyModel.sleepModel.deepSleep lowSleepTime:manridyModel.sleepModel.lowSleep];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                //查询数据库
                NSArray *dataArr = [self.sleepFmdbTool queryDate:self.currentDateStr];
                if (dataArr.count == 0) {
                    //插入数据
                    [self.sleepFmdbTool insertModel:self.SleepModel];
                }else {
                    [self.sleepFmdbTool modifyData:self.currentDateStr model:self.SleepModel];
                }
            });
        }
    }
}

//同步GPS数据
- (void)receiveGPSWithModel:(manridyModel *)manridyModel
{
    if (manridyModel.isReciveDataRight == ResponsEcorrectnessDataRgith) {
        if (manridyModel.receiveDataType == ReturnModelTypeGPSHistoryModel) {
            
            if (manridyModel.gpsDailyModel.sumPackage != 0) {
                if (manridyModel.gpsDailyModel.sumPackage == manridyModel.gpsDailyModel.currentPackage + 1) {
                    
                    _hud.label.text = @"数据同步完成";
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                         [self.motionFmdbTool insertGPSModel:manridyModel.gpsDailyModel];
                    });
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [_hud hideAnimated:YES];
                        UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"已成功连接设备：%@",[BLETool shareInstance].currentDev.deviceName] delegate:self cancelButtonTitle:@"去主页" otherButtonTitles:nil, nil];
                        view.tag = 102;
                        [view show];
                    });
                }
            }else {
                _hud.label.text = @"数据同步完成";
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [_hud hideAnimated:YES];
                    UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"已成功连接设备：%@",[BLETool shareInstance].currentDev.deviceName] delegate:self cancelButtonTitle:@"去主页" otherButtonTitles:nil, nil];
                    view.tag = 102;
                    [view show];
                });
            }
        }
    }
}

#pragma mark - 懒加载
- (UIView *)headView
{
    if (!_headView) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor whiteColor];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 11, 100, 21)];
        label.text = @"搜索设备";
        [view addSubview:label];
        
        _switchButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 40, 11, 30, 21)];
        [_switchButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
        [_switchButton setImage:[UIImage imageNamed:@"open"] forState:UIControlStateSelected];
        
        [_switchButton addTarget:self action:@selector(ConnectSwitch) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:_switchButton];
        
        [self.BLEListView addSubview:view];
        _headView = view;
    }
    
    return _headView;
}

- (UITableView *)BLEListView
{
    if (!_BLEListView) {
        UITableView *view = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        view.backgroundColor = [UIColor whiteColor];
        view.allowsSelection = NO;
        [view registerNib:[UINib nibWithNibName:@"BLECell" bundle:nil] forCellReuseIdentifier:@"bleCell"];
        
        view.delegate = self;
        view.dataSource = self;
        
        [self addSubview:view];
        _BLEListView = view;
    }
    
    return _BLEListView;
}

- (NSMutableArray *)peripheralsArr
{
    if (!_peripheralsArr) {
        _peripheralsArr = [NSMutableArray array];
    }
    
    return _peripheralsArr;
}

- (ClockFmdbTool *)clockFmdbTool
{
    if (!_clockFmdbTool) {
        NSString *userPhone = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserName"];
        _clockFmdbTool = [[ClockFmdbTool alloc] initWithPath:userPhone];
    }
    
    return _clockFmdbTool;
}

- (MotionFmdbTool *)motionFmdbTool
{
    if (!_motionFmdbTool) {
        NSString *userPhone = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserName"];
        _motionFmdbTool = [[MotionFmdbTool alloc] initWithPath:userPhone withSQLType:SQLTypeMotion];
    }
    
    return _motionFmdbTool;
}

//运动数据模型
- (MotionDailyDataModel *)MotionModel
{
    if (!_MotionModel) {
        _MotionModel = [[MotionDailyDataModel alloc] init];
    }
    
    return _MotionModel;
}

//数据库操作工具
- (SleepFmdbTool *)sleepFmdbTool
{
    if (!_sleepFmdbTool) {
        NSString *userPhone = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserName"];
        SleepFmdbTool *tool = [[SleepFmdbTool alloc] initWithPath:userPhone];
        
        _sleepFmdbTool = tool;
    }
    
    return _sleepFmdbTool;
}

//运动数据模型
- (SleepDailyDataModel *)SleepModel
{
    if (!_SleepModel) {
        _SleepModel = [[SleepDailyDataModel alloc] init];
    }
    
    return _SleepModel;
}

#pragma mark - 获取当前View的控制器的方法
- (UIViewController *)findViewController:(UIView *)sourceView
{
    
    id target=sourceView;
    while (target) {
        target = ((UIResponder *)target).nextResponder;
        if ([target isKindOfClass:[UIViewController class]]) {
            break;
        }
    }
    return target;
}

@end
