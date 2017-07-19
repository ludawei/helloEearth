//
//  HCHttpManager.h
//  HighCourt
//
//  Created by ludawei on 13-9-24.
//  Copyright (c) 2013年 ludawei. All rights reserved.
//

#import "AFNetworking.h"
#import "PLHttpCmd.h"

@interface PLHttpManager:NSObject
{
}

+ (PLHttpManager *)sharedInstance;

- (NSString *)baseUrlString;
- (NSString *)finalImagePath:(NSString *)imgUrl;

- (void)parserRequest:(PLHttpCmd *)cmd;
-(AFHTTPSessionManager *)manager;
-(NSURLSessionDataTask *)GET:(NSString *)url parameters:(id)parameters success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
   failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
-(NSURLSessionDataTask *)POST:(NSString *)url parameters:(id)parameters success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
    failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
@end
