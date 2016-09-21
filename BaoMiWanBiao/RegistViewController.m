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
#import <BmobSDK/BmobSMS.h>
#import "UserInfoViewController.h"
#import "MBProgressHUD.h"

@interface RegistViewController ()<UIAlertViewDelegate,UITextFieldDelegate>
{
    int seconds;
    NSTimer *countDown;
}
@end

@implementation RegistViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    seconds = 60;
    [self modifyUI];
}

- (void)modifyUI
{
    self.navigationItem.title = @"注册";
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonAction)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    self.phoneNumberView.layer.borderWidth= 1.0f;
    self.phoneNumberView.layer.borderColor= [UIColor colorWithRed:204.0 / 255.0 green:204.0 / 255.0 blue:204.0 / 255.0 alpha:1].CGColor;
    
    //验证码输入框UI设置
    self.safeCodeView.layer.borderWidth= 1.0f;
    self.safeCodeView.layer.borderColor= [UIColor colorWithRed:204.0 / 255.0 green:204.0 / 255.0 blue:204.0 / 255.0 alpha:1].CGColor;
    
    //两次密码输入框
    //第一次
    self.firstEnterPwdView.layer.borderWidth= 1.0f;
    self.firstEnterPwdView.layer.borderColor= [UIColor colorWithRed:204.0 / 255.0 green:204.0 / 255.0 blue:204.0 / 255.0 alpha:1].CGColor;
    
    //第二次
    self.secondEnterPwdView.layer.borderWidth= 1.0f;
    self.secondEnterPwdView.layer.borderColor= [UIColor colorWithRed:204.0 / 255.0 green:204.0 / 255.0 blue:204.0 / 255.0 alpha:1].CGColor;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{

    if (textField.tag == 101) {
        if(range.length + range.location > textField.text.length)
        {
            return NO;
        }
        
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        return newLength <= 11;
    }else
    if (textField.tag == 102) {
        if(range.length + range.location > textField.text.length)
        {
            return NO;
        }
        
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        return newLength <= 6;
    }else
    if (textField.tag == 103 || textField.tag == 104) {
        if(range.length + range.location > textField.text.length)
        {
            return NO;
        }
        
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        return newLength <= 8;
    }
    
    return YES;
    
    
    
#if 0
    int pwdStrong = [self validatePassword];
    switch (pwdStrong) {
        case 1:
            DeBugLog(@"弱");
            break;
        case 2:
            DeBugLog(@"中");
            break;
        case 3:
            DeBugLog(@"中强");
            break;
        case 4:
            DeBugLog(@"强");
            
        default:
            break;
    }
#endif
    
//    if(range.length + range.location > textField.text.length)
//    {
//        return NO;
//    }
//    
//    NSUInteger newLength = [textField.text length] + [string length] - range.length;
//    return newLength <= 11;
    
//    return YES;
}

#pragma mark - 点击事件
- (IBAction)getSafeCodeAction:(UIButton *)sender {
    
    if ([self isMobileNumber: self.phoneNumberTextField.text]) {
        //验证次号码是否已经存在
        //查找UserModel表
        BmobQuery   *bquery = [BmobQuery queryWithClassName:@"UserModel"];
        //添加playerName不是小明的约束条件
        [bquery whereKey:@"phone" equalTo:self.phoneNumberTextField.text];
        [bquery countObjectsInBackgroundWithBlock:^(int number,NSError  *error){
            DeBugLog(@"%d",number);
            
            //如果存在，提示换号码
            if (number > 0) {
                UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"提示" message:@"该号码已被注册，请换个号码试试！" delegate:self cancelButtonTitle:@"重新输入" otherButtonTitles:nil, nil];
                [view show];
            }else {
                //不存在，就请求验证码
                
                //改变获取验证码按钮为60秒倒计时
                [self changeGetSafeCodeButtonState];
                
                //显示等待菊花
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                //请求验证码
                [BmobSMS requestSMSCodeInBackgroundWithPhoneNumber:self.phoneNumberTextField.text andTemplate:@"密保宝" resultBlock:^(int number, NSError *error) {
                    if (error) {
                        DeBugLog(@"%@",error);
                        UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"提示" message:@"验证码发送失败，请检查当前网络状态" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                        [view show];
                        
                        //隐藏等待菊花
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                    } else {
                        //获得smsID
                        DeBugLog(@"sms ID：%d",number);
                        UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"提示" message:@"验证码已发送，请注意查收" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
                        [view show];
                        
                        //隐藏等待菊花
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                    }
                }];
            }
        }];
    }else {
        UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入正确的手机号" delegate:self cancelButtonTitle:@"重新输入" otherButtonTitles:nil, nil];
        [view show];
    }
}

