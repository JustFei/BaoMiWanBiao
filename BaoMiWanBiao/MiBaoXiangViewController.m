//
//  MiBaoXiangViewController.m
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/7/26.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "MiBaoXiangViewController.h"
#import "ShouDongJiaMiWenJianJIaTableViewCell.h"
#import "LocalPhotoViewController.h"
#import "PhotoShowViewController.h"
#import "ASProgressPopUpView.h"
#import "FolderPhotoViewController.h"

#import "SM4-OCMethod.h"

//SM4加密
//#import "sms4.h"
//#import "sm4test.h"

#define WIDTH self.view.frame.size.width
#define HEIGHT self.view.frame.size.height

@interface MiBaoXiangViewController ()<UITableViewDelegate,UITableViewDataSource,FolderSelectPhotoDelegate,ASProgressPopUpViewDataSource>
{
    //选中图片数组，也是TableView的数据源
    NSMutableArray *_selectPhotos;
    
    //存储到本地沙盒缩略图中的图片数组
    NSMutableArray *_localPhotos;
    //存储到本地沙盒JiaMi文件夹中的图片数组（以后存储到数据库当中）
    NSMutableArray *_jiamiPhotosArr;
    
    UIButton *_addImageButton;
    UIButton *_deleteImageButton;
    
    NSString *userPhone;
    
    UIButton *_leftButton;
    UIButton *_rightButton;
}

@property (nonatomic ,weak) UITableView *photoView;

//存储着多选删除的多个图片的信息，key：选中cell的indexPath，value：这张图片的路径
@property (nonatomic ,strong) NSMutableDictionary *dataDic;

//全选删除时的数据源
@property (nonatomic, strong) NSMutableArray *deleteDataArray;

@property (weak, nonatomic) ASProgressPopUpView *addProgressView;
@property (nonatomic ,strong) SM4_OCMethod *SM4;

@end

@implementation MiBaoXiangViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
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
    userPhone = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserName"];
    
    //这里暂时注释这两个方法
    _localPhotos = [self gitImagesWithDirctory:[NSString stringWithFormat:@"%@-JiaMi",userPhone]];
    
    _jiamiPhotosArr = [self gitImagesWithDirctory:[NSString stringWithFormat:@"%@-JiaMi",userPhone]];
    
    [self creatUI];
    
    [self.addProgressView setHidden:YES];
    
}

#pragma mark - 创建UI
//创建UI
- (void)creatUI
{
    self.dataDic = [[NSMutableDictionary alloc]init];
    self.photoView.backgroundColor = [UIColor whiteColor];
    
    self.view.backgroundColor=[UIColor whiteColor];
    self.navigationItem.title=@"手动加密文件夹";
    
    //设置右边
    _rightButton = [[UIButton alloc]initWithFrame:CGRectMake(0,0,70,30)];
    [_rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_rightButton setTitle:@"编辑" forState:UIControlStateNormal];
    [_rightButton addTarget:self action:@selector(edit:)forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:_rightButton];
    self.navigationItem.rightBarButtonItem= rightItem;
    
    UIView *tabbarView = [[UIView alloc] initWithFrame:CGRectMake(0, HEIGHT - 49, WIDTH, 49)];
    tabbarView.backgroundColor = [UIColor whiteColor];
    tabbarView.layer.borderWidth = 0.5;
    tabbarView.layer.borderColor = [[UIColor grayColor] CGColor];
    
    _addImageButton = [[UIButton alloc] initWithFrame:CGRectMake(12, 10, WIDTH - 24, tabbarView.frame.size.height - 20)];
    [_addImageButton setTitle:@"添加保密文件" forState:UIControlStateNormal];
    [_addImageButton setBackgroundColor:[UIColor colorWithRed:0 green:137.0 / 255.0 blue:252.0 / 255.0 alpha:1]];
    [_addImageButton addTarget:self action:@selector(addImage) forControlEvents:UIControlEventTouchUpInside];
    _addImageButton.tag = 101;
    
    _deleteImageButton = [[UIButton alloc] initWithFrame:CGRectMake(12, 10, WIDTH - 24, tabbarView.frame.size.height - 20)];
    [_deleteImageButton setTitle:@"移除" forState:UIControlStateNormal];
    [_deleteImageButton setBackgroundColor:[UIColor redColor]];
    [_deleteImageButton addTarget:self action:@selector(deleteImages) forControlEvents:UIControlEventTouchUpInside];
    _deleteImageButton.tag = 102;
    
    [tabbarView addSubview:_deleteImageButton];
    [tabbarView addSubview:_addImageButton];
    [self.view addSubview:tabbarView];
}

