//
//  CommonUtil.h
//  ChinaWeatherAPI_ios
//
//  Created by Zhongjie LIU on 11/1/12.
//  Copyright (c) 2012 Eray Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommonUtil : NSObject

+ (bool) isEmpty: (id) var;
+ (NSString*) checkString: (NSString*) src length: (int) length;
+ (NSString*) formatCoord: (NSString*) res;
+ (NSString*) JSONArray2Str: (NSArray*) json;
+ (NSArray*) Str2JSONArray: (NSString*) str;
+ (int) randomInt;
+ (NSDate*) Str2date: (NSString*) dateValue;
@end
