//
//  XXFColorConstants.h
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/8/6.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#define UIColorFromRGBWithAlpha(rgbValue,a) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]

#define kXXFColorBarChartControllerBackground [UIColor whiteColor]