//cell里面展示的是缩略图
- (NSMutableArray *)gitImagesWithDirctory:(NSString *)dir
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *DocumentDirctory = paths.firstObject;
    NSString *fileDirectory = [DocumentDirctory stringByAppendingString:[NSString stringWithFormat:@"/%@",dir]];
    NSArray *files = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:fileDirectory error:nil];
    
    NSMutableArray *mutArr = [NSMutableArray arrayWithArray:files];
    
    //循环遍历出.DS_Store 字符串
    for (NSInteger index = mutArr.count - 1; index >= 0 ; index --) {
        if ([mutArr[index] isEqualToString:@".DS_Store"]) {
            [mutArr removeObjectAtIndex:index];
            XXFLog(@"在第%ld次遍历出.DS_Store，删除后数组还剩%lu",(long)index ,(unsigned long)mutArr.count);
            
        }
    }
//    XXFLog(@"%@",mutArr);
    
    return mutArr;
}

#pragma mark - 点击事件
//编辑按钮点击事件
- (void)edit:(UIButton *)sender
{

    if (_localPhotos.count == 0) {
        return;
    }

    
    //如果在编辑title下，点击就变成全选
    if ([sender.titleLabel.text isEqualToString:@"编辑"]) {
        [sender setTitle:@"全选" forState:UIControlStateNormal];
        [_leftButton setTitleColor:[UIColor colorWithWhite:1.0 alpha:1] forState:UIControlStateNormal];
        if (_localPhotos.count != 0) {
            if (self.photoView.isEditing) {
                [self.photoView setEditing:NO animated:YES];
                
                //将删除图片按钮最前置
                _addImageButton.hidden = NO;
                _deleteImageButton.hidden = YES;
            }else {
                [self.photoView setEditing:YES animated:YES];
                
                //将添加图片按钮最前置
                _addImageButton.hidden = YES;
                _deleteImageButton.hidden = NO;
            }
        }
        
        //启动表格的编辑模式
        [self.photoView setEditing:YES animated:YES];
        //如果在全选title下，点击就变成取消全选
    }else if ([sender.titleLabel.text isEqualToString:@"全选"]){
        [sender setTitle:@"取消全选" forState:UIControlStateNormal];
        
        //全选所有数据
        //先删除之前添加到 deleteDataArray 数组中的数据
        [self.deleteDataArray removeAllObjects];
        //再添加所有数据
        [self.deleteDataArray addObjectsFromArray:_localPhotos];
        [self.dataDic removeAllObjects];
        
        for (int i = 0; i < _localPhotos.count; i ++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
            //设为选中状态
            [self.photoView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
            [self.dataDic setObject:[_localPhotos objectAtIndex:indexPath.row] forKey:indexPath];
        }
        
        //如果在取消全选下，点击就变回全选
    }else if([sender.titleLabel.text isEqualToString:@"取消全选"]) {
        [sender setTitle:@"全选" forState:UIControlStateNormal];
        
        [self.deleteDataArray removeAllObjects];
        [self.dataDic removeAllObjects];
        for (int i = 0; i < _localPhotos.count; i ++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
            //取消选中状态
            [self.photoView deselectRowAtIndexPath:indexPath animated:YES];
        }
    }
}

//添加图片按钮
- (void)addImage
{
//    LocalPhotoViewController *pick=[[LocalPhotoViewController alloc] init];
//    [pick.view setBackgroundColor:[UIColor whiteColor]];
    self.navigationItem.backBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:nil action:nil];
//    pick.selectPhotoDelegate=self;
//    _selectPhotos = pick.selectPhotos;
    FolderPhotoViewController *pick = [[FolderPhotoViewController alloc] init];
    pick.view.backgroundColor = [UIColor whiteColor];
    pick.selectPhotoDelegate = self;
    _selectPhotos = pick.selectPhotos;
    
    [self.navigationController pushViewController:pick animated:YES];
}

