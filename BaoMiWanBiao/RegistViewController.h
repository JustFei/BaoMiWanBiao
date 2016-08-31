//
//  RegistViewController.h
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/7/25.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegistViewController : UIViewController

//手机号View
@property (weak, nonatomic) IBOutlet UIView *phoneNumberView;
//手机号输入框
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;

//验证码View
@property (weak, nonatomic) IBOutlet UIView *safeCodeView;
//验证码输入框
@property (weak, nonatomic) IBOutlet UITextField *safeCodeTextField;

//第一次输入密码View
@property (weak, nonatomic) IBOutlet UIView *firstEnterPwdView;
//第一次输入密码输入框
@property (weak, nonatomic) IBOutlet UITextField *firstEnterPwdTextField;

//第二次输入密码View
@property (weak, nonatomic) IBOutlet UIView *secondEnterPwdView;
//第二次输入密码输入框
@property (weak, nonatomic) IBOutlet UITextField *secondEnterPwdTextField;

//获取验证码按钮
@property (weak, nonatomic) IBOutlet UIButton *getSafeCode;

@end
