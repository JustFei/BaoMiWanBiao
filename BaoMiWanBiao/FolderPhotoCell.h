//
//  FolderPhotoCell.h
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/8/26.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FolderPhotoCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;

@property (weak, nonatomic) IBOutlet UILabel *imageNameLabel;

@property (weak, nonatomic) IBOutlet UIButton *selectButton;

@end
