//
//  HEMapAnimLogic.m
//  HelloEarth
//
//  Created by 卢大维 on 15/8/14.
//  Copyright (c) 2015年 weather. All rights reserved.
//

#import "HEMapAnimLogic.h"
#import "CWDataManager.h"
#import "Masonry.h"
#import "Util.h"
#import "PLHttpManager.h"
#import "UIImage+Tint.h"

#define MK_CHINA_CENTER_REGION MKCoordinateRegionMake(CLLocationCoordinate2DMake(33.2, 105.0), MKCoordinateSpanMake(42, 64))

@interface HEMapAnimLogic ()
{
    NSArray *locPoints;
    BOOL isClear;
}

@property (nonatomic,strong) MaplyBaseViewController *theViewC;

// 雷达动画
@property (nonatomic,assign) NSInteger type;

@property (nonatomic,strong) MapImagesManager *mapImagesManager;
@property (nonatomic,copy) NSDictionary *allImages;
@property (nonatomic,copy) NSArray *allUrls;
@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic) NSInteger currentPlayIndex;

@end

@implementation HEMapAnimLogic

-(void)dealloc
{
    [self clear];
}

-(instancetype)initWithController:(UIViewController *)theViewC
{
    if (self = [super init]) {
        self.theViewC = (MaplyBaseViewController *)theViewC;
    }
    
    return self;
}

-(void)showImagesAnimation:(enum MapImageType)type
{
    self.type = type==MapImageTypeRain?0:1;
    
    [self.delegate setPlayButtonSelect:NO];
    
    if (!self.mapImagesManager) {
        self.mapImagesManager = [[MapImagesManager alloc] init];
    }
    self.currentPlayIndex = 0;
    
    [self requestImage:type];
}

-(void)requestImage:(enum MapImageType)type
{
    INIT_WEAK_SELF;
    [self.mapImagesManager requestImageList:type completed:^(enum MapImageDownloadType downloadType) {
        
        NSArray *imageUrls = nil;
        
        if (type == MapImageTypeRain) {
            imageUrls = [[CWDataManager sharedInstance].mapRainData objectForKey:@"list"];
        }
        else if (type == MapImageTypeCloud)
        {
            imageUrls = [[CWDataManager sharedInstance].mapCloudData objectForKey:@"list"];
        }
        weakSlef.allUrls = imageUrls;
        NSString *url = [weakSlef.allUrls.firstObject objectForKey:@"l2"];
        
        [weakSlef.mapImagesManager downloadImageWithUrl:url type:type completed:^(UIImage *image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (image) {
                    MaplySticker *sticker = [[MaplySticker alloc] init];
                    MaplyCoordinateSystem *coordSys = [[MaplySphericalMercator alloc] initWebStandard];
                    sticker.coordSys = coordSys;
                    
                    if (type == MapImageTypeRain) {
                        locPoints = [weakSlef.allUrls.firstObject objectForKey:@"l3"];
                    }
                    else if(type == MapImageTypeCloud)
                    {
                        locPoints = @[@"-4.98", @"50.02", @"59.97", @"144.97"];
                    }
                    
                    NSString *p1 = [NSString stringWithFormat:@"%@", locPoints.firstObject];
                    NSString *p2 = [NSString stringWithFormat:@"%@", locPoints[1]];
                    NSString *p3 = [NSString stringWithFormat:@"%@", locPoints[2]];
                    NSString *p4 = [NSString stringWithFormat:@"%@", locPoints.lastObject];
                    
                    // Stickers are sized in geographic (because they're for KML ground overlays).  Bleah.
                    
                    sticker.ll = [coordSys geoToLocal:MaplyCoordinateMakeWithDegrees([p2 doubleValue], [p1 doubleValue])];
                    sticker.ur = [coordSys geoToLocal:MaplyCoordinateMakeWithDegrees([p4 doubleValue], [p3 doubleValue])];
                    
                    // And a random rotation
                    //        sticker.rotation = 2*M_PI * drand48();
                    sticker.image = image;
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSlef.theViewC removeObject:weakSlef.stickersObj];
                        weakSlef.stickersObj = [weakSlef.theViewC addStickers:@[sticker] desc:@{kMaplyFade: @(1.0),
                                                                                        kMaplyDrawPriority: @(kMaplyModelDrawPriorityDefault+100),}];
                        
                        [weakSlef changeImageAnim:image];
                    });
                }
            });
        }];
    }];
}

