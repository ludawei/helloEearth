//
//  CWHttpCmdFeedback.m
//  ChinaWeather
//
//  Created by 曹 君平 on 7/19/13.
//  Copyright (c) 2013 Platomix. All rights reserved.
//

#import "CWHttpCmdFeedback.h"
#import "AuthorizeUtil.h"

// http://app.weather.com.cn/second/feedback/upload

@implementation CWHttpCmdFeedback

- (NSString *)method
{
    return @"POST";
}

- (NSString *)path
{
    return @"http://app.weather.com.cn/second/feedback/upload";
}

-(BOOL)isResponseZipped
{
    return YES;
}

- (NSData *)data
{
    NSString* content = self.content ? self.content : @"";
    NSString* email = self.email ? self.email : @"";
    NSString* tel = self.tel ? self.tel : @"";

    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    if (!version){
        version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    }
    
    NSMutableDictionary *queryJson = [NSMutableDictionary dictionary];
    [queryJson setValue: [AuthorizeUtil getAppKey] forKey: @"appKey"];

    NSMutableDictionary* data = [NSMutableDictionary dictionary];
    [data setValue: @"3d-earth" forKey: @"userId"];
    [data setValue: @"" forKey: @"uId"];
    [data setValue: [NSString stringWithFormat: @"ios_%@", [[UIDevice currentDevice] systemVersion]] forKey: @"osVersion"];
    [data setValue: version forKey: @"softVersion"];
    [data setValue: content forKey: @"content"];
    [data setValue: email forKey: @"email"];
    [data setValue: tel forKey: @"tel"];
    
    [queryJson setValue: data forKey: @"data"];
    
    return [NSJSONSerialization dataWithJSONObject:queryJson options:0 error:nil];
}

@end
