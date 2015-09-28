//
//  CWDataManager.h
//  NextRain
//
//  Created by 卢大维 on 14-10-23.
//  Copyright (c) 2014年 weather. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ENUM(NSInteger, CWDataType){
    CWDataTypeProductList,
    CWDataTypeMapdata,
};

@interface CWDataManager : NSObject

@property (readwrite) BOOL enablePushNotification;
@property (readwrite) NSString *imageVersion;

+ (CWDataManager *)sharedInstance;

@property (nonatomic,assign) CGPoint productOffset;
@property (nonatomic,assign) BOOL loadingAnimationFinished;

@property (readwrite) NSDictionary *mapRainData;
@property (readwrite) NSDictionary *mapCloudData;

-(void)setProductList:(NSArray *)datas;
-(NSArray *)productList;

-(void)setMapdata:(NSDictionary *)mapdata fileMark:(NSString *)fileMark;
-(NSDictionary *)mapdataByFileMark:(NSString *)fileMark;


-(NSDictionary *)indexDict;
-(NSDictionary *)mapDataTypes;
@end
