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


typedef enum{
    ScanStateScaning = 0,
    ScanStateScaned ,
    ScanStateNull   ,
}ScanState;

@interface BLEConnectContentView () <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, BleConnectDelegate, BleDiscoverDelegate, BleReceiveDelegate>
{
    BOOL _blueToothOpen;
    UIButton *_switchButton;
}

@property (nonatomic ,strong) NSMutableArray *peripheralsArr;

@property (nonatomic ,weak) UITableView *BLEListView;

@property (nonatomic ,weak) UIView *headView;

@property (nonatomic ,strong) NSTimer *scanDeviceTimer;

@end

@implementation BLEConnectContentView

- (void)layoutSubviews
{
    self.BLEListView.frame = self.bounds;
    
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
        
//        self.currPeripheral = device.peripheral;
        //显示等待菊花
        [MBProgressHUD showHUDAddedTo:self animated:YES];
        
        [[BLETool shareInstance] connectDevice:device];
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
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"bleSwitchState"];
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
    
    [[BLETool shareInstance] writeTimeToPeripheral:[NSDate date]];
}

- (void)manridyBLEDidDisconnectDevice:(manridyBleDevice *)device
{
    self.peripheralsArr = nil;
    [BLETool shareInstance].currentDev = nil;
    
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"bleConnectState"];
}

#pragma mark -BleReceiveDelegate
- (void)receiveSetTimeDataWithModel:(manridyModel *)manridyModel
{
    if (manridyModel.isReciveDataRight == ResponsEcorrectnessDataRgith) {
        if (manridyModel.receiveDataType == ReturnModelTypeSetTimeModel) {
            
            //隐藏等待菊花
            [MBProgressHUD hideHUDForView:self animated:YES];
            UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"已成功连接设备：%@",[BLETool shareInstance].currentDev.deviceName] delegate:self cancelButtonTitle:@"去主页" otherButtonTitles:nil, nil];
            view.tag = 102;
            [view show];
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
