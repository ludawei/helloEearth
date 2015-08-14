//
//  HEMapAnimLogic.m
//  HelloEarth
//
//  Created by 卢大维 on 15/8/14.
//  Copyright (c) 2015年 weather. All rights reserved.
//

#import "HEMapAnimLogic.h"
#import "MapImagesManager.h"
#import "CWDataManager.h"
#import "Masonry.h"
#import "Util.h"
#import "PLHttpManager.h"

#define MK_CHINA_CENTER_REGION MKCoordinateRegionMake(CLLocationCoordinate2DMake(33.2, 105.0), MKCoordinateSpanMake(42, 64))

@interface HEMapAnimLogic ()
{
    NSArray *locPoints;
}

@property (nonatomic,strong) WhirlyGlobeViewController *theViewC;

// 雷达动画
@property (nonatomic,strong) MapImagesManager *mapImagesManager;
@property (nonatomic,copy) NSDictionary *allImages;
@property (nonatomic,copy) NSArray *allUrls;
@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic) NSInteger currentPlayIndex;

@property (nonatomic,strong) UIView *bottomView;

@property (nonatomic,strong) UIButton *playButton;
@property (nonatomic,strong) UISlider *progressView;
@property (nonatomic,strong) UILabel *timeLabel,*dateLbl;

@end

@implementation HEMapAnimLogic

-(instancetype)initWithController:(UIViewController *)theViewC
{
    if (self = [super init]) {
        self.theViewC = (WhirlyGlobeViewController *)theViewC;
    }
    
    return self;
}

-(void)showImagesAnimation:(enum MapImageType)type
{
    if (!self.mapImagesManager) {
        self.mapImagesManager = [[MapImagesManager alloc] init];
    }
    
    if (!self.bottomView) {
        [self initBottomViews];
    }
    
    self.bottomView.hidden = NO;
    [self requestImage:MapImageTypeRain];
}

