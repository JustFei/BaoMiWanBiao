//
//  FolderViewController.m
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/8/25.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "FolderViewController.h"
#import "FolderContentView.h"
#import "FolderPhotoCell.h"

// 宽
#define kScreenW [UIScreen mainScreen].bounds.size.width
// 高
#define kScreenH [UIScreen mainScreen].bounds.size.height

@interface FolderViewController ()
{
    UIButton *_leftButton;
    UIButton *_rightButton;
}

@property (weak, nonatomic) FolderContentView *folderView;

@end

@implementation FolderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor = [UIColor whiteColor];
    //修改navigationbar
    self.navigationItem.title = @"密码本";
    //左侧返回按键设置
    
    _leftButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 55, 30)];
    [_leftButton setTitle:@" 取消" forState:UIControlStateNormal];
    [_leftButton setFont:[UIFont systemFontOfSize:14]];
    [_leftButton setTitleColor:[UIColor colorWithWhite:1.0 alpha:0] forState:UIControlStateNormal];
    [_leftButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [_leftButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBackItem = [[UIBarButtonItem alloc] initWithCustomView:_leftButton];
    self.navigationItem.leftBarButtonItem = leftBackItem;
    
//    UIButton *rightEditItem = [[UIButton alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(editPhotos:)];
    _rightButton = [[UIButton alloc] init];
    [_rightButton setTitle:@"编辑" forState:UIControlStateNormal];
    [_rightButton setFont:[UIFont systemFontOfSize:15]];
    [_rightButton addTarget:self action:@selector(editPhotos:) forControlEvents:UIControlEventTouchUpInside];
    _rightButton.frame = CGRectMake(kScreenW - 50 , 10, 60, 30);
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:_rightButton];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    self.folderView.backgroundColor = [UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
}

#pragma mark - navigationbar左右按钮的事件
- (void)backAction
{
    if (self.folderView.photoTableView.editing) {
        //这里执行退出编辑模式
        [self.folderView.photoTableView setEditing:NO animated:YES];
        
        //改变左侧按钮的title
        [_leftButton setTitleColor:[UIColor colorWithWhite:1.0 alpha:0] forState:UIControlStateNormal];
        
        //改变右侧按钮状态和title
        _rightButton.selected = !_rightButton.selected;
        [_rightButton setTitle:@"编辑" forState:UIControlStateNormal];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

- (void)editPhotos:(UIButton *)sender
{
    //如果在编辑title下，点击就变成全选
    if ([sender.titleLabel.text isEqualToString:@"编辑"]) {
        [sender setTitle:@"全选" forState:UIControlStateNormal];
        [_leftButton setTitleColor:[UIColor colorWithWhite:1.0 alpha:1] forState:UIControlStateNormal];
        if (self.folderView.localPhotos.count != 0) {
            if (self.folderView.photoTableView.isEditing) {
                [self.folderView.photoTableView setEditing:NO animated:YES];
                
                //将删除图片按钮最前置
                self.folderView.addImageButton.hidden = NO;
                self.folderView.deleteImageButton.hidden = YES;
            }else {
                [self.folderView.photoTableView setEditing:YES animated:YES];
                
                //将添加图片按钮最前置
                self.folderView.addImageButton.hidden = YES;
                self.folderView.deleteImageButton.hidden = NO;
            }
        }
        
        self.folderView.changeRightItemTitleblock = ^() {
            [sender setTitle:@"编辑" forState:UIControlStateNormal];
            [_leftButton setTitleColor:[UIColor colorWithWhite:1.0 alpha:0] forState:UIControlStateNormal];
        };
        
        //启动表格的编辑模式
        [self.folderView.photoTableView setEditing:YES animated:YES];
        //如果在全选title下，点击就变成取消全选
    }else if ([sender.titleLabel.text isEqualToString:@"全选"]){
        [sender setTitle:@"取消全选" forState:UIControlStateNormal];
        
        //全选所有数据
        //先删除之前添加到 deleteDataArray 数组中的数据
        [self.folderView.deleteDataArray removeAllObjects];
        //再添加所有数据
        [self.folderView.deleteDataArray addObjectsFromArray:self.folderView.localPhotos];
        [self.folderView.dataDic removeAllObjects];
        
        for (int i = 0; i < self.folderView.localPhotos.count; i ++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
            //设为选中状态
            [self.folderView.photoTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
            [self.folderView.dataDic setObject:[self.folderView.localPhotos objectAtIndex:indexPath.row] forKey:indexPath];
        }
        
        //如果在取消全选下，点击就变回全选
    }else if([sender.titleLabel.text isEqualToString:@"取消全选"]) {
        [sender setTitle:@"全选" forState:UIControlStateNormal];

        [self.folderView.deleteDataArray removeAllObjects];
        
        for (int i = 0; i < self.folderView.localPhotos.count; i ++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
            //取消选中状态
            [self.folderView.photoTableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark  - 懒加载
- (FolderContentView *)folderView
{
    if (!_folderView) {
        FolderContentView *view = [[FolderContentView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64)];
        view.backgroundColor = [UIColor yellowColor];
        
        [self.view addSubview: view];
        _folderView = view;
    }
    
    return _folderView;
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
