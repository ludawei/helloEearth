//
//  CWHttpCmdNewGeoArea.m
//  ChinaWeather
//
//  Created by 卢大维 on 14-7-22.
//  Copyright (c) 2014年 Platomix. All rights reserved.
//

#import "CWHttpCmdNewGeoArea.h"
#import "CWEncode.h"
#import "PLHttpManager.h"

@implementation CWHttpCmdNewGeoArea

- (NSString *)method
{
    return @"GET";
}

- (NSString *)path
{
    return @"http://geo.weather.com.cn/al1/";
}

- (NSDictionary *)queries
{
    NSMutableDictionary* queryJson = [NSMutableDictionary dictionary];
    if(self.longitude)
        [queryJson setValue:self.longitude forKey: @"lon"];
    if(self.latitude)
        [queryJson setValue:self.latitude forKey: @"lat"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmm"];
    NSString *curTime = [formatter stringFromDate:[NSDate date]];
    
    [queryJson setObject:curTime forKey:@"date"];
    [queryJson setObject:@"f573587ae1f343c5" forKey:@"appid"];
    
    // key
    NSString *public_key = [self getPublicKey:queryJson];
    NSString *key = [CWEncode encodeByPublicKey:public_key privateKey:@"chinaweather_geo_data"];
    
    [queryJson setObject:key forKey:@"key"];
    [queryJson setObject:[queryJson[@"appid"] substringToIndex:6] forKey:@"appid"];
    
    return queryJson;
}

-(NSString *)getPublicKey:(NSDictionary *)dict
{
    NSString *key = @"http://geo.weather.com.cn/al1/?";
    
    key = [key stringByAppendingString:[NSString stringWithFormat:@"lon=%@", dict[@"lon"]]];
    key = [key stringByAppendingString:[NSString stringWithFormat:@"&lat=%@", dict[@"lat"]]];
    key = [key stringByAppendingString:[NSString stringWithFormat:@"&date=%@", dict[@"date"]]];
    key = [key stringByAppendingString:[NSString stringWithFormat:@"&appid=%@", dict[@"appid"]]];
    
    return key;
}


@end