-(void)requestImage:(enum MapImageType)type
{
    [self.mapImagesManager requestImageList:type completed:^(enum MapImageDownloadType downloadType) {
        
        NSArray *imageUrls = nil;
        
        if (type == MapImageTypeRain) {
            imageUrls = [[CWDataManager sharedInstance].mapRainData objectForKey:@"list"];
        }
        else if (type == MapImageTypeCloud)
        {
            imageUrls = [[CWDataManager sharedInstance].mapCloudData objectForKey:@"list"];
        }
        self.allUrls = imageUrls;
        NSString *url = [self.allUrls.firstObject objectForKey:@"l2"];
        
        __weak typeof(self) weakSlef = self;
        [self.mapImagesManager downloadImageWithUrl:url type:type region:MK_CHINA_CENTER_REGION completed:^(UIImage *image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (image) {
                    //                    [weakSlef.mapView removeOverlays:self.mapView.overlays];
                    //                    [weakSlef removeMapOverlayWithoutTileOverlay];
                    
                    //                    MyOverlay *groundOverlay = [[MyOverlay alloc] initWithRegion:MK_CHINA_CENTER_REGION];
                    MaplySticker *sticker = [[MaplySticker alloc] init];
                    
                    if (type == MapImageTypeRain) {
                        locPoints = [weakSlef.allUrls.firstObject objectForKey:@"l3"];
                        NSString *p1 = [NSString stringWithFormat:@"%@", locPoints.firstObject];
                        NSString *p2 = [NSString stringWithFormat:@"%@", locPoints[1]];
                        NSString *p3 = [NSString stringWithFormat:@"%@", locPoints[2]];
                        NSString *p4 = [NSString stringWithFormat:@"%@", locPoints.lastObject];
                        
                        // Stickers are sized in geographic (because they're for KML ground overlays).  Bleah.
                        MaplyCoordinateSystem *coordSys = [[MaplySphericalMercator alloc] initWebStandard];
                        sticker.coordSys = coordSys;
                        sticker.ll = [coordSys geoToLocal:MaplyCoordinateMakeWithDegrees([p2 doubleValue], [p1 doubleValue])];
                        sticker.ur = [coordSys geoToLocal:MaplyCoordinateMakeWithDegrees([p4 doubleValue], [p3 doubleValue])];
                        
                        sticker.image = image;
                        // And a random rotation
                        //        sticker.rotation = 2*M_PI * drand48();
                        
                    }
                    else if(type == MapImageTypeCloud)
                    {
                        //                        groundOverlay = [[MyOverlay alloc] initWithNorthEast:CLLocationCoordinate2DMake(59.97, 50.02) southWest:CLLocationCoordinate2DMake(-4.98, 144.97)];
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.stickersObj = [self.theViewC addStickers:@[sticker] desc:@{kMaplyFade: @(1.0),
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
        self.playButton.selected = NO;
    }
    
    self.mapImagesManager.hudView = self.theViewC.view;
    [self.mapImagesManager requestImageList:type completed:^(enum MapImageDownloadType downloadType) {
        if (downloadType == MapImageDownloadTypeFail) {
            LOG(@"加载失败");
        }
        else
        {
            __weak typeof(self) weakSlef = self;
            [self.mapImagesManager downloadAllImageWithType:type region:MK_CHINA_CENTER_REGION completed:^(NSDictionary *images) {
                
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
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(timeDidFired) userInfo:nil repeats:YES];
        self.currentPlayIndex = index;
        if (index >= self.allImages.count-1) {
            self.currentPlayIndex = 0;
        }
        self.playButton.selected = YES;
        
        [self timeDidFired];
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
            [self repeatAnimation];
        }
    }
}

-(void)repeatAnimation
{
    //    @autoreleasepool {
    //        NSString *imageUrl = [self.allImages objectForKey:@(self.currentPlayIndex)];
    //         UIImage *curImage = [self.mapImagesManager imageFromDiskForUrl:imageUrl];
    //        [self changeImageAnim:curImage];
    //    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.timer) {
            [self startAnimationWithIndex:0];
        }
    });
}

-(void)changeImageAnim:(UIImage *)image
{
    @autoreleasepool{
        
        MaplySticker *sticker = [[MaplySticker alloc] init];
        // Stickers are sized in geographic (because they're for KML ground overlays).  Bleah.
        
        locPoints = [[self.allUrls objectAtIndex:self.allUrls.count-self.currentPlayIndex-1] objectForKey:@"l3"];
        NSString *p1 = [NSString stringWithFormat:@"%@", locPoints.firstObject];
        NSString *p2 = [NSString stringWithFormat:@"%@", locPoints[1]];
        NSString *p3 = [NSString stringWithFormat:@"%@", locPoints[2]];
        NSString *p4 = [NSString stringWithFormat:@"%@", locPoints.lastObject];
        
        // Stickers are sized in geographic (because they're for KML ground overlays).  Bleah.
        MaplyCoordinateSystem *coordSys = [[MaplySphericalMercator alloc] initWebStandard];
        sticker.coordSys = coordSys;
        sticker.ll = [coordSys geoToLocal:MaplyCoordinateMakeWithDegrees([p2 doubleValue], [p1 doubleValue])];
        sticker.ur = [coordSys geoToLocal:MaplyCoordinateMakeWithDegrees([p4 doubleValue], [p3 doubleValue])];
        
        sticker.image = image;
        // And a random rotation
        //        sticker.rotation = 2*M_PI * drand48();
        [self.theViewC removeObject:self.stickersObj];
        self.stickersObj = [self.theViewC addStickers:@[sticker] desc:@{kMaplyDrawPriority: @(kMaplyModelDrawPriorityDefault+100)}];
        
        NSString *timeTxt = [[self.allUrls objectAtIndex:self.allUrls.count-self.currentPlayIndex-1] objectForKey:@"l1"];
        [self setTimeLabelText:timeTxt];
        [self setDateLabelText:timeTxt];
        
        //    LOG(@"%d, %ld", self.currentPlayIndex, self.allImages.count);
        //        self.progressView.progress = 1.0*(self.currentPlayIndex+1)/self.allImages.count;
        CGFloat radio = 100.0*(self.currentPlayIndex)/self.allImages.count;
        self.progressView.value = radio;
    }
}


-(void)setTimeLabelText:(NSString *)text
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //    if (self.type == 0)
    {
        NSDate* expirationDate = [NSDate dateWithTimeIntervalSince1970:[text integerValue]];
        [dateFormatter setDateFormat:@"HH:mm"];
        self.timeLabel.text = [dateFormatter stringFromDate:expirationDate];
    }
    //    else
    //    {
    //        [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    //        NSDate* expirationDate = [dateFormatter dateFromString: text];
    //        [dateFormatter setDateFormat:@"HH:mm"];
    //        self.timeLabel.text = [dateFormatter stringFromDate:expirationDate];
    //    }
    dateFormatter = nil;
}

-(void)setDateLabelText:(NSString *)text
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //    if (self.type == 0)
    {
        NSDate* expirationDate = [NSDate dateWithTimeIntervalSince1970:[text integerValue]];
        [dateFormatter setDateFormat:@"yyyy年MM月dd日"];
        self.dateLbl.text = [dateFormatter stringFromDate:expirationDate];
    }
    //    else
    //    {
    //        [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    //        NSDate* expirationDate = [dateFormatter dateFromString: text];
    //        [dateFormatter setDateFormat:@"yyyy年MM月dd日"];
    //        self.dateLbl.text = [dateFormatter stringFromDate:expirationDate];
    //    }
    dateFormatter = nil;
}

-(void)initBottomViews
{
    //    UIButton *button = [UIButton new];
    //    [button setImage:[UIImage imageNamed:@"next_page"] forState:UIControlStateNormal];
    //    [button addTarget:self action:@selector(clickNextPage) forControlEvents:UIControlEventTouchUpInside];
    //    [self.backView addSubview:button];
    //    [button mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.top.mas_equalTo(self.backView).offset(10);
    //        make.right.mas_equalTo(self.backView).offset(-10);
    //    }];
    //    [button sizeToFit];
    //
    //    if (self.type == 0) {
    //        UIButton *leftbutton = [UIButton new];
    //        [leftbutton setImage:[UIImage imageNamed:@"last_page"] forState:UIControlStateNormal];
    //        [leftbutton addTarget:self action:@selector(clickLastPage) forControlEvents:UIControlEventTouchUpInside];
    //        [self.backView addSubview:leftbutton];
    //        [leftbutton mas_makeConstraints:^(MASConstraintMaker *make) {
    //            make.top.mas_equalTo(self.backView).offset(10);
    //            make.left.mas_equalTo(self.backView).offset(10);
    //        }];
    //        [leftbutton sizeToFit];
    //    }
    //
    CGFloat height = 75;
    UIView *bottomView = [[UIView alloc] init];
    [self.theViewC.view addSubview:bottomView];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.mas_equalTo(self.theViewC.view);
        //        make.centerX.mas_equalTo(self.view.mas_centerX);
        //        make.width.mas_equalTo(self.view).multipliedBy(0.7);
        make.height.mas_equalTo(height);
    }];
    
    self.bottomView = bottomView;
    //
    //    UIView *backView = [[UIView alloc] init];
    //    backView.backgroundColor = [UIColor colorWithRed:45/255.0 green:40/255.0 blue:16/255.0 alpha:0.3];
    //    [bottomView addSubview:backView];
    //    [backView mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.edges.mas_equalTo(bottomView);
    //    }];
    //
    //    if (self.type == 1) {
    //        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
    //        [backView addGestureRecognizer:tap];
    //    }
    
    UILabel *titleLbl = [self createLabelWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:30]];
    titleLbl.textColor = UIColorFromRGB(0x929292);
    //    if (self.type == 0)
    {
        titleLbl.text = @"全国雷达拼图";
    }
    //    else
    //    {
    //        titleLbl.text = @"区域卫星云图";
    //    }
    
    [bottomView addSubview:titleLbl];
    [titleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(bottomView);
        make.centerX.mas_equalTo(bottomView.mas_centerX);
    }];
    
    UILabel *dateLbl = [self createLabelWithFont:[UIFont fontWithName:@"Helvetica" size:18]];
    dateLbl.textColor = UIColorFromRGB(0xa2a2a0);
    dateLbl.textAlignment = NSTextAlignmentRight;
    [bottomView addSubview:dateLbl];
    [dateLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(bottomView).offset(10);
        make.left.mas_equalTo(titleLbl.mas_right).offset(5);
        make.right.mas_equalTo(-5);
    }];
    
    self.dateLbl = dateLbl;
    
    self.timeLabel = [self createLabelWithFont:[UIFont fontWithName:@"Helvetica" size:18]];
    self.timeLabel.textColor = UIColorFromRGB(0xa2a2a0);
    self.timeLabel.textAlignment = NSTextAlignmentRight;
    [bottomView addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(dateLbl.mas_bottom);
        make.left.mas_equalTo(titleLbl.mas_right).offset(5);
        make.right.mas_equalTo(-5);
    }];
    
    
    UIView *bView = [UIView new];
    bView.backgroundColor = [UIColor colorWithRed:45/255.0 green:40/255.0 blue:16/255.0 alpha:0.1];
    [bottomView addSubview:bView];
    [bView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titleLbl.mas_bottom);
        make.bottom.mas_equalTo(bottomView.mas_bottom);
        make.left.and.right.mas_equalTo(bottomView);
    }];
    
    CGFloat buttonWidth = 40;
    UIButton *nextButton = [[UIButton alloc] init];
    [nextButton setImage:[UIImage imageNamed:@"Future"] forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(clickNext) forControlEvents:UIControlEventTouchUpInside];
    [bView addSubview:nextButton];
    [nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.and.top.and.bottom.mas_equalTo(bView);
        make.width.mas_equalTo(buttonWidth);
    }];
    
    self.playButton = [[UIButton alloc] init];
    [self.playButton setImage:[UIImage imageNamed:@"Broadcast"] forState:UIControlStateNormal];
    [self.playButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateSelected];
    [self.playButton addTarget:self action:@selector(clickPlay) forControlEvents:UIControlEventTouchUpInside];
    [bView addSubview:self.playButton];
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(nextButton.mas_left);
        make.top.and.bottom.mas_equalTo(bView);
        make.width.mas_equalTo(buttonWidth);
    }];
    
    UIButton *lastButton = [[UIButton alloc] init];
    [lastButton setImage:[UIImage imageNamed:@"Past"] forState:UIControlStateNormal];
    [lastButton addTarget:self action:@selector(clickLast) forControlEvents:UIControlEventTouchUpInside];
    [bView addSubview:lastButton];
    [lastButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.playButton.mas_left);
        make.top.and.bottom.mas_equalTo(bView);
        make.width.mas_equalTo(buttonWidth);
    }];
    
    self.progressView = [[UISlider alloc] init];
    self.progressView.userInteractionEnabled = YES;
    //    self.progressView.frame = CGRectMake(CGRectGetMaxX(self.playButton.frame)+10, 5, bottomView.width-(CGRectGetMaxX(self.playButton.frame)+10) - 60, height-10);
    self.progressView.backgroundColor = [UIColor clearColor];
    self.progressView.minimumValue = 0;
    self.progressView.maximumValue = 95;
    self.progressView.minimumTrackTintColor = UIColorFromRGB(0x2593c8); // 设置已过进度部分的颜色
    self.progressView.maximumTrackTintColor = UIColorFromRGB(0xa8a8a8); // 设置未过进度部分的颜色
    // [oneProgressView setProgress:0.8 animated:YES]; // 设置初始值，可以看到动画效果
    //    [self.progressView setProgressViewStyle:UIProgressViewStyleDefault]; // 设置显示的样式
    [self.progressView setThumbImage:[UIImage imageNamed:@"Slider"] forState:UIControlStateNormal];
    [self.progressView addTarget:self action:@selector(changeProgress:) forControlEvents:UIControlEventValueChanged];
    [bView addSubview:self.progressView];
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(5);
        make.top.mas_equalTo(5);
        make.right.mas_equalTo(lastButton.mas_left);
        make.bottom.mas_equalTo(-5);
    }];
    
    self.bottomView.hidden = YES;
}

