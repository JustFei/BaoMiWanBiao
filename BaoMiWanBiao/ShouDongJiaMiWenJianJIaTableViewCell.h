//
//  ShouDongJiaMiWenJianJIaTableViewCell.h
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/7/27.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShouDongJiaMiWenJianJIaTableViewCell : UITableViewCell

//文件夹左侧的缩略图
@property (weak, nonatomic) IBOutlet UIImageView *thumbnail;

//图片的名字
@property (weak, nonatomic) IBOutlet UILabel *imageName;
@end
