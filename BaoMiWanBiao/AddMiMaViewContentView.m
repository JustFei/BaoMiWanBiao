//
//  AddMiMaViewContentView.m
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/7/29.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "AddMiMaViewContentView.h"
#import "AddMiMaCell.h"
#import "FMDB.h"
#import "PasswordNoteModel.h"
#import "XxfFmdbTool.h"

@interface AddMiMaViewContentView ()<UITableViewDelegate, UITableViewDataSource>
{
    NSArray *_categoryItemText;
}

//输入条目的列表
@property (nonatomic ,weak)UITableView *textTableView;

//加密按钮
@property (nonatomic ,weak)UIButton *jiamiButton;

//确定添加按钮
@property (nonatomic ,weak)UIButton *sureButton;

//删除按钮
@property (nonatomic ,weak)UIButton *deleteButton;

//底部View
@property (nonatomic ,weak)UIView *tabbarView;

//用户密码本数据模型
@property (nonatomic ,strong)PasswordNoteModel *accountModel;

//数据库工具
@property (nonatomic ,strong)XxfFmdbTool *tool;

@end

@implementation AddMiMaViewContentView

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.textTableView.backgroundColor = [UIColor whiteColor];
    self.jiamiButton.backgroundColor = [UIColor whiteColor];
    
    self.tabbarView.frame = CGRectMake(0, self.frame.size.height - 49, self.frame.size.width, 49);
    self.deleteButton.frame = CGRectMake(12, 10, self.tabbarView.frame.size.width / 2 - 12 - 18, self.tabbarView.frame.size.height - 20);
    self.sureButton.frame = CGRectMake(self.center.x + 18, 10, self.tabbarView.frame.size.width / 2 - 12 - 18, self.tabbarView.frame.size.height - 20);
    
}

#pragma mark - 按钮点击事件
//加密按钮点按事件
- (void)selectJiami
{
    if (!self.jiamiButton.selected) {
        
        //选中状态，隐藏所有文字
        [self.jiamiButton setSelected:YES];
        
        NSArray * cellArr = [self.textTableView visibleCells];
        
        //遍历当前表可视的cell，
        for (int index = 0; index < cellArr.count; index ++) {
            
            AddMiMaCell *cell = cellArr[index];
            
            switch (index) {
                case 0:
                    cell.infoTextField.secureTextEntry = YES;
                    break;
                case 1:
                    cell.infoTextField.secureTextEntry = YES;
                    break;
                case 2:
                    cell.infoTextField.secureTextEntry = YES;
                    break;
                case 3:
                    cell.infoTextField.secureTextEntry = YES;
                    break;
                    
                default:
                    break;
            }
        }
    }else {
        
        //非选中状态，显示所有文字
        [self.jiamiButton setSelected:NO];
        
        NSArray * cellArr = [self.textTableView visibleCells];
        
        //遍历当前表可视的cell，
        for (int index = 0; index < cellArr.count; index ++) {
            
            AddMiMaCell *cell = cellArr[index];
            
            switch (index) {
                case 0:
                    cell.infoTextField.secureTextEntry = NO;
                    break;
                case 1:
                    cell.infoTextField.secureTextEntry = NO;
                    break;
                case 2:
                    cell.infoTextField.secureTextEntry = NO;
                    break;
                case 3:
                    cell.infoTextField.secureTextEntry = NO;
                    break;
                    
                default:
                    break;
            }
        }
    }
}

//确定按钮
- (void)sureAction
{
    NSLog(@"确定按钮");

    NSArray * cellArr = [self.textTableView visibleCells];
    
    //遍历当前表可视的cell，
    for (int index = 0; index < cellArr.count; index ++) {
        
        AddMiMaCell *cell = cellArr[index];
        
        switch (index) {
            case 0:
                self.accountModel.name = cell.infoTextField.text;
                break;
            case 1:
                self.accountModel.account = cell.infoTextField.text;
                break;
            case 2:
                self.accountModel.password = cell.infoTextField.text;
                break;
            case 3:
                self.accountModel.memorandum = cell.infoTextField.text;
                break;
                
            default:
                break;
        }
    }
    
    _accountModel.isEncrypt = self.jiamiButton.isSelected;
    
    BOOL result = [self.tool insertModel:self.accountModel];
    
    NSLog(@"写入数据库状态：%d",result);
    
    UIViewController *vc = [self findViewController:self];
    
    /**
     *  还没有实现跳转回去
     */
    [vc.navigationController popViewControllerAnimated:YES];
    
}

