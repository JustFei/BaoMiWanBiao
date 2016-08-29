//
//  FolderContentView.m
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/8/26.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "FolderContentView.h"
#import "FolderPhotoCell.h"
#import "LocalPhotoViewController.h"
#import "PhotoShowViewController.h"

#define WIDTH self.frame.size.width
#define HEIGHT self.frame.size.height

@interface FolderContentView () <UITableViewDelegate, UITableViewDataSource, SelectPhotoDelegate>
{
    
    
    //选中图片数组，也是TableView的数据源
    NSMutableArray *_selectPhotos;
    
    //存储到本地沙盒缩略图中的图片数组
//    NSMutableArray *_localPhotos;
}



@end

@implementation FolderContentView

- (void)layoutSubviews
{
    self.photoTableView.backgroundColor = [UIColor whiteColor];
    
    self.localPhotos = [self gitImagesWithDirctory:@"JieMi"];
    
//    self.toolView.frame = CGRectMake(0, HEIGHT - 49, WIDTH, 50);
    self.toolView.backgroundColor = [UIColor whiteColor];
    
    [self createUI];
}

- (void)createUI
{
    self.dataDic = [[NSMutableDictionary alloc]init];
    
    self.deleteImageButton.frame = CGRectMake(12, 10, WIDTH - 24, self.toolView.frame.size.height - 20);
    
    self.addImageButton.frame = CGRectMake(12, 10, WIDTH - 24, self.toolView.frame.size.height - 20);
    
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.localPhotos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"folderphotocell";
    FolderPhotoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    //设置右侧附加按钮样式为小箭头
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    //获取本地图片路径名
    NSString *loaclImagePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingString:[NSString stringWithFormat:@"/Thumbnail/%@",self.localPhotos[indexPath.row]]];
    NSLog(@"%@",loaclImagePath);
    UIImage *localImage = [[UIImage alloc] initWithContentsOfFile:loaclImagePath];
    
    //从本地沙盒获取图片
    [cell.headImageView setImage:localImage];
    cell.imageNameLabel.text = self.localPhotos[indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}


//选中方法
#pragma mark -选中cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FolderPhotoCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (self.photoTableView.isEditing) {
        //把indexpath 以_dataArray的值作为key 插入到dataDic字典中
        [self.dataDic setObject:[self.localPhotos objectAtIndex:indexPath.row] forKey:indexPath];
        if (self.dataDic.count == 0) {
            _addImageButton.enabled = NO;
        }
        else
        {
            _addImageButton.enabled = YES;
        }
    }else {
        //这里跳转到图片浏览控制器
//        NSString *jiamiFilePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingString:[NSString stringWithFormat:@"/JiaMi/%@",_jiamiPhotosArr[indexPath.row]]];
//        NSData *jiamiPhotoData = [NSData dataWithContentsOfFile:jiamiFilePath];
//        NSData *jiemiPhotoData = [self.SM4 SM4Jiemi:jiamiPhotoData];
//        UIImage *jiemiImage = [UIImage imageWithData:jiemiPhotoData];
//        
//        PhotoShowViewController *psVC = [[PhotoShowViewController alloc] initWithImage:jiemiImage title:cell.imageName.text];
//        
//        [self.navigationController pushViewController:psVC animated:YES];
    }
}

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

#pragma mark - 点击事件
//添加图片按钮
- (void)addImage
{
    LocalPhotoViewController *pick=[[LocalPhotoViewController alloc] init];
    [pick.view setBackgroundColor:[UIColor whiteColor]];
    [self findViewController:self].navigationItem.backBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:nil action:nil];
    pick.selectPhotoDelegate=self;
    //    pick.selectPhotos=_selectPhotos;
    _selectPhotos = pick.selectPhotos;
    
    [[self findViewController:self].navigationController pushViewController:pick animated:YES];
}

#pragma mark - deletePics
//删除图片按钮
- (void)deleteImages
{
    //以下代码是处理数据的删除的操作。
    if (self.dataDic.count != 0) {
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        //先删除本地沙盒文件
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSMutableArray *dataArr = [NSMutableArray arrayWithArray:self.dataDic.allValues];
        
        //在此创建解密文件夹，如果存在就不创建
        NSString *createJieMiDir = [paths.firstObject stringByAppendingString:@"/JieMi"];
        //判断是否存在Thumbnail文件夹，如果不存在，就创建
        if (![[NSFileManager defaultManager] fileExistsAtPath:createJieMiDir]) {
            [fileManager createDirectoryAtPath:createJieMiDir withIntermediateDirectories:YES attributes:nil error:nil];
            
        }else {
            NSLog(@"FileDir is exists");
        }
        
        //循环删除数据
        for (NSInteger index = dataArr.count - 1; index >= 0; index --) {
            
            //此处为删除加密文件夹里面的内容
            NSString *jiemiFilePath = [paths.lastObject stringByAppendingString:[NSString stringWithFormat:@"/JieMi/%@",dataArr[index]]];
            //先判断有没有该路径
            BOOL jiemiDirHave = [[NSFileManager defaultManager] fileExistsAtPath:jiemiFilePath];
            //如果有就删除，
            if (!jiemiDirHave) {
                NSLog(@"no  havejiemi");
                return ;
            }else {
                
                BOOL blDele= [fileManager removeItemAtPath:jiemiFilePath error:nil];
                self.changeRightItemTitleblock();
                
                if (blDele) {
                    NSLog(@"delejiami success");
                }else {
                    NSLog(@"delejiami fail");
                }
            }
        }
        
        //删除数据源
        [self.localPhotos removeObjectsInArray:[self.dataDic allValues]];
        
        //删除界面的cell
        [self.photoTableView deleteRowsAtIndexPaths:[self.dataDic allKeys] withRowAnimation:UITableViewRowAnimationFade];
        
        //删除存储删除信息的字典dataDic
        [self.dataDic removeAllObjects];
        
        [self.photoTableView setEditing:!self.photoTableView.editing animated:YES];
        _deleteImageButton.hidden = YES;
        _addImageButton.hidden = NO;
    }
}

