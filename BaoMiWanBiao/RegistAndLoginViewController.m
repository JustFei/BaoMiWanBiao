    //
//  RegistAndLoginViewController.m
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/7/25.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "RegistAndLoginViewController.h"
#import "RegistViewController.h"
#import <BmobSDK/Bmob.h>
#import "MainViewController.h"

@interface RegistAndLoginViewController ()<UITextFieldDelegate>

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
    self.userHeadIamgeView.backgroundColor = UIColorFromRGBWithAlpha(0x2c91F4, 1);
    
    //设置用户注册按钮边框的颜色和宽度
    self.registButton.layer.borderWidth = 1.0f;
    [self.registButton.layer setBorderColor:[UIColor colorWithRed:204.0 / 255.0 green:204.0 / 255.0 blue:204.0 / 255.0 alpha:1].CGColor];
    
    //设置用户名输入框的边框颜色和宽度
    self.userNameView.layer.borderWidth= 1.0f;
    self.userNameView.layer.borderColor= [UIColor colorWithRed:204.0 / 255.0 green:204.0 / 255.0 blue:204.0 / 255.0 alpha:1].CGColor;
    
    //设置密码输入框的边框颜色和宽度
    self.passWordView.layer.borderWidth= 1.0f;
    self.passWordView.layer.borderColor= [UIColor colorWithRed:204.0 / 255.0 green:204.0 / 255.0 blue:204.0 / 255.0 alpha:1].CGColor;
    
}

#pragma mark - 点击事件
- (IBAction)forgetPwdAction:(UIButton *)sender {
    NSLog(@"forget the password");
}

//查询账号密码是否正确
- (IBAction)loginButtonAction:(UIButton *)sender {
    if (self.userNameTextField.text != NULL) {
        if (self.passWordTextField.text != NULL) {
            //都有数据的情况下，请求查询
            BmobQuery *bquery = [BmobQuery queryWithClassName:@"UserModel"];
            [bquery whereKey:@"phone" equalTo:self.userNameTextField.text];
            [bquery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
                if (number == 0) {
                    UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"提示" message:@"该用户不存在，请重新输入。" delegate:self cancelButtonTitle:@"重新输入" otherButtonTitles:nil, nil];
                    [view show];
                }
            }];
            
            [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
                if (!error) {
                    for (BmobObject *obj in array) {
                        //打印playerName
                        NSLog(@"phone = %@", [obj objectForKey:@"phone"]);
                        NSLog(@"pwd = %@", [obj objectForKey:@"pwd"]);
                        //打印objectId,createdAt,updatedAt
                        //                    NSLog(@"obj.objectId = %@", [obj objectId]);
                        //                    NSLog(@"obj.createdAt = %@", [obj createdAt]);
                        //                    NSLog(@"obj.updatedAt = %@", [obj updatedAt]);
                        if (![self.passWordTextField.text isEqualToString:[obj objectForKey:@"pwd"]]) {
                            UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"提示" message:@"密码不正确，请重新输入。" delegate:self cancelButtonTitle:@"重新输入" otherButtonTitles:nil, nil];
                            [view show];
                        }else {
                            MainViewController *vc = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
                            [self presentViewController:[[UINavigationController alloc] initWithRootViewController:vc] animated: YES completion:nil];
                        }
                    }
                }else
                {
                    NSLog(@"%@",error);
                }
                
            }];
        }
    }
    
}
- (IBAction)registButtonAction:(UIButton *)sender {
    
    RegistViewController *registVC = [[RegistViewController alloc] initWithNibName:@"RegistViewController" bundle:[NSBundle mainBundle]];
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:registVC] animated:YES completion:^{
        
    }];
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

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField.tag == 101) {
        
    }else if (textField.tag == 102) {

    }
}
//控制输入字符长度
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    int MAX_CHARS = 30;
    
    NSMutableString *newtxt = [NSMutableString stringWithString:textField.text];
    
    [newtxt replaceCharactersInRange:range withString:string];
    
    //输入密码字符个数大于0时，忘记密码按钮隐藏
    if (textField.tag == 102) {
        if ([newtxt length] == 0) {
            [self.forgetPwdButton setHidden:NO];
        } else {
            [self.forgetPwdButton setHidden:YES];
        }
    }

    return ([newtxt length] <= MAX_CHARS);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