//删除按钮
- (void)deleteAction
{
    NSArray * cellArr = [self.textTableView visibleCells];
    
    PasswordNoteModel *model = [[PasswordNoteModel alloc] init];
    
    //遍历当前表可视的cell，
    for (int index = 0; index < cellArr.count; index ++) {
        
        AddMiMaCell *cell = cellArr[index];
        
        switch (index) {
            case 0:
                model.name = cell.infoTextField.text;
                break;
//            case 1:
//                model.account = cell.infoTextField.text;
//                break;
//            case 2:
//                model.password = cell.infoTextField.text;
//                break;
//            case 3:
//                model.memorandum = cell.infoTextField.text;
//                break;
                
            default:
                break;
        }
    }
#warning SQL删除语句只能对列表中的某一项下面的某个值进行删除，如果该值存在同名的情况，会导致数据库误删除的操作，回头改成根据ID删除
    NSString *SQLdelete = [NSString stringWithFormat:@"DELETE FROM PasswordNoteTable WHERE name = '%@'",model.name ];
    
    [self.tool deleteData:SQLdelete];
    
}

//点击键盘其他区域收起键盘，退出编辑模式
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self endEditing:YES];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _categoryItemText.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AddMiMaCell *cell = [tableView dequeueReusableCellWithIdentifier:@"addmimacell"];
    
    cell.categoryItem.text = _categoryItemText[indexPath.row];
    cell.infoTextField.placeholder = @"请输入相关信息";
    cell.infoTextField.textAlignment = NSTextAlignmentRight;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

#pragma mark - 懒加载
//输入信息内容框
- (UITableView *)textTableView
{
    if (!_textTableView) {
        UITableView *tbView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, self.frame.size.width, self.frame.size.width * 0.625) style:UITableViewStylePlain];
        tbView.backgroundColor = [UIColor whiteColor];
        
        tbView.delegate = self;
        tbView.dataSource = self;
        
        tbView.scrollEnabled = NO;
        tbView.allowsSelection = NO;
        tbView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        
        _categoryItemText = [[NSArray alloc] initWithObjects:@"名称", @"账号", @"密码", @"注释", nil];
        
        [self addSubview:tbView];
        
        [tbView registerNib:[UINib nibWithNibName:@"AddMiMaCell" bundle:nil] forCellReuseIdentifier:@"addmimacell"];
        _textTableView = tbView;
    }
    return _textTableView;
}

//加密按钮
- (UIButton *)jiamiButton
{
    if (!_jiamiButton) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(15, self.textTableView.frame.size.height + 30, 20 , 20)];
        [btn setImage:[UIImage imageNamed:@"no_select.png"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"select.png"] forState:UIControlStateSelected];
        
        [btn addTarget:self action:@selector(selectJiami) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        
        _jiamiButton = btn;
    }
    
    return _jiamiButton;
}

//确定按钮
- (UIButton *)sureButton
{
    if (!_sureButton) {
        UIButton *btn = [[UIButton alloc] init];
        [btn addTarget:self action:@selector(sureAction) forControlEvents:UIControlEventTouchUpInside];
        [btn setTitle:@"确定" forState:UIControlStateNormal];
        [btn setTintColor:[UIColor blackColor]];
        [btn setBackgroundColor:[UIColor blueColor]];
    
        [self.tabbarView addSubview:btn];
        _sureButton = btn;
    }
    
    return _sureButton;
}

//删除按钮
- (UIButton *)deleteButton
{
    if (!_deleteButton) {
        UIButton *btn = [[UIButton alloc] init];
        [btn addTarget:self action:@selector(deleteAction) forControlEvents:UIControlEventTouchUpInside];
        [btn setTitle:@"删除" forState:UIControlStateNormal];
        [btn setTintColor:[UIColor blackColor]];
        [btn setBackgroundColor:[UIColor grayColor]];
        
        [self.tabbarView addSubview:btn];
        _deleteButton = btn;
    }
    
    return _deleteButton;
}

//底部tabbar视图
- (UIView *)tabbarView
{
    if (!_tabbarView) {
        UIView *view = [[UIView alloc] init];
        
        [self addSubview:view];
        _tabbarView = view;
    }
    
    return _tabbarView;
}

//用户账户数据模型
- (PasswordNoteModel *)accountModel
{
    if (!_accountModel) {
        _accountModel = [[PasswordNoteModel alloc] init];
    }
    
    return _accountModel;
}

//
- (XxfFmdbTool *)tool
{
    if (!_tool) {
        NSString *userPhone = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserName"];
        XxfFmdbTool *tool = [[XxfFmdbTool alloc] initWithPath:userPhone];
        
        _tool = tool;
    }
    return _tool;
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
