//
//  BLEConnectViewController.m
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/9/6.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "BLEConnectViewController.h"
#import "BLEConnectContentView.h"

@interface BLEConnectViewController ()

@property (nonatomic ,weak) BLEConnectContentView *connectView;

@end

@implementation BLEConnectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    self.connectView.backgroundColor = [UIColor redColor];
    
}

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BLEConnectContentView *)connectView
{
    if (!_connectView) {
        BLEConnectContentView *view = [[BLEConnectContentView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height)];
        view.backgroundColor = [UIColor yellowColor];
        
        [self.view addSubview:view];
        _connectView = view;
    }
    
    return _connectView;
}

@end
