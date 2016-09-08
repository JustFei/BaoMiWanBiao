//
//  manridyBleDevice.m
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/9/8.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "manridyBleDevice.h"

@implementation manridyBleDevice

- (instancetype)initWith:(CBPeripheral *)cbPeripheral andAdvertisementData:(NSDictionary *)advertisementData
{
    manridyBleDevice *per = [[manridyBleDevice alloc] init];
    
    per.peripheral = cbPeripheral;
    per.deviceName = [advertisementData objectForKey:@"kCBAdvDataLocalName"];
    per.uuidString = [advertisementData objectForKey:@"kCBAdvDataServiceUUIDs"];
    
    return per;
}

@end
