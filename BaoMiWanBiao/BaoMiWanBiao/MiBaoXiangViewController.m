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

#import "SM4-OCMethod.h"

//SM4加密
//#import "sms4.h"
//#import "sm4test.h"

#define WIDTH self.view.frame.size.width
#define HEIGHT self.view.frame.size.height

@interface MiBaoXiangViewController ()<UITableViewDelegate,UITableViewDataSource,SelectPhotoDelegate>
{
    //选中图片数组，也是TableView的数据源
    NSMutableArray *_selectPhotos;
    
    //存储到本地沙盒缩略图中的图片数组
    NSMutableArray *_localPhotos;
    //存储到本地沙盒JiaMi文件夹中的图片数组（以后存储到数据库当中）
    NSMutableArray *_jiamiPhotosArr;
    
    UIButton *_addImageButton;
    UIButton *_deleteImageButton;
}

@property (nonatomic ,weak) UITableView *photoView;

//存储着多选删除的多个图片的信息，key：选中cell的indexPath，value：这张图片的路径
@property (nonatomic ,strong) NSMutableDictionary *dataDic;

@property (nonatomic ,strong) SM4_OCMethod *SM4;

@end

@implementation MiBaoXiangViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //修改navigationbar的颜色
    self.navigationItem.title = @"密码本";
    //左侧返回按键设置

    UIBarButtonItem *leftBackItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
    self.navigationItem.leftBarButtonItem = leftBackItem;
    
    //这里暂时注释这两个方法
    _localPhotos = [self gitImagesWithDirctory:@"Thumbnail"];
    
    _jiamiPhotosArr = [self gitImagesWithDirctory:@"JiaMi"];
    
    [self creatUI];
    
}

#pragma mark - 创建UI
//创建UI
- (void)creatUI
{
    self.dataDic = [[NSMutableDictionary alloc]init];
    self.photoView.backgroundColor = [UIColor whiteColor];
    
    self.view.backgroundColor=[UIColor whiteColor];
    self.navigationItem.title=@"自动加密文件夹";
    
    //设置右边
    UIButton *rightButton = [[UIButton alloc]initWithFrame:CGRectMake(0,0,70,30)];
    [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightButton setTitle:@"编辑" forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(edit)forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem= rightItem;
    
    UIView *tabbarView = [[UIView alloc] initWithFrame:CGRectMake(0, HEIGHT - 49, WIDTH, 49)];
    tabbarView.backgroundColor = [UIColor whiteColor];
    tabbarView.layer.borderWidth = 0.5;
    tabbarView.layer.borderColor = [[UIColor grayColor] CGColor];
    
    _addImageButton = [[UIButton alloc] initWithFrame:CGRectMake(12, 10, WIDTH - 24, tabbarView.frame.size.height - 20)];
    [_addImageButton setTitle:@"添加图片" forState:UIControlStateNormal];
    [_addImageButton setBackgroundColor:[UIColor colorWithRed:0 green:137.0 / 255.0 blue:252.0 / 255.0 alpha:1]];
    [_addImageButton addTarget:self action:@selector(addImage) forControlEvents:UIControlEventTouchUpInside];
    _addImageButton.tag = 101;
    
    _deleteImageButton = [[UIButton alloc] initWithFrame:CGRectMake(12, 10, WIDTH - 24, tabbarView.frame.size.height - 20)];
    [_deleteImageButton setTitle:@"删除选中图片" forState:UIControlStateNormal];
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
            NSLog(@"在第%ld次遍历出.DS_Store，删除后数组还剩%ld",index ,mutArr.count);
            
        }
    }
    NSLog(@"%@",mutArr);
    
    return mutArr;
}


//编辑按钮点击事件
- (void)edit
{
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
}

//添加图片按钮
- (void)addImage
{
    LocalPhotoViewController *pick=[[LocalPhotoViewController alloc] init];
    [pick.view setBackgroundColor:[UIColor whiteColor]];
    self.navigationItem.backBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:nil action:nil];
    pick.selectPhotoDelegate=self;
//    pick.selectPhotos=_selectPhotos;
    _selectPhotos = pick.selectPhotos;
    
    [self.navigationController pushViewController:pick animated:YES];
}

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

