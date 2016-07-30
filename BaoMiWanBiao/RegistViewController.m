//
//  RegistViewController.m
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/7/25.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "RegistViewController.h"

@interface RegistViewController ()

@end

@implementation RegistViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self modifyUI];
}

- (void)modifyUI
{
    //手机号输入框UI设置
    UIImageView *leftView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 13, 16)];
    leftView.image = [UIImage imageNamed:@"user.png"];
    self.phoneNumberTextField.leftViewMode = UITextFieldViewModeAlways;
    self.phoneNumberTextField.leftView = leftView;
    self.phoneNumberTextField.placeholder = @"请输入手机号";
    
    //验证码输入框UI设置
    UIImageView *leftView1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 13, 16)];
    leftView1.image = [UIImage imageNamed:@"key.png"];
    self.safeCodeTextField.leftViewMode = UITextFieldViewModeAlways;
    self.safeCodeTextField.leftView = leftView1;
    self.safeCodeTextField.placeholder = @"请输入验证码";
    
    UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 84, 44)];
    [rightButton setTitle:@"获取验证码" forState:UIControlStateNormal];
    rightButton.titleLabel.font = [UIFont systemFontOfSize:13];
    [rightButton setTitleColor:[UIColor colorWithRed:0 green:138.0 / 255.0 blue:249.0 / 255.0 alpha:1] forState:UIControlStateNormal];
    self.safeCodeTextField.rightViewMode = UITextFieldViewModeAlways;
    self.safeCodeTextField.rightView = rightButton;
    
    //两次密码输入框
    //第一次
    UIImageView *leftView2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 13, 16)];
    leftView2.image = [UIImage imageNamed:@"locked.png"];
    self.firstEnterPwdTextField.leftViewMode = UITextFieldViewModeAlways;
    self.firstEnterPwdTextField.leftView = leftView2;
    self.firstEnterPwdTextField.placeholder = @"请设置8位数的字母";
    
    //第二次
    UIImageView *leftView3 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 13, 16)];
    leftView3.image = [UIImage imageNamed:@"locked.png"];
    self.secondEnterPwdTextField.leftViewMode = UITextFieldViewModeAlways;
    self.secondEnterPwdTextField.leftView = leftView3;
    self.secondEnterPwdTextField.placeholder = @"请确认登录密码";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)NextStepButtonAction:(UIButton *)sender {
}
- (IBAction)backButtonAction:(UIButton *)sender {
    
    [self hiddenKeyboard];
    [self dismissViewControllerAnimated:YES completion:nil];
}

//点击屏幕除了键盘其他的地方
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self hiddenKeyboard];
}

- (void)hiddenKeyboard
{
    //收起键盘
    if (![self.phoneNumberTextField isExclusiveTouch]) {
        [self.phoneNumberTextField resignFirstResponder];
    }
    if (![self.safeCodeTextField isExclusiveTouch]) {
        [self.safeCodeTextField resignFirstResponder];
    }
    if (![self.firstEnterPwdTextField isExclusiveTouch]) {
        [self.firstEnterPwdTextField resignFirstResponder];
    }
    if (![self.secondEnterPwdTextField isExclusiveTouch]) {
        [self.secondEnterPwdTextField resignFirstResponder];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
