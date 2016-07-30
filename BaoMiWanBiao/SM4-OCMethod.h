//
//  SM4-OCMethod.h
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/7/30.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SM4_OCMethod : NSObject

//加密方法
- (NSData *)Sm4Jiami :(NSData *)mingwenData;

//解密方法
- (NSData *)SM4Jiemi :(NSData *)miwenData;

@end
