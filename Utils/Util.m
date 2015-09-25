//
//  Util.m
//  chinaweathernews
//
//  Created by 卢大维 on 14-10-17.
//  Copyright (c) 2014年 weather. All rights reserved.
//

#import "Util.h"
#import "CWEncode.h"

@implementation Util

+ (UIImage *) createImageWithColor: (UIColor *) color width:(CGFloat)width height:(CGFloat)height
{
    CGRect rect=CGRectMake(0.0f, 0.0f, width, height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

+ (UIImage *) drawText:(NSString*)text inImage:(UIImage*)image font:(UIFont *)font textColor:(UIColor *)color
{
    if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0f);
    } else {
        UIGraphicsBeginImageContext(image.size);
    }
    
    CGRect rect = CGRectMake(0,0,image.size.width,image.size.height);
    [image drawInRect:rect];

    CGFloat textWidth = image.size.width/2 * sin(M_PI/4);
    
    CGSize size = [text sizeWithAttributes:@{NSFontAttributeName: font}];
    
    CGRect r = CGRectMake(rect.size.width/2 - textWidth, rect.size.height/2 - textWidth, textWidth*2, textWidth*2*2);
    
    if (size.width < rect.size.width)
    {
        r = CGRectMake(rect.origin.x,
                              rect.origin.y + (rect.size.height - size.height)/2,
                              rect.size.width,
                              (rect.size.height - size.height)/2);

    }

#if 1
    NSMutableParagraphStyle *parStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    parStyle.lineBreakMode = NSLineBreakByWordWrapping;
    parStyle.alignment     = NSTextAlignmentCenter;
    [text drawInRect:r withAttributes:@{NSFontAttributeName : font,
                                        NSParagraphStyleAttributeName: parStyle,
                                        NSForegroundColorAttributeName: color}];
#else
    [color set];
    [text drawInRect:r withFont:font lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];
#endif
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage *)addImage:(UIImage *)image1 toImage:(UIImage *)image2 toRect:(CGRect)frame
{
    UIGraphicsBeginImageContext(image2.size);
    
    // Draw image1
    [image2 drawInRect:CGRectMake(0, 0, image2.size.width, image2.size.height)];
    
    // Draw image2
    [image1 drawInRect:frame];
    
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resultingImage;
}

+(UIButton *)leftNavButtonWithSize:(CGSize)size
{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    [button setImage:[UIImage imageNamed:@"返回"] forState:UIControlStateNormal];
    button.imageEdgeInsets = UIEdgeInsetsMake(-10, -5, 0, 0);
    
    return button;
}

+(UIButton *)rightNavButtonWithTitle:(NSString *)title
{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleEdgeInsets = UIEdgeInsetsMake(-10, 0, 0, -5);
    [button sizeToFit];
    
    return button;
}
#pragma mark - *****************************
+ (NSString*) getAppKey
{
    NSString* appKey = @"";
    @try
    {
        NSString* str = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"WEATHER_APPKEY"];
        if (str != nil)
            appKey = str;
    }
    @catch(NSException* e)
    {
    }
    return appKey;
}

+ (NSString *)parseWeather:(NSString *)code
{
    switch (code.intValue)
    {
        case 10:  return @"暴雨";
        case 11:  return @"大暴雨";
        case 12:  return @"特大暴雨";
        case 13:  return @"阵雪";
        case 14:  return @"小雪";
        case 15:  return @"中雪";
        case 16:  return @"大雪";
        case 17:  return @"暴雪";
        case 18:  return @"雾";
        case 19:  return @"冻雨";
        case 20:  return @"沙尘暴";
        case 21:  return @"小到中雨";
        case 22:  return @"中到大雨";
        case 23:  return @"大到暴雨";
        case 24:  return @"暴雨到大暴雨";
        case 25:  return @"大暴雨到特大暴雨";
        case 26:  return @"小到中雪";
        case 27:  return @"中到大雪";
        case 28:  return @"大到暴雪";
        case 29:  return @"浮尘";
        case 30:  return @"扬沙";
        case 31:  return @"强沙尘暴";
        case 32:  return @"浓雾";
        case 33:  return @"雪";
        case 34:  return @"阴";
        case 35:  return @"阵雨";
        case 36:  return @"阵雨";
        case 37:  return @"阵雨";
        case 38:  return @"阵雨";
        case 39:  return @"阴";
        case 40:  return @"阴";
        case 49:  return @"强浓雾";
        case 53:  return @"霾";
        case 54:  return @"中度霾";
        case 55:  return @"重度霾";
        case 56:  return @"严重霾";
        case 57:  return @"大雾";
        case 58:  return @"特强浓雾";
        case 99:  return @"无";
        case 0:   return @"晴";
        case 1:   return @"多云";
        case 2:   return @"阴";
        case 3:   return @"阵雨";
        case 4:   return @"雷阵雨";
        case 5:   return @"雷阵雨伴有冰雹";
        case 6:   return @"雨夹雪";
        case 7:   return @"小雨";
        case 8:   return @"中雨";
        case 9:   return @"大雨";
            
        default:
            break;
    }
    return @"?";
}

