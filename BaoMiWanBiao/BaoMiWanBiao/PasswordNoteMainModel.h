//
//  PasswordNoteMainModel.h
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/8/1.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PasswordNoteMainModel : NSObject

/**
 *  密码名称
 */
@property (nonatomic ,copy)NSString *name;

/**
 *  是否加密
 */
@property (nonatomic ,assign)BOOL isEncrypt;

@end
