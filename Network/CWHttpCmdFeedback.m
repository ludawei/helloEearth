//
//  CWHttpCmdFeedback.m
//  ChinaWeather
//
//  Created by ludawei on 7/19/13.
//  Copyright (c) 2013 Platomix. All rights reserved.
//

#import "CWHttpCmdFeedback.h"
#import "DeviceUtil.h"
#import "Util.h"
#import "PLHttpManager.h"

@implementation CWHttpCmdFeedback

- (NSString *)method
{
    return @"POST";
}

- (NSString *)path
{
    return @"http://decision-admin.tianqi.cn/Home/work/request";
}

-(void)startRequest
{
    NSString* content = self.content ? self.content : @"";
    NSString* email = self.email ? self.email : @"";
    NSString* tel = self.tel ? self.tel : @"";
    
    NSMutableDictionary* data = [NSMutableDictionary dictionary];
    [data setValue: @"23" forKey: @"appid"];
    [data setValue: @"蓝PI.寰宇" forKey: @"uid"];
    [data setValue: content forKey: @"content"];
    [data setValue: email forKey: @"email"];
    [data setValue: tel forKey: @"mobile"];
    
    [[PLHttpManager sharedInstance] POST:self.path parameters:data success:^(NSURLSessionDataTask *operation, id responseObject) {
        [self didSuccess:responseObject];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        [self didFailed:operation];
    }];
}

@end
