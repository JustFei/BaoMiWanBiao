//
//  BLEConnectViewController.h
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/9/6.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^HiddenSearchBleViewCallBcak)(void);

@interface BLEConnectViewController : UIViewController

@property (nonatomic ,copy) HiddenSearchBleViewCallBcak hiddenSearchBleViewCallBack;

@end