//返回按钮
- (void)backAction
{
    if (self.photoView.editing) {
        //这里执行退出编辑模式
        [self.photoView setEditing:NO animated:YES];
        
        //改变左侧按钮的title
        [_leftButton setTitleColor:[UIColor colorWithWhite:1.0 alpha:0] forState:UIControlStateNormal];
        
        //改变右侧按钮状态和title
        _rightButton.selected = !_rightButton.selected;
        
        //改变删除按钮
        [_addImageButton setHidden:NO];
        [_deleteImageButton setHidden:YES];
        [_rightButton setTitle:@"编辑" forState:UIControlStateNormal];
        
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

//删除图片按钮
- (void)deleteImages
{
    XXFLog(@"总共有%ld个数据",(unsigned long)self.dataDic.count);
    //以下代码是处理数据的删除的操作。
    if (self.dataDic.count != 0) {
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        //先删除本地沙盒文件
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSMutableArray *dataArr = [NSMutableArray arrayWithArray:self.dataDic.allValues];
        
        //在此创建解密文件夹，如果存在就不创建
        NSString *createJieMiDir = [paths.firstObject stringByAppendingString:[NSString stringWithFormat:@"/%@-JieMi",userPhone]];
        //判断是否存在Thumbnail文件夹，如果不存在，就创建
        if (![[NSFileManager defaultManager] fileExistsAtPath:createJieMiDir]) {
            [fileManager createDirectoryAtPath:createJieMiDir withIntermediateDirectories:YES attributes:nil error:nil];
            
        }else {
            XXFLog(@"FileDir is exists");
        }
        
        //此处为处理删除时先删除UI上的cell可以让人产生秒删的感觉，实际上后台还在慢慢的move数据。此处用了子线程异步做循环，循环里面子线程在同步做删除，这样可以做到性能和体验的最优解~
        
        //删除数据源
        [_localPhotos removeObjectsInArray:[self.dataDic allValues]];
        
        //删除界面的cell
        [self.photoView deleteRowsAtIndexPaths:[self.dataDic allKeys] withRowAnimation:UITableViewRowAnimationFade];
        
        [_rightButton setTitle:@"编辑" forState:UIControlStateNormal];
        [_leftButton setTitleColor:[UIColor colorWithWhite:1.0 alpha:0] forState:UIControlStateNormal];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //循环删除数据
            for (NSInteger index = dataArr.count - 1; index >= 0; index --) {
                @autoreleasepool {
                    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        
                        //此处为删除加密文件夹里面的内容
                        NSString *jiamiFilePath = [paths.lastObject stringByAppendingString:[NSString stringWithFormat:@"/%@-JiaMi/%@",userPhone ,dataArr[index]]];
                        NSString *moveToPath = [paths.lastObject stringByAppendingString:[NSString stringWithFormat:@"/%@-JieMi/%@",userPhone , dataArr[index]]];
                        //先判断有没有该路径
                        BOOL jiamiDirHave = [[NSFileManager defaultManager] fileExistsAtPath:jiamiFilePath];
                        BOOL jiemiDirHave = [[NSFileManager defaultManager] fileExistsAtPath:moveToPath];
                        //如果有就删除，
                        if (!jiamiDirHave) {
                            XXFLog(@"no  havejiami");
                            return ;
                        }else {
                            
                            
                            if (!jiemiDirHave) {
                                
                                //在移除前先进行解密，再移除
                                //SM4解密
                                NSData *jiamiPhotoData = [NSData dataWithContentsOfFile:jiamiFilePath options:NSDataReadingMappedIfSafe error:nil];
                                NSData *jiemiPhotoData = [self.SM4 SM4Jiemi:jiamiPhotoData];
                                
                                //如果大于1M，就分段写，如果小于的话，就直接写入
                                if (jiemiPhotoData.length <= 1024 * 1024) {
                                    [jiemiPhotoData writeToFile:moveToPath atomically:YES];
                                }else {
                                    [self writeFile:jiemiPhotoData WithFilePath:moveToPath];
                                }
                                
                                //移除加密文件夹中的
                                [fileManager removeItemAtPath:jiamiFilePath error:nil];
                                
                                [_jiamiPhotosArr removeObject:dataArr[index]];
                                
                            }else{
                                BOOL blDele= [fileManager removeItemAtPath:jiamiFilePath error:nil];
                                [_jiamiPhotosArr removeObject:dataArr[index]];
                                if (blDele) {
                                    XXFLog(@"delejiami success");
                                }else {
                                    XXFLog(@"delejiami fail");
                                }
                            }
                        }
                        
                        
                    });
                    
                    
                }
                
            }
        });
        
        
        
        //删除存储删除信息的字典dataDic
        [self.dataDic removeAllObjects];
        
        [_leftButton setTitleColor:[UIColor colorWithWhite:1.0 alpha:0] forState:UIControlStateNormal];
        [_rightButton setTitle:@"编辑" forState:UIControlStateNormal];
        
        [self.photoView setEditing:!self.photoView.editing animated:YES];
        _deleteImageButton.hidden = YES;
        _addImageButton.hidden = NO;
    }
}

