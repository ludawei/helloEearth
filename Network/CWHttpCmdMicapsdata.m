//
//  CWHttpCmdMicapsdata.m
//  ChinaWeather
//
//  Created by 卢大维 on 15/1/14.
//  Copyright (c) 2015年 Platomix. All rights reserved.
//

#import "CWHttpCmdMicapsdata.h"
#import "CWEncode.h"
#import "Util.h"

// http://scapi.weather.com.cn/weather/micapsdata?vti=030&type=1000&date=20141120&appid=6f688d&key=fSw7DD9dvDrtMqsK02ZhDa4%2Bl3E%3D
@implementation CWHttpCmdMicapsdata

- (NSString *)method
{
    return @"GET";
}

- (NSString *)path
{
    return [self getURLString:[self queries_1]];
}

- (NSDictionary *)queries
{
    return nil;
}

- (NSDictionary *)queries_1
{
    NSMutableDictionary* queryJson = [NSMutableDictionary dictionary];
    if(self.vti)
        [queryJson setValue:self.vti forKey: @"vti"];
    if(self.type)
        [queryJson setValue:self.type forKey: @"type"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmm"];
    NSString *curTime = [formatter stringFromDate:[NSDate date]];
    
    [queryJson setObject:curTime forKey:@"date"];
    [queryJson setObject:@"6f688d62594549a2" forKey:@"appid"];
    
    NSString *public_key = [self getPublicKey:queryJson];
    NSString *key = [CWEncode encodeByPublicKey:public_key privateKey:@"chinaweather_data"];
    
    [queryJson setObject:key forKey:@"key"];
    [queryJson setObject:[queryJson[@"appid"] substringToIndex:6] forKey:@"appid"];
    
    return queryJson;
}

-(NSString *)getPublicKey:(NSDictionary *)dict
{
    NSString *key = @"http://scapi.weather.com.cn/weather/micapsdata?";
    
    key = [key stringByAppendingString:[NSString stringWithFormat:@"vti=%@", dict[@"vti"]]];
    key = [key stringByAppendingString:[NSString stringWithFormat:@"&type=%@", dict[@"type"]]];
    key = [key stringByAppendingString:[NSString stringWithFormat:@"&date=%@", dict[@"date"]]];
    key = [key stringByAppendingString:[NSString stringWithFormat:@"&appid=%@", dict[@"appid"]]];
    
    return key;
}

-(NSString *)getURLString:(NSDictionary *)dict
{
    NSString *key = [self getPublicKey:dict];
    
    key = [key stringByAppendingString:[NSString stringWithFormat:@"&key=%@", [Util AFPercentEscapedQueryStringPairMemberFromString:dict[@"key"] encoding:NSUTF8StringEncoding]]];
    
    return key;
}
@end
