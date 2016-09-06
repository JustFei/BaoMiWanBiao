//
//  BLEConnectView.h
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/9/6.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^HiddenSelfCallBack)(void);

@interface BLEConnectView : UIView

@property (nonatomic ,copy) HiddenSelfCallBack hiddenSelfCallBack;

@end