//选中了几张图片
-(void)getFolderSelectedPhoto:(NSMutableArray *)photos{
    //选中的图片存储在_selectPhotos数组中
    _selectPhotos = [NSMutableArray arrayWithArray:photos];
    XXFLog(@"供选择%lu张照片",(unsigned long)[photos count]);
    
    for (NSInteger index = 0; index < _selectPhotos.count; index ++) {
        @autoreleasepool {
            //设置cell的图片和图片名字
            NSString *picName=[_selectPhotos objectAtIndex:index];
            
            //            NSString * exestr = [picName pathExtension];
            
            //异步执行自定义队列（40张图片的批量写入，内存峰值可以控制在130MB以内）(现在采用fwrite写入文件，可以做到几十M以内就可以完成写入)
            dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                NSFileManager *fileManager = [[NSFileManager alloc] init];
                
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *createJiamiDir = [paths.firstObject stringByAppendingString:[NSString stringWithFormat:@"/%@-JiaMi",userPhone]];
                //判断是否存在JiaMi文件夹，如果不存在，就创建
                if (![[NSFileManager defaultManager] fileExistsAtPath:createJiamiDir]) {
                    [fileManager createDirectoryAtPath:createJiamiDir withIntermediateDirectories:YES attributes:nil error:nil];
                    
                }else {
                    XXFLog(@"3FileDir is exists");
                }
                NSString *jiamiFilePath = [NSString stringWithFormat:@"%@/%@", createJiamiDir, picName];
                
                //获取jiemi图片路径名
                NSString *jiemiImagePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingString:[NSString stringWithFormat:@"/%@-JieMi/%@",userPhone ,picName]];
                
                NSData *imageData = [NSData dataWithContentsOfFile:jiemiImagePath options:NSDataReadingMappedIfSafe error:nil];
                NSData *jiamiData = [self.SM4 Sm4Jiami:imageData];
                
                //如果大于1M，就分段写，如果小于的话，就直接写入
                if (jiamiData.length <= 1024 * 1024) {
                    [jiamiData writeToFile:jiamiFilePath atomically:YES];
                }else {
                    [self writeFile:jiamiData WithFilePath:jiamiFilePath];
                }
                //获取本地图片路径名
                NSString *loaclImagePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingString:[NSString stringWithFormat:@"/%@-JieMi/%@",userPhone ,picName]];
                [fileManager removeItemAtPath:loaclImagePath error:nil];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    //添加加密文件夹数据源里的项目
                    _jiamiPhotosArr = [self gitImagesWithDirctory:[NSString stringWithFormat:@"%@-JiaMi",userPhone]];
                    
                    _localPhotos = [self gitImagesWithDirctory:[NSString stringWithFormat:@"%@-JiaMi",userPhone]];
                    
                    [self.addProgressView setHidden:NO];
                    //添加进度条
                    CGFloat percent = (float)(index + 1) / _selectPhotos.count;
                    [self.addProgressView setProgress:percent animated:YES];
                    
                    [self.photoView reloadData];
                });
                
            });
        }
    }
}

