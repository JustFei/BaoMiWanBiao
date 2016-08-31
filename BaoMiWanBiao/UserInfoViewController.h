//
//  UserInfoViewController.h
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/8/31.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserModel.h"

@interface UserInfoViewController : UIViewController

//提交的用户信息model
@property (nonatomic ,strong) UserModel *userModel;

//身份证View
@property (weak, nonatomic) IBOutlet UIView *idNumberView;
//身份证输入框
@property (weak, nonatomic) IBOutlet UITextField *idNumberTextField;

//预留问题Label
@property (weak, nonatomic) IBOutlet UILabel *reservedQuestionLabel;
//预留问题View
@property (weak, nonatomic) IBOutlet UIView *reservedQuestionView;

//答案View
@property (weak, nonatomic) IBOutlet UIView *answerView;
//答案输入框
@property (weak, nonatomic) IBOutlet UITextField *answerTextField;
@end
