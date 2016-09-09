//
//  BLETool.h
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/9/8.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BabyBluetooth.h"
#import "CBPeripheralSingleton.h"


typedef enum{
    kBLEstateDisConnected = 0,
    kBLEstateDidConnected ,
    kBLEstateBindUnConnected ,
}kBLEstate;

@class manridyBleDevice;

//扫描设备协议
@protocol BleDiscoverDelegate <NSObject>

@required

- (void)manridyBLEDidDiscoverDeviceWithMAC:(manridyBleDevice *)device;

@optional
/**
 *
 *
 *  @return the service did protocoled, for bracelet ,you could write @"FF20" ,you also can never implement this method for connect bracelet.
 */
- (NSString *)serverUUID;

@end

//连接协议
@protocol BleConnectDelegate <NSObject>

@required
/**
 *  invoked when the device did connected by the centeral
 *
 *  @param device: the device did connected
 */
- (void)manridyBLEDidConnectDevice:(manridyBleDevice *)device;

@optional
/**
 *  invoked when the device did disconnected
 *
 *  @param device the device did disconnected
 */
- (void)manridyBLEDidDisconnectDevice:(manridyBleDevice *)device;

@end

//写入协议
@protocol BleWriteDelegate <NSObject>

@optional

/**
 *  返回数据
 *
 */
- (void)receiveData:(NSData *)data;

- (void)witeClockToPeripheral:(NSString *)clock;

@end

@interface BLETool : NSObject

+ (instancetype)shareInstance;

@property (nonatomic ,assign) kBLEstate state; //support add observer ,abandon @readonly ,don't change it anyway.

@property (nonatomic ,strong) manridyBleDevice *currentDev;

@property (nonatomic ,assign) id <BleDiscoverDelegate>discoverDelegate;

@property (nonatomic ,assign) id <BleConnectDelegate>connectDelegate;

@property (nonatomic ,assign) id <BleWriteDelegate>writeDelegate;

#pragma mark - action of connecting layer -连接层操作
//扫描设备
- (void)scanDevice;

//停止扫描
- (void)stopScan;

//连接设备
- (void)connectDevice:(manridyBleDevice *)device;

//断开设备连接
- (void)unConnectDevice;

//重连设备
- (void)reConnectDevice;

//检索已连接的外接设备
- (NSArray *)retrieveConnectedPeripherals;

//
- (void)debindFromSystem;

//写入数据操作
- (void)writeDataToPeripheral:(NSString *)info;

@end