#pragma mark - UITableViewDelegate
//tableview 委托方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _localPhotos.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //去重用队列中根据标识符取可重用的cell
    ShouDongJiaMiWenJianJIaTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"photoimage"];
    
    //设置右侧附加按钮样式为小箭头
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    //获取本地图片路径名
    NSString *loaclImagePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingString:[NSString stringWithFormat:@"/%@-Thumbnail/%@",userPhone ,_localPhotos[indexPath.row]]];
//    XXFLog(@"%@",loaclImagePath);
    UIImage *localImage = [[UIImage alloc] initWithContentsOfFile:loaclImagePath];
    
    //从本地沙盒获取图片
    [cell.thumbnail setImage:localImage];
    cell.imageName.text = _localPhotos[indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

#pragma mark - 文件本地保存（加密操作）写入文件的方法
- (void)writeFile:(NSData *)data WithFilePath:(NSString *)filePath
{
    FILE *file = fopen([filePath UTF8String], [@"ab+" UTF8String]);
    if (file) {
        const int bufferSize = 1024 * 1024;
        // 初始化一个1M的buffer
        Byte *buffer = (Byte*)malloc(bufferSize);
        NSUInteger read = 0, offset = 0, written = 0;
        NSError* err = nil;
        if (data.length != 0)
        {
            do {
                read = bufferSize;
                if ((data.length - read) < offset) {
                    read = data.length - offset;
                }
                //更新缓冲区
                [data getBytes:buffer range:NSMakeRange(offset, read)];
                written = fwrite(buffer, sizeof(char), read, file);
                offset += read;
                XXFLog(@"%lu",(data.length - offset));
                
            } while (!(read < bufferSize) && !err);//没到结尾，没出错，ok继续
        }
        // 释放缓冲区，关闭文件
        free(buffer);
        buffer = NULL;
        fclose(file);
        file = NULL;
    }
}

#pragma mark - 左划删除
//设置编辑风格EditingStyle
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //----通过表视图是否处于编辑状态来选择是左滑删除，还是多选删除。
    if (self.photoView.editing)
    {
        //当表视图处于没有未编辑状态时选择多选删除
        return UITableViewCellEditingStyleDelete| UITableViewCellEditingStyleInsert;
    }
    else
    {
        //当表视图处于没有未编辑状态时选择左滑删除
        return UITableViewCellEditingStyleDelete;
    }
}

/*改变删除按钮的title*/
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"移除";
}

