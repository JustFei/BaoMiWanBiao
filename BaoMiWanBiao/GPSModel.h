//
//  GPSModel.h
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/9/20.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GPSModel : NSObject



@property (nonatomic ,assign) NSInteger sumPackage;

@property (nonatomic ,assign) NSInteger currentPackage;

//经度
@property (nonatomic ,assign) float lon;

//纬度
@property (nonatomic ,assign) float lat;

@end
