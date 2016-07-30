//
//  PhotoShowViewController.m
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/7/28.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "PhotoShowViewController.h"
#import "PhotoShowContentView.h"

@interface PhotoShowViewController ()

@property (nonatomic ,weak)PhotoShowContentView *photoView;

@end

@implementation PhotoShowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (instancetype)initWithImage:(UIImage *)showImage
{
    self = [super init];
    if (self) {
        [self.photoView setShowImage:showImage];
    }
    return self;
}

- (PhotoShowContentView *)photoView
{
    if (!_photoView) {
        PhotoShowContentView *psView = [[PhotoShowContentView alloc] initWithFrame:self.view.frame];
        
        [self.view addSubview:psView];
        _photoView = psView;
    }
    
    return _photoView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
