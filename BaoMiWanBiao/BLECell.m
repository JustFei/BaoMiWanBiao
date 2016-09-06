//
//  BLECell.m
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/9/6.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "BLECell.h"

@implementation BLECell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)connectAction:(UIButton *)sender {
    if ([sender.titleLabel.text isEqualToString:@"连接"]) {
        self.connectActionCallBack();
    }else if ([sender.titleLabel.text isEqualToString:@"断开连接"]) {
        self.cancelActionCallBack();
    }
}

@end
