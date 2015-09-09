//
//  CWDataManager.m
//  NextRain
//
//  Created by 卢大维 on 14-10-23.
//  Copyright (c) 2014年 weather. All rights reserved.
//

#import "CWDataManager.h"
#import "Base64.h"
#import "DeviceUtil.h"

static NSString *key_normalProducts = @"normalProducts";

#define IDENTIFY_WITH_TYPE(t) \
[NSString stringWithFormat:@"%d", t]

static NSString *key_map_rainImageList = @"map_rainImageList";
static NSString *key_map_cloudImageList = @"map_cloudImageList";

@interface CWDataManager ()

@property (readwrite) NSMutableDictionary *normalProducts;
@property (nonatomic, strong) NSString *basePath;
//@property (nonatomic, strong) NSArray *cacheIndexs;  // 缓存几个city的数据

@end

@implementation CWDataManager

+ (CWDataManager *)sharedInstance {
    static CWDataManager *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

-(instancetype)init
{
    if (self = [super init]) {
        self.normalProducts = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:key_normalProducts]];
    }
    return self;
}
#pragma mark - private

- (void)ensurePathExists:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:path])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:path
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
}

- (NSString *)pathForIdentify:(NSString *)identify
{
    if(!identify && identify.length)
        return nil;
    
    NSString *path;
    
    if(!self.basePath)
    {
        NSString *_path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        _path = [_path stringByAppendingPathComponent:@"data"];
        self.basePath = _path;
        
        [self ensurePathExists:self.basePath];
    }
    path = self.basePath;
    
//    if (self.notInUserDir) {
//        // 加入userid
//        path = [path stringByAppendingPathComponent:[TJUserManager sharedInstance].userName];
//        [self ensurePathExists:path];
//    }
//    self.notInUserDir = NO;     // 是否在分用户，用完后要重置为NO
    
    // 文件分类的目录，可能没有创建
    [self ensurePathExists:[[path stringByAppendingPathComponent:identify] stringByDeletingLastPathComponent]];
    return [path stringByAppendingPathComponent:identify];
}

// NOTE: data is kind of NSData
- (void)setData:(id)data forIdentify:(NSString *)identify
{
    if(!data || !identify || identify.length == 0 ||
       ![data isKindOfClass:[NSData class]])
        return;
    
    NSString *path = [self pathForIdentify:identify];
    if(!path) return;
    
    NSData *d = data;
    [d writeToFile:path atomically:YES];
}

- (id)dataForIdentify:(NSString *)identify
{
    if(!identify || identify.length == 0)
        return nil;
    NSString *path = [self pathForIdentify:identify];
    if(!path) return nil;
    return [NSData dataWithContentsOfFile:path];
}

// bool to data
- (void)setBool:(BOOL)boolValue forIdentify:(NSString *)identify
{
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeBool:boolValue forKey:identify];
    [archiver finishEncoding];
    [self setData:data forIdentify:identify];
}

- (BOOL)boolForIdentify:(NSString *)identify defaultValue:(BOOL)defaultValue
{
    NSData *data = [self dataForIdentify:identify];
    if(!data)
    {
        [self setBool:defaultValue forIdentify:identify];
        return defaultValue;
    }
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    BOOL boolValue = [unarchiver decodeBoolForKey:identify];
    [unarchiver finishDecoding];
    return boolValue;
}

- (BOOL)boolForIdentify:(NSString *)identify
{
    return [self boolForIdentify:identify defaultValue:NO];
}

// dictionary to data
- (void)setDictionary:(id)dict forIdentify:(NSString *)identify
{
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:dict forKey:identify];
    [archiver finishEncoding];
    [self setData:data forIdentify:identify];
}

- (id)dictionaryForIdentify:(NSString *)identify
{
    NSData *data = [self dataForIdentify:identify];
    if(!data) return nil;
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSDictionary *dict = [unarchiver decodeObjectForKey:identify];
    [unarchiver finishDecoding];
    return dict;
}

// array to data
- (void)setArray:(id)array forIdentify:(NSString *)identify
{
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:array forKey:identify];
    [archiver finishEncoding];
    [self setData:data forIdentify:identify];
}

- (id)arrayForIdentify:(NSString *)identify
{
    NSData *data = [self dataForIdentify:identify];
    if(!data) return nil;
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSArray *array = [unarchiver decodeObjectForKey:identify];
    [unarchiver finishDecoding];
    return array;
}

#pragma mark - public
-(void)setNormalProduct:(NSMutableDictionary *)normalProduct forKey:(NSString *)pid
{
    [self.normalProducts setObject:normalProduct forKey:pid];
    
    [[NSUserDefaults standardUserDefaults] setObject:self.normalProducts forKey:key_normalProducts];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSDictionary *)normalProductForKey:(NSString *)pid
{
    return [self.normalProducts objectForKey:pid];
}

-(BOOL)enablePushNotification
{
    id boolValue = [[NSUserDefaults standardUserDefaults] objectForKey:@"enablePushNotification"];
    if (boolValue == nil) {
        [self setEnablePushNotification:YES];
    }
    
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"enablePushNotification"];
}

-(void)setEnablePushNotification:(BOOL)enablePushNotification
{
    [[NSUserDefaults standardUserDefaults] setBool:enablePushNotification forKey:@"enablePushNotification"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// map data
-(void)setMapRainData:(NSDictionary *)mapRainData
{
    [self setDictionary:mapRainData forIdentify:[Base64 base64EncodeString:key_map_rainImageList]];
}

-(NSDictionary *)mapRainData
{
    return [self dictionaryForIdentify:[Base64 base64EncodeString:key_map_rainImageList]];
}

-(void)setMapCloudData:(NSDictionary *)mapCloudData
{
    [self setDictionary:mapCloudData forIdentify:[Base64 base64EncodeString:key_map_cloudImageList]];
}

-(NSDictionary *)mapCloudData
{
    return [self dictionaryForIdentify:[Base64 base64EncodeString:key_map_cloudImageList]];
}
@end
