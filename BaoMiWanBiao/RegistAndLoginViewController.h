//
//  RegistAndLoginViewController.h
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/7/25.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegistAndLoginViewController : UIViewController

//用户头像
@property (weak, nonatomic) IBOutlet UIImageView *userHeadIamgeView;

//用户名输入框
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
//密码输入框
@property (weak, nonatomic) IBOutlet UITextField *passWordTextField;

//注册按钮属性
@property (weak, nonatomic) IBOutlet UIButton *registButton;



@end
