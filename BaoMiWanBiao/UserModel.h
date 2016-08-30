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
@property (nonatomic ,assign) NSInteger *question;

#pragma mark 用户表查询
/**
 *  查询用户表
 *
 *  @return 创建用户表的查询
 */
+(BmobQuery *)query;




#pragma mark 用户登录注册操作等相关操作
/**
 *  用户登陆
 *
 *  @param username 用户名
 *  @param password 密码
 */
+(void)loginWithUsernameInBackground:(NSString*)username
                            password:(NSString*)password;


/**
 *  登陆后返回用户信息
 *
 *  @param username 用户名
 *  @param password 密码
 *  @param block    是否成功登陆，若成功登陆返回用户信息
 */
+(void)loginWithUsernameInBackground:(NSString *)username
                            password:(NSString *)password
                               block:(BmobUserResultBlock)block;

/**
 *	注销登陆账号,删除本地账号
 */
+(void)logout;

/**
 *	后台注册
 */
-(void)signUpInBackground;


/**
 *	后台注册,返回注册结果
 *
 *	@param	block	返回成功还是失败
 */
-(void)signUpInBackgroundWithBlock:(BmobBooleanResultBlock)block;

@end
