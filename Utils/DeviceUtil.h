//
//  DeviceUtil.h
//  adi
//
//  Created by LIU Zhongjie on 4/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#include <UIKit/UIKit.h>

@interface DeviceUtil : NSObject

+ (NSString*) getIMSI;
+ (NSString*) getDeviceId;
+ (NSString*) getSoftVersion: (bool) isName;
+ (NSString*) getOsVersionInMetaData;
+ (NSString*) getMobileVersion;
+ (NSString*) getVersionType;
+ (NSString*) getDeviceType;
+ (int) getOperatorId;
+ (NSString*) getPhoneNumber: (bool) withIMSI;

@end
