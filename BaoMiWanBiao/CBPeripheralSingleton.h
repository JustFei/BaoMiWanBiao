//
//  CBPeripheralSingleton.h
//  BaoMiWanBiao
//
//  Created by JustBill on 16/9/7.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface CBPeripheralSingleton : NSObject

@property (nonatomic ,strong) CBPeripheral *peripheral;

+ (instancetype)sharePeripheral;

@end
