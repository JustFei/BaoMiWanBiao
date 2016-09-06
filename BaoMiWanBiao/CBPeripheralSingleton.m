//
//  CBPeripheralSingleton.m
//  BaoMiWanBiao
//
//  Created by JustBill on 16/9/7.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "CBPeripheralSingleton.h"

@interface CBPeripheralSingleton () <NSCopying, NSMutableCopying>

@end

@implementation CBPeripheralSingleton

static CBPeripheralSingleton *peripheral = nil;

- (instancetype)init
{
    self = [super init];
    if (self) {
        
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

@end
