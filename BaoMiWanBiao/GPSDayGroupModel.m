//
//  GPSDayGroupModel.m
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/9/21.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "GPSDayGroupModel.h"

@implementation GPSDayGroupModel

- (NSMutableArray *)GPSArr
{
    if (!_GPSArr) {
        _GPSArr = [NSMutableArray array];
    }
    
    return  _GPSArr;
}

@end
