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
[NSString stringWithFormat:@"%td", t]

#define IDENTIFY_WITH_ID_AND_TYPE(i, t) \
[NSString stringWithFormat:@"%td-%@", i, t]

static NSString *key_map_rainImageList = @"map_rainImageList";
static NSString *key_map_cloudImageList = @"map_cloudImageList";

@interface CWDataManager ()

@property (readwrite) NSMutableDictionary *normalProducts;
@property (nonatomic, strong) NSString *basePath;
@property (nonatomic, strong) NSCache *tongjiImageCache;
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
        self.dateFormatter = [[NSDateFormatter alloc] init];
        self.tongjiImageCache = [NSCache new];
        self.productReqtimes = [NSMutableDictionary dictionary];
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

-(NSString *)imageVersion
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"imageVersion"];
}

-(void)setImageVersion:(NSString *)imageVersion
{
    [[NSUserDefaults standardUserDefaults] setValue:imageVersion forKey:@"imageVersion"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSString *)appVerison
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"appVersion"];
}

-(void)setAppVerison:(NSString *)appVerison
{
    [[NSUserDefaults standardUserDefaults] setValue:appVerison forKey:@"appVersion"];
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

-(void)setProductList:(NSArray *)datas
{
    [self setArray:datas forIdentify:IDENTIFY_WITH_TYPE(CWDataTypeProductList)];
}
-(NSArray *)productList
{
    return [self arrayForIdentify:IDENTIFY_WITH_TYPE(CWDataTypeProductList)];
}

-(void)setMapdata:(NSDictionary *)mapdata fileMark:(NSString *)fileMark;
{
    [self setDictionary:mapdata forIdentify:IDENTIFY_WITH_ID_AND_TYPE(CWDataTypeMapdata, fileMark)];
}
-(NSDictionary *)mapdataByFileMark:(NSString *)fileMark
{
    return [self dictionaryForIdentify:IDENTIFY_WITH_ID_AND_TYPE(CWDataTypeMapdata, fileMark)];
}


-(void)saveTongjiImage:(UIImage *)image forName:(NSString *)name
{
    NSString *_path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    _path = [_path stringByAppendingPathComponent:@"tongji_images"];
    
    [self ensurePathExists:_path];
    
    NSString *filename = [_path stringByAppendingPathComponent:[Base64 base64EncodeString:name]];
    [UIImagePNGRepresentation(image) writeToFile:filename atomically:YES];
}

-(UIImage *)tongjiImageForName:(NSString *)name
{
    UIImage *image = [self.tongjiImageCache objectForKey:name];
    if (image) {
        return image;
    }
    
    NSString *_path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    _path = [_path stringByAppendingPathComponent:@"tongji_images"];
    
    NSString *filename = [_path stringByAppendingPathComponent:[Base64 base64EncodeString:name]];
    
    image = [UIImage imageWithContentsOfFile:filename];
    if (image) {
        [self.tongjiImageCache setObject:image forKey:name];
    }
    
    return image;
}

/* ******************************** some file datas ********************************* */
-(NSDictionary *)indexDict
{
    return @{@"fog_fc":@[@[@[@"一级", @"轻雾", @"能见度1-10公里"],
                         @[@"二级", @"大雾",	@"能见度0.5-1公里"],
                         @[@"三级", @"浓雾", @"能见度0.2-0.5公里"],
                         @[@"四级", @"强浓雾", @"能见度0.05-0.2公里"]],
                         ],
             
             @"haze_fc":@[@[@[@"一级", @"轻度霾", @"能见度大于5公里"],
                          @[@"二级", @"中度霾", @"能见度2-5公里"],
                          @[@"三级",	@"重度霾", @"能见度0.2-0.5公里"],
                          @[@"四级", @"严重霾", @"能见度0.05-0.2公里"]],
                          ],
             
             @"spc_fc":@[@[@[@"雷暴", @"伴有雷击和闪电的局地对流性天气"],
                         @[@"短时强降雨", @"3小时内某地降雨量超过30毫米，短时强降雨是一种强对流天气"],
                         @[@"雷暴大风或冰雹"]],
                         ],
             
             @"js_24_fc,js_48_fc,js_72_fc":
                 @[@[@[@"小雨", @"0-10毫米"],
                   @[@"中雨", @"10-25毫米"],
                   @[@"大雨", @"25-50毫米"],
                   @[@"暴雨", @"50-100毫米"],
                   @[@"大暴雨", @"100-250毫米"],
                   @[@"特大暴雨", @"＞250毫米"]
                     ],
                   
                   @[@[@"小雨", @"0-10毫米"],
                     @[@"中雨", @"10-25毫米"],
                     @[@"大雨", @"25-50毫米"],
                     @[@"暴雨", @"50-100毫米"],
                     @[@"大暴雨", @"100-250毫米"],
                     @[@"特大暴雨", @"＞250毫米"]
                     ],
                   
                   @[@[@"小雪", @"0-2.5毫米"],
                     @[@"中雪", @"2.5-5毫米"],
                     @[@"大雪", @"5-10毫米"],
                     @[@"暴雪", @"10-25毫米"],
                     @[@"大暴雪", @"＞25毫米"]
                     ]
                   ],
             
             @"kqzl_24,kqzl_48,kqzl_72":
                 @[@[@[@"一级", @"好", @"非常有利于空气污染物稀释、扩散和清除"],
                   @[@"二级", @"较好", @"较有利于空气污染物稀释、扩散和清除"],
                   @[@"三级", @"一般", @"对空气污染物稀释、扩散和清除无明显影响"],
                   @[@"四级", @"较差", @"不利于空气污染物稀释、扩散和清除"],
                   @[@"五级", @"差", @"很不利于空气污染物稀释、扩散和清除"],
                   @[@"六级", @"极差", @"极不利于空气污染物稀释、扩散和清除"],],
                   ],
             @"GWYB_24":
                 @[
                     ],
             @"SCYB_24":
                 @[],
             @"DFJWYB_24":
                 @[],
             
             FILEMARK_RADAR:@[@[@"组合反射率是气象雷达接收周围一定范围内不同高度云层反射雷达波的比率。从而判断云层厚度和高度，预报大雨和暴风等强对流天气的数据产品。\n单位：dbz"]],
             };
}

-(NSDictionary *)mapDataTypes
{
    return @{@"卫星地图":@"divdiv.nicggmmh",
             @"默认地图":@"divdiv.nicgc1ap"};
}

-(NSDictionary *)mapOfflineImageInfo
{
    return @{@"卫星地图":@{@"type":@"satellite", @"ext":@"jpg"},
             @"默认地图":@{@"type":@"default", @"ext":@"png"}
             };
}

/* ******************************** some file datas ********************************* */

@end
