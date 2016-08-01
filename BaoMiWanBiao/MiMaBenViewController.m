//
//  MiMaBenViewController.m
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/7/29.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "MiMaBenViewController.h"
#import "MiMaBenContentView.h"

@interface MiMaBenViewController ()

@property (nonatomic ,weak)MiMaBenContentView *miMaBenView;

@end

@implementation MiMaBenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.miMaBenView.backgroundColor = [UIColor whiteColor];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [self.miMaBenView.mimaArr removeAllObjects];
    
    NSArray *arr = [self.miMaBenView.sqlTool queryData:nil];
    [self.miMaBenView.mimaArr addObjectsFromArray:arr];
    
    [self.miMaBenView.mimabenTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (MiMaBenContentView *)miMaBenView
{
    if (!_miMaBenView) {
        MiMaBenContentView *view = [[MiMaBenContentView alloc] initWithFrame:self.view.frame];
        
        [self.view addSubview:view];
        _miMaBenView = view;
    }
    
    return _miMaBenView;
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
