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
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenNavigationBar)];
        imageView.userInteractionEnabled = YES;
        [imageView addGestureRecognizer:tap];
        DeBugLog(@"展示图片的imageView的frame == %@",NSStringFromCGRect(imageView.frame));
        
        [self addSubview:imageView];
        _selectPhotoView = imageView;
    }
    
    return _selectPhotoView;
}

- (void)hiddenNavigationBar
{
    UIViewController *vc = [self findViewController:self];
    
    if (vc.navigationController.navigationBar.hidden) {
        [UIView animateWithDuration:0.2 animations:^{
            vc.navigationController.navigationBar.hidden = !vc.navigationController.navigationBar.hidden;
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES];
            self.backgroundColor = [UIColor whiteColor];
        } completion:nil];
    }else {
        [UIView animateWithDuration:0.2 animations:^{
            vc.navigationController.navigationBar.hidden = !vc.navigationController.navigationBar.hidden;
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:YES];
            self.backgroundColor = [UIColor blackColor];
        } completion:nil];
        
    }
    
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


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
