//
//  CBPeripheralSingleton.h
//  BaoMiWanBiao
//
//  Created by JustBill on 16/9/7.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "manridyBleDevice.h"
#import "BLETool.h"

@interface CBPeripheralSingleton : NSObject

@property (nonatomic ,strong) manridyBleDevice *device;

//@property (nonatomic ,assign) kBLEstate state;

@property (nonatomic ,assign) BOOL auto_reconnect_cancel;

+ (instancetype)sharePeripheral;

//设置重连
- (void)setAutoReconnect:(BOOL)isNeed andReconnectCheckTime:(NSTimeInterval)timeSec;

//扫描设备
- (void)scanDevice;

//停止扫描
- (void)stopScan;

//获得设备数组
- (NSArray *)getDevices;

//当前状态
//- (kBLEstate)currentState;

//是否绑定
- (BOOL)isBinded;

//连接到设备
- (void)connectDevice:(manridyBleDevice *)device;

//不连接某设备
- (void)unConnectDevice;

@end
