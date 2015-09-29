//
//  MapImagesManager.m
//  NextRain
//
//  Created by 卢大维 on 14-10-28.
//  Copyright (c) 2014年 weather. All rights reserved.
//

#import "MapImagesManager.h"
#import "AFNetworking.h"
#import "CWDataManager.h"
#import "CWEncode.h"
#import "MBProgressHUD+Extra.h"
#import <CommonCrypto/CommonDigest.h>
#import "AlertViewBlocks.h"

#import "PLHttpManager.h"
#import "SDImageCache.h"
#import "SDWebImageDownloader.h"

@interface MapImagesManager ()

@property (nonatomic,strong) AFHTTPRequestOperationManager *client;
@property (nonatomic,strong) MBProgressHUD *hud;
@property (nonatomic,strong) NSMutableArray *operations;
@property (nonatomic) int netWithoutWifiStatus;

@end

@implementation MapImagesManager

//+ (MapImagesManager *)sharedInstance {
//    static MapImagesManager *_sharedInstance = nil;
//    static dispatch_once_t oncePredicate;
//    dispatch_once(&oncePredicate, ^{
//        _sharedInstance = [[self alloc] init];
//    });
//
//    return _sharedInstance;
//}

-(instancetype)init
{
    if (self = [super init]) {
        self.client = [[PLHttpManager sharedInstance] manager];
        self.isQuanGuo = YES;
        
        self.netWithoutWifiStatus = 0;
    }
    return self;
}

-(void)dealloc
{
    if (self.operations) {
        [self.operations enumerateObjectsUsingBlock:^(id<SDWebImageOperation> operation, NSUInteger idx, BOOL *stop) {
            [operation cancel];
        }];
        self.operations = nil;
    }
    
    [self.hud removeFromSuperview];
    self.hud = nil;
    self.hudView = nil;
}

-(void)requestImageList:(enum MapImageType)type completed:(void (^)(enum MapImageDownloadType downloadType))block
{
    NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
    
    NSString *lastTime = @"";
    NSString *path = @"";
    if (type == MapImageTypeRain) {
        // 降雨  http://scapi.weather.com.cn/product/list/radar_mector_r_20.html
        path = @"http://api.tianqi.cn:8070/v1/img.py";
        lastTime = [[CWDataManager sharedInstance].mapRainData objectForKey:@"time"];
    }
    else if (type == MapImageTypeCloud)
    {
        // 云图
        path = @"http://scapi.weather.com.cn/product/list/cloudnew_20.html";
        lastTime = [[CWDataManager sharedInstance].mapCloudData objectForKey:@"time"];
    }
    if (!lastTime || nowTime - [lastTime doubleValue] >= 10*60) {
        // 获取降雨图
        [self.client GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            id json = responseObject;//[NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
            if (json && [json isKindOfClass:[NSDictionary class]]) {
                
                if (type == MapImageTypeRain) {
                    NSArray *urls = [json objectForKey:@"radar_img"];
                    
                    NSMutableArray *formatUrls = [NSMutableArray arrayWithCapacity:urls.count];
                    for (NSInteger i=urls.count-1; i>=0; i--) {
                        
                        NSArray *imgInfo = [urls objectAtIndex:i];
                        NSString *imgUrl = [imgInfo firstObject];
                        NSString *imgTime = [imgInfo objectAtIndex:1];
                        NSString *imgLocation = [imgInfo lastObject];
                        [formatUrls addObject:@{@"l1":imgTime,
                                                @"l2":imgUrl,
                                                @"l3":imgLocation}];
                        
                    }
                    
                    urls = formatUrls;
                    
                    // 降雨
                    [[CWDataManager sharedInstance] setMapRainData:@{@"time":[NSString stringWithFormat:@"%f", nowTime], @"list": urls}];
                }
                else if (type == MapImageTypeCloud)
                {
                    NSArray *urls = [json objectForKey:@"l"];
                    // 云图
                    [[CWDataManager sharedInstance] setMapCloudData:@{@"time":[NSString stringWithFormat:@"%f", nowTime], @"list": urls}];
                }
                block(MapImageDownloadTypeNew);
            }
            else
            {
                block(MapImageDownloadTypeFail);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            block(MapImageDownloadTypeFail);
        }];
    }
    else
    {
        block(MapImageDownloadTypeOld);
    }
}

