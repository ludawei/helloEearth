//
//  CWHttpCmdWeather.m
//  ChinaWeather
//
//  Created by 曹 君平 on 7/5/13.
//  Copyright (c) 2013 Platomix. All rights reserved.
//

#import "CWHttpCmdWeather.h"
#import "DecStr.h"
#import "ZipStr.h"
#import "CWDataManager.h"

// http://data.weather.com.cn/cwapidata/zh_cn.html?uk=
// http://data.weather.com.cn/cwapidata/??zh_cn/101010100.html,zh_cn/101010200.html?uk=NmY2ODhkNjI1OTQ1NDlhMnwyMDEzLTA3LTEw
// 获取城市的 时间、城市信息、实况、预报、指数、预警、广告、天气解读八方面数据内容的异步线程类

@implementation CWHttpCmdWeather

- (NSString *)path
{
    NSString *language = @"zh_cn";
    if(self.cityIds && self.cityIds.count > 0)
    {
        NSMutableString *string = [NSMutableString stringWithFormat:@"http://data.weather.com.cn/cwapidatanew/??"];
        for (int i = 0; i < self.cityIds.count; ++i)
        {
            if(i > 0) [string appendString:@","];

            [string appendFormat:@"%@/%@.html", language, self.cityIds[i]];
        }
        return string;
    }

    // should not happen
    return @"cwapidata";
}

- (NSDictionary *)queries
{
    return nil;
}

- (NSDictionary *)headers
{
    return @{@"Accept" :@"application/json"};
}

- (void)didSuccess:(id)object
{
    NSMutableDictionary *ret_dict = nil;
    if([object isKindOfClass:[NSArray class]])
    {
        ret_dict = [NSMutableDictionary dictionary];
        
        NSArray *components = object;

        for (NSData *rawData in components)
        {
            id jsonObject = nil;
            char* decryptStr = (char*) malloc([rawData length] + 1); // need to free
            memcpy(decryptStr, (const char*) [rawData bytes], [rawData length]);
            [DecStr decrypt: decryptStr length: [rawData length]];
            decryptStr[[rawData length]] = '\0';
            
            char* uncomStr = [ZipStr Uncompress:decryptStr length:[rawData length]]; // need to free
            if(uncomStr)
            {
                // the ownership of uncomStr is transferred
                NSData *decodedResponseData = [NSData dataWithBytesNoCopy:uncomStr length:strlen(uncomStr)];
                jsonObject = [NSJSONSerialization JSONObjectWithData:decodedResponseData options:NSJSONReadingMutableContainers error:nil];
                // free is not necessary
                // free(uncomStr);
            }
            
            if(jsonObject)
            {
                // log city name for debug
                NSString *cityId = [[jsonObject objectForKey:@"c"] objectForKey:@"c1"];

                if (cityId) {
                    [ret_dict setObject:jsonObject forKey:cityId];
                }
                //返回数据后收集用户信息
                // 成功后请求historyWeather
            }

            free(decryptStr);
        }
    }
    // else unknown data, should not happen

    if (ret_dict) {
        [super didSuccess:ret_dict];
    }
    else
    {
        [super didSuccess:object];
    }
}

@end
