//
//  FolderPhotoViewController.m
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/9/2.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "FolderPhotoViewController.h"
#import "LocalPhotoCell.h"

@interface FolderPhotoViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>

//JiaMi文件夹里面的所有文件
@property (nonatomic, strong) NSMutableArray *folderFildeNameArr;
@end

@implementation FolderPhotoViewController
{
    //全选按钮
    UIButton *btnDone;
    NSMutableArray *selectPhotoNames;
    NSString *userPhone;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if(self.selectPhotos==nil)
    {
        self.selectPhotos=[[NSMutableArray alloc] init];
        selectPhotoNames=[[NSMutableArray alloc] init];
    }else{
        selectPhotoNames=[[NSMutableArray alloc] init];
        self.lbAlert.text=[NSString stringWithFormat:@"已经选择%ld张照片",self.selectPhotos.count];
    }
    
    self.collection.backgroundColor = [UIColor whiteColor];
    btnDone = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnDone setTitle:@"全选" forState:UIControlStateNormal];
    [btnDone setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnDone addTarget:self action:@selector(selectAllAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:btnDone];
    
    self.navigationItem.rightBarButtonItem = rightButton;
    
    userPhone = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserName"];

    self.folderFildeNameArr = [self gitImagesWithDirctory:[NSString stringWithFormat:@"%@-JieMi",userPhone]];
    
}

#pragma mark - UICollectionDelegate && UICollectionDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.folderFildeNameArr.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    @autoreleasepool {
        static NSString *CellIdentifier = @"photocell";
        LocalPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
        
        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // load the asset for this cell
            //获取本地图片路径名
            NSString *loaclImagePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingString:[NSString stringWithFormat:@"/%@-Thumbnail/%@",userPhone ,self.folderFildeNameArr[indexPath.row]]];
            //    NSLog(@"%@",loaclImagePath);
            UIImage *localImage = [[UIImage alloc] initWithContentsOfFile:loaclImagePath];
            
            //回来测试下
            [cell.img setImage:localImage];
            [cell.btnSelect setHidden:YES];
//            NSString *url=[asset valueForProperty:ALAssetPropertyAssetURL];
//            [cell.btnSelect setHidden:[selectPhotoNames indexOfObject:url]==NSNotFound];
        });
        
        return cell;
    }
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    LocalPhotoCell *cell=(LocalPhotoCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if(cell.btnSelect.hidden)
    {
        [cell.btnSelect setHidden:NO];
//        ALAsset *asset=self.photos[indexPath.row];
        
        [self.selectPhotos addObject:self.folderFildeNameArr[indexPath.row]];
//        [selectPhotoNames addObject:[asset valueForProperty:ALAssetPropertyAssetURL]];
    }else{
        [cell.btnSelect setHidden:YES];
        NSString *asset=self.folderFildeNameArr[indexPath.row];
        for (NSString *a in self.selectPhotos) {
//            NSLog(@"%@-----%@",[asset valueForProperty:ALAssetPropertyAssetURL],[a valueForProperty:ALAssetPropertyAssetURL]);
//            NSString *str1=[asset valueForProperty:ALAssetPropertyAssetURL];
//            NSString *str2=[a valueForProperty:ALAssetPropertyAssetURL];
            if([asset isEqual:a])
            {
                [self.selectPhotos removeObject:a];
                break;
            }
        }
        
//        [selectPhotoNames removeObject:[asset valueForProperty:ALAssetPropertyAssetURL]];
    }
    
    if(self.selectPhotos.count==0)
    {
        self.sureButton.enabled = NO;
        self.lbAlert.text=@"请选择照片";
    }
    else{
        self.sureButton.enabled = YES;
        self.lbAlert.text=[NSString stringWithFormat:@"已经选择%lu张照片",(unsigned long)self.selectPhotos.count];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)selectAllAction:(UIButton *)sender
{
    if ([sender.titleLabel.text isEqualToString:@"全选"]) {
        [_selectPhotos removeAllObjects];
        _selectPhotos = self.folderFildeNameArr;
        [sender setTitle:@"取消全选" forState:UIControlStateNormal];
    }else if ([sender.titleLabel.text isEqualToString:@"取消全选"]) {
        [_selectPhotos removeAllObjects];
        [sender setTitle:@"全选" forState:UIControlStateNormal];
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
            NSLog(@"在第%ld次遍历出.DS_Store，删除后数组还剩%lu",(long)index ,(unsigned long)mutArr.count);
            
        }
    }
    //    NSLog(@"%@",mutArr);
    
    return mutArr;
}

#pragma mark - 懒加载
- (UICollectionView *)collection
{
    if (!_collection) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumInteritemSpacing = 2;
        layout.minimumLineSpacing = 2;
        layout.itemSize = CGSizeMake(([UIScreen mainScreen].bounds.size.width - 8) / 3, ([UIScreen mainScreen].bounds.size.width - 8) / 3);
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        UICollectionView *view = [[UICollectionView alloc] initWithFrame:CGRectMake(2, 2 + 64, [UIScreen mainScreen].bounds.size.width - 4, [UIScreen mainScreen].bounds.size.height - 64 - 46) collectionViewLayout:layout];
        
        view.delegate = self;
        view.dataSource = self;
        
        [self.view addSubview:view];
        
        [view registerNib:[UINib nibWithNibName:@"LocalPhotoCell" bundle:nil]  forCellWithReuseIdentifier:@"photocell"];
        _collection = view;
    }
    
    return _collection;
}

- (IBAction)btnConfirm:(UIButton *)sender {
    if (self.selectPhotoDelegate!=nil) {
        
        [self.navigationController popViewControllerAnimated:YES];
        
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.selectPhotoDelegate getFolderSelectedPhoto:self.selectPhotos];
        });
        
        
    }
}
@end
