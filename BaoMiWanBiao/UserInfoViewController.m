//
//  UserInfoViewController.m
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/8/31.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "UserInfoViewController.h"
#import "MainViewController.h"
#import "MBProgressHUD.h"

@interface UserInfoViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    BOOL showList;//是否弹出下拉列表
    NSInteger questionNumber;
}
@property (nonatomic ,strong) NSArray *dataArr;

@property (nonatomic ,weak) UITableView *questionTableView;

@end

@implementation UserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    XXFLog(@"phont = %@,pwd = %@",self.userModel.phone ,self.userModel.pwd);
    [self motifyUI];
    _dataArr = @[@"您父亲的名字是？",@"你的学号是？",@"您配偶的生日是？",@"您母亲的名字是？",@"对您影响最大的人是？",@"您配偶的名字是？"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    showList = NO; //默认不显示下拉框
}

- (void)motifyUI
{
    self.idNumberView.layer.borderWidth = 1.0f;
    [self.idNumberView.layer setBorderColor:[UIColor colorWithRed:204.0 / 255.0 green:204.0 / 255.0 blue:204.0 / 255.0 alpha:1].CGColor];
    self.reservedQuestionView.layer.borderWidth = 1.0f;
    [self.reservedQuestionView.layer setBorderColor:[UIColor colorWithRed:204.0 / 255.0 green:204.0 / 255.0 blue:204.0 / 255.0 alpha:1].CGColor];
    self.answerView.layer.borderWidth = 1.0f;
    [self.answerView.layer setBorderColor:[UIColor colorWithRed:204.0 / 255.0 green:204.0 / 255.0 blue:204.0 / 255.0 alpha:1].CGColor];
    self.answerTextField.enabled = NO;
    
    //开启预留问题的点击效果
    self.reservedQuestionView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dropdown)];
    [self.reservedQuestionView addGestureRecognizer:tap];
}

-(void)dropdown{
//    [textField resignFirstResponder];
    if (showList) {//如果下拉框已显示，什么都不做
        CGRect sf = self.questionTableView.frame;
        
        //把dropdownList放到前面，防止下拉框被别的控件遮住
        [self.view bringSubviewToFront:self.questionTableView];
        
        showList = NO;//显示下拉框
        self.questionTableView.frame = sf;
        [UIView beginAnimations:@"ResizeForKeyBoard1" context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        sf.size.height = 0;
        self.questionTableView.frame = sf;
        
        [UIView commitAnimations];
//        self.questionTableView.hidden = YES;
        
    }else {//如果下拉框尚未显示，则进行显示
        
        CGRect sf = self.questionTableView.frame;
        
        //把dropdownList放到前面，防止下拉框被别的控件遮住
        [self.view bringSubviewToFront:self.questionTableView];
        self.questionTableView.hidden = NO;
        showList = YES;//显示下拉框
        self.questionTableView.frame = sf;
        [UIView beginAnimations:@"ResizeForKeyBoard" context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        sf.size.height = 200;
        self.questionTableView.frame = sf;

        [UIView commitAnimations];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;
    }
    
    cell.textLabel.text = [_dataArr objectAtIndex:[indexPath row]];
    cell.textLabel.font = [UIFont systemFontOfSize:8.0f];
    cell.accessoryType  = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 35;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    questionNumber = indexPath.row;
    self.reservedQuestionLabel.text = [_dataArr objectAtIndex:[indexPath row]];
    showList = NO;
    self.questionTableView.hidden = YES;
    
    CGRect sf = self.questionTableView.frame;
    sf.size.height = 30;
    self.questionTableView.frame = sf;
    CGRect frame = self.questionTableView.frame;
    frame.size.height = 0;
    self.questionTableView.frame = frame;
    
    self.answerTextField.enabled = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 点击事件
- (IBAction)sureButtonAction:(UIButton *)sender {
    
    UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请完善用户信息" delegate:self cancelButtonTitle:@"重新输入" otherButtonTitles:nil, nil];
    if (self.idNumberTextField.text != NULL) {
        if (self.answerTextField.text != NULL) {
            self.userModel.identityCode = self.idNumberTextField.text;
            self.userModel.question = questionNumber;
            self.userModel.answer = self.answerTextField.text;
            
            //显示等待菊花
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            //这里上传所有的用户数据
            //往GameScore表添加一条playerName为小明，分数为78的数据
            BmobObject *gameScore = [BmobObject objectWithClassName:@"UserModel"];
            [gameScore setObject:self.userModel.phone forKey:@"phone"];
            [gameScore setObject:self.userModel.pwd forKey:@"pwd"];
            [gameScore setObject:self.userModel.identityCode forKey:@"identityCode"];
            [gameScore setObject:[NSNumber numberWithInteger:self.userModel.question] forKey:@"question"];
            [gameScore setObject:self.userModel.answer forKey:@"answer"];
            [gameScore saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
                //进行操作
                if (isSuccessful) {
                    XXFLog(@"数据上传成功");
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    
                    
                }
            }];
            //最后一次登陆的时间
            [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"LastLogin"];
            //这里保存用户名到本地
            [[NSUserDefaults standardUserDefaults] setObject:self.userModel.phone forKey:@"UserName"];
            
        }else {
            [view show];
        }
        
    }else {
        [view show];
    }
    
    
    MainViewController *vc = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

//点击屏幕除了键盘其他的地方
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self hiddenKeyboard];
//    [self hiddenQuestionTableView];
}

- (void)hiddenKeyboard
{
    //收起键盘
    if (![self.idNumberTextField isExclusiveTouch]) {
        [self.idNumberTextField resignFirstResponder];
    }
    if (![self.answerTextField isExclusiveTouch]) {
        [self.answerTextField resignFirstResponder];
    }
}

- (void)hiddenQuestionTableView
{
    if (showList) {//如果下拉框已显示，什么都不做
        CGRect sf = self.questionTableView.frame;
        
        //把dropdownList放到前面，防止下拉框被别的控件遮住
        [self.view bringSubviewToFront:self.questionTableView];
        
        showList = NO;//显示下拉框
        self.questionTableView.frame = sf;
        [UIView beginAnimations:@"ResizeForKeyBoard" context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        sf.size.height = 0;
        self.questionTableView.frame = sf;
        
        [UIView commitAnimations];
        self.questionTableView.hidden = YES;
        return;
    }
}

#pragma mark - 懒加载
- (UITableView *)questionTableView
{
    if (!_questionTableView) {
        UITableView *view = [[UITableView alloc] initWithFrame:CGRectMake(12, self.reservedQuestionView.frame.origin.y + 44, self.view.frame.size.width - 24, 0) style:UITableViewStylePlain];
        view.delegate = self;
        view.dataSource = self;
        view.backgroundColor = [UIColor grayColor];
        view.separatorColor = [UIColor lightGrayColor];
        view.hidden = YES;
        
        [self.view addSubview:view];
        _questionTableView = view;
    }
    
    return _questionTableView;
}

@end
