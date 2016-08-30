//
//  RegistViewController.m
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/7/25.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "RegistViewController.h"
#import "UserModel.h"
#import <BmobSDK/Bmob.h>

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
    self.phoneNumberTextField.placeholder = @"  请输入手机号";
    self.phoneNumberTextField.layer.borderWidth= 1.0f;
    self.phoneNumberTextField.layer.borderColor= [UIColor colorWithRed:204.0 / 255.0 green:204.0 / 255.0 blue:204.0 / 255.0 alpha:1].CGColor;
    
    //验证码输入框UI设置
    UIImageView *leftView1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 13, 16)];
    leftView1.image = [UIImage imageNamed:@"key.png"];
    self.safeCodeTextField.leftViewMode = UITextFieldViewModeAlways;
    self.safeCodeTextField.leftView = leftView1;
    self.safeCodeTextField.placeholder = @"  请输入验证码";
    self.safeCodeTextField.layer.borderWidth= 1.0f;
    self.safeCodeTextField.layer.borderColor= [UIColor colorWithRed:204.0 / 255.0 green:204.0 / 255.0 blue:204.0 / 255.0 alpha:1].CGColor;
    
    
    UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 84, 44)];
    [rightButton addTarget:self action:@selector(verifyTheNum) forControlEvents:UIControlEventTouchUpInside];
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
    self.firstEnterPwdTextField.placeholder = @"  请设置登陆密码";
    self.firstEnterPwdTextField.layer.borderWidth= 1.0f;
    self.firstEnterPwdTextField.layer.borderColor= [UIColor colorWithRed:204.0 / 255.0 green:204.0 / 255.0 blue:204.0 / 255.0 alpha:1].CGColor;
    
    //第二次
    UIImageView *leftView3 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 13, 16)];
    leftView3.image = [UIImage imageNamed:@"locked.png"];
    self.secondEnterPwdTextField.leftViewMode = UITextFieldViewModeAlways;
    self.secondEnterPwdTextField.leftView = leftView3;
    self.secondEnterPwdTextField.placeholder = @"  请确认登录密码";
    self.secondEnterPwdTextField.layer.borderWidth= 1.0f;
    self.secondEnterPwdTextField.layer.borderColor= [UIColor colorWithRed:204.0 / 255.0 green:204.0 / 255.0 blue:204.0 / 255.0 alpha:1].CGColor;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)NextStepButtonAction:(UIButton *)sender {
    
    //在GameScore创建一条数据，如果当前没GameScore表，则会创建GameScore表
    BmobObject  *userModel = [BmobObject objectWithClassName:@"UserModel"];
    //phone为输入框中的值
    [userModel setObject:self.phoneNumberTextField.text forKey:@"phone"];
    //设置userName为小明
    [userModel setObject:self.firstEnterPwdTextField.text forKey:@"pwd"];
//    //设置cheatMode为NO
//    [userModel setObject:[NSNumber numberWithBool:NO] forKey:@"cheatMode"];
//    //设置age为18
//    [userModel setObject:[NSNumber numberWithInt:18] forKey:@"age"];
    
    //异步保存到服务器
    [userModel saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        if (isSuccessful) {
            //创建成功后会返回objectId，updatedAt，createdAt等信息
            //创建对象成功，打印对象值
            NSLog(@"%@",userModel);
        } else if (error){
            //发生错误后的动作
            NSLog(@"%@",error);
        } else {
            NSLog(@"Unknow error");
        }
    }];
}
- (IBAction)backButtonAction:(UIButton *)sender {
    
    [self hiddenKeyboard];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 点击事件
- (void)verifyTheNum
{
    //验证次号码是否已经存在
    //查找UserModel表
    BmobQuery   *bquery = [BmobQuery queryWithClassName:@"UserModel"];
    //添加playerName不是小明的约束条件
    [bquery whereKey:@"phone" equalTo:self.phoneNumberTextField.text];
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
