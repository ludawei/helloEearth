//
//  DecStr.m
//  adi
//
//  Created by LIU Zhongjie on 3/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DecStr.h"
#import "UtilConstants.h"

@implementation DecStr

+ (void) encrypt: (char*) buffer length: (unsigned int) len
{
    int pos = 0;
    @try
    {
        NSInteger keylen = [KEY lengthOfBytesUsingEncoding: NSUTF8StringEncoding];
        const char* c = [KEY UTF8String];
        for (int i = 0; i < len; i++, pos = (pos + 1) % keylen)
            buffer[i] ^= c[pos];
    }
    @catch (NSException* e)
    {
    }
}

+ (void) decrypt: (char*) buffer length: (int) len
{
    [DecStr encrypt: buffer length: len];
}

@end