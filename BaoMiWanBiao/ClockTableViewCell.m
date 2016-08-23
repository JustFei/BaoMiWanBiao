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
        [self.clockButton setSelected:NO];
    }else {
        [self.clockButton setSelected:YES];
    }
}

@end