-(void)downloadAllImageWithType:(enum MapImageType)type completed:(void (^)(NSDictionary *images))block loadType:(enum MapImageDownloadType)loadType
{
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable:
                NSLog(@"No Internet Connection");
                [MBProgressHUD showHUDNoteWithText:@"网络不通，请稍后再试"];
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                NSLog(@"WIFI");
                [self startDownloadAllImageWithType:type completed:block loadType:loadType];
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                NSLog(@"3G");
                [self startDownloadAllImageWithType:type completed:block loadType:loadType];
                break;
            default:
                NSLog(@"Unkown network status");
                break;
                
        }
    }];
    
    [manager startMonitoring];
}

-(void)startDownloadAllImageWithType:(enum MapImageType)type completed:(void (^)(NSDictionary *images))block loadType:(enum MapImageDownloadType)loadType
{
    if (self.operations) {
        [self.operations enumerateObjectsUsingBlock:^(id<SDWebImageOperation> operation, NSUInteger idx, BOOL *stop) {
            [operation cancel];
        }];
    }
    
    NSMutableDictionary *allImages = [NSMutableDictionary dictionary];
    
    NSArray *imageUrls = nil;
    if (type == MapImageTypeRain) {
        imageUrls = [[CWDataManager sharedInstance].mapRainData objectForKey:@"list"];
    }
    else if (type == MapImageTypeCloud)
    {
        imageUrls = [[CWDataManager sharedInstance].mapCloudData objectForKey:@"list"];
    }
    
    if (loadType == MapImageDownloadTypeNew)
    {
        // 清除以前的图片
        [self clearImagesFromDisk];
    }
    
    if (self.hud) {
        [self.hud hide:YES];
        [self.hud removeFromSuperview];
        self.hud = nil;
    }
    self.hud = [MBProgressHUD showHUDInView:self.hudView andText:nil];
    
    __block int failCount = 0;
    
    self.operations = [NSMutableArray arrayWithCapacity:20];
    for (int i=(int)imageUrls.count-1; i>=0; i--) {
        NSString *url = [[imageUrls objectAtIndex:i] objectForKey:@"l2"];
        NSString *imageUrl = @"";
        if (loadType == MapImageDownloadTypeOld) {
            NSTimeInterval timeint = [[[CWDataManager sharedInstance].mapRainData objectForKey:@"time"] doubleValue];
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeint];
            imageUrl = [self getFinalUrl:url date:date isCloud:type==MapImageTypeCloud];
        }
        else
        {
            imageUrl = [self getFinalUrl:url date:[NSDate date] isCloud:type==MapImageTypeCloud];
        }
        
        INIT_WEAK_SELF;
        [self downloadImage:imageUrl completed:^(UIImage *image) {
            if (image) {
                [allImages setObject:imageUrl forKey:@(i)];
            }
            else
            {
                failCount++;
            }
            
            CGFloat radio = 1.0*(failCount+allImages.count)/imageUrls.count;
            weakSlef.hud.mode = MBProgressHUDModeDeterminate;
            weakSlef.hud.progress = radio;
            weakSlef.hud.labelText = [NSString stringWithFormat:@"%.f%%", 100.0*radio];
            if (failCount+allImages.count == imageUrls.count) {
                // 下载完成
                if (weakSlef.hud)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSlef.hud hide:YES];
                        [weakSlef.hud removeFromSuperview];
                        weakSlef.hud = nil;
                    });
                }
                
                block(allImages);
            }
        }];
    }
}

-(void)downloadImageWithUrl:(NSString *)url type:(enum MapImageType)type completed:(void (^)(UIImage *image))block
{
    NSString *imageUrl = [self getFinalUrl:url date:[NSDate date] isCloud:type==MapImageTypeCloud];
    
    [self downloadImage:imageUrl completed:^(UIImage *image) {
        block(image);
    }];
}

-(void)downloadImage:(NSString *)imageUrl completed:(void (^)(UIImage *image))block
{
    if (!imageUrl) {
        LOG(@"imageUrl is nil");
    }
    
    UIImage *image = [self imageFromDiskForUrl:imageUrl];
    if (image) {
        block(image);
    }
    else
    {
        INIT_WEAK_SELF;
        __block id<SDWebImageOperation> operation = [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:imageUrl] options:SDWebImageDownloaderUseNSURLCache progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
            block(image);
            if (image) {
                [weakSlef storeImage:image withUrl:imageUrl];
            }
            
            [weakSlef.operations removeObject:operation];
            operation = nil;
        }];
        if (operation) {
            [self.operations addObject:operation];
        }
    }
}

