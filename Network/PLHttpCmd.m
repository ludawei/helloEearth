//
//  HCHttpCmd.m
//  HighCourt
//
//  Created by ludawei on 13-9-23.
//  Copyright (c) 2013年 ludawei. All rights reserved.
//

#import "PLHttpCmd.h"
#import "PLHttpManager.h"

static NSString *ret_content = @"content";
static NSString *ret_status = @"status";
static NSString *ewr_result = @"result";

@interface PLHttpCmd ()

//@property (nonatomic,strong) TJNetworkAnimView *animationView;

@end

@implementation PLHttpCmd

+ (id)cmd
{
    return [[self alloc] init];
}

- (id)init
{
    self = [super init];
    if(self)
    {
//        _cancelCallback = NO;
    }
    return self;
}

-(NSString *)subDomain
{
    return nil;
}

-(NSString *)method
{
    return @"GET";
}

-(NSString *)path
{
    return @"";
}

- (NSDictionary *)headers
{
    return nil;
}

- (NSDictionary *)queries
{
    NSArray *keys = [self getPropertyNameArray];
    
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:keys.count];
    for (NSString *propertyName in keys)
    {
        NSString *value = [self valueForKey:propertyName];
        if (value) {
            [d setObject:value forKey:propertyName];
        }
        
    }
    
    return d;
}

- (NSData *)data
{
    return nil;
}

- (BOOL)isResponseZipped
{
    return NO;
}

-(void)saveRetStatus:(id)object
{
    self.msg = [[object objectForKey:@"content"] objectForKey:@"resultDesc"];
    self.ret = [[[object objectForKey:@"content"] objectForKey:@"result"] intValue];
}

- (void)didSuccess:(id)object
{
//    [self saveRetStatus:object];
//    [self.animationView hideAnimation];
    if ([object isKindOfClass:[NSDictionary class]] || [object isKindOfClass:[NSArray class]]) {
//        NSDictionary *content = [(NSDictionary *)object objectForKey:ret_content];
        if (object) {
            if( _success)
            {
                _success(object);
            }
        }
        else
        {
            
        }
    }
    else
    {
        LOG(@"数据结构出错！");
    }
}

- (void)didFailed:(AFHTTPRequestOperation *)response
{
//    [self.animationView hideAnimation];
    if( _fail)
    {
        _fail(response);
    }
}

-(void)startRequest
{
//    [self.animationView showAnimation];
    [self startRequestWithOutAnimation];
}

-(void)startRequestWithOutAnimation
{
    [[PLHttpManager sharedInstance] parserRequest:self];
}

//-(UIView *)animationView
//{
//    if (!_animationView) {
//        _animationView = [TJNetworkAnimView loadFromNib];
//        [_animationView hideAnimation];
//        [[UIApplication sharedApplication].keyWindow addSubview:self.animationView];
//    }
//    return _animationView;
//}

@end
