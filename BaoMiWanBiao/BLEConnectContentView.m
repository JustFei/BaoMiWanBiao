//
//  BLEConnectContentView.m
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/9/6.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "BLEConnectContentView.h"
#import "BLECell.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "BabyBluetooth.h"
#import "MBProgressHUD.h"
#import "MainViewController.h"
#import "BLEConnectViewController.h"
#import "CBPeripheralSingleton.h"


@interface BLEConnectContentView () <UITableViewDelegate, UITableViewDataSource, CBCentralManagerDelegate, UIAlertViewDelegate>
{
    BOOL _blueToothOpen;
    UIButton *_switchButton;
    BabyBluetooth *baby;
}
// 蓝牙检测
@property (nonatomic ,strong) CBCentralManager *centralManager;

@property (nonatomic ,strong) CBPeripheral *currPeripheral;

@property (nonatomic ,strong) NSMutableArray *peripheralsArr;

@property (nonatomic ,weak) UITableView *BLEListView;

@property (nonatomic ,weak) UIView *headView;

@property (nonatomic ,strong) CBPeripheralSingleton *peripheralSing;

@end

@implementation BLEConnectContentView

- (void)layoutSubviews
{
    self.peripheralSing = [CBPeripheralSingleton sharePeripheral];
    self.BLEListView.frame = self.bounds;
    
    //初始化BabyBluetooth 蓝牙库
    baby = [BabyBluetooth shareBabyBluetooth];
    //设置蓝牙委托
    [self babyDelegate];
    
    // 蓝牙检测
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
}

#pragma mark - CLLocationManagerDelegate
-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    //第一次打开或者每次蓝牙状态改变都会调用这个函数
    if(central.state==CBCentralManagerStatePoweredOn)
    {
        NSLog(@"蓝牙设备开着");
        _blueToothOpen = YES;
    }
    else
    {
        NSLog(@"蓝牙设备关着");
        _blueToothOpen = NO;
    }
}

#pragma mark - babyDelegate
//设置蓝牙委托
-(void)babyDelegate{
    
    __weak typeof(self) weakSelf = self;
    
    //设置扫描到设备的委托
    [baby setBlockOnDiscoverToPeripherals:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        NSLog(@"搜索到了设备:%@",peripheral.name);
    }];
    
#warning this is choose what peripheral we want
    //过滤器
    //设置查找设备的过滤器
    [baby setFilterOnDiscoverPeripherals:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
        //最常用的场景是查找某一个前缀开头的设备
        //if ([peripheralName hasPrefix:@"Pxxxx"] ) {
        //    return YES;
        //}
        //return NO;
        //设置查找规则是名称大于1 ， the search rule is peripheral.name length > 1
        if (peripheralName.length >1) {
            return YES;
        }
        return NO;
    }];
    
    //设置扫描到设备的委托
    [baby setBlockOnDiscoverToPeripherals:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        NSLog(@"搜索到了设备:%@",peripheral.name);
        [weakSelf insertTableView:peripheral advertisementData:advertisementData];
    }];
    
    //设置设备连接成功的委托,同一个baby对象，使用不同的channel切换委托回调
    [baby setBlockOnConnected:^(CBCentralManager *central, CBPeripheral *peripheral) {
        NSLog(@"连接到了设备:%@",peripheral.name);
        
        //currPeripheral指向我们点击的cell的peripheral
        weakSelf.currPeripheral = peripheral;
        weakSelf.peripheralSing.peripheral = peripheral;
        
        [MBProgressHUD hideHUDForView:weakSelf animated:YES];
        UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"已成功连接设备：%@",peripheral.name] delegate:weakSelf cancelButtonTitle:@"去主页" otherButtonTitles:nil, nil];
        [view show];
        
    }];
    
    //断开Peripherals的连接的block
    [baby setBlockOnDisconnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"断开了设备:%@",peripheral.name);
    }];
}

//插入table数据
-(void)insertTableView:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData{
    if(![self.peripheralsArr containsObject:peripheral]){
        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.peripheralsArr.count inSection:0];
        [indexPaths addObject:indexPath];
        [self.peripheralsArr addObject:peripheral];
//        [peripheralsAD addObject:advertisementData];
        [self.BLEListView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    }
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
    CBPeripheral *peripheral = self.peripheralsArr[indexPath.row];
    cell.nameLabel.text = peripheral.name;
    
    __weak typeof(cell) weakCell = cell;
    cell.connectActionCallBack = ^void {
        
        //先停止扫描和断开其他链接
        [baby cancelScan];
        [baby cancelAllPeripheralsConnection];
        
        //显示等待菊花
        [MBProgressHUD showHUDAddedTo:self animated:YES];
        
        baby.having(self.currPeripheral).connectToPeripherals().begin();
        [weakCell.connectButton setTitle:@"断开连接" forState:UIControlStateNormal];
        [weakCell.connectButton setBackgroundColor:[UIColor grayColor]];
    };
    
    cell.cancelActionCallBack = ^void {
        //先停止扫描和断开其他链接
        [baby cancelScan];
        [baby cancelAllPeripheralsConnection];
        
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
            [baby cancelScan];
            [[self findViewController:self].navigationController popViewControllerAnimated:YES];
            BLEConnectViewController *bleVC = (BLEConnectViewController *)[self findViewController:self];
            bleVC.hiddenSearchBleViewCallBack();
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
        [baby cancelAllPeripheralsConnection];
        //取消扫描
        [baby cancelScan];
        
        //移除cell
        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
        
        for (int row = 0; row < self.peripheralsArr.count; row ++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
            [indexPaths addObject:indexPath];
        }
        
        //删除数据源
        self.peripheralsArr = nil;
        
        [self.BLEListView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        
    }else {
        if (!_blueToothOpen) {
            UIAlertView *view = [[UIAlertView alloc ] initWithTitle:@"提示" message:@"请确认设备是否已开启蓝牙" delegate:self cancelButtonTitle:@"去看看！" otherButtonTitles:nil, nil];
            [view setTag:101];
            [view show];
        }else {
        
            [_switchButton setSelected:YES];
            
            //设置委托后直接可以使用，无需等待CBCentralManagerStatePoweredOn状态
            baby.scanForPeripherals().begin();
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
