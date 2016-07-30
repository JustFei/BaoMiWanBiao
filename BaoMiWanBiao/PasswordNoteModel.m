//
//  PasswordNoteModel.m
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/7/30.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "PasswordNoteModel.h"

@implementation PasswordNoteModel

+ (instancetype)modelWith:(NSString *)name account:(NSString *)account password:(NSString *)password memorandum:(NSString *)memorandum
{
    PasswordNoteModel *model = [[PasswordNoteModel alloc] init];
    model.name = name;
    model.account = account;
    model.password = password;
    model.memorandum = memorandum;
    
    return model;
}

@end