-(UILabel *)createLabelWithFont:(UIFont *)font
{
    UILabel *lbl = [UILabel new];
    lbl.font = font;
    lbl.adjustsFontSizeToFitWidth = YES;
    lbl.minimumScaleFactor = 0.5;
    
    return lbl;
}

-(void)changeProgress:(id)sender
{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
        self.playButton.selected = NO;
    }
    
    self.currentPlayIndex = self.progressView.value*(self.allImages.count)/self.progressView.maximumValue;
    NSString *imageUrl = [self.allImages objectForKey:@(self.allImages.count-self.currentPlayIndex-1)];
    UIImage *curImage = [self.mapImagesManager imageFromDiskForUrl:imageUrl];
    if (curImage) {
        [self changeImageAnim:curImage];
    }
    else
    {
        LOG(@"Image file 不存在~~%@", imageUrl);
    }
}

-(void)clickPlay
{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
        self.playButton.selected = NO;
    }
    else
    {
        //        if (self.type == 0) {
        [self requestImageList:MapImageTypeRain];
        //        }
        //        else
        //        {
        //            [self requestImageList:MapImageTypeCloud];
        //        }
    }
}

-(void)clickLast
{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
        self.playButton.selected = NO;
    }
    
    self.currentPlayIndex = MAX(0, self.currentPlayIndex - 1);
    NSString *imageUrl = [self.allImages objectForKey:@(self.allImages.count-self.currentPlayIndex-1)];
    UIImage *curImage = [self.mapImagesManager imageFromDiskForUrl:imageUrl];
    if (curImage) {
        [self changeImageAnim:curImage];
    }
    else
    {
        LOG(@"Image file 不存在~~%@", imageUrl);
    }
}

-(void)clickNext
{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
        self.playButton.selected = NO;
    }
    
    self.currentPlayIndex = MIN(self.allImages.count-1, self.currentPlayIndex + 1);
    NSString *imageUrl = [self.allImages objectForKey:@(self.allImages.count-self.currentPlayIndex-1)];
    UIImage *curImage = [self.mapImagesManager imageFromDiskForUrl:imageUrl];
    if (curImage) {
        [self changeImageAnim:curImage];
    }
    else
    {
        LOG(@"Image file 不存在~~%@", imageUrl);
    }
}
@end
