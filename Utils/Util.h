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
+ (UIImage *)imageChangedWithColor:(UIColor *)color image:(UIImage *)image;
+ (UIImage *) drawText:(NSString*)text inImage:(UIImage*)image font:(UIFont *)font textColor:(UIColor *)color;
+ (UIImage *)addImage:(UIImage *)image1 toImage:(UIImage *)image2 toRect:(CGRect)frame;
+(UIButton *)leftNavButtonWithSize:(CGSize)size;
+(UIButton *)rightNavButtonWithTitle:(NSString *)title;

+ (NSString*) getAppKey;
+ (NSString *)parseWeather:(NSString *)code;
+ (NSString *)parseWindDirection:(NSString *)code;
+ (NSString *)parseWindForce:(NSString *)code;

+ (NSString *)requestEncodeWithString:(NSString *)url appId:(NSString *)appId privateKey:(NSString *)priKey;
+ (NSString *)AFPercentEscapedQueryStringPairMemberFromString:(NSString *)string encoding:(NSStringEncoding)edcoding;

+(UIColor *)colorFromRGBString:(NSString *)rbgString alpha:(CGFloat)a;
+(UIFont *)modifyFontWithName:(NSString *)name size:(CGFloat)size;
+(UIFont *)modifySystemFontWithSize:(CGFloat)size;
+(UIFont *)modifyBoldSystemFontWithSize:(CGFloat)size;

+ (BOOL) isEmpty: (id) var;
+ (NSString*) checkString: (NSString*) src length: (int) length;
+ (NSString*) formatCoord: (NSString*) res;
+ (NSString*) JSONArray2Str: (NSArray*) json;
+ (NSArray*) Str2JSONArray: (NSString*) str;
+ (NSInteger) randomInt;
+ (NSDate*) Str2date: (NSString*) dateValue;
@end
