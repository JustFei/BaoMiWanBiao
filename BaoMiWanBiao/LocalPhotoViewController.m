//
//  LocalPhotoViewController.m
//  AlbumTest
//
//  Created by ejiang on 14-7-28.
//  Copyright (c) 2014年 daijier. All rights reserved.
//

#import "LocalPhotoViewController.h"

@interface LocalPhotoViewController ()
@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;

@end

@implementation LocalPhotoViewController{
    UIBarButtonItem *btnDone;
    NSMutableArray *selectPhotoNames;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if(self.selectPhotos==nil)
    {
        self.selectPhotos=[[NSMutableArray alloc] init];
        selectPhotoNames=[[NSMutableArray alloc] init];
    }else{
        selectPhotoNames=[[NSMutableArray alloc] init];
        for (ALAsset *asset in self.selectPhotos ) {
            //NSLog(@"%@",[asset valueForProperty:ALAssetPropertyAssetURL]);
            [selectPhotoNames addObject:[asset valueForProperty:ALAssetPropertyAssetURL]];
        }
        self.lbAlert.text=[NSString stringWithFormat:@"已经选择%ld张照片",(unsigned long)self.selectPhotos.count];
    }
    
    //self.collection.dataSource=self;
    //self.collection.delegate=self;
    //[self.collection registerNib:[UINib nibWithNibName:@"LocalPhotoCell" bundle:nil]  forCellWithReuseIdentifier:@"photocell"];
    //self.title = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    self.collection.backgroundColor = [UIColor whiteColor];
    btnDone=[[UIBarButtonItem alloc] initWithTitle:@"相册" style:UIBarButtonItemStylePlain target:self action:@selector(albumAction)];
    self.navigationItem.rightBarButtonItem = btnDone;
    NSUInteger groupTypes = ALAssetsGroupSavedPhotos;
    ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group, BOOL *stop) {
        ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allAssets];
        [group setAssetsFilter:onlyPhotosFilter];
        
        if ([group numberOfAssets] > 0)
        {
            [self showPhoto:group];
        }
        else
        {
            NSLog(@"读取相册完毕");
            //[self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        }
    };
    
    [[AssetHelper defaultAssetsLibrary] enumerateGroupsWithTypes:groupTypes usingBlock:listGroupBlock                                    failureBlock:nil];
}

//- (NSMutableArray *)selectPhotos
//{
//    if (!_selectPhotos) {
//        NSMutableArray *mutArr = [[NSMutableArray alloc] init];
//        _selectPhotos = mutArr;
//    }
//    
//    return  _selectPhotos;
//}

-(void)albumAction{
    LocalAlbumTableViewController *album=[[LocalAlbumTableViewController alloc] init];
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:album];
    album.delegate=self;
    [self.navigationController presentViewController:nvc animated:YES completion:^(void){
        NSLog(@"开始");
    }];
    // [self.navigationController pushViewController:album animated:YES];
    //    [self.navigationController popToRootViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.photos.count;
}

#define kImageViewTag 1 // the image view inside the collection view cell prototype is tagged with "1"
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    @autoreleasepool {
        static NSString *CellIdentifier = @"photocell";
        LocalPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
        
        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // load the asset for this cell
            ALAsset *asset=self.photos[indexPath.row];
            CGImageRef thumbnailImageRef = [asset thumbnail];
            UIImage *thumbnail = [UIImage imageWithCGImage:thumbnailImageRef];
            
            //这里可以获取到全尺寸的高清图
//            ALAssetRepresentation *reprsentation = [asset defaultRepresentation];
//            CGImageRef fullImage = [reprsentation fullResolutionImage];
//            UIImage *full = [UIImage imageWithCGImage:fullImage];
            
            //回来测试下
            [cell.img setImage:thumbnail];
            NSString *url=[asset valueForProperty:ALAssetPropertyAssetURL];
            [cell.btnSelect setHidden:[selectPhotoNames indexOfObject:url]==NSNotFound];
        });
    
        
        return cell;
    }
    
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    LocalPhotoCell *cell=(LocalPhotoCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if(cell.btnSelect.hidden)
    {
        [cell.btnSelect setHidden:NO];
        ALAsset *asset=self.photos[indexPath.row];
        [self.selectPhotos addObject:asset];
        [selectPhotoNames addObject:[asset valueForProperty:ALAssetPropertyAssetURL]];
    }else{
        [cell.btnSelect setHidden:YES];
        ALAsset *asset=self.photos[indexPath.row];
        for (ALAsset *a in self.selectPhotos) {
            NSLog(@"%@-----%@",[asset valueForProperty:ALAssetPropertyAssetURL],[a valueForProperty:ALAssetPropertyAssetURL]);
            NSString *str1=[asset valueForProperty:ALAssetPropertyAssetURL];
            NSString *str2=[a valueForProperty:ALAssetPropertyAssetURL];
            if([str1 isEqual:str2])
                {
                    [self.selectPhotos removeObject:a];
                    break;
                }
        }
        
        [selectPhotoNames removeObject:[asset valueForProperty:ALAssetPropertyAssetURL]];
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

- (IBAction)btnConfirm:(id)sender {
    if (self.selectPhotoDelegate!=nil) {
        
            [self.navigationController popViewControllerAnimated:YES];
        
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.selectPhotoDelegate getSelectedPhoto:self.selectPhotos];
        });
        
        
    }
}

-(void) showPhoto:(ALAssetsGroup *)album
{
    if(album!=nil)
    {
        if(self.currentAlbum==nil||![[self.currentAlbum valueForProperty:ALAssetsGroupPropertyName] isEqualToString:[album valueForProperty:ALAssetsGroupPropertyName]])
        {
            self.currentAlbum=album;
            if (!self.photos) {
                _photos = [[NSMutableArray alloc] init];
            } else {
                [self.photos removeAllObjects];
                
            }
            ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (result) {
                    [self.photos addObject:result];
                }else{
                }
            };
            
            ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allAssets];
            [self.currentAlbum setAssetsFilter:onlyPhotosFilter];
            [self.currentAlbum enumerateAssetsUsingBlock:assetsEnumerationBlock];
            self.title = [self.currentAlbum valueForProperty:ALAssetsGroupPropertyName];
            [self.collection reloadData];
        }
    }
}
-(void)selectAlbum:(ALAssetsGroup *)album{
    [self showPhoto:album];
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

@end
