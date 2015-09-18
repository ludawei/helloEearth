//
//  DeviceUtil.m
//  adi
//
//  Created by LIU Zhongjie on 4/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DeviceUtil.h"
//#import <sys/utsname.h>
#import "Util.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

@implementation DeviceUtil

+ (NSString*) getIMSI
{
    return @"unsupported";
}

+ (NSString*) getDeviceId
{
    return @"unsupported";
}

+ (NSString*) getSoftVersion: (bool) isName
{
    if (isName)
    {
        NSString* name = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"Software Version Name"];
        if (name != nil)
            return name;
        else
            return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    }
    else
    {
//        NSString* version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"Software Version Code"];
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
        if (version != nil)
            return version;
        else
            return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    }
}

+ (NSString*) getOsVersionInMetaData
{
    NSString* version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"osVersion"];
    if (version != nil)
        return version;
    else
    {
        NSString* ret = [[UIDevice currentDevice] systemName];
        ret = [ret stringByAppendingString: [[UIDevice currentDevice] systemVersion]];
        return [Util checkString: ret length: 25];
    }
}

+ (NSString*) getMobileVersion
{
    NSString* ret = [[UIDevice currentDevice] systemVersion];
    ret = [NSString stringWithFormat: @"ios_%@", ret];
    return [Util checkString: ret length: 25];
}

+ (NSString*) getVersionType
{
    NSString* version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"VERSIONTYPE"];
    if (version != nil)
        return version;
    else
    {
        return @"general";
    }
}

+ (NSString*) getDeviceType
{
    UIDevice *dev = [UIDevice currentDevice];
//    struct utsname systemInfo;
//    uname(&systemInfo);
//    //get the device model and the system version
//    NSString* model = [NSString stringWithCString: systemInfo.machine encoding: NSUTF8StringEncoding];
    return [Util checkString: dev.model length: 50];
}

+ (int) getOperatorId
{
    int Operator = 0;
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = info.subscriberCellularProvider;
    NSString* simOperator = [carrier carrierName];
    if (simOperator != nil)
    {
        if ([simOperator compare: @"46000"] == 0 ||
            [simOperator compare: @"46002"] == 0 ||
            [simOperator compare: @"46007"])
        {
            return 1;//中国移动
        }
        else if ([simOperator compare: @"46001"] == 0)
        {
            return 2;//中国联通
        }
        else if ([simOperator compare: @"46003"] == 0)
        {
            return 3;//中国电信
        }
    }
    return Operator;
}

+ (NSString*) getPhoneNumber: (bool) withIMSI
{
    return @"unsupported";
}

@end