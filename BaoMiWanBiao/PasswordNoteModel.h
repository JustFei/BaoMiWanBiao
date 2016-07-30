//
//  PasswordNoteModel.h
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/7/30.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PasswordNoteModel : NSObject

//  名称
@property (nonatomic ,copy)NSString *name;

//  账户
@property (nonatomic ,copy)NSString *account;

//  密码
@property (nonatomic ,copy)NSString *password;

//  备忘
@property (nonatomic ,copy)NSString *memorandum;

//  是否加密
@property (nonatomic ,assign)BOOL isEncrypt;


+ (instancetype)modelWith: (NSString *)name account:(NSString *)account password:(NSString *)password memorandum:(NSString *)memorandum;

@end
