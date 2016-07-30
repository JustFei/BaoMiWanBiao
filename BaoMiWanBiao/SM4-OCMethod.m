//
//  SM4-OCMethod.m
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/7/30.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "SM4-OCMethod.h"
#import "sm4.h"
#import "sm4test.h"

@implementation SM4_OCMethod

#pragma mark - 文件加解密操作
#pragma mark -加密操作
- (NSData *)Sm4Jiami :(NSData *)mingwenData
{
    //3.数据流的长度
    unsigned long plainInDataLength = mingwenData.length;
    
    //plainInDataLength是
    unsigned char key[16]   = {0x55,0x65,0x46,0x38,0x55,0x39,0x77,0x48,0x46,0x4f,0x4d,0x66,0x73,0x32,0x59,0x38};
    
    if (plainInDataLength <= 64 * 1024) {
        int p = 0;
        
        //4.p是需要填充的数据也是填充的位数
        if (plainInDataLength % 16 != 0) {
            p = 16 - plainInDataLength % 16;
            NSLog(@"数据流的长度 == %lu，填充的长度 == %d",plainInDataLength , p);
        }
        
        //5.定义char类型的变量plainInChar，长度为数据流的长度加上p。
        unsigned char plainInChar[plainInDataLength + p];
        
#warning 这里在拷贝内存的时候，有几张图片就是考不过去，第1，2，3张图片作为代表
        //6.将数据流的内存拷贝到char的内存中去，长度为填充过后的长度
        memcpy(plainInChar, mingwenData.bytes, plainInDataLength);
        //7.进行数据填充，在源数据后面填充知道达到16的倍数，填充的内容是p == 14（十六进制是0e）
        for (int i = 0; i < p; i++)
        {
            plainInChar[plainInDataLength + i] =  p;
        }
        
        //3.验证一下填充后的char[]是不是最开始的明文数据
        
        //plainInData=<74686973 20697320 706c6169 6e207465 7874>
        NSLog(@"plainInData=%@",mingwenData);
        
        NSLog(@"%d",p);
        
        //plainInChar == this is plain text
        
        NSData *data = [[NSData alloc]initWithBytes:plainInChar length:sizeof(plainInChar)];
        
        //data=<74686973 20697320 706c6169 6e207465 78740e0e 0e0e0e0e 0e0e0e0e 0e0e0e0e>
        //NSLog(@"data=%@",data);
        
        //填充后的char[]转成NSString == this is plain text
        NSLog(@"填充后的char[]转成NSString == %@",[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
        
        //五、调用刚才添加的方法加密
        //定义输出密文的变量
        unsigned char cipherOutChar[plainInDataLength + p];
        
        
        
        testEncodejiami(key, plainInDataLength + p, plainInChar, cipherOutChar);
        //对加密的数据输出
        NSData *miwenData =  [[NSData alloc]initWithBytes:cipherOutChar length:sizeof(cipherOutChar)];
        
        NSLog(@"加密成功");
        
        return miwenData;
        
    }else {
        
        //大于64字节的处理：只加密前64K字节
        //5.定义char类型的变量plainInChar，长度为64字节。
        unsigned char plainInChar[65536];
        
#warning 这里在拷贝内存的时候，有几张图片就是考不过去，第1，2，3张图片作为代表
        //6.将数据流的内存拷贝到char的内存中去，长度为填充过后的长度
        memcpy(plainInChar, mingwenData.bytes, 65536);
        
        unsigned char cipherOutChar[65536];
        
        testEncodejiami(key, 65536, plainInChar, cipherOutChar);
        //对加密的数据输出
        //将加密后的char数组转成data类型，应为64字节
        NSMutableData *qian64MiwenData =  [[NSMutableData alloc]initWithBytes:cipherOutChar length:sizeof(cipherOutChar)];
        
        //将明文data从64字节开始剪切到最后，为pinjieData
        NSData *pinjieData = [mingwenData subdataWithRange:NSMakeRange(65536, mingwenData.length - 65536)];
        
        //将前64位和最后剪切的数据拼接
        [qian64MiwenData appendData:pinjieData];
        
        NSLog(@"加密成功");
        
        return qian64MiwenData;
    }
}

#pragma mark -解密操作
- (NSData *)SM4Jiemi :(NSData *)miwenData
{
    
    unsigned char key[16]   = {0x55,0x65,0x46,0x38,0x55,0x39,0x77,0x48,0x46,0x4f,0x4d,0x66,0x73,0x32,0x59,0x38};
    
    if (miwenData.length <= 64 * 1024) {
        //六、将cipherTextData作为输入，调用第4步的解密方法，进行解密
        //将data拷贝到字符数组中
        unsigned char cipherTextChar[miwenData.length];
        memcpy(cipherTextChar, miwenData.bytes, miwenData.length);
        //调用解密方法，输出是明文plainOutChar
        unsigned char plainOutChar[miwenData.length];
        
        //这里讲秘钥，密文，填充字节数添加进去
        testDecodejiemi(key, miwenData.length, cipherTextChar, plainOutChar);
        //由于明文是填充过的，解密时候要去填充，去填充要在解密后才可以，在解密前是去不了的
        int p2 = plainOutChar[sizeof(plainOutChar) - 1];//p2是填充的数据，也是填充的长度
        
        NSInteger outLength = miwenData.length ;//明文的长度
        
        //这里需要做判断，p2是否等于后面几个数
        //先判断最后一个字节是否为0，如果为0，就直接跳过，原明文没有填充
        if (p2 != 0) {
            
            //遍历最后p2个字节的数字是否都相同，如果都相同，则进行剪切，如果有一个不相同，就直接跳出
            for (int index = 1; index <= p2; index ++) {
                if (p2 != plainOutChar[sizeof(plainOutChar) - index]) {
                    break;
                }
                
                //当判断到倒数p2个字节时，数字仍旧相同的情况，就进行剪切得到原来明文的长度
                while (index == p2) {
                    outLength = outLength - p2;
                    break;
                }
            }
        }
        
        //去掉填充得到明文
        unsigned char plainOutWithoutPadding[outLength];
        memcpy(plainOutWithoutPadding, plainOutChar, outLength);
        //明文转成NSData 再转成NSString打印
        NSData *mingwenData = [[NSData alloc]initWithBytes:plainOutWithoutPadding length:sizeof(plainOutWithoutPadding)];
        
        NSLog(@"解密成功");
        
        return mingwenData;
    }else {
        
        //密文>64字节的时候，先取出前64字节进行解密，再拼接后面字节
        NSData *qianMianData = [miwenData subdataWithRange:NSMakeRange(0, 65536)];
        //将data拷贝到字符数组中
        unsigned char cipherTextChar[qianMianData.length];
        memcpy(cipherTextChar, miwenData.bytes, qianMianData.length);
        //调用解密方法，输出是明文plainOutChar
        unsigned char plainOutChar[qianMianData.length];
        //解密
        testDecodejiemi(key, 65536., cipherTextChar, plainOutChar);
        //将输出的转换为NSdata
//        NSData *mingwenData = [[NSData alloc]initWithBytes:plainOutChar length:sizeof(plainOutChar)];
        
        NSMutableData *qian64MingwenData =  [[NSMutableData alloc]initWithBytes:plainOutChar length:sizeof(plainOutChar)];
        
        //将明文data从64字节开始剪切到最后，为pinjieData
        NSData *pinjieData = [miwenData subdataWithRange:NSMakeRange(65536, miwenData.length - 65536)];
        
        //将前64位和最后剪切的数据拼接
        [qian64MingwenData appendData:pinjieData];
        
        NSLog(@"解密成功");
        
        return qian64MingwenData;
    }
}

@end