-(NSString *)getFinalUrl:(NSString *)imgUrl date:(NSDate *)date isCloud:(BOOL)isCloud
{
    if (!imgUrl) {
        return @"";
    }
    NSString *url = [imgUrl stringByAppendingString:@"?"];
    
    NSDateFormatter *formatter = [CWDataManager sharedInstance].dateFormatter;
    [formatter setDateFormat:@"yyyyMMddHHmm"];
    NSString *curTime = [formatter stringFromDate:date];
    
    if (isCloud) {
        url = [url stringByAppendingString:[NSString stringWithFormat:@"date=%@", curTime]];
    }
    //    else
    //    {
    //        url = [url stringByAppendingString:[NSString stringWithFormat:@"loncenter=%f", region.center.longitude]];
    //        url = [url stringByAppendingString:[NSString stringWithFormat:@"&latcenter=%f", region.center.latitude]];
    //        url = [url stringByAppendingString:[NSString stringWithFormat:@"&lonspan=%f", region.span.longitudeDelta]];
    //        url = [url stringByAppendingString:[NSString stringWithFormat:@"&latspan=%f", region.span.latitudeDelta]];
    //        url = [url stringByAppendingString:[NSString stringWithFormat:@"&width=%f", self.isQuanGuo?2000.0:500.0]];
    //        url = [url stringByAppendingString:[NSString stringWithFormat:@"&proj=%@", @"webmector"]];
    //        url = [url stringByAppendingString:[NSString stringWithFormat:@"&date=%@", curTime]];
    //    }
    
    NSString *myUrl = [url stringByAppendingString:[NSString stringWithFormat:@"&appid=%@", [weather_appId substringToIndex:6]]];
    url = [url stringByAppendingString:[NSString stringWithFormat:@"&appid=%@", weather_appId]];
    
    NSString *key = [CWEncode encodeByPublicKey:url privateKey:weather_priKey];
    //    key = AFPercentEscapedQueryStringPairMemberFromStringWithEncoding(key, NSASCIIStringEncoding);
    
    myUrl = [myUrl stringByAppendingString:[NSString stringWithFormat:@"&key=%@", key]];
    
    formatter = nil;
    return myUrl;
}


// file
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

-(NSString *)imagePathForUrl:(NSString *)url
{
    NSString *_path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    if (self.isQuanGuo) {
        _path = [_path stringByAppendingPathComponent:@"mapImagesQuanGuo"];
    }
    else
    {
        _path = [_path stringByAppendingPathComponent:@"mapImages"];
    }
    
    [self ensurePathExists:_path];
    
    NSString *filename = [self cachedFileNameForKey:url];
    return [_path stringByAppendingPathComponent:filename];
}

- (NSString *)cachedFileNameForKey:(NSString *)key {
    const char *str = [key UTF8String];
    if (str == NULL) {
        str = "";
    }
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
    
    return filename;
}

-(void)storeImage:(UIImage *)image withUrl:(NSString *)url
{
    NSString *imagePath = [self imagePathForUrl:url];
    
    NSData *imageData = UIImagePNGRepresentation(image);
    [imageData writeToFile:imagePath atomically:YES];
}

-(UIImage *)imageFromDiskForUrl:(NSString *)url
{
    NSString *imagePath = [self imagePathForUrl:url];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:imagePath]) {
        
        NSData *data = [NSData dataWithContentsOfFile:imagePath];
        UIImage *image = [UIImage imageWithData:data];
        return image;
    }
    return nil;
}

-(void)clearImagesFromDisk
{
    NSString *_path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    if (self.isQuanGuo) {
        _path = [_path stringByAppendingPathComponent:@"mapImagesQuanGuo"];
    }
    else
    {
        _path = [_path stringByAppendingPathComponent:@"mapImages"];
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:_path])
    {
        [fileManager removeItemAtPath:_path error:nil];
    }
}

+(void)clearAllImagesFromDisk
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        double currTime = [[NSDate date] timeIntervalSince1970];
        double lastTime = [[NSUserDefaults standardUserDefaults] doubleForKey:@"mapImages_lastClearTime"];
        if (!lastTime) {
            [[NSUserDefaults standardUserDefaults] setDouble:[[NSDate date] timeIntervalSince1970] forKey:@"mapImages_lastClearTime"];
        }
        else if (currTime - lastTime > 24*3600)
        {
            NSString *dictPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
            NSString *quanGuoPath = [dictPath stringByAppendingPathComponent:@"mapImagesQuanGuo"];
            NSString *path = [dictPath stringByAppendingPathComponent:@"mapImages"];
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if([fileManager fileExistsAtPath:quanGuoPath])
            {
                [fileManager removeItemAtPath:quanGuoPath error:nil];
            }
            
            if([fileManager fileExistsAtPath:path])
            {
                [fileManager removeItemAtPath:path error:nil];
            }
            
            [[NSUserDefaults standardUserDefaults] setDouble:[[NSDate date] timeIntervalSince1970] forKey:@"mapImages_lastClearTime"];
        }
    });
}
@end
