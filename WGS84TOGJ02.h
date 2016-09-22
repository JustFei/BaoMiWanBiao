//
//  WGS84TOGJ02.h
//  Localication
//
//  Created by vera on 16/3/9.
//  Copyright © 2016年 vera. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface WGS84TOGJ02 : NSObject

//判断是否已经超出中国范围
+ (BOOL)outOfChina:(CLLocation *)location;
//转GCJ-02
+ (CLLocation *)transformToMars:(CLLocation *)location;
@end
