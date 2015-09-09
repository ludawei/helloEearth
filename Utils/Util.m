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

    [color set];
    
    CGFloat textWidth = image.size.width/2 * sin(M_PI/4);
    
    CGSize size = [text sizeWithAttributes:@{NSFontAttributeName: font}];
    if (size.width < rect.size.width)
    {
        CGRect r = CGRectMake(rect.origin.x,
                              rect.origin.y + (rect.size.height - size.height)/2,
                              rect.size.width,
                              (rect.size.height - size.height)/2);
        [text drawInRect:r withFont:font lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];
    }
    else
    {
        CGRect r = CGRectMake(rect.size.width/2 - textWidth, rect.size.height/2 - textWidth, textWidth*2, textWidth*2*2);
        [text drawInRect:r withFont:font lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];
    }
    
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
@end
