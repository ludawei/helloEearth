//
//  CWEncode.h
//  ChinaWeather
//
//  Created by 卢大维 on 14-7-23.
//  Copyright (c) 2014年 Platomix. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CWEncode : NSObject

+(NSString *)encodeByPublicKey:(NSString *)public_key privateKey:(NSString *)private_key;
+(void)test;

@end
