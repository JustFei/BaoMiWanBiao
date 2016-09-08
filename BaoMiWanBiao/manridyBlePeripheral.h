//
//  manridyBlePeripheral.h
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/9/8.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

@class CBPeripheral;
#import <Foundation/Foundation.h>

@interface manridyBlePeripheral : NSObject

@property (nonatomic ,strong) CBPeripheral *cbDevice;
//@property (nonatomic ,strong) NSString *mediaAC;
//@property (nonatomic ,strong) NSNumber *RSSI;
@property (nonatomic ,strong) NSString *uuidString;
@property (nonatomic ,strong) NSString *deviceName;

- (instancetype)initWith:(CBPeripheral *)cbPeripheral andAdvertisementData:(NSDictionary *)advertisementData;

@end
