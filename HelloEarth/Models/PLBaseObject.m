//
//  HCBaseObject.m
//  HighCourt
//
//  Created by ludawei on 13-9-24.
//  Copyright (c) 2013年 ludawei. All rights reserved.
//

#import "PLBaseObject.h"

@implementation PLBaseObject

-(id)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        [self dictionaryForObject:dict];
    }
    return self;
}

// 将一个字典反射到类中,但好字典的key与类的属性名相同
- (void)dictionaryForObject:(NSDictionary*) dict
{
    for (NSString *key in [dict allKeys])
    {
        id value = [dict objectForKey:key];
        
        if (value==[NSNull null])
        {
            continue;
        }
//        if ([value isKindOfClass:[NSDictionary class]])
//        {
//            id subObj = [self valueForKey:key];
//            if (subObj)
//                [subObj dictionaryForObject:value];
//        }
//        else
        @try {
            NSString *classKey = [NSString stringWithString:key];
            if ([classKey isEqualToString:@"description"])
            {
                classKey = @"description_";
            }
            [self setValue:value forKeyPath:classKey];
        }
        @catch (NSException *exception) {
            //LOG(@"%@类没有 '%@'", [self class], key);
            continue;
        }
    }
}

-(NSDictionary *)dictionaryFromObject
{
    
    NSArray *keys = [self allKeys];
    
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:keys.count];
    for (NSString *propertyName in keys)
    {
        NSString *value = [self valueForKey:propertyName];
        if (value) {
            [d setObject:value forKey:propertyName];
        }
        else
        {
            [d setObject:@"" forKey:propertyName];
        }
    }
    
    return d;
}

@end
