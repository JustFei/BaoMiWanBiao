//
//  ClockTableViewCell.h
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/8/23.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ModifyisOpenButtonState)(BOOL);

@interface ClockTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *clockTime;
@property (weak, nonatomic) IBOutlet UIButton *clockButton;

@property (strong, nonatomic) ModifyisOpenButtonState modifyOpenButtonBlock;

@end
