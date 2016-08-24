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
    self.view.backgroundColor = [UIColor whiteColor];

    //左侧返回按键设置
    UIBarButtonItem *leftBackItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
    self.navigationItem.leftBarButtonItem = leftBackItem;
    
    
}

- (instancetype)initWithImage:(UIImage *)showImage title:(NSString *)titile
{
    self = [super init];
    if (self) {
        [self.photoView setShowImage:showImage];
        self.navigationItem.title = titile;
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

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