//选中了几张图片
-(void)getSelectedPhoto:(NSMutableArray *)photos{
    
    //选中的图片存储在_selectPhotos数组中
    _selectPhotos = [NSMutableArray arrayWithArray:photos];
    NSLog(@"供选择%lu张照片",(unsigned long)[photos count]);
    
    for (NSInteger index = 0; index < _selectPhotos.count; index ++) {
        
        //设置cell的图片和图片名字
        ALAsset *asset=[_selectPhotos objectAtIndex:index];
        ALAssetRepresentation *fullImage = [asset defaultRepresentation];
        CGImageRef posterImageRef=[fullImage fullResolutionImage];
        UIImage *posterImage=[UIImage imageWithCGImage:posterImageRef];
        
        //将获取到的图片保存到APP的沙盒中
        BOOL result = [self saveImageToDocumentDirectory:[UIImage imageWithCGImage:asset.defaultRepresentation.fullResolutionImage] appendingString:[asset.defaultRepresentation filename]];
        
        //添加加密文件夹数据源里的项目
        _jiamiPhotosArr = [self gitImagesWithDirctory:@"JiaMi"];
        
        if (result) {
            _localPhotos = [self gitImagesWithDirctory:@"Thumbnail"];
        }
    }
    
    [self.photoView reloadData];
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
    NSString *loaclImagePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingString:[NSString stringWithFormat:@"/Thumbnail/%@",_localPhotos[indexPath.row]]];
    NSLog(@"%@",loaclImagePath);
    UIImage *localImage = [[UIImage alloc] initWithContentsOfFile:loaclImagePath];
    
    //从本地沙盒获取图片
    [cell.thumbnail setImage:localImage];
    cell.imageName.text = _localPhotos[indexPath.row];
    
    //从系统相册里获取的图片
    //[cell.thumbnail setImage:posterImage];
    //cell.imageName.text=[asset.defaultRepresentation filename];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

#pragma mark - 文件本地保存（加密操作）
//将获取到的图片保存到APP的沙盒中
- (BOOL)saveImageToDocumentDirectory:(UIImage *)image appendingString:(NSString *)imageName
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    /**
     *  缩略图文件存储
     */
    NSString *createThumbnailDir = [paths.firstObject stringByAppendingString:@"/Thumbnail"];
    //判断是否存在Thumbnail文件夹，如果不存在，就创建
    if (![[NSFileManager defaultManager] fileExistsAtPath:createThumbnailDir]) {
        [fileManager createDirectoryAtPath:createThumbnailDir withIntermediateDirectories:YES attributes:nil error:nil];
        
    }else {
        NSLog(@"FileDir is exists");
    }
    NSString *thumbnailFilePath = [NSString stringWithFormat:@"%@/%@", createThumbnailDir, imageName];
    //只做缩略图
    UIImage *thumbnailImage = [self imageCompressForSize:image targetSize:CGSizeMake(55, 55)];
    NSData *thumbnailData = UIImagePNGRepresentation(thumbnailImage);
    BOOL thumbnailResult = [thumbnailData writeToFile:thumbnailFilePath atomically:YES];
    
    NSLog(@"缩略图已经存储到%@，是否成功：%d",thumbnailFilePath ,thumbnailResult);
    
    /**
     *  加密文件存储
     */
    NSString *createJiamiDir = [paths.firstObject stringByAppendingString:@"/JiaMi"];
    //判断是否存在JiaMi文件夹，如果不存在，就创建
    if (![[NSFileManager defaultManager] fileExistsAtPath:createJiamiDir]) {
        [fileManager createDirectoryAtPath:createJiamiDir withIntermediateDirectories:YES attributes:nil error:nil];
        
    }else {
        NSLog(@"FileDir is exists");
    }
    NSString *jiamiFilePath = [NSString stringWithFormat:@"%@/%@", createJiamiDir, imageName];
    NSData *imageData = UIImagePNGRepresentation(image);
    NSData *jiamiData = [self.SM4 Sm4Jiami:imageData];
    BOOL jiamiResult = [jiamiData writeToFile:jiamiFilePath atomically:YES];
    
    NSLog(@"图片已经存储到%@，是否成功：%d" ,jiamiFilePath ,jiamiResult);
    
    return jiamiResult;
}

