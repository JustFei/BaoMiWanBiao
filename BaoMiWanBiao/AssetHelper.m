//
//  PhotoModel.m
//  AlbumTest
//
//  Created by ejiang on 14-8-1.
//  Copyright (c) 2014年 daijier. All rights reserved.
//

#import "AssetHelper.h"

@implementation AssetHelper
+(ALAssetsLibrary *) defaultAssetsLibrary;
{
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *library = nil;
    dispatch_once(&pred,
                  ^{
                      library = [[ALAssetsLibrary alloc] init];
                  });
    return library;
}
@end