+ (NSString *)parseWindDirection:(NSString *)code
{
    // {\"0\":\"无持续风向\",\"1\":\"东北风\",\"2\":\"东风\",\"3\":\"东南风\",\"4\":\"南风\",\"5\":\"西南风\",\"6\":\"西风\",\"7\":\"西北风\",\"8\":\"北风\",\"9\":\"旋转风\"}
    
    switch (code.intValue)
    {
        case 0:   return @"无持续风向";
        case 1:   return @"东北风";
        case 2:   return @"东风";
        case 3:   return @"东南风";
        case 4:   return @"南风";
        case 5:   return @"西南风";
        case 6:   return @"西风";
        case 7:   return @"西北风";
        case 8:   return @"北风";
        case 9:   return @"旋转风";
            
        default:
            break;
    }
    return @"?";
}

+ (NSString *)parseWindForce:(NSString *)code
{
    switch (code.intValue)
    {
        case 0:   return @"微风";
            
        default:
            break;
    }
    return [NSString stringWithFormat:@"%@级", code];
}

+ (NSString *)requestEncodeWithString:(NSString *)url appId:(NSString *)appId privateKey:(NSString *)priKey
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmm"];
    NSString *now = [formatter stringFromDate:[NSDate date]];
    
    NSString *public_key = [NSString stringWithFormat:@"%@date=%@&appid=%@", url, now, appId];
    NSString *key = [CWEncode encodeByPublicKey:public_key privateKey:priKey];
    NSString *finalUrl = [NSString stringWithFormat:@"%@date=%@&appid=%@&key=%@", url, now, [appId substringToIndex:6], [Util AFPercentEscapedQueryStringPairMemberFromString:key encoding:NSUTF8StringEncoding]];
    
    return finalUrl;
}

+ (NSString *)AFPercentEscapedQueryStringPairMemberFromString:(NSString *)string encoding:(NSStringEncoding)edcoding
{
    return AFPercentEscapedQueryStringPairMemberFromStringWithEncoding(string, edcoding);
}

static NSString * AFPercentEscapedQueryStringPairMemberFromStringWithEncoding(NSString *string, NSStringEncoding encoding) {
    static NSString * const kAFCharactersToBeEscaped = @":/?&=;+!@#$()',*";
    static NSString * const kAFCharactersToLeaveUnescaped = @"[].";
    
    return (__bridge_transfer  NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)string, (__bridge CFStringRef)kAFCharactersToLeaveUnescaped, (__bridge CFStringRef)kAFCharactersToBeEscaped, CFStringConvertNSStringEncodingToEncoding(encoding));
}

+(UIColor *)colorFromRGBString:(NSString *)rbgString
{
    if ([rbgString hasPrefix:@"rgba"]) {
        return [UIColor clearColor];
    }
    unsigned long rgbValue = strtoul([[rbgString stringByReplacingOccurrencesOfString:@"#" withString:@"0x"] UTF8String], 0, 16);
    
    return [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0];
}

+(UIFont *)modifyFontWithName:(NSString *)name size:(CGFloat)size
{
    CGFloat newSize = MIN(size*SCREEN_SIZE.width/414.0, size);
    return [UIFont fontWithName:name size:newSize];
}
+(UIFont *)modifySystemFontWithSize:(CGFloat)size
{
    CGFloat newSize = MIN(size*SCREEN_SIZE.width/414.0, size);
    return [UIFont systemFontOfSize:newSize];
}
+(UIFont *)modifyBoldSystemFontWithSize:(CGFloat)size
{
    CGFloat newSize = MIN(size*SCREEN_SIZE.width/414.0, size);
    return [UIFont boldSystemFontOfSize:newSize];
}


+ (BOOL) isEmpty: (id) var
{
    if ([var isKindOfClass: [NSString class]])
        return var == nil || [var stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0;
    else if ([var isKindOfClass: [NSArray class]])
        return var == nil || ((NSArray*) var).count == 0;
    else
        return var == nil;
}

+ (NSString*) checkString: (NSString*) src length: (int) length
{
    if (src == nil)
        return @"";
    return [src lengthOfBytesUsingEncoding: NSUTF8StringEncoding] <= length ? src : [src substringToIndex: length];
}

+ (NSString*) formatCoord: (NSString*) res
{
    NSString* returnStr = @"";
    @try
    {
        float parseFloat = [res floatValue];
        returnStr = [NSString stringWithFormat: @"%.7f", parseFloat];
    }
    @catch (NSException *exception)
    {
        returnStr = @"";
    }
    return returnStr;
}

+ (NSString*) JSONArray2Str: (NSArray*) json
{
    if (json == nil)
        return nil;
    NSData* data = [NSJSONSerialization dataWithJSONObject: json options: 0 error: nil];
    return [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
}

+ (NSArray*) Str2JSONArray: (NSString*) str
{
    if ([Util isEmpty: str])
        return nil;
    
    @try {
        NSArray* returnJSONArray = [NSJSONSerialization JSONObjectWithData: [str dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableLeaves error: nil];
        return returnJSONArray;
    }
    @catch (NSException *exception) {
        return nil;
    }
}

+ (NSInteger) randomInt
{
    return arc4random() % 3 + 1;
}
+ (NSDate*) Str2date: (NSString*) dateValue
{
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat: @"yyyy-MM-dd"];
    NSDate* date = [dateFormat dateFromString: dateValue];
    return date;
}
@end
