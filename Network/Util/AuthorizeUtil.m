//
//  AuthorizeUtil.m
//  adi
//
//  Created by Zhongjie LIU on 10/12/12.
//
//

#import "AuthorizeUtil.h"
#import "DecStr.h"
#import "Base64.h"

@interface AuthorizeUtil (Private)

+ (bool) oauthWeather;
+ (NSString*) getExpiration;
+ (NSString*) getUpload;

@end

@implementation AuthorizeUtil

const NSString* EXPIRATION = @"expiration";
const NSString* UPLOAD = @"upload";

+ (NSString*) getAppKey
{
    NSString* appKey = @"";
    @try
    {
        NSString* str = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"WEATHER_APPKEY"];
//        NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
//        NSString* str = (NSString*) [userDefaults objectForKey: @"WEATHER_APPKEY"];
        if (str != nil)
            appKey = str;
    }
    @catch(NSException* e)
    {
    }
    return appKey;
}

+ (void) saveOauthData: (NSString*) expiration string: (NSString*) upload
{
    NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setValue: expiration
                   forKey: (NSString*) EXPIRATION];
    [userDefault setValue: upload
                   forKey: (NSString*) UPLOAD];
}

+ (NSString*) getExpiration
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* exp = (NSString*) [userDefaults objectForKey: (NSString*) EXPIRATION];
    if (exp == nil)
        return @"";
    return exp;
}

+ (NSString*) getUpload
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* upload = (NSString*) [userDefaults objectForKey: (NSString*) UPLOAD];
    if (upload == nil)
        return @"";
    return upload;
}

+ (NSString*) getBaseUpload
{
    NSString* str = [AuthorizeUtil getUpload];
    if ([str isEqual: @""])
        return str;
    const char* bytes = [str UTF8String];
    return [Base64 base64Encode: (const unsigned char*) bytes length: (int)[str lengthOfBytesUsingEncoding: NSUTF8StringEncoding]];
}

@end
