//
//  FolderPhotoViewController.h
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/9/2.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FolderSelectPhotoDelegate<NSObject>
-(void)getFolderSelectedPhoto:(NSMutableArray *)photos;
@end


@interface FolderPhotoViewController : UIViewController

@property (weak, nonatomic)  UICollectionView *collection;

@property (weak, nonatomic) IBOutlet UILabel *lbAlert;

@property (weak, nonatomic) IBOutlet UIButton *sureButton;


- (IBAction)btnConfirm:(UIButton *)sender;

@property (nonatomic,retain) id<FolderSelectPhotoDelegate> selectPhotoDelegate;
@property (nonatomic, strong) NSMutableArray *photos;
//@property (nonatomic, strong) ALAssetsGroup *currentAlbum;
@property (nonatomic, strong) NSMutableArray *selectPhotos;
@end
