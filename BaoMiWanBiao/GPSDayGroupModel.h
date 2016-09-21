//
//  GPSDayGroupModel.h
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/9/21.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GPSDayGroupModel : NSObject

@property (nonatomic ,copy) NSString *startTime;

@property (nonatomic ,copy) NSString *endTime;

@property (nonatomic ,strong) NSMutableArray *GPSArr;

@end
