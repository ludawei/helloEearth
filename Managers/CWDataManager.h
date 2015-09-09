//
//  CWDataManager.h
//  NextRain
//
//  Created by 卢大维 on 14-10-23.
//  Copyright (c) 2014年 weather. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CWDataManager : NSObject

@property (readwrite) BOOL enablePushNotification;

+ (CWDataManager *)sharedInstance;

@property (readwrite) NSDictionary *mapRainData;
@property (readwrite) NSDictionary *mapCloudData;

@end
