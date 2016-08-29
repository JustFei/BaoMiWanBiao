//
//  PhotoShowContentView.m
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/7/28.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "PhotoShowContentView.h"

@interface PhotoShowContentView ()

@property (nonatomic ,weak)UIImageView *selectPhotoView;

@end

@implementation PhotoShowContentView

- (void)setShowImage:(UIImage *)showImage
{
    [self.selectPhotoView setImage:showImage];
    [self.selectPhotoView setContentMode:UIViewContentModeScaleAspectFit];
}

- (UIImageView *)selectPhotoView
{
    if (!_selectPhotoView) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        
        NSLog(@"展示图片的imageView的frame == %@",NSStringFromCGRect(imageView.frame));
        
        [self addSubview:imageView];
        _selectPhotoView = imageView;
    }
    
    return _selectPhotoView;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
