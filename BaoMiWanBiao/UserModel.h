//
//  UserModel.h
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/8/30.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BmobSDK/BmobConfig.h>
#import <BmobSDK/BmobObject.h>

@class BmobQuery;

@interface UserModel : BmobObject

//手机
@property (nonatomic ,copy) NSString *phone;

//密码
@property (nonatomic ,copy) NSString *pwd;

//昵称
@property (nonatomic ,copy) NSString *nickName;

//身份证
@property (nonatomic ,copy) NSString *identityCode;

//答案
@property (nonatomic ,copy) NSString *answer;

//性别
@property (nonatomic ,assign) NSInteger sex;

//年龄
@property (nonatomic ,assign) NSInteger age;

//身高
@property (nonatomic ,assign) NSInteger height;

//体重
@property (nonatomic ,assign) NSInteger weight;

//问题
@property (nonatomic ,assign) NSInteger question;


@end
