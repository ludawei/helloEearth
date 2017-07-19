//
//  HCHttpManager.m
//  HighCourt
//
//  Created by ludawei on 13-9-24.
//  Copyright (c) 2013年 ludawei. All rights reserved.
//

#import "PLHttpManager.h"
//#import "AFNetworkActivityIndicatorManager.h"

#if 1
NSString * const pLBaseURLString = @"http://decision.tianqi.cn";
#else
NSString * const pLBaseURLString = @"";
#endif

@interface PLHttpManager ()

@property (nonatomic,strong) AFHTTPSessionManager *manager;

@end

@implementation PLHttpManager

+ (PLHttpManager *)sharedInstance
{
    static PLHttpManager *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

-(id)init
{
    self = [super init];
    if (!self)
    {
        return nil;
    }
    
    _manager = [AFHTTPSessionManager manager];
    _manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"application/octet-stream",@"multipart/form-data", @"text/html; charset=ISO-8859-1", @"application/javascript",nil];
//    [(AFJSONResponseSerializer *)self.manager.responseSerializer setReadingOptions:NSJSONReadingAllowFragments];
//    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    return self;
}

-(NSString *)baseUrlString
{
    return pLBaseURLString;
}

-(NSString *)finalImagePath:(NSString *)imgUrl
{
    return [NSString stringWithFormat:@"%@%@", pLBaseURLString, imgUrl];
}

-(void)parserRequest:(PLHttpCmd *)cmd
{
    NSMutableURLRequest *request = [self.manager.requestSerializer requestWithMethod:cmd.method URLString:cmd.path parameters:cmd.queries error:nil];
    
    if(cmd.headers)
    {
        NSArray *keys = cmd.headers.allKeys;
        for(NSString *key in keys)
        {
            [request addValue:[cmd.headers objectForKey:key] forHTTPHeaderField:key];
        }
    }
    
    [[self.manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (!error) {
            [cmd didSuccess:responseObject];
        }
        else
        {
            [cmd didFailed:nil];
        }
    }] resume];
}

-(AFHTTPSessionManager *)manager
{
    return _manager;
}

-(NSURLSessionDataTask *)GET:(NSString *)url parameters:(id)parameters success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
          failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    return [self.manager GET:url parameters:parameters success:success failure:failure];
}

-(NSURLSessionDataTask *)POST:(NSString *)url parameters:(id)parameters success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
   failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    return [self.manager POST:url parameters:parameters success:success failure:failure];
}
@end
