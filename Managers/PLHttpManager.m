//
//  HCHttpManager.m
//  HighCourt
//
//  Created by ludawei on 13-9-24.
//  Copyright (c) 2013年 ludawei. All rights reserved.
//

#import "PLHttpManager.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "CWHttpCmdWeather.h"
#import "DecStr.h"
#import "ZipStr.h"

#if 1
NSString * const pLBaseURLString = @"http://decision.tianqi.cn";
#else
NSString * const pLBaseURLString = @"";
#endif

@interface PLHttpManager ()

@property (nonatomic,strong) AFHTTPRequestOperationManager *manager;

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
    
    _manager = [AFHTTPRequestOperationManager manager];
    _manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"application/octet-stream",@"multipart/form-data", @"text/html; charset=ISO-8859-1", @"application/javascript",nil];
//    [(AFJSONResponseSerializer *)self.manager.responseSerializer setReadingOptions:NSJSONReadingAllowFragments];
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
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
    
    NSData *data = cmd.data;
    if(data)
    {
        int len = (int)[data length];
        char* encryStr = (char*) malloc(len);
        if(encryStr)
        {
            memcpy(encryStr, [data bytes], len);
            [DecStr encrypt: encryStr length: len];
            NSData *_data = [NSData dataWithBytes:encryStr length:len];
            free(encryStr);
            
            [request setHTTPBody:_data];
        }
    }
    
    AFHTTPRequestOperation *operation = [self.manager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([cmd isKindOfClass:[CWHttpCmdWeather class]]) {
            responseObject = operation.responseData;
            
            NSString *multipartLength = [[operation.response allHeaderFields] objectForKey:@"lengthn"];
            if([responseObject isKindOfClass:[NSData class]] &&
               multipartLength)
            {
                responseObject = [self splitMultiWeather:responseObject andLength:multipartLength];
            }
        }
        
        if ([cmd isResponseZipped]) {
            responseObject = [self decodeResponseZippedData:operation.responseData];
        }
        
        [cmd didSuccess:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([cmd isResponseZipped]) {
           id responseObject = [self decodeResponseZippedData:operation.responseData];
            LOG(@"%@",responseObject);
            if (responseObject) {
                [cmd didSuccess:responseObject];
            }
            else
            {
                [cmd didFailed:operation];
            }
        }
        else
        {
            [cmd didFailed:operation];
        }
    }];
    
    [self.manager.operationQueue addOperation:operation];
}


#pragma mark - 针对多城市数据的分割方法

- (NSArray *)splitMultiWeather:(NSData *)data andLength:(NSString *)length
{
    NSArray *lens;
    if(!length)
    {
        lens = [NSArray arrayWithObject:[NSString stringWithFormat:@"%ld", (unsigned long)data.length]];
    }
    else
    {
        lens = [length componentsSeparatedByString:@","];
    }
    
    int offset = 0;
    NSMutableArray *components = [NSMutableArray arrayWithCapacity:lens.count];
    for (NSString *lenStr in lens)
    {
        int len = [lenStr intValue];
        if(offset + len > data.length)
        {
            // out of range
            break;
        }
        NSData *subdata = [data subdataWithRange:NSMakeRange(offset, len)];
        offset += len;
        [components addObject:subdata];
    }
    
    return components;
}

- (id)decodeResponseZippedData:(id)object
{
    NSData *rawData = object;
    
    id jsonObject = nil;
    
    char* decryptStr = (char*) malloc([rawData length] + 1); // need to free
    memcpy(decryptStr, (const char*) [rawData bytes], [rawData length]);
    [DecStr decrypt: decryptStr length: (int)[rawData length]];
    decryptStr[[rawData length]] = '\0';
    
#if 0
    NSData *data = [NSData dataWithBytes:decryptStr length:[rawData length]];
    jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    
    free(decryptStr);
#else
    char* uncomStr = [ZipStr Uncompress:decryptStr length:(int)[rawData length]]; // need to free
    if(uncomStr)
    {
        NSData *decodedResponseData = [NSData dataWithBytesNoCopy:uncomStr length:strlen(uncomStr)];
        jsonObject = [NSJSONSerialization JSONObjectWithData:decodedResponseData options:NSJSONReadingMutableContainers error:nil];
    }
    else
    {
        NSData *decodedResponseData = [NSData dataWithBytesNoCopy:decryptStr length:[rawData length]];
        jsonObject = [NSJSONSerialization JSONObjectWithData:decodedResponseData options:NSJSONReadingMutableContainers error:nil];
    }
#endif
    
    return jsonObject;
}

-(AFHTTPRequestOperationManager *)manager
{
    return _manager;
}
@end
