//
//  ClockContentView.h
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/8/23.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CloseAddButton)(void);
typedef void(^OpenAddButton)(void);

@interface ClockContentView : UIView

@property (weak, nonatomic) UITableView *clockTableView;

- (void)presentAddTimePickerWithHInt:(NSInteger )hInt MInt:(NSInteger )mInt;

@property (strong, nonatomic) CloseAddButton closeAddBlock;
@property (strong, nonatomic) OpenAddButton openAddBlock;

@end
