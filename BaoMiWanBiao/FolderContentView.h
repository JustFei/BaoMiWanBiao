//
//  FolderContentView.h
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/8/26.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ChangeRightItemTitleBlock)(void);

@interface FolderContentView : UIView

@property (nonatomic, weak) UIButton *addImageButton;

@property (nonatomic, weak) UIButton *deleteImageButton;

/**
 *  解密后的照片展示
 */
@property (weak, nonatomic) UITableView *photoTableView;

//删除数据源
@property (nonatomic, strong) NSMutableArray *deleteDataArray;

//存储着多选删除的多个图片的信息，key：选中cell的indexPath，value：这张图片的路径
@property (nonatomic ,strong) NSMutableDictionary *dataDic;

//图片的tableview
@property (nonatomic, strong) NSMutableArray *localPhotos;

//底部操作按钮
@property (nonatomic, weak) UIView *toolView;

@property (nonatomic, copy) ChangeRightItemTitleBlock changeRightItemTitleblock;

@end
