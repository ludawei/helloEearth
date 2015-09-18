//
//  CWEncode.m
//  ChinaWeather
//
//  Created by 卢大维 on 14-7-23.
//  Copyright (c) 2014年 Platomix. All rights reserved.
//

#import "CWEncode.h"
#include "encode.h"

@implementation CWEncode

+(NSString *)encodeByPublicKey:(NSString *)public_key privateKey:(NSString *)private_key
{
    char *rkey =  calloc(50,sizeof(char));
    encode((char *)public_key.UTF8String, (char *)private_key.UTF8String, rkey);
    NSString *key = [NSString stringWithUTF8String:rkey];
    free(rkey);
    
    return key;
}

+(void) test
{
    //  strcpy(cKeyVal,"doMIwSLtisVFvJWz2j9V7Rj5d5c%3D");
    char *public_key = "http://geo.weather.com.cn/al1/?appid=f573587ae1f343c5&date=201407231024&lat=39.91&lon=116.30";//"http://geo.weather.com.cn/al1/?lon=132.23&lat=34.17&date=201407181129&appid=f573587ae1f343c5";
    char *private_key = "chinaweather_geo_data";
    char *rkey =  calloc(50,sizeof(char));
    
    encode(public_key,private_key,rkey);
    printf("encode 返回：\n");
    printf("key: %s\n", rkey);
    free(rkey);
}

@end