#pragma mark - deletePics
//删除图片按钮
- (void)deleteImages
{
    //以下代码是处理数据的删除的操作。
    if (self.dataDic.count != 0) {
        
        //先删除本地沙盒文件
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSMutableArray *dataArr = [NSMutableArray arrayWithArray:self.dataDic.allValues];
        
        //循环删除数据
        for (NSInteger index = dataArr.count - 1; index >= 0; index --) {
            
            //此处为删除加密文件夹里面的内容
            NSString *jiamiFilePath = [paths.lastObject stringByAppendingString:[NSString stringWithFormat:@"/JiaMi/%@",dataArr[index]]];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            //先判断有没有该路径
            BOOL jiamiDirHave=[[NSFileManager defaultManager] fileExistsAtPath:jiamiFilePath];
            
            //如果有就删除，
            if (!jiamiDirHave) {
                NSLog(@"no  have");
                return ;
            }else {
                NSLog(@" have");
                BOOL blDele= [fileManager removeItemAtPath:jiamiFilePath error:nil];
                [_jiamiPhotosArr removeObject:dataArr[index]];
                if (blDele) {
                    NSLog(@"dele success");
                }else {
                    NSLog(@"dele fail");
                }
            }
            
            //此处为删除缩略图里面的内容
            NSString *thumbnailFilePath = [paths.lastObject stringByAppendingString:[NSString stringWithFormat:@"/Thumbnail/%@",dataArr[index]]];
            BOOL thumbnailDirHave=[[NSFileManager defaultManager] fileExistsAtPath:thumbnailFilePath];
            
            //如果有就删除，
            if (!thumbnailDirHave) {
                NSLog(@"no  have");
                return ;
            }else {
                NSLog(@" have");
                BOOL blDele= [fileManager removeItemAtPath:thumbnailFilePath error:nil];;
                if (blDele) {
                    NSLog(@"dele success");
                }else {
                    NSLog(@"dele fail");
                }
            }
        }
        
        //删除数据源
        [_localPhotos removeObjectsInArray:[self.dataDic allValues]];
        
        //删除界面的cell
        [self.photoView deleteRowsAtIndexPaths:[self.dataDic allKeys] withRowAnimation:UITableViewRowAnimationFade];
        
        //删除存储删除信息的字典dataDic
        [self.dataDic removeAllObjects];
        
        [self.photoView setEditing:!self.photoView.editing animated:YES];
        _deleteImageButton.hidden = YES;
        _addImageButton.hidden = NO;
    }
}

#pragma mark -左划删除
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
    return @"删除";
}

/*左划删除用到的函数*/
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        //先删除本地沙盒文件
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        //删除加密文件夹里的文件
        NSString *filePath = [paths.lastObject stringByAppendingString:[NSString stringWithFormat:@"/JiaMi/%@",_localPhotos[indexPath.row]]];
        //删除加密文件夹路劲数据源
        [_jiamiPhotosArr removeObject:_localPhotos[indexPath.row]];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        //先判断有没有该路径
        BOOL blHave=[[NSFileManager defaultManager] fileExistsAtPath:filePath];
        //如果有就删除，
        if (!blHave) {
            NSLog(@"no  have");
            return ;
        }else {
            NSLog(@" have");
            BOOL blDele= [fileManager removeItemAtPath:filePath error:nil];;
            if (blDele) {
                NSLog(@"dele success");
            }else {
                NSLog(@"dele fail");
            }
        }
        
        //此处为删除缩略图里面的内容
        NSString *thumbnailFilePath = [paths.lastObject stringByAppendingString:[NSString stringWithFormat:@"/Thumbnail/%@",_localPhotos[indexPath.row]]];
        BOOL thumbnailDirHave=[[NSFileManager defaultManager] fileExistsAtPath:thumbnailFilePath];
        
        //如果有就删除，
        if (!thumbnailDirHave) {
            NSLog(@"no  have");
            return ;
        }else {
            NSLog(@" have");
            BOOL blDele= [fileManager removeItemAtPath:thumbnailFilePath error:nil];;
            if (blDele) {
                NSLog(@"dele success");
            }else {
                NSLog(@"dele fail");
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
        //这里跳转到图片浏览控制器（待完成）
        NSString *jiamiFilePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingString:[NSString stringWithFormat:@"/JiaMi/%@",_jiamiPhotosArr[indexPath.row]]];
        NSData *jiamiPhotoData = [NSData dataWithContentsOfFile:jiamiFilePath];
        NSData *jiemiPhotoData = [self.SM4 SM4Jiemi:jiamiPhotoData];
        UIImage *jiemiImage = [UIImage imageWithData:jiemiPhotoData];
        
        PhotoShowViewController *psVC = [[PhotoShowViewController alloc] initWithImage:jiemiImage];
        
        [self.navigationController pushViewController:psVC animated:YES];
    }
}

#pragma mark - lazy
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
        
        NSLog(@"scale image fail");
        
    }
    
    UIGraphicsEndImageContext();
    
    return newImage;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
