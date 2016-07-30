/*
 * SM4/SMS4 algorithm test programme
 * 2012-4-21
 */

#include <string.h>
#include <stdio.h>
#include "sm4.h"

int mainTest4()
{
	unsigned char key[16] = {0x01,0x23,0x45,0x67,0x89,0xab,0xcd,0xef,0xfe,0xdc,0xba,0x98,0x76,0x54,0x32,0x10};
	unsigned char input[16] = {0x01,0x23,0x45,0x67,0x89,0xab,0xcd,0xef,0xfe,0xdc,0xba,0x98,0x76,0x54,0x32,0x10};
	unsigned char output[16];
	sm4_context ctx;
	unsigned long i;

	//encrypt standard testing vector
	sm4_setkey_enc(&ctx,key);
	sm4_crypt_ecb(&ctx,1,16,input,output);
	for(i=0;i<16;i++)
		printf("密文 == %02x ", output[i]);
	printf("\n");

	//decrypt testing
	sm4_setkey_dec(&ctx,key);
	sm4_crypt_ecb(&ctx,0,16,output,output);
	for(i=0;i<16;i++)
		printf("明文和秘钥 == %02x ", output[i]);
	printf("\n");

	//decrypt 1M times testing vector based on standards.
	i = 0;
	sm4_setkey_enc(&ctx,key);
	while (i<1000000) 
    {
		sm4_crypt_ecb(&ctx,1,16,input,input);
		i++;
    }
	for(i=0;i<16;i++)
		printf("加密一百万次 == %02x ", input[i]);
	printf("\n");
	
    return 0;
}

//4.对plainInChar加密，由于源代码中加解密是放在一起的，现在在sm4test.c中新添加两个方法把加密和解密分开,由于计算length总出问题，所以直接把length作为参数传进去
/**
 *  加密
 *
 *  @param key    传入16字节秘钥
 *  @param lenght 填充的字节数
 *  @param in     传入的明文
 *  @param output 输出的密文
 */
void testEncodejiami(unsigned char key[], unsigned int lenght,unsigned char in[], unsigned char output[]){
    sm4_context ctx;
    //设置上下文和密钥
    sm4_setkey_enc(&ctx,key);
    //加密
    sm4_crypt_ecb(&ctx,1,lenght,in,output);
}

/**
 *  解密
 *
 *  @param key    把秘钥当参数传入
 *  @param lenght 明文未满16字节倍数的，填充至16字节倍数后，填充的字节数，0 <= lenght <= 15
 *  @param in     传入的密文
 *  @param output 输出的明文
 */
void testDecodejiemi(unsigned char key[], unsigned int lenght, unsigned char in[], unsigned char output[]){
    sm4_context ctx;
    //设置上下文和密钥
    sm4_setkey_dec(&ctx,key);
    //解密
    sm4_crypt_ecb(&ctx,0,lenght,in,output);
}
