//
//  CBPeripheralSingleton.m
//  BaoMiWanBiao
//
//  Created by JustBill on 16/9/7.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "CBPeripheralSingleton.h"
#import "BLETool.h"

@interface CBPeripheralSingleton () <NSCopying, NSMutableCopying>
{
    NSMutableArray *_deviceArray;
}
@end

@implementation CBPeripheralSingleton

static CBPeripheralSingleton *peripheral = nil;

#pragma mark - singleton
- (instancetype)init
{
    self = [super init];
    if (self) {
        [BLETool shareInstance].discoverDelegate = self;
        _deviceArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}

+ (instancetype)sharePeripheral
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        peripheral = [[self alloc] init];
    });
    
    return peripheral;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        peripheral = [super allocWithZone:zone];
    });
    
    return peripheral;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return self;
}

#pragma mark - 蓝牙操作
//设置重连
- (void)setAutoReconnect:(BOOL)isNeed andReconnectCheckTime:(NSTimeInterval)timeSec
{
    __block CBPeripheralSingleton *__safe_self = self;
    
    dispatch_queue_t queue = dispatch_queue_create("auto-reconnect-queue", 0);
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, timeSec *NSEC_PER_SEC, 0.1 *   timeSec *NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        if ([__safe_self auto_reconnect_cancel] ) {
            dispatch_source_cancel(timer);
        }
        __safe_self.state = [__safe_self currentState];
        
        //        NSLog(@"_state :=================== %d",__safe_self.state);
        
        if (__safe_self.state == kBLEstateBindUnConnected) {
            [[BLETool shareInstance] reConnectDevice];
        }
    });
    dispatch_resume(timer);
}

#pragma mark - device&&state
//扫描设备
- (void)scanDevice
{
    [_deviceArray removeAllObjects];
    [[BLETool shareInstance] scanDevice];
}

//停止扫描
- (void)stopScan
{
    [[BLETool shareInstance] stopScan];
}

//获得设备数组
- (NSArray *)getDevices
{
    return _deviceArray;
}

//当前状态
- (kBLEstate)currentState
{
    return [[BLETool shareInstance] state];
}

//是否绑定
- (BOOL)isBinded
{
    if ([self currentState] == kBLEstateDisConnected) {
        return NO;
    }
    return YES;
}

//是否连接状态
- (BOOL)isConnected{
    if ([self currentState] == kBLEstateDidConnected) {
        return YES;
    }
    return NO;
}

//连接到设备
- (void)connectDevice:(manridyBleDevice *)device
{
    [[BLETool shareInstance] connectDevice:device];
}

//不连接某设备
- (void)unConnectDevice
{
    [[BLETool shareInstance] unConnectDevice];
}

#pragma mark -blelib3Delegate

- (void)manridyBLEDidDiscoverDeviceWithMAC:(manridyBleDevice *)device{
    
    if (![_deviceArray containsObject:device]) {
        [_deviceArray addObject:device];
    }
}

@end
