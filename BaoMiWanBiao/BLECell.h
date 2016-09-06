//
//  BLECell.h
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/9/6.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ConnectActionCallBack)(void);
typedef void(^CancelActionCallBack)(void);

@interface BLECell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *connectButton;

@property (nonatomic ,copy) ConnectActionCallBack connectActionCallBack;
@property (nonatomic ,copy) CancelActionCallBack cancelActionCallBack;

@end