//选中了几张图片
-(void)getSelectedPhoto:(NSMutableArray *)photos{
    
    //选中的图片存储在_selectPhotos数组中
    _selectPhotos = [NSMutableArray arrayWithArray:photos];
    NSLog(@"供选择%lu张照片",(unsigned long)[photos count]);
    
    for (NSInteger index = 0; index < _selectPhotos.count; index ++) {
        
        //设置cell的图片和图片名字
        ALAsset *asset=[_selectPhotos objectAtIndex:index];
        //        ALAssetRepresentation *fullImage = [asset defaultRepresentation];
        //        CGImageRef posterImageRef=[fullImage fullResolutionImage];
        //        UIImage *posterImage=[UIImage imageWithCGImage:posterImageRef];
        
        //将获取到的图片保存到APP的沙盒中
        BOOL result = [self saveImageToDocumentDirectory:[UIImage imageWithCGImage:asset.defaultRepresentation.fullResolutionImage] appendingString:[asset.defaultRepresentation filename]];
        
        //添加加密文件夹数据源里的项目
//        _jiamiPhotosArr = [self gitImagesWithDirctory:@"JiaMi"];
        
        if (result) {
            self.localPhotos = [self gitImagesWithDirctory:@"JieMi"];
        }
    }
    
    [self.photoTableView reloadData];
}

#pragma mark - 文件本地保存
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
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:thumbnailFilePath]) {
        
        BOOL thumbnailResult = [thumbnailData writeToFile:thumbnailFilePath atomically:YES];
        
        NSLog(@"缩略图已经存储到%@，是否成功：%d",thumbnailFilePath ,thumbnailResult);
    }else {
        NSLog(@"该缩略图同名或者已经存在了");
    }
    
    
    /**
     *  加密文件存储
     */
    NSString *createJiamiDir = [paths.firstObject stringByAppendingString:@"/JieMi"];
    //判断是否存在JiaMi文件夹，如果不存在，就创建
    if (![[NSFileManager defaultManager] fileExistsAtPath:createJiamiDir]) {
        [fileManager createDirectoryAtPath:createJiamiDir withIntermediateDirectories:YES attributes:nil error:nil];
        
    }else {
        NSLog(@"FileDir is exists");
    }
    NSString *jiamiFilePath = [NSString stringWithFormat:@"%@/%@", createJiamiDir, imageName];
    NSData *imageData = UIImagePNGRepresentation(image);
    
    BOOL jiamiResult;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:jiamiFilePath]) {
        jiamiResult = [imageData writeToFile:jiamiFilePath atomically:YES];
        
        NSLog(@"图片已经存储到%@，是否成功：%d" ,jiamiFilePath ,jiamiResult);
    }else {
        NSLog(@"添加到解密文件夹中的文件名已存在");
    }
    
    return jiamiResult;
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

#pragma mark - 懒加载
- (UITableView *)photoTableView
{
    if (!_photoTableView) {
        UITableView *view = [[UITableView alloc] initWithFrame:CGRectMake(0,  0, WIDTH , HEIGHT  - 49) style:UITableViewStylePlain];
        
        view.delegate = self;
        view.dataSource = self;
        
        [self addSubview:view];
        
        [view registerNib:[UINib nibWithNibName:@"FolderPhotoCell" bundle:nil] forCellReuseIdentifier:@"folderphotocell"];
        _photoTableView = view;
    }
    
    return _photoTableView;
}

- (UIView *)toolView
{
    if (!_toolView) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, HEIGHT - 49, WIDTH, 49)];
        view.layer.borderWidth = 0.5;
        view.layer.borderColor = [[UIColor grayColor] CGColor];
        
        [self addSubview:view];
        _toolView = view;
    }
    
    return  _toolView;
}

- (NSMutableArray *)localPhotos
{
    if (!_localPhotos) {
        _localPhotos = [NSMutableArray array];
    }
    
    return _localPhotos;
}

- (NSMutableArray *)deleteDataArray
{
    if (!_deleteDataArray) {
        _deleteDataArray = [NSMutableArray array];
    }
    
    return _deleteDataArray;
}

- (UIButton *)addImageButton
{
    if (!_addImageButton) {
        UIButton *btn = [[UIButton alloc] init];
        [btn setTitle:@"添加图片" forState:UIControlStateNormal];
        [btn setBackgroundColor:[UIColor colorWithRed:0 green:137.0 / 255.0 blue:252.0 / 255.0 alpha:1]];
        [btn addTarget:self action:@selector(addImage) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = 101;
        
        [self.toolView addSubview:btn];
        _addImageButton = btn;
    }
    
    return _addImageButton;
}

- (UIButton *)deleteImageButton
{
    if (!_deleteImageButton) {
        UIButton *btn = [[UIButton alloc] init];
        [btn setTitle:@"彻底删除选中图片" forState:UIControlStateNormal];
        [btn setBackgroundColor:[UIColor redColor]];
        [btn addTarget:self action:@selector(deleteImages) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = 102;
        
        [self.toolView addSubview:btn];
        _deleteImageButton = btn;
    }
    
    return _deleteImageButton;
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

@end