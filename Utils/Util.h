//
//  Util.h
//  chinaweathernews
//
//  Created by 卢大维 on 14-10-17.
//  Copyright (c) 2014年 weather. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Util : NSObject

+(UIImage *) createImageWithColor: (UIColor *) color width:(CGFloat)width height:(CGFloat)height;
+ (NSString*) getAppKey;
+ (NSString *)parseWeather:(NSString *)code;
+ (NSString *)parseWindDirection:(NSString *)code;
+ (NSString *)parseWindForce:(NSString *)code;

+ (NSString *)requestEncodeWithString:(NSString *)url appId:(NSString *)appId privateKey:(NSString *)priKey;
+ (NSString *)AFPercentEscapedQueryStringPairMemberFromString:(NSString *)string encoding:(NSStringEncoding)edcoding;

+(UIColor *)colorFromRGBString:(NSString *)rbgString;
@end