-(void)requestImageList:(enum MapImageType)type
{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
//        self.playButton.selected = NO;
        [self.delegate setPlayButtonSelect:NO];
    }
    
    isClear = NO;
    
    self.mapImagesManager.hudView = self.theViewC.view;
    INIT_WEAK_SELF;
    [self.mapImagesManager requestImageList:type completed:^(enum MapImageDownloadType downloadType) {
        if (downloadType == MapImageDownloadTypeFail) {
            LOG(@"加载失败");
        }
        else
        {
            [weakSlef.mapImagesManager downloadAllImageWithType:type completed:^(NSDictionary *images) {
                
                if (images) {
                    // 开始动画
                    weakSlef.allImages = images;
                    NSArray *imageUrls = nil;
                    if (type == MapImageTypeRain) {
                        imageUrls = [[CWDataManager sharedInstance].mapRainData objectForKey:@"list"];
                    }
                    else if (type == MapImageTypeCloud)
                    {
                        imageUrls = [[CWDataManager sharedInstance].mapCloudData objectForKey:@"list"];
                    }
                    weakSlef.allUrls = imageUrls;
                    [weakSlef startAnimationWithIndex:weakSlef.currentPlayIndex];
                }
                
            } loadType:downloadType];
        }
    }];
}

-(void)startAnimationWithIndex:(NSInteger)index
{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    
    INIT_WEAK_SELF;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weakSlef.timer = [NSTimer scheduledTimerWithTimeInterval:0.2f target:weakSlef selector:@selector(timeDidFired) userInfo:nil repeats:YES];
        weakSlef.currentPlayIndex = index;
        if (index >= weakSlef.allImages.count-1) {
            weakSlef.currentPlayIndex = 0;
        }
//        self.playButton.selected = YES;
        [weakSlef.delegate setPlayButtonSelect:YES];
        
        [weakSlef timeDidFired];
    });
}

-(void)timeDidFired
{
    @autoreleasepool {
        NSString *imageUrl = [self.allImages objectForKey:@(self.allImages.count-self.currentPlayIndex-1)];
        UIImage *curImage = [self.mapImagesManager imageFromDiskForUrl:imageUrl];
        if (curImage) {
            [self changeImageAnim:curImage];
        }
        else
        {
            LOG(@"Image file 不存在~~%@", imageUrl);
        }
        
        self.currentPlayIndex++;
        
        if (self.currentPlayIndex > self.allImages.count-1) {
            [self.timer invalidate];
            [self performSelector:@selector(repeatAnimation) withObject:nil afterDelay:3.0];
        }
    }
}

-(void)repeatAnimation
{
    if (self.timer && !isClear) {
        [self startAnimationWithIndex:0];
    }
}

