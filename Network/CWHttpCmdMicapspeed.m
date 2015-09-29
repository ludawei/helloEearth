//
//  CWHttpCmdHistorywindspeed.m
//  ChinaWeather
//
//  Created by 卢大维 on 15/1/23.
//  Copyright (c) 2015年 Platomix. All rights reserved.
//

#import "CWHttpCmdMicapspeed.h"
#import "CWEncode.h"
#import "Util.h"

// http://scapi.weather.com.cn/weather/micapswind?lon=121.674889&lat=38.878078&type=1000&date=20141120&appid=6f688d&key=tT%2FsoQNYRSXyxiOZl%2BUIsPMe%2B4M%3D
@implementation CWHttpCmdMicapspeed

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
    if(self.lat)
        [queryJson setValue:self.lat forKey: @"lat"];
    if(self.lon)
        [queryJson setValue:self.lon forKey: @"lon"];
    [queryJson setObject:@"1000" forKey:@"type"];
    NSDateFormatter *formatter = [CWDataManager sharedInstance].dateFormatter;
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
    NSString *key = @"http://scapi.weather.com.cn/weather/micapswind?";
    
    key = [key stringByAppendingString:[NSString stringWithFormat:@"lon=%@", dict[@"lon"]]];
    key = [key stringByAppendingString:[NSString stringWithFormat:@"&lat=%@", dict[@"lat"]]];
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