- (IBAction)NextStepButtonAction:(UIButton *)sender {
    
    if ([self.firstEnterPwdTextField.text isEqualToString:self.secondEnterPwdTextField.text]) {
        
        //显示等待菊花
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        //验证
        [BmobSMS verifySMSCodeInBackgroundWithPhoneNumber:self.phoneNumberTextField.text andSMSCode:self.safeCodeTextField.text resultBlock:^(BOOL isSuccessful, NSError *error) {
            if (isSuccessful) {
                DeBugLog(@"%@",@"验证成功，可执行用户请求的操作");
                //验证码验证成功后，停止定时器
                [self releaseTImer];
                
                //隐藏等待菊花
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                
                //传递model给下一个控制器
                UserModel *model = [[UserModel alloc] init];
                model.phone = self.phoneNumberTextField.text;
                model.pwd = self.secondEnterPwdTextField.text;
                UserInfoViewController *vc = [[UserInfoViewController alloc] initWithNibName:@"UserInfoViewController" bundle:nil];
                vc.userModel = model;
                [self.navigationController pushViewController:vc animated:YES];
            } else {
                DeBugLog(@"%@",error);
                UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"提示" message:@"验证码输入错误，请重新输入。" delegate:self cancelButtonTitle:@"重新输入" otherButtonTitles:nil, nil];
                [view show];
                //隐藏等待菊花
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            }
        }];
    
    }else
    {
        UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"提示" message:@"两次输入的密码不一致，请重新输入。" delegate:self cancelButtonTitle:@"重新输入" otherButtonTitles:nil, nil];
        [view show];
    }
    
    
    
}
- (void)backButtonAction{
    
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

- (void)changeGetSafeCodeButtonState
{
    self.getSafeCode.enabled = NO;
    
    countDown = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerFireMethod:) userInfo:nil repeats:YES];
    
}
                          
-(void)timerFireMethod:(NSTimer *)theTimer {
    if (seconds == 1) {
        [theTimer invalidate];
        seconds = 60;
        [self.getSafeCode setTitle:@"获取验证码" forState: UIControlStateNormal];
        [self.getSafeCode setTitleColor:UIColorFromRGBWithAlpha(0x2c91F4, 1) forState:UIControlStateNormal];
        [self.getSafeCode setEnabled:YES];
    }else{
        seconds--;
        NSString *title = [NSString stringWithFormat:@"%d秒后尝试",seconds];
        [self.getSafeCode setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.getSafeCode setEnabled:NO];
        [self.getSafeCode setTitle:title forState:UIControlStateNormal];
    }
}

//如果登陆成功，停止验证码的倒数，
- (void)releaseTImer {
    if (countDown) {
        if ([countDown respondsToSelector:@selector(isValid)]) {
            if ([countDown isValid]) {
                [countDown invalidate];
                seconds = 60;
            }
        }
    }
}

#pragma mark - 正则表达式
//判断手机号格式
- (BOOL)isMobileNumber:(NSString *)mobileNum
{
    if (mobileNum.length != 11)
    {
        return NO;
    }
    /**
     * 手机号码:
     * 13[0-9], 14[5,7], 15[0, 1, 2, 3, 5, 6, 7, 8, 9], 17[0, 1, 6, 7, 8], 18[0-9]
     * 移动号段: 134,135,136,137,138,139,147,150,151,152,157,158,159,170,178,182,183,184,187,188
     * 联通号段: 130,131,132,145,152,155,156,170,171,176,185,186
     * 电信号段: 133,134,153,170,177,180,181,189
     */
    NSString *MOBILE = @"^1(3[0-9]|4[57]|5[0-35-9]|7[01678]|8[0-9])\\d{8}$";
    /**
     * 中国移动：China Mobile
     * 134,135,136,137,138,139,147,150,151,152,157,158,159,170,178,182,183,184,187,188
     */
    NSString *CM = @"^1(3[4-9]|4[7]|5[0-27-9]|7[08]|8[2-478])\\d{8}$";
    /**
     * 中国联通：China Unicom
     * 130,131,132,145,152,155,156,170,171,176,185,186
     */
    NSString *CU = @"^1(3[0-2]|4[5]|5[256]|7[016]|8[56])\\d{8}$";
    /**
     * 中国电信：China Telecom
     * 133,134,153,170,177,180,181,189
     */
    NSString *CT = @"^1(3[34]|53|7[07]|8[019])\\d{8}$";
    
    
    NSPredicate *regexmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regexcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regexcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regexct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    
    if (([regexmobile evaluateWithObject:mobileNum] == YES)
        || ([regexcm evaluateWithObject:mobileNum] == YES)
        || ([regexct evaluateWithObject:mobileNum] == YES)
        || ([regexcu evaluateWithObject:mobileNum] == YES))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (int)validatePassword

{
    int count = 0;
//    NSString * length = @"^\\w{6,18}$";//长度
    
    NSString * number = @"^\\w*\\d+\\w*$";//数字
    
    NSString * lower = @"^\\w*[a-z]+\\w*$";//小写字母
    
    NSString * upper = @"^\\w*[A-Z]+\\w*$";//大写字母
    
    NSString * punct = @"/^[:punct:]+$/x";
    
    NSPredicate *regexnumber = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",number];
    NSPredicate *regexlower = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",lower];
    NSPredicate *regexupper = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",upper];
    NSPredicate *regexpunct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",punct];
    
    BOOL isHaveNumber = [regexnumber evaluateWithObject: self.firstEnterPwdTextField.text];
    BOOL isHaveLower = [regexlower evaluateWithObject:self.firstEnterPwdTextField.text];
    BOOL isHaveUpper = [regexupper evaluateWithObject:self.firstEnterPwdTextField.text];
    BOOL isHavePunct = [regexpunct evaluateWithObject:self.firstEnterPwdTextField.text];
    
//    return [self validateWithRegExp: number] && [self validateWithRegExp: lower] && [self validateWithRegExp: upper];
    
    if (isHaveNumber) {
        count ++;
    }
    if (isHaveLower) {
        count ++;
    }
    if (isHaveUpper) {
        count ++;
    }
    if (isHavePunct) {
        count ++;
    }
    
    return count;
}

//- (BOOL)validateWithRegExp: (NSString *)regExp
//
//{
//    
//    NSPredicate * predicate = [NSPredicate predicateWithFormat: @"SELF MATCHES %@", regExp];
//    
//    return [predicate evaluateWithObject: self.firstEnterPwdTextField.text];
//    
//}

@end
