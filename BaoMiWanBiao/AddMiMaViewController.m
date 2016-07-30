//
//  AddMiMaViewController.m
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/7/29.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "AddMiMaViewController.h"
#import "AddMiMaViewContentView.h"

@interface AddMiMaViewController ()

@property (nonatomic ,weak)AddMiMaViewContentView *addMiMaView;

@end

@implementation AddMiMaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.addMiMaView.backgroundColor = [UIColor whiteColor];
    
    self.navigationController.title = @"密码本";
    self.navigationController.navigationBar.tintColor = [UIColor blueColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (AddMiMaViewContentView *)addMiMaView
{
    if (!_addMiMaView) {
        AddMiMaViewContentView *view = [[AddMiMaViewContentView alloc] initWithFrame:self.view.frame];
        
        [self.view addSubview: view];
        _addMiMaView = view;
    }
    
    return _addMiMaView;
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
