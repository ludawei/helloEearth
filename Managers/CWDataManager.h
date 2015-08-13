//
//  CWDataManager.h
//  NextRain
//
//  Created by 卢大维 on 14-10-23.
//  Copyright (c) 2014年 weather. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CWDataManager : NSObject

@property (readwrite) NSArray *subscribeIndexs;
@property (readwrite) NSArray *navList;
@property (readwrite) NSArray *hotCities;
@property (readwrite) BOOL enablePushNotification;

+ (CWDataManager *)sharedInstance;

// 收藏相关
-(NSArray *)collectList;
-(NSDictionary *)collectDict;
-(void)collectDictAddObject:(NSDictionary *)collectDict;
-(void)collectDictremoveObjectForKey:(NSString *)key;

-(void)saveUerData:(NSDictionary *)userDict;
-(NSDictionary *)userDict;

@property (readwrite) NSDictionary *mapRainData;
@property (readwrite) NSDictionary *mapCloudData;

@end
