//
//  RegistAndLoginViewController.m
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/7/25.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "RegistAndLoginViewController.h"
#import "RegistViewController.h"

@interface RegistAndLoginViewController ()

@end

@implementation RegistAndLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self modifyUI];
    
}

//修改xib中的UI一些属性
- (void)modifyUI
{
    
    //设置用户头像的圆形
    self.userHeadIamgeView.layer.cornerRadius = self.userHeadIamgeView.frame.size.height / 2;
    self.userHeadIamgeView.backgroundColor = [UIColor blueColor];
    
    //设置用户注册按钮边框的颜色和宽度
    self.registButton.layer.borderWidth = 1.0f;
    [self.registButton.layer setBorderColor:[UIColor colorWithRed:204.0 / 255.0 green:204.0 / 255.0 blue:204.0 / 255.0 alpha:1].CGColor];
    
    //设置用户名输入框的边框颜色和宽度
    self.userNameTextField.layer.borderWidth= 1.0f;
    self.userNameTextField.layer.borderColor= [UIColor colorWithRed:204.0 / 255.0 green:204.0 / 255.0 blue:204.0 / 255.0 alpha:1].CGColor;
    
    //设置密码输入框的边框颜色和宽度
    self.passWordTextField.layer.borderWidth= 1.0f;
    self.passWordTextField.layer.borderColor= [UIColor colorWithRed:204.0 / 255.0 green:204.0 / 255.0 blue:204.0 / 255.0 alpha:1].CGColor;
    
    //设置用户名输入框左侧的图片和提示文字
    CGRect frame = CGRectMake(22, 10, 13, 16);
    UIImageView *leftview = [[UIImageView alloc] initWithFrame:frame];
    leftview.image = [UIImage imageNamed:@"user.png"];
    self.userNameTextField.leftViewMode = UITextFieldViewModeAlways;
    self.userNameTextField.leftView = leftview;
    self.userNameTextField.placeholder = @"请输入手机号";
    
    //设置密码输入框左右两侧的图片和文字
    CGRect frame1 = CGRectMake(22, 10, 13, 16);
    UIImageView *leftview1 = [[UIImageView alloc] initWithFrame:frame1];
    leftview1.image = [UIImage imageNamed:@"locked.png"];
    self.passWordTextField.leftViewMode = UITextFieldViewModeAlways;
    self.passWordTextField.leftView = leftview1;
    self.passWordTextField.placeholder = @"请输入密码";
    
    UIImageView *rightView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    rightView.image = [UIImage imageNamed:@"forget.png"];
    self.passWordTextField.rightViewMode = UITextFieldViewModeAlways;
    self.passWordTextField.rightView = rightView;
    
}

//点击屏幕除了键盘其他的地方
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    //收起键盘
    if (![self.userNameTextField isExclusiveTouch]) {
        [self.userNameTextField resignFirstResponder];
    }
    if (![self.passWordTextField isExclusiveTouch]) {
        [self.passWordTextField resignFirstResponder];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)loginButtonAction:(UIButton *)sender {
}
- (IBAction)registButtonAction:(UIButton *)sender {
    
    RegistViewController *registVC = [[RegistViewController alloc] initWithNibName:@"RegistViewController" bundle:[NSBundle mainBundle]];
    [self presentViewController:registVC animated:YES completion:^{
        
    }];
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
