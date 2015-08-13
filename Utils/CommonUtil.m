//
//  CommonUtil.m
//  ChinaWeatherAPI_ios
//
//  Created by Zhongjie LIU on 11/1/12.
//  Copyright (c) 2012 Eray Mobile. All rights reserved.
//

#import "CommonUtil.h"

@implementation CommonUtil

+ (bool) isEmpty: (id) var
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
    if ([CommonUtil isEmpty: str])
        return nil;
    
    @try {
        NSArray* returnJSONArray = [NSJSONSerialization JSONObjectWithData: [str dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableLeaves error: nil];
        return returnJSONArray;
    }
    @catch (NSException *exception) {
        return nil;
    }
}

+ (int) randomInt
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
