//
//  ClockTableViewCell.m
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/8/23.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "ClockTableViewCell.h"

@interface ClockTableViewCell ()


@end

@implementation ClockTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)clockButtonAction:(UIButton *)sender {
    
    if ([self.clockButton isSelected]) {
        [self.clockButton setSelected:0];
    }else {
        [self.clockButton setSelected:1];
    }
    
    self.modifyOpenButtonBlock(self.clockButton.isSelected);
}

@end