/*左划删除用到的函数*/
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        //先删除本地沙盒文件
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        //在此创建解密文件夹，如果存在就不创建
        NSString *createJieMiDir = [paths.firstObject stringByAppendingString:[NSString stringWithFormat:@"/%@-JieMi",userPhone]];
        //判断是否存在Thumbnail文件夹，如果不存在，就创建
        if (![[NSFileManager defaultManager] fileExistsAtPath:createJieMiDir]) {
            [fileManager createDirectoryAtPath:createJieMiDir withIntermediateDirectories:YES attributes:nil error:nil];
            
        }else {
            XXFLog(@"FileDir is exists");
        }
        
        //删除加密文件夹里的文件
        NSString *filePath = [paths.lastObject stringByAppendingString:[NSString stringWithFormat:@"/%@-JiaMi/%@",userPhone ,_localPhotos[indexPath.row]]];
        NSString *moveToPath = [paths.lastObject stringByAppendingString:[NSString stringWithFormat:@"/%@-JieMi/%@",userPhone ,_localPhotos[indexPath.row]]];
        //删除加密文件夹路劲数据源
        [_jiamiPhotosArr removeObject:_localPhotos[indexPath.row]];
        
        //先判断有没有该路径
        BOOL blHaveAtPath=[[NSFileManager defaultManager] fileExistsAtPath:filePath];
        BOOL blHaveMoveToPath = [[NSFileManager defaultManager] fileExistsAtPath:moveToPath];
        //如果有就删除，
        if (!blHaveAtPath) {
            XXFLog(@"no  have");
            return ;
        }else {
            
            //如果解密文件夹里有该文件命名的话，这里做出判断，将加密文件夹里的文件进行删除
            if (blHaveMoveToPath) {
                BOOL blDele= [fileManager removeItemAtPath:filePath error:nil];
                if (blDele) {
                    XXFLog(@"delete success");
                }else {
                    XXFLog(@"delete fail");
                }
            }else {
                //在移除前先进行解密，再移除
                //SM4解密
                NSData *jiamiPhotoData = [NSData dataWithContentsOfFile:filePath options:NSDataReadingMappedIfSafe error:nil];
                NSData *jiemiPhotoData = [self.SM4 SM4Jiemi:jiamiPhotoData];

                //如果大于1M，就分段写，如果小于的话，就直接写入
                if (jiemiPhotoData.length <= 1024 * 1024) {
                    [jiemiPhotoData writeToFile:moveToPath atomically:YES];
                }else {
                    [self writeFile:jiemiPhotoData WithFilePath:moveToPath];
                }
            }
        }
        
        /*此处处理自己的代码，如删除数据*/
        [_localPhotos removeObjectAtIndex:indexPath.row];
        /*删除tableView中的一行*/
        [self.photoView deleteRowsAtIndexPaths:[NSMutableArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        [self.photoView reloadData];
    }
}

#pragma mark -全选删除
//取消选中
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //dataDic就是记录选择或者取消的项的字典
    [self.dataDic removeObjectForKey:indexPath];
    if (self.dataDic.count == 0)
    {
        _addImageButton.enabled = YES;
    }
    else
    {
        _addImageButton.enabled = NO;
    }
}

//选中方法
#pragma mark -选中cell（解密操作）
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ShouDongJiaMiWenJianJIaTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (self.photoView.isEditing) {
        //把indexpath 以_dataArray的值作为key 插入到dataDic字典中
        [self.dataDic setObject:[_localPhotos objectAtIndex:indexPath.row] forKey:indexPath];
        if (self.dataDic.count == 0) {
            _addImageButton.enabled = NO;
        }
        else
        {
            _addImageButton.enabled = YES;
        }
    }else {
        //这里跳转到图片浏览控制器
        NSString *jiamiFilePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingString:[NSString stringWithFormat:@"/%@-JiaMi/%@",userPhone ,_jiamiPhotosArr[indexPath.row]]];
        NSData *jiamiPhotoData = [NSData dataWithContentsOfFile:jiamiFilePath];
        NSData *jiemiPhotoData = [self.SM4 SM4Jiemi:jiamiPhotoData];
        
        //这里判断文件为图片还是视频，分别传递到不同的控制器
        UIImage *jiemiImage = [UIImage imageWithData:jiemiPhotoData];
        
        PhotoShowViewController *psVC = [[PhotoShowViewController alloc] initWithImage:jiemiImage title:cell.imageName.text];
        
        [self.navigationController pushViewController:psVC animated:YES];
    }
}