-(void)changeImageAnim:(UIImage *)image
{
    @autoreleasepool{
        
        MaplySticker *sticker = [[MaplySticker alloc] init];
        // Stickers are sized in geographic (because they're for KML ground overlays).  Bleah.
        
//        locPoints = [[self.allUrls objectAtIndex:self.allUrls.count-self.currentPlayIndex-1] objectForKey:@"l3"];
        NSString *p1 = [NSString stringWithFormat:@"%@", locPoints.firstObject];
        NSString *p2 = [NSString stringWithFormat:@"%@", locPoints[1]];
        NSString *p3 = [NSString stringWithFormat:@"%@", locPoints[2]];
        NSString *p4 = [NSString stringWithFormat:@"%@", locPoints.lastObject];
        
        // Stickers are sized in geographic (because they're for KML ground overlays).  Bleah.
        MaplyCoordinateSystem *coordSys = [[MaplySphericalMercator alloc] initWebStandard];
        sticker.coordSys = coordSys;
        sticker.ll = [coordSys geoToLocal:MaplyCoordinateMakeWithDegrees([p2 doubleValue], [p1 doubleValue])];
        sticker.ur = [coordSys geoToLocal:MaplyCoordinateMakeWithDegrees([p4 doubleValue], [p3 doubleValue])];
        
//        if (self.type == 0) {
//            sticker.image = [image imageWithTintColor:[UIColor yellowColor]];
//        }
//        else
        {
            sticker.image = image;
        }
        // And a random rotation
        //        sticker.rotation = 2*M_PI * drand48();
        [self.theViewC removeObject:self.stickersObj];
        self.stickersObj = [self.theViewC addStickers:@[sticker] desc:@{kMaplyDrawPriority: @(kMaplyModelDrawPriorityDefault+100)}];
        
        NSString *timeTxt = [[self.allUrls objectAtIndex:self.allUrls.count-self.currentPlayIndex-1] objectForKey:@"l1"];
        [self setTimeLabelText:timeTxt];
        
        //    LOG(@"%d, %ld", self.currentPlayIndex, self.allImages.count);
        //        self.progressView.progress = 1.0*(self.currentPlayIndex+1)/self.allImages.count;
        CGFloat radio = 100.0*(self.currentPlayIndex)/(self.allImages.count-1);
//        [self.progressView setValue:radio animated:YES];
        [self.delegate setProgressValue:radio];
    }
}


-(void)setTimeLabelText:(NSString *)text
{
    if ([Util isEmpty:text]) {
        return;
    }
    
    NSDateFormatter *dateFormatter = [CWDataManager sharedInstance].dateFormatter;
    if (self.type == 0)
    {
        NSDate* expirationDate = [NSDate dateWithTimeIntervalSince1970:[text longLongValue]];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
//        self.timeLabel.text = [dateFormatter stringFromDate:expirationDate];
        [self.delegate setTimeText:[dateFormatter stringFromDate:expirationDate]];
    }
    else
    {
        [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
        NSDate* expirationDate = [dateFormatter dateFromString: text];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
//        self.timeLabel.text = [dateFormatter stringFromDate:expirationDate];
        [self.delegate setTimeText:[dateFormatter stringFromDate:expirationDate]];
    }
}

-(void)changeProgress:(UISlider *)progressView
{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
//        self.playButton.selected = NO;
        [self.delegate setPlayButtonSelect:NO];
    }
    
    self.currentPlayIndex = round(progressView.value*(self.allImages.count-1)/progressView.maximumValue);
    NSString *imageUrl = [self.allImages objectForKey:@(self.allImages.count-self.currentPlayIndex-1)];
    if (imageUrl) {
        UIImage *curImage = [self.mapImagesManager imageFromDiskForUrl:imageUrl];
        if (curImage) {
            [self changeImageAnim:curImage];
        }
        else
        {
            LOG(@"Image file 不存在~~%@", imageUrl);
        }
    }
}

-(void)clickPlay
{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
//        self.playButton.selected = NO;
        [self.delegate setPlayButtonSelect:NO];
    }
    else
    {
        if (self.type == 0) {
            [self requestImageList:MapImageTypeRain];
        }
        else
        {
            [self requestImageList:MapImageTypeCloud];
        }
    }
}

-(void)clear
{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
//        self.playButton.selected = NO;
        
        [self.delegate setPlayButtonSelect:NO];
    }
    
    [self.delegate setProgressValue:0];
    [self setTimeLabelText:[[self.allUrls firstObject] objectForKey:@"l1"]];
    self.mapImagesManager = nil;
    isClear = YES;
    [self.theViewC removeObject:self.stickersObj];
}
@end
