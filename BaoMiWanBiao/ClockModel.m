//
//  Clocker.m
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/8/23.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "ClockModel.h"

@implementation ClockModel

- (NSMutableArray *)clockArr
{
    if (!_clockArr) {
        _clockArr = [NSMutableArray array];
    }
    
    return _clockArr;
}

@end