#pragma mark - ASProgressPopUpView dataSource

// <ASProgressPopUpViewDataSource> is entirely optional
// it allows you to supply custom NSStrings to ASProgressPopUpView
- (NSString *)progressView:(ASProgressPopUpView *)progressView stringForProgress:(float)progress
{
    NSString *s;
        int a = progress * _selectPhotos.count;
        s = [NSString stringWithFormat:@"正在加密第%d张图片",a];
        XXFLog(@"%@",s);
        if (progress >= 1) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [progressView setHidden:YES];
                progressView.progress = 0.0;

            });
        }

    return s;
}

#pragma mark - 懒加载
//配置photoview相关委托
- (UITableView *)photoView
{
    if (!_photoView) {
        UITableView *view = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT - 49)];
        
        //设置代理
        view.delegate = self;
        view.dataSource = self;
        
        [self.view addSubview:view];
        
        [view registerNib:[UINib nibWithNibName:@"ShouDongJiaMiWenJianJIaTableViewCell" bundle:nil] forCellReuseIdentifier:@"photoimage"];
        _photoView = view;
    }
    return _photoView;
}

- (ASProgressPopUpView *)addProgressView
{
    if (!_addProgressView) {
        ASProgressPopUpView *view = [[ASProgressPopUpView alloc] initWithFrame:CGRectMake(10, self.view.center.y - 10, WIDTH - 20, 40)];
        
        //字体和大小
        view.font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:16];
        //线条的渐变色
        view.popUpViewAnimatedColors = @[[UIColor redColor], [UIColor orangeColor], [UIColor greenColor]];
        view.dataSource = self;
        [view setHidden:YES];
        [view showPopUpViewAnimated:YES];
        
        
        [self.view addSubview:view];
        _addProgressView = view;
    }
    
    return _addProgressView;
}

- (SM4_OCMethod *)SM4
{
    if (!_SM4) {
        _SM4 = [SM4_OCMethod new];
    }
    
    return _SM4;
}

#pragma mark - 生成缩略图
/**
 *  生成缩略图
 *
 *  @param sourceImage 原图片
 *  @param size        缩略图的尺寸
 *
 *  @return 返回缩略图
 */
-(UIImage *)imageCompressForSize:(UIImage *)sourceImage targetSize:(CGSize)size{
    
    UIImage *newImage = nil;
    
    CGSize imageSize = sourceImage.size;
    
    CGFloat width = imageSize.width;
    
    CGFloat height = imageSize.height;
    
    CGFloat targetWidth = size.width;
    
    CGFloat targetHeight = size.height;
    
    CGFloat scaleFactor = 0.0;
    
    CGFloat scaledWidth = targetWidth;
    
    CGFloat scaledHeight = targetHeight;
    
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    
    if(CGSizeEqualToSize(imageSize, size) == NO){
        
        CGFloat widthFactor = targetWidth / width;
        
        CGFloat heightFactor = targetHeight / height;
        
        if(widthFactor > heightFactor){
            
            scaleFactor = widthFactor;
            
        }
        
        else{
            
            scaleFactor = heightFactor;
            
        }
        
        scaledWidth = width * scaleFactor;
        
        scaledHeight = height * scaleFactor;
        
        if(widthFactor > heightFactor){
            
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
            
        }else if(widthFactor < heightFactor){
            
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            
        }
        
    }
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 3.0);
    
    CGRect thumbnailRect = CGRectZero;
    
    thumbnailRect.origin = thumbnailPoint;
    
    thumbnailRect.size.width = scaledWidth;
    
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    if(newImage == nil){
        
        XXFLog(@"scale image fail");
        
    }
    
    UIGraphicsEndImageContext();
    
    return newImage;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
