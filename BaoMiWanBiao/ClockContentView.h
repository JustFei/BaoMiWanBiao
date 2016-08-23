//
//  ClockContentView.h
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/8/23.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CloseAddButton)(void);

@interface ClockContentView : UIView

- (void)presentTimePickerWithHInt:(NSInteger )hInt MInt:(NSInteger )mInt;

@property (strong, nonatomic) CloseAddButton closeAddBlck;

@end
