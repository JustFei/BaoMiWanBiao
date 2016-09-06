//
//  BLEConnectView.m
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/9/6.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "BLEConnectView.h"
#import "BLEConnectViewController.h"

@interface BLEConnectView ()
//连接图片
@property (nonatomic ,weak) UIImageView *connectImageView;
//连接状态文本
@property (nonatomic ,weak) UILabel *connectStateLabel;
//连接按钮
@property (nonatomic ,weak) UIButton *connectButton;

@end

@implementation BLEConnectView

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.connectImageView.frame = CGRectMake(65, 145, self.frame.size.width - 130, 87);
    self.connectStateLabel.frame = CGRectMake(65, 270, self.frame.size.width - 130, 40);
    self.connectButton.frame = CGRectMake(65, 360, self.frame.size.width - 130, 40);
    
}

- (void)pushToConnectBLE
{
    BLEConnectViewController *vc = [[BLEConnectViewController alloc] init];
    [[self findViewController:self].navigationController pushViewController:vc animated:YES];
    
    vc.hiddenSearchBleViewCallBack = ^void {
        self.hiddenSelfCallBack();
    };
}

#pragma mark - 懒加载 
- (UIImageView *)connectImageView
{
    if (!_connectImageView) {
        UIImageView *view = [[UIImageView alloc] init];
        view.backgroundColor = [UIColor whiteColor];
        view.image = [UIImage imageNamed:@"connect"];
        
        [self addSubview:view];
        _connectImageView  = view;
    }
    
    return  _connectImageView;
}

- (UILabel *)connectStateLabel
{
    if (!_connectStateLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.text = @"您的腕表未连接";
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor whiteColor];
        
        [self addSubview:label];
        _connectStateLabel = label;
    }
    
    return  _connectStateLabel;
}

- (UIButton *)connectButton
{
    if (!_connectButton) {
        UIButton *button = [[UIButton alloc] init];
        [button setTitle:@"点击连接腕表" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(pushToConnectBLE) forControlEvents:UIControlEventTouchUpInside];
        [button setBackgroundColor:UIColorFromRGBWithAlpha(0x2c91F4, 1)];
        [button setTintColor:[UIColor whiteColor]];
        
        [self addSubview:button];
        _connectButton = button;
    }
    
    return _connectButton;
}

#pragma mark - 获取当前View的控制器的方法
- (UIViewController *)findViewController:(UIView *)sourceView
{
    id target=sourceView;
    while (target) {
        target = ((UIResponder *)target).nextResponder;
        if ([target isKindOfClass:[UIViewController class]]) {
            break;
        }
    }
    return target;
}

@end
