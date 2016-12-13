//
//  ViewController.m
//  HelloEarth
//
//  Created by 卢大维 on 15/7/28.
//  Copyright (c) 2015年 weather. All rights reserved.
//

#import "ViewController.h"
#import <WhirlyGlobeMaplyComponent/WhirlyGlobeComponent.h>
//#import "WhirlyGlobeComponent.h"
#import "MyRemoteTileInfo.h"
#import "MyMaplyRemoteTileSource.h"
#import "MapImagesManager.h"
#import "CWDataManager.h"
#import "Masonry.h"
#import "Util.h"
#import "PLHttpManager.h"
#import "MapStatisticsBottomView.h"
#import "NSDate+Utilities.h"

#import "HEMapDatas.h"
#import "HEMapAnimLogic.h"
#import <MediaPlayer/MediaPlayer.h>

#import "HESettingController.h"
#import "CWLocationManager.h"
#import "HELegendController.h"
#import "HEProductsController.h"
#import "HEMapDataAnimLogic.h"
#import "HEMapAnimFlow.h"

#import "MBProgressHUD+Extra.h"
#import "HESplashController.h"
#import "AlertViewBlocks.h"
#import "NSDate+Utilities.h"

#import "HEShareView.h"
#import "HEDataFlowBottomView.h"

#define VIEW_MARGIN self.view.width*0.04
#define EXPAND_MARGIN 12

#define CHINA_CENTER_COOR MaplyCoordinateMakeWithDegrees(104, 32)

NS_ENUM(NSInteger, MapAnimType)
{
    MapAnimTypeImage=1,
    MapAnimTypeData,
};

@interface ViewController ()<WhirlyGlobeViewControllerDelegate, MaplyViewControllerDelegate, HEMapAnimLogicDelegate, HEMapDataAnimDelegate, HESettingDelegate, HEProductDelegate, HEShareDelegate, HEMapAnimFlowDelegate>
{
    CGFloat globeHeight;
    
    CGFloat initMapHeight;
    NSArray *locPoints;
    
    MaplyAtmosphere *atmosObj;
    
    MPMoviePlayerViewController * player;
    
    // setting
    BOOL show3D,showLight,showLocation,showMapDataUI;
    WhirlyGlobeViewController *globeViewC;
    MaplyViewController *mapViewC;
    
    MaplyQuadImageTilesLayer *tileLayer, *defaultTileLayer, *satelliteTileLayer;
    MaplyStarsModel *stars;
    
    // product data
    BOOL isBottomFull,isHiddenStatusBar;
    NSString *productType;
    NSString *productName;
    NSString *productAge;
    
    UIImageView *loadingIV;
    
    NSString *mapDataType;
    
    BOOL autoRotate;
}

@property (nonatomic,strong) MaplyBaseViewController *theViewC;
//@property (nonatomic,strong) WhirlyGlobeViewController *theViewC;

@property (nonatomic,strong) HEMapDatas *mapDatas;
@property (nonatomic,copy) NSArray *comObjs;
@property (nonatomic,strong) HEMapDataAnimLogic *mapDataAnimLogic;

@property (nonatomic,strong) HEMapAnimLogic *mapAnimLogic;
@property (nonatomic,strong) HEMapAnimFlow *mapAnimFlow;
@property (nonatomic,strong) MaplyComponentObject *markersObj,*markersTJ1,*markersTJ2,*markersTJ3;
@property (nonatomic,strong) MaplyComponentObject *markerLocation;

@property (nonatomic,strong) MaplyComponentObject *cityLabelsObj;

@property (nonatomic,assign) enum MapAnimType animType;

// UI
//@property (nonatomic,strong) UIView *topView;
@property (nonatomic,strong) UIButton *shareButton, *logoButton;

@property (nonatomic,strong) UIView *bottomView,*bottomContentView;

@property (nonatomic,strong) UIButton *playButton, *indexButton, *expandButton;
@property (nonatomic,strong) UISlider *progressView;
@property (nonatomic,strong) UILabel *titleLbl, *timeLabel;

@property (nonatomic,strong) UIControl *dimView, *navDimView;
@property (nonatomic,strong) UIView *logoPopView;
@property (nonatomic,strong) HEShareView *shareView;

// 统计
@property (nonatomic,copy) NSDictionary *markerDatas;
@property (nonatomic,strong) MapStatisticsBottomView *statisticsView;

// 请求
@property (nonatomic,strong) AFHTTPRequestOperation *currentOperation;

@property (nonatomic,strong) HEDataFlowBottomView *dataFlowBottomView;

@end

@implementation ViewController

// 状态栏样式
//-(UIStatusBarStyle)preferredStatusBarStyle
//{
//    return UIStatusBarStyleLightContent;
//}

-(BOOL)prefersStatusBarHidden
{
    return NO;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self preLoadMapView];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationed:) name:noti_update_location object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadAnimFinished) name:noti_loadanim_ok object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
}

-(void)preLoadMapView
{
    initMapHeight = -1;
    show3D = YES;
    showLight = NO;
    showLocation = YES;
    mapDataType = @"默认地图";
    
    [self initViews];
    [self makeMapViewAndDatas];
}

#pragma mark - inits
-(void)initDatas
{
    self.mapDatas = nil;
    self.mapDatas = [[HEMapDatas alloc] initWithController:self.theViewC];
    
    self.mapDataAnimLogic = nil;
    self.mapDataAnimLogic = [[HEMapDataAnimLogic alloc] initWithMapDatas:self.mapDatas];
    self.mapDataAnimLogic.delegate = self;
    
    self.mapAnimLogic = nil;
    self.mapAnimLogic = [[HEMapAnimLogic alloc] initWithController:self.theViewC];
    self.mapAnimLogic.delegate = self;
    
    self.mapAnimFlow = nil;
    self.mapAnimFlow = [[HEMapAnimFlow alloc] initWithController:self.theViewC];
    self.mapAnimFlow.delegate = self;
}

-(void)initMapView
{
    if (self.theViewC) {
        [self.theViewC.view removeFromSuperview];
        [self.theViewC removeFromParentViewController];
        self.theViewC = nil;
//        globeViewC = nil;
//        mapViewC = nil;
    }
    if (show3D) {
        if (!globeViewC) {
            globeViewC = [[WhirlyGlobeViewController alloc] init];
            globeViewC.delegate = self;
        }
        
        self.theViewC = globeViewC;
    }
    else
    {
        if (!mapViewC) {
            mapViewC = [[MaplyViewController alloc] initAsFlatMap];
            mapViewC.viewWrap = true;
            mapViewC.rotateGesture = NO;
            mapViewC.doubleTapZoomGesture = true;
            mapViewC.twoFingerTapGesture = true;
            mapViewC.delegate = self;
        }
        
        self.theViewC = mapViewC;
    }
    [self.view addSubview:self.theViewC.view];
    [self.view sendSubviewToBack:self.theViewC.view];
    self.theViewC.view.frame = self.view.bounds;
    self.theViewC.view.layer.shadowOffset = CGSizeMake(1, 1);
    self.theViewC.view.layer.shadowColor = [[UIColor greenColor] colorWithAlphaComponent:0.3].CGColor;
    [self addChildViewController:self.theViewC];
    
    // 地图图层
    tileLayer.enable = NO;
    [self.theViewC removeLayer:tileLayer];
    MaplyQuadImageTilesLayer *newLayer = [self createTileLayer];
    
    [self.theViewC addLayer:newLayer];
    tileLayer = newLayer;
    tileLayer.enable = YES;
    
    self.theViewC.frameInterval = 2;
    self.theViewC.threadPerLayer = true;
    
    if (show3D) {
        float minHeight,maxHeight;
        [globeViewC getZoomLimitsMin:&minHeight max:&maxHeight];
        [globeViewC setZoomLimitsMin:minHeight max:3.0];
        
        if (initMapHeight == -1) {
            initMapHeight = globeViewC.height;
        }
        
    }
    else
    {
        mapViewC.heading = 0;
        mapViewC.height = M_PI/2;
        
        if (initMapHeight == -1) {
            initMapHeight = mapViewC.height;
        }
        
    }
    
    [self addCountry_china];
}

-(MaplyQuadImageTilesLayer *)createTileLayer
{
    if ([mapDataType isEqualToString:@"默认地图"] && defaultTileLayer)
    {
        return defaultTileLayer;
    }
    
    if ([mapDataType isEqualToString:@"卫星地图"] && satelliteTileLayer)
    {
        return satelliteTileLayer;
    }
    
    NSString *mapId = [[CWDataManager sharedInstance].mapDataTypes objectForKey:mapDataType];
    NSDictionary *mapImageInfo = [[CWDataManager sharedInstance].mapOfflineImageInfo objectForKey:mapDataType];
    
    NSString *baseCacheDir =
    [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)
     objectAtIndex:0];
    NSString *aerialTilesCacheDir = [NSString stringWithFormat:@"%@/%@/",baseCacheDir, mapId];
    int maxZoom = 18;
    
    MyRemoteTileInfo *myTileInfo = [[MyRemoteTileInfo alloc] initWithBaseURL:[NSString stringWithFormat:@"http://api.tiles.mapbox.com/v4/%@/", mapId] ext:@"png" minZoom:0 maxZoom:maxZoom];
    myTileInfo.imageInfo = mapImageInfo;
    
    MyMaplyRemoteTileSource *tileSource = [[MyMaplyRemoteTileSource alloc] initWithInfo:myTileInfo];
    tileSource.cacheDir = aerialTilesCacheDir;
    tileSource.imageInfo = mapImageInfo;
    
    MaplyQuadImageTilesLayer *layer = [[MaplyQuadImageTilesLayer alloc] initWithCoordSystem:tileSource.coordSys tileSource:tileSource];
    layer.handleEdges = false;
    layer.coverPoles = true;
    layer.maxTiles = 256;
//    layer.singleLevelLoading = true;
//    layer.animationPeriod = 6.0;
//    layer.drawPriority = 0;
//    layer.waitLoad = true;

//    [tileLayer reset];
    
    if ([mapDataType isEqualToString:@"默认地图"]) {
        defaultTileLayer = layer;
    }
    else if ([mapDataType isEqualToString:@"卫星地图"])
    {
        satelliteTileLayer = layer;
    }
    
    return layer;
}

-(void)makeMapViewAndDatas
{
    showMapDataUI = NO;
    if (!self.theViewC || (show3D && mapViewC) || (!show3D && globeViewC)) {
        [self initMapView];
        [self initDatas];
        
        INIT_WEAK_SELF;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (show3D) {
                globeViewC.heading = 0;
                globeViewC.keepNorthUp = true;
                [globeViewC animateToPosition:CHINA_CENTER_COOR time:0.3];
                //                [globeViewC setAutoRotateInterval:0.2 degrees:20];
                
                [weakSlef addStars:@"starcatalog_orig"];
                if (showLight) {
                    [weakSlef addSun];
                }
            }
            else
            {
                [mapViewC animateToPosition:CHINA_CENTER_COOR height:initMapHeight time:0.3];
            }
            
            showMapDataUI = YES;
            // 重新设置地图显示
//            [self changeProduct_normal];
            [weakSlef refreshDataAndUI];
            
            if (showLocation) {
                [weakSlef addUserLocationMarker];
            }
        });
    }
}

-(void)initViews
{
    [self initTopViews];
    [self initBottomViews];
    
    self.dimView = [UIControl new];
    self.dimView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    [self.navigationController.view addSubview:self.dimView];
    [self.dimView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.navigationController.view);
    }];
    self.dimView.hidden = YES;
    [self.dimView addTarget:self action:@selector(closeLogoView) forControlEvents:UIControlEventTouchDown];
    
    self.logoPopView.hidden = YES;
    
    self.shareView.hidden = YES;
}

-(void)initTopViews
{
    self.navigationItem.hidesBackButton = YES;
    CGRect rect = CGRectMake(0, 0, self.view.width, SELF_NAV_HEIGHT);
    self.navigationController.navigationBar.bounds = rect;
    UIView *view = [[UIView alloc] initWithFrame:rect];
    
    NSArray *images = @[@[@"产品－未选中", @"产品－选中"],
                        @[@"设置－未选中", @"设置－选中"],
                        @[@"分享－未选中", @"分享－选中"],
                        @[@"回位－未选中", @"回位－选中"],
                        @[@"未选中－1", @"选中－1"],
                        ];
    UIButton *lastButton;
    for (NSInteger i=0; i<5; i++) {
        
        NSString *imgName = [[images objectAtIndex:i] firstObject];
        NSString *selectImgName = [[images objectAtIndex:i] lastObject];
        UIButton *button = [self createButtonWithImg:[UIImage imageNamed:imgName] selectImg:[UIImage imageNamed:selectImgName]];
        button.tag = i;
        [view addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            if (lastButton) {
                make.left.mas_equalTo(lastButton.mas_right);
            }
            else
            {
                make.left.mas_equalTo(0);
            }
            make.top.mas_equalTo(SELF_NAV_HEIGHT*0.12);
            make.bottom.mas_equalTo(-SELF_NAV_HEIGHT*0.12);
//            make.height.mas_equalTo(view.mas_height).multipliedBy(0.8);
            make.width.mas_equalTo(view.mas_width).multipliedBy(0.2);
        }];
        
        [button addTarget:self action:@selector(clickMenu:) forControlEvents:UIControlEventTouchUpInside];
        lastButton = button;
        if (i == 4) {
            self.logoButton = button;
        }
        
        if (i == 2) {
            self.shareButton = button;
        }
    }
    
    lastButton = nil;
    
    self.navDimView = [[UIControl alloc] initWithFrame:rect];
    self.navDimView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    self.navDimView.hidden = YES;
    [self.navDimView addTarget:self action:@selector(closeLogoView) forControlEvents:UIControlEventTouchDown];
    [view addSubview:self.navDimView];
    
    self.navigationItem.titleView = view;
//    [self.navigationController.navigationBar addSubview:view];
}

-(void)initBottomViews
{
    CGFloat buttonWidth = 35;
    CGFloat margin = VIEW_MARGIN;

    UIButton *expandButton = [self createButtonWithImg:[UIImage imageNamed:@"全屏－1"] selectImg:[UIImage imageNamed:@"非全屏－1"]];
    [expandButton addTarget:self action:@selector(clickExpand) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:expandButton];
    [expandButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-margin);
        make.bottom.mas_equalTo(-EXPAND_MARGIN);
        make.width.height.mas_equalTo(buttonWidth);
    }];
    self.expandButton = expandButton;
    
    CGFloat height = 90;
    UIView *bottomView = [[UIView alloc] init];
    bottomView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    [self.view addSubview:bottomView];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(height);
    }];
    [self.view bringSubviewToFront:expandButton];
    self.bottomView = bottomView;
    
    UIView *view = [UIView new];
    [bottomView addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(bottomView);
    }];
    self.bottomContentView = view;
    
    UILabel *titleLbl = [self createLabelWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:18]];
    titleLbl.textColor = [UIColor whiteColor];
    [view addSubview:titleLbl];
    [titleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(view);
        make.left.mas_equalTo(margin);
        make.height.mas_equalTo(30);
        make.right.mas_equalTo(-margin);
    }];
    self.titleLbl = titleLbl;
    
    self.timeLabel = [self createLabelWithFont:[Util modifyFontWithName:@"Helvetica" size:14]];
    self.timeLabel.textColor = [UIColor whiteColor];
    [view addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titleLbl.mas_bottom).offset(-2);
        make.left.mas_equalTo(titleLbl.mas_left);
        make.height.mas_greaterThanOrEqualTo(12);
    }];
    
    self.indexButton = [self createButtonWithImg:[UIImage imageNamed:@"图例"] selectImg:nil];
    [view addSubview:self.indexButton];
    [self.indexButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-10);
        make.bottom.mas_equalTo(self.timeLabel.mas_bottom);
        make.width.mas_equalTo(50);
        make.top.mas_greaterThanOrEqualTo(0);
    }];
    [self.indexButton addTarget:self action:@selector(clickLegend) forControlEvents:UIControlEventTouchUpInside];
    self.indexButton.hidden = YES;
    
    UIView *bView = [UIView new];
//    bView.backgroundColor = [UIColor colorWithRed:45/255.0 green:40/255.0 blue:16/255.0 alpha:0.1];
    [view addSubview:bView];
    [bView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(40);
        make.bottom.mas_equalTo(view.mas_bottom).offset(-9);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(view);
    }];
    
    UIImageView *slideBack = [UIImageView new];
    slideBack.userInteractionEnabled = YES;
    slideBack.image = [UIImage imageNamed:@"刻度－20"];
    [bView addSubview:slideBack];
    [slideBack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(margin+buttonWidth);
        make.top.mas_equalTo(20);
        make.right.mas_equalTo(expandButton.mas_left).offset(-margin);
        make.height.mas_lessThanOrEqualTo(10);
//        make.bottom.mas_equalTo(bView);
    }];
//    [slideBack sizeToFit];
    
    self.playButton = [self createButtonWithImg:[UIImage imageNamed:@"play"] selectImg:[UIImage imageNamed:@"pause"]];
    [self.playButton addTarget:self action:@selector(clickPlay) forControlEvents:UIControlEventTouchUpInside];
    self.playButton.contentEdgeInsets = UIEdgeInsetsMake(0, margin, 0, margin);
    [bView addSubview:self.playButton];
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(15);
        make.bottom.mas_equalTo(slideBack.mas_bottom).offset(5);
//        make.width.mas_equalTo(buttonWidth);
        make.right.mas_equalTo(slideBack.mas_left);
    }];
    
    self.progressView = [[UISlider alloc] init];
    self.progressView.continuous = NO;
    self.progressView.userInteractionEnabled = YES;
    self.progressView.backgroundColor = [UIColor clearColor];
    self.progressView.minimumValue = 0;
    self.progressView.maximumValue = 100;
    self.progressView.minimumTrackTintColor = [UIColor clearColor];//UIColorFromRGB(0x2593c8); // 设置已过进度部分的颜色
    self.progressView.maximumTrackTintColor = [UIColor clearColor];//UIColorFromRGB(0xa8a8a8); // 设置未过进度部分的颜色
    [self.progressView setThumbImage:[UIImage imageNamed:@"slider"] forState:UIControlStateNormal];
    [self.progressView addTarget:self action:@selector(changeProgress:) forControlEvents:UIControlEventValueChanged];
    [bView addSubview:self.progressView];
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(slideBack.mas_left);
        make.right.mas_equalTo(slideBack.mas_right);
        make.centerY.mas_equalTo(slideBack.mas_bottom);
    }];
}

-(UIButton *)createButtonWithImg:(UIImage *)img selectImg:(UIImage *)selectImg
{
    UIButton *button = [UIButton new];
    [button setImage:img forState:UIControlStateNormal];
    if (selectImg) {
        [button setImage:selectImg forState:UIControlStateHighlighted];
        [button setImage:selectImg forState:UIControlStateSelected];
    }
    button.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    return button;
}

-(UILabel *)createLabelWithFont:(UIFont *)font
{
    UILabel *lbl = [UILabel new];
    lbl.font = font;
    lbl.adjustsFontSizeToFitWidth = YES;
    lbl.minimumScaleFactor = 0.5;
    
    return lbl;
}

#pragma mark - setup views
-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    if (!isHiddenStatusBar) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
        [self setNeedsStatusBarAppearanceUpdate];
    }
    
    if (self.view.width != self.navigationController.navigationBar.width) {
        [self initTopViews];
    }
    
    self.shareButton.enabled = self.view.width < self.view.height;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setBackgroundImage:[Util createImageWithColor:[UIColor colorWithWhite:0 alpha:0.3] width:1 height:(STATUS_HEIGHT+SELF_NAV_HEIGHT)] forBarMetrics:UIBarMetricsDefault];
    if (isHiddenStatusBar) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        
        [self.navigationController setNavigationBarHidden:YES];
    }
    
    self.statisticsView.hidden = YES;
    
    if (isHiddenStatusBar) {
        if (isBottomFull) {
            [self setHalfBottomLayout];
        }
    }
    else
    {
        if (isBottomFull) {
            [self setFullBottomLayout];
        }
        else
        {
            // 默认显示一半的
            [self setHalfBottomLayout];
        }
    }
    
    [self.view layoutIfNeeded];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // 初始显示 "雷达图"
    if (!productType) {
        productType = FILEMARK_RADAR;
        productName = @"雷达图";
        
        self.mapAnimLogic.hideHUD = YES;
    }
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.theViewC clearAnnotations];
    [self.statisticsView hide];
//    [self closeLogoView];
    
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

-(void)willEnterForeground
{
    if ([productType isEqualToString:FILEMARK_RADAR]) {
        isBottomFull = YES;
        self.animType = MapAnimTypeImage;
        [self.mapAnimLogic showImagesAnimation:MapImageTypeRain];
    }
    else if ([productType isEqualToString:FILEMARK_CLOUD])
    {
        isBottomFull = YES;
        self.animType = MapAnimTypeImage;
        [self.mapAnimLogic showImagesAnimation:MapImageTypeCloud];
    }
}

//-(void)didEnterBackground
//{
//
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    self.markerDatas = nil;
}

-(void)changeProduct_normal
{
    if (!productName) {
        return;
    }
    
    self.titleLbl.text = productName;
    
    if ([[NSDate date] timeIntervalSince1970] - [[[CWDataManager sharedInstance].productReqtimes objectForKey:productName] doubleValue] <= 60*3) {
        if (isBottomFull) {
            NSArray *types = [productType componentsSeparatedByString:@","];
            
            self.animType = MapAnimTypeData;
            [self.mapDataAnimLogic showProductWithTypes:types withAge:productAge];
        }
        else
        {
            self.comObjs = [self.mapDatas changeType:productType];
            
            // 设置时间
            NSDateFormatter *dateFormatter = [CWDataManager sharedInstance].dateFormatter;
            NSString *time = [[[CWDataManager sharedInstance] mapdataByFileMark:productType] objectForKey:@"time"];
            
            long long timeInt = [time longLongValue];
            NSDate* expirationDate = [NSDate dateWithTimeIntervalSince1970:timeInt/1000];
            [dateFormatter setDateFormat:@"yyyy.MM.dd HH:mm"];
            [self setTimeText:[dateFormatter stringFromDate:expirationDate]];
        }
    }
    else
    {
        [MBProgressHUD showHUDInView:self.view andText:nil];
        NSString *url = [Util requestEncodeWithString:[NSString stringWithFormat:@"http://scapi.weather.com.cn/weather/micapsfile?fileMark=%@&isChina=true&", productType] appId:@"f63d329270a44900" privateKey:@"sanx_data_99"];
        
        [self.currentOperation cancel];
        self.currentOperation = [[PLHttpManager sharedInstance].manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            if (responseObject && [responseObject isKindOfClass:[NSArray class]]) {
                if (isBottomFull) {
                    NSArray *types = [productType componentsSeparatedByString:@","];
                    if (types.count == [responseObject count]) {
                        for (NSInteger i=0; i<types.count; i++) {
                            [[CWDataManager sharedInstance] setMapdata:[responseObject objectAtIndex:i] fileMark:[types objectAtIndex:i]];
                            [[CWDataManager sharedInstance].productReqtimes setObject:@([[NSDate date] timeIntervalSince1970]) forKey:productName];
                        }
                    }
                    
                    self.animType = MapAnimTypeData;
                    [self.mapDataAnimLogic showProductWithTypes:types withAge:productAge];
                    
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                }
                else
                {
                    if ([[responseObject firstObject] count] == 0) {
                        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                        
                        [MBProgressHUD showHUDNoteInView:self.view withText:@"没有数据"];
                        LOG(@"%@", url);
                    }
                    else
                    {
                        [[CWDataManager sharedInstance] setMapdata:[responseObject firstObject] fileMark:productType];
                        [[CWDataManager sharedInstance].productReqtimes setObject:@([[NSDate date] timeIntervalSince1970]) forKey:productName];
                        self.comObjs = [self.mapDatas changeType:productType];
                        
                        // 设置时间
                        NSDateFormatter *dateFormatter = [CWDataManager sharedInstance].dateFormatter;
                        
                        long long timeInt = [[[responseObject firstObject] objectForKey:@"time"] longLongValue];
                        NSDate* expirationDate = [NSDate dateWithTimeIntervalSince1970:timeInt/1000];
                        [dateFormatter setDateFormat:@"yyyy.MM.dd HH:mm"];
                        [self setTimeText:[dateFormatter stringFromDate:expirationDate]];
                        
                        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                    }
                }
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        }];
    }
}

-(void)resetMapUI
{
    [self.currentOperation cancel];
    
    [self.mapDataAnimLogic clear];
    [self.theViewC removeObjects:self.comObjs];
    self.comObjs = nil;
    
    [self.mapAnimLogic clear];
    [self.theViewC removeObject:self.mapAnimLogic.stickersObj];
    self.mapAnimLogic.stickersObj = nil;
    
    [self clearMarkerObjs];
    
    if (!self.statisticsView.hidden) {
        self.statisticsView.hidden = YES;
    }
    
    self.timeLabel.text = @"";
}

-(void)clearMarkerObjs
{
    NSMutableArray *temp = [NSMutableArray array];
    if (self.markersObj) {
        [temp addObject:self.markersObj];
    }
    if (self.markersTJ1) {
        [temp addObject:self.markersTJ1];
    }
    if (self.markersTJ2) {
        [temp addObject:self.markersTJ2];
    }
    if (self.markersTJ3) {
        [temp addObject:self.markersTJ3];
    }
    if (temp.count > 0) {
        [self.theViewC disableObjects:temp mode:MaplyThreadCurrent];
        [self.theViewC startChanges];
        
        [self.theViewC removeObjects:temp mode:MaplyThreadCurrent];
        
        // 修改bug : 删除markers时的黑色块
        sleep(0.2);
        INIT_WEAK_SELF;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSlef.theViewC endChanges];
        });
    }
    self.markersObj = nil;
    self.markersTJ1 = nil;
    self.markersTJ2 = nil;
    self.markersTJ3 = nil;
    temp = nil;
}

#pragma mark - map actions
- (void)addCountry_china
{
    NSDictionary *vectorDict = @{
                                 kMaplyColor: UIColorFromRGB(0x28a7e1),
                                 kMaplySelectable: @(true),
                                 kMaplyVecWidth: @(4.0)};
    
    INIT_WEAK_SELF;
    // handle this in another thread
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0),
                   ^{
                       NSString *outlineFile = [[NSBundle mainBundle] pathForResource:@"china" ofType:@"json"];
                       
                       NSData *jsonData = [NSData dataWithContentsOfFile:outlineFile];
                       if (jsonData)
                       {
                           MaplyVectorObject *wgVecObj = [MaplyVectorObject VectorObjectFromGeoJSONApple:jsonData];
                           
                           // the admin tag from the country outline geojson has the country name ­ save
                           NSString *vecName = [[wgVecObj attributes] objectForKey:@"name"];
                           wgVecObj.userObject = vecName;
                           
                           // add the outline to our view
                           [weakSlef.theViewC addVectors:[NSArray arrayWithObject:wgVecObj] desc:vectorDict];
                           // If you ever intend to remove these, keep track of the MaplyComponentObjects above.
                           
                           MaplyScreenLabel *lbl1 = [self mapLabelWithName:@"北京" latlon:@"39.9049870000,116.4052810000"];
                           MaplyScreenLabel *lbl2 = [self mapLabelWithName:@"上海" latlon:@"31.2317070000,121.4726410000"];
                           self.cityLabelsObj = [weakSlef.theViewC addScreenLabels:@[lbl1, lbl2] desc:@{kMaplyTextOutlineSize: @(0.6),
                                                                                                        kMaplyTextOutlineColor: [UIColor blackColor],
                                                                                                        kMaplyFont: [UIFont systemFontOfSize:14.0],
                                                                                                        kMaplyDrawPriority: @(200),
                                                                                                        kMaplyMaxVis:@1.8,
                                                                                                        kMaplyMinVis:@0.0
                                                                                                        }];
                       }
                       
                   });
}

-(MaplyScreenLabel *)mapLabelWithName:(NSString *)name latlon:(NSString *)latlon
{
    NSString *lat = [[latlon componentsSeparatedByString:@","] firstObject];
    NSString *lon = [[latlon componentsSeparatedByString:@","] lastObject];
    
    MaplyScreenLabel *label = [[MaplyScreenLabel alloc] init];
    label.loc = MaplyCoordinateMakeWithDegrees(lon.floatValue, lat.floatValue);
//    label.keepUpright = true;
//    label.layoutPlacement = kMaplyLayoutRight;
    label.layoutImportance = 2;
    label.text = [@"•" stringByAppendingString:name];
    label.offset = CGPointMake(-3, 3);
//    label.iconSize = CGSizeMake(15, 15);
//    label.iconImage2 = [UIImage imageNamed:@"city_location"];
//    label.userObject = [NSString stringWithFormat:@"%s",location->name];
    return label;
}

- (void)addStars:(NSString *)inFile
{
    if (!globeViewC)
        return;
    
    // Load the stars
    NSString *fileName = [[NSBundle mainBundle] pathForResource:inFile ofType:@"txt"];
    if (fileName)
    {
        if (!stars) {
            stars = [[MaplyStarsModel alloc] initWithFileName:fileName];
            stars.image = [UIImage imageNamed:@"star_background"];
            [stars addToViewC:globeViewC date:[NSDate date] desc:nil mode:MaplyThreadCurrent];
        }
    }
}

- (void)addSun
{
    if (!globeViewC)
        return;
    
    // Lighting for the sun
    NSDate *now = [NSDate date];
    if ([now hour] > 12) {
        now = [NSDate dateWithHoursFromNow:12-now.hour];
    }
    
    MaplySun *sun = [[MaplySun alloc] initWithDate:now];
    MaplyLight *sunLight = [sun makeLight];
    [self.theViewC clearLights];
    [self.theViewC addLight:sunLight];
    
    // And some atmosphere, because the iDevice fill rate is just too fast
    atmosObj = [[MaplyAtmosphere alloc] initWithViewC:globeViewC];
    [atmosObj setSunPosition:[sun getDirection]];
}

-(void)addUserLocationMarker
{
    CLLocation *location = [CWLocationManager sharedInstance].locationManager.location;
    if (location && [CWLocationManager sharedInstance].plackMark) {
        if (self.markerLocation) {
            [self.theViewC removeObject:self.markerLocation];
        }
        
        location = [location locationMarsFromEarth];
        
        UIImage *img = [UIImage imageNamed:@"map_anni_point"];
        MaplyScreenMarker *anno = [[MaplyScreenMarker alloc] init];
        anno.loc             = MaplyCoordinateMakeWithDegrees(location.coordinate.longitude, location.coordinate.latitude);
        anno.offset          = CGPointMake(0, img.size.height/2);
        anno.size            = img.size;//CGSizeMake(30, 30);
        anno.userObject      = @{@"type": @"userLocation", @"title": [CWLocationManager sharedInstance].plackMark.locality, @"subTitle": [CWLocationManager sharedInstance].plackMark.name };
        anno.image = img;
        anno.layoutImportance = MAXFLOAT;
        
        self.markerLocation = [self.theViewC addScreenMarkers:@[anno] desc:@{kMaplyDrawPriority: @(kMaplyModelDrawPriorityDefault+300)}];
    }
    
}

-(void)addTongJiMarkers
{
    [MBProgressHUD showHUDInView:self.view andText:@"处理中..."];
    INIT_WEAK_SELF;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *annos1 = [weakSlef annotationsWithServerDatas:@"level1"];
        
        if (annos1 && [productType isEqualToString:FILEMARK_TONGJI] && showMapDataUI) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSlef.markersTJ1 = [weakSlef.theViewC addScreenMarkers:annos1 desc:@{kMaplyFade: @(1.0), kMaplyDrawPriority: @(kMaplyModelDrawPriorityDefault+200)}];
                [MBProgressHUD hideAllHUDsForView:weakSlef.view animated:YES];
            });
        }
    });
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        NSArray *annos2 = [weakSlef annotationsWithServerDatas:@"level2"];
        if (annos2 && [productType isEqualToString:FILEMARK_TONGJI] && showMapDataUI) {
            weakSlef.markersTJ2 = [weakSlef.theViewC addScreenMarkers:annos2 desc:@{kMaplyMaxVis:@0.1, kMaplyMinVis:@0.0, kMaplyFade: @(1.0), kMaplyDrawPriority: @(kMaplyModelDrawPriorityDefault+200)}];
            annos2 = nil;
        }
    }];
    [op2 setCompletionBlock:^{
        LOG(@"op2 完成");
    }];
    
//    NSBlockOperation *op3 = [NSBlockOperation blockOperationWithBlock:
//    [op2 addExecutionBlock:^{
//        NSArray *annos3 = [weakSlef annotationsWithServerDatas:@"level3"];
//        if (annos3 && [productType isEqualToString:FILEMARK_TONGJI] && showMapDataUI) {
//            weakSlef.markersTJ3 = [weakSlef.theViewC addScreenMarkers:annos3 desc:@{kMaplyMaxVis:@0.05, kMaplyMinVis:@0, kMaplyFade: @(1.0), kMaplyDrawPriority: @(kMaplyModelDrawPriorityDefault+200)}];
//            annos3 = nil;
//        }
//    }];
    [queue addOperation:op2];
}

-(void)addNetEyeMarkers:(NSArray *)datas
{
    NSMutableArray *annos = [NSMutableArray arrayWithCapacity:datas.count];
    for (NSInteger i=0; i<datas.count; i++) {
        NSDictionary *dict = [datas objectAtIndex:i];
        
        MaplyScreenMarker *anno = [[MaplyScreenMarker alloc] init];
        anno.layoutImportance = MAXFLOAT;
        anno.loc             = MaplyCoordinateMakeWithDegrees([dict[@"lon"] floatValue], [dict[@"lat"] floatValue]);
        anno.size            = CGSizeMake(30, 30);
        anno.userObject      = @{@"type": @"eyes", @"title": dict[@"name"], @"subTitle": dict[@"url"]};
        anno.image           = [UIImage imageNamed:@"weather_camera_icon"];
        [annos addObject:anno];
    }
    
    self.markersObj = [self.theViewC addScreenMarkers:annos desc:@{kMaplyFade: @(1.0), kMaplyDrawPriority: @(kMaplyModelDrawPriorityDefault+200)}];
    annos = nil;
}

#pragma mark - Whirly Globe Delegate
//- (void)globeViewController:(WhirlyGlobeViewController *)viewC layerDidLoad:(WGViewControllerLayer *)layer
//{
//    LOG(@"layerDidLoad");
//}

- (void)globeViewControllerDidStartMoving:(WhirlyGlobeViewController *)viewC userMotion:(bool)userMotion
{
    LOG(@"Started moving");
}

- (void)globeViewController:(WhirlyGlobeViewController *)viewC didStopMoving:(MaplyCoordinate *)corners userMotion:(bool)userMotion
{
    LOG(@"Stopped moving %f, %f", viewC.height, viewC.heading);
    
//    if (self.markerDatas && self.markerDatas.count > 0) {
//        [self addAnnotations];
//    }
}

-(void)globeViewController:(WhirlyGlobeViewController *)viewC didSelect:(NSObject *)selectedObj
{
    [self didSelectedObjOnMap:selectedObj];
}

#pragma mark - MaplyViewControllerDelegate
- (void)maplyViewController:(MaplyViewController *)viewC didSelect:(NSObject *)selectedObj
{
    [self didSelectedObjOnMap:selectedObj];
}

#pragma mark - map tool
-(void)didSelectedObjOnMap:(NSObject *)selectedObj
{
    [self.theViewC clearAnnotations];
    
    if ([selectedObj isKindOfClass:[MaplyScreenMarker class]])
    {
        MaplyMarker *marker = (MaplyMarker *)selectedObj;
        
        NSDictionary *data = (NSDictionary *)marker.userObject;
        if ([data[@"type"] isEqualToString:@"tongji"]) {
            NSString *areaid = [data objectForKey:@"subTitle"];
            if (areaid && self.statisticsView.hidden) {
                
                //            if (self.isShowTemp) {
                //                self.statisticsTempView.addr = [view.annotation title];
                //                [self.statisticsTempView showWithStationId:areaid];
                //            }
                //            else
                {
                    self.statisticsView.addr = [data objectForKey:@"title"];
                    [self.statisticsView showWithStationId:areaid];
                }
            }
        }
        else if([data[@"type"] isEqualToString:@"eyes"])
        {
            NSString *url = [data objectForKey:@"subTitle"];
            player = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:url]];
            [player.moviePlayer setShouldAutoplay:YES];
            [player.moviePlayer setScalingMode:MPMovieScalingModeAspectFit];
            [player.moviePlayer setControlStyle:MPMovieControlStyleFullscreen];
            [player.moviePlayer play];
            
            [self presentMoviePlayerViewControllerAnimated:player];
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doVideoPlayFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
        }
        else if([data[@"type"] isEqualToString:@"userLocation"])
        {
            MaplyCoordinate loc = marker.loc;
            MaplyAnnotation *annotate = [[MaplyAnnotation alloc] init];
            annotate.title = data[@"title"];
            annotate.subTitle = data[@"subTitle"];
            [self.theViewC addAnnotation:annotate forPoint:loc offset:CGPointMake(0, -15)];
        }
    }
}

#pragma mark - private actions
- (void)doVideoPlayFinished:(id)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    player = nil;
}

-(void)resetLocationToInit
{
    if (show3D) {
        [globeViewC animateToPosition:CHINA_CENTER_COOR height:initMapHeight heading:0 time:0.3];
    }
    else
    {
        [mapViewC animateToPosition:CHINA_CENTER_COOR height:initMapHeight time:0.3];
    }
}

-(void)clickMenu:(UIButton *)button
{
    switch (button.tag) {
        case 0:
        {
            // products
            HEProductsController *next = [HEProductsController new];
            next.delegate = self;
            next.fileMark = productType;
            [self.navigationController pushViewController:next animated:YES];
            break;
        }
        case 1:
        {
            // setting
            UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            HESettingController *next = (HESettingController *)[board instantiateViewControllerWithIdentifier:@"setting"];
            next.delegate = self;
            next.set3D = show3D;
            next.setLight = showLight;
            next.setLocation = showLocation;
            next.mapDataType = mapDataType;
            [self.navigationController pushViewController:next animated:YES];
            break;
        }
        case 2:
        {
            // share
            UIImage *mapImage = [self.theViewC snapshot];
            self.theViewC.view.hidden = YES;
            UIImage *viewImage = [self.navigationController.view viewShot];
            self.theViewC.view.hidden = NO;
            
            UIImage *image = [Util addImage:viewImage toImage:mapImage toRect:CGRectMake(0, 0, mapImage.size.width, mapImage.size.height)];
            if (self.shareView.hidden) {
                self.shareView.shareImage = image;
                [self.shareView show];
                
                self.theViewC.view.userInteractionEnabled = NO;
                
                self.dimView.hidden = NO;
                self.dimView.alpha = 0;
                self.navDimView.hidden = NO;
                self.navDimView.alpha = 0;
                [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:0 animations:^{
                    self.dimView.alpha = 1;
                    self.navDimView.alpha = 1;
                    [self.navigationController.view layoutIfNeeded];
                } completion:^(BOOL finished) {
                    
                }];
            }
            
            break;
        }
        case 3:
        {
            // reset
            [self resetLocationToInit];
            break;
        }
        case 4:
        {
            // logo
            if (self.logoPopView.hidden) {
                button.selected = !button.selected;
                
                self.theViewC.view.userInteractionEnabled = NO;
                
                self.logoPopView.hidden = NO;
                self.logoPopView.alpha = 1;
                self.dimView.hidden = NO;
                self.dimView.alpha = 0;
                self.navDimView.hidden = NO;
                self.navDimView.alpha = 0;
                [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:0 animations:^{
                    self.logoPopView.transform = CGAffineTransformIdentity;
                    self.dimView.alpha = 1;
                    self.navDimView.alpha = 1;
                } completion:^(BOOL finished) {
                    
                }];
            }
            else
            {
                [self closeLogoView];
            }
            
            break;
        }
        default:
        break;
    }
}

-(void)showNetEyesMarkers
{
    [self.currentOperation cancel];
    [MBProgressHUD showHUDInView:self.view andText:nil];
    self.currentOperation = [[PLHttpManager sharedInstance].manager GET:@"http://decision.tianqi.cn//data/video/videoweather.html" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {

        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if (responseObject) {
            self.markerDatas = (NSDictionary *)responseObject;
            [self addNetEyeMarkers:responseObject];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
    }];
}

-(void)showTongJiMarkers
{
    NSString *url = [Util requestEncodeWithString:@"http://scapi.weather.com.cn/weather/stationinfo?" appId:@"f63d329270a44900" privateKey:@"sanx_data_99"];
    
    [self.currentOperation cancel];
    [MBProgressHUD showHUDInView:self.view andText:nil];
    self.currentOperation = [[PLHttpManager sharedInstance].manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {

        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if (responseObject) {
            self.markerDatas = (NSDictionary *)responseObject;
            [self addTongJiMarkers];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
}

-(void)changeProgress:(id)sender
{
    if (self.animType == MapAnimTypeData) {
        [self.mapDataAnimLogic changeProgress:sender];
    }
    else if (self.animType == MapAnimTypeImage)
    {
        [self.mapAnimLogic changeProgress:sender];
    }
}

-(void)clickPlay
{
    if (self.animType == MapAnimTypeData) {
        [self.mapDataAnimLogic clickPlay];
    }
    else if (self.animType == MapAnimTypeImage)
    {
        [self.mapAnimLogic clickPlay];
    }
}

-(void)clickExpand
{
    self.expandButton.selected = !self.expandButton.selected;
    if (self.navigationController.navigationBarHidden) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        
        if (isBottomFull)
        {
            [self setFullBottomLayout];
        }
        
        isHiddenStatusBar = NO;
    }
    else
    {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        
        if (isBottomFull) {
            [self setHalfBottomLayout];
        }
        
        isHiddenStatusBar = YES;
    }
    
    [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}

-(void)setFullBottomLayout
{
    [self.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(0);
    }];
    
    [self.titleLbl mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(40);
    }];
    
    [self.timeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.progressView.mas_top).offset(-2);
        make.left.mas_equalTo(self.progressView.mas_left);
        make.height.mas_greaterThanOrEqualTo(12);
    }];
    
    [self.bottomContentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.bottomView);
    }];
    
    [self.indexButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-VIEW_MARGIN);
        make.bottom.mas_equalTo(self.titleLbl.mas_bottom);
        make.width.mas_equalTo(50);
        make.top.mas_greaterThanOrEqualTo(0);
    }];
}

-(void)setHalfBottomLayout
{
    CGFloat modifyHeight = MAX(self.bottomView.height-(self.expandButton.height+EXPAND_MARGIN*2)+5, 0);
    [self.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(modifyHeight);

    }];
    
    [self.titleLbl mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(self.bottomContentView);
//        make.left.mas_equalTo(VIEW_MARGIN);
        make.height.mas_equalTo(30);
//        make.right.mas_equalTo(-VIEW_MARGIN);
    }];
    
    [self.timeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLbl.mas_bottom).offset(-2);
        make.left.mas_equalTo(self.titleLbl.mas_left);
        make.height.mas_greaterThanOrEqualTo(12);
    }];
    
    CGFloat topModify = 5;
    UIEdgeInsets padding = UIEdgeInsetsMake(topModify, 0, 0, 0);
    [self.bottomContentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.bottomView).insets(padding);
    }];
    
    [self.indexButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.expandButton.mas_left).offset(-VIEW_MARGIN);
//        make.bottom.mas_equalTo(self.timeLabel.mas_bottom);
        make.width.mas_equalTo(50);
        make.top.mas_greaterThanOrEqualTo(0);
        make.height.mas_equalTo(modifyHeight);
    }];
}

-(void)clickLegend
{
    HELegendController *next = [HELegendController new];
    next.fileMark = productType;
    [self.navigationController pushViewController:next animated:YES];
}

-(void)closeLogoView
{
    self.logoButton.selected = NO;
    self.theViewC.view.userInteractionEnabled = YES;
    
    if (!self.logoPopView.hidden) {
        
        self.dimView.alpha = 1;
        self.navDimView.alpha = 1;
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.logoPopView.transform = CGAffineTransformMakeScale(0.01, 0.01);
            self.logoPopView.alpha = 0;
            self.dimView.alpha = 0;
            self.navDimView.alpha = 0;
        } completion:^(BOOL finished) {
            self.logoPopView.hidden = YES;
            self.dimView.hidden = YES;
            self.navDimView.hidden = YES;
        }];
    }
    
    if (!self.shareView.hidden) {
        self.dimView.alpha = 1;
        self.navDimView.alpha = 1;

        [self.shareView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.navigationController.view.mas_bottom);
            make.left.right.mas_equalTo(self.navigationController.view);
            make.height.mas_equalTo(200);
        }];
        
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            self.dimView.alpha = 0;
            self.navDimView.alpha = 0;
            [self.navigationController.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            self.dimView.hidden = YES;
            self.navDimView.hidden = YES;
            
            self.shareView.hidden = YES;
        }];
    }
}

-(void)clickSqView
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"保存图片到相册?" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert showAlerViewFromButtonAction:nil animated:YES handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            UIImageWriteToSavedPhotosAlbum([UIImage imageNamed:@"qrcode_for_gh_9eb43db17ffb_430.jpg"], self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        }
    }];
//    NSString *str = @"weixin://qr/wTnL0yLEQX8_rWaw92zT";//@"http://weixin.qq.com/r/wTnL0yLEQX8_rWaw92zT";//
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    
    if (error) {
        [MBProgressHUD showHUDNoteInView:self.navigationController.view withText:@"图片保存出错"];
        return;
    }
    
    [MBProgressHUD showHUDNoteInView:self.navigationController.view withText:@"图片已保存"];
}

#pragma mark - tool methods
-(NSArray *)annotationsWithServerDatas:(NSString *)level
{
    NSArray *datas = [self.markerDatas objectForKey:level];
    
    NSMutableArray *annos = [NSMutableArray arrayWithCapacity:datas.count];
    for (NSInteger i=0; i<datas.count; i++) {
        if (![productType isEqualToString:FILEMARK_TONGJI] || !showMapDataUI) {
            return nil;
        }
        
        @autoreleasepool {
            NSDictionary *dict = [datas objectAtIndex:i];
#if 0
            MaplyScreenLabel *anno = [MaplyScreenLabel new];
            anno.loc             = MaplyCoordinateMakeWithDegrees([dict[@"lon"] floatValue], [dict[@"lat"] floatValue]);
            anno.text            = dict[@"name"];
            anno.iconImage2      = [UIImage imageNamed:@"circle39"];
            anno.userObject      = @{@"type": @"tongji", @"title": dict[@"name"], @"subTitle": [dict[@"stationid"] stringByAppendingFormat:@"-%@", dict[@"areaid"]]};
#else
            UIImage *newImage = [[CWDataManager sharedInstance] tongjiImageForName:dict[@"name"]];
            if (!newImage) {
                newImage = [Util drawText:dict[@"name"] inImage:[UIImage imageNamed:@"circle39"] font:[UIFont systemFontOfSize:12] textColor:[UIColor whiteColor]];
                [[CWDataManager sharedInstance] saveTongjiImage:newImage forName:dict[@"name"]];
            }
            
            MaplyScreenMarker *anno = [[MaplyScreenMarker alloc] init];
            anno.layoutImportance = [level isEqualToString:@"level1"]?MAXFLOAT:10.0f;
            anno.loc             = MaplyCoordinateMakeWithDegrees([dict[@"lon"] floatValue], [dict[@"lat"] floatValue]);
            anno.size            = CGSizeMake(30, 30);
            anno.userObject      = @{@"type": @"tongji", @"title": dict[@"name"], @"subTitle": [dict[@"stationid"] stringByAppendingFormat:@"-%@", dict[@"areaid"]]};
            anno.image           = newImage;
#endif
            [annos addObject:anno];
        }
    }
    
    return annos;
}

-(MapStatisticsBottomView *)statisticsView
{
    if (!_statisticsView) {
        //        _statisticsView = [[MapStatisticsBottomView alloc] initWithFrame:CGRectMake(0, self.backView.height, self.backView.width, self.backView.height)];
        _statisticsView = [MapStatisticsBottomView new];
        [self.view addSubview:_statisticsView];
        [_statisticsView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.width.and.height.mas_equalTo(self.view);
            make.top.mas_equalTo(self.view.mas_bottom);
        }];
    }
    
    return _statisticsView;
}

-(UIView *)logoPopView
{
    if (!_logoPopView) {
        _logoPopView = [UIView new];
        _logoPopView.backgroundColor = [UIColor blackColor];
        _logoPopView.layer.cornerRadius = 10;
        _logoPopView.layer.borderColor = [UIColor whiteColor].CGColor;
        _logoPopView.layer.borderWidth = 2.0;
        [self.navigationController.view addSubview:_logoPopView];
        [_logoPopView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.navigationController.view.mas_centerX);
            make.centerY.mas_equalTo(self.navigationController.view.mas_centerY).offset(-10);
            make.width.mas_equalTo(self.navigationController.view).multipliedBy(0.8);
            make.height.mas_equalTo(self.navigationController.view).multipliedBy(0.55);
        }];
        self.logoPopView.transform = CGAffineTransformMakeScale(0.0, 0.0);
        
        UIScrollView *sv = [UIScrollView new];
        [_logoPopView addSubview:sv];
        [sv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(_logoPopView);
        }];
        
        UIView *sv_sub = [UIView new];
        [sv addSubview:sv_sub];
        [sv_sub mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(sv);
            make.width.mas_equalTo(sv).offset(-1);
        }];
        
        UIButton *closeButton = [self createButtonWithImg:[UIImage imageNamed:@"关闭"] selectImg:nil];
        [sv_sub addSubview:closeButton];
        [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(sv_sub).offset(5);
            make.right.mas_equalTo(sv_sub).offset(-5);
            make.size.mas_equalTo(CGSizeMake(self.view.width*0.08, self.view.width*0.08));
        }];
        [closeButton addTarget:self action:@selector(closeLogoView) forControlEvents:UIControlEventTouchUpInside];
        
        NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:13];
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:@"      欢迎您使用 “蓝PI·寰宇” 气象数据3D展示系统，它将带您进入全新的气象数据视觉化体验！"];
        [text addAttributes:@{NSParagraphStyleAttributeName:paragraphStyle } range:NSMakeRange(0, text.length)];
        
        UILabel *titleView = [self createLabelWithFont:[Util modifyBoldSystemFontWithSize:18]];
        titleView.textColor = [UIColor whiteColor];
        titleView.numberOfLines = 0;
        titleView.attributedText = text;
        titleView.preferredMaxLayoutWidth = self.view.width * 0.8;
        [sv_sub addSubview:titleView];
        [titleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(closeButton.mas_bottom).offset(10);
            make.left.mas_equalTo(sv_sub).offset(15);
            make.right.mas_equalTo(sv_sub).offset(-10);
        }];
        [titleView sizeToFit];
        
        UIButton *sqView = [self createButtonWithImg:[UIImage imageNamed:@"qrcode_for_gh_9eb43db17ffb_430.jpg"] selectImg:nil];
        [sv_sub addSubview:sqView];
        [sqView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_greaterThanOrEqualTo(titleView.mas_bottom).offset(20);
            make.centerX.mas_equalTo(sv_sub.mas_centerX);
            make.width.mas_equalTo(sv_sub.mas_width).multipliedBy(0.5);
            make.height.mas_equalTo(sv_sub.mas_width).multipliedBy(0.5);
            make.height.width.mas_lessThanOrEqualTo(sv.mas_height).offset(-10);
        }];
        
        [sqView addTarget:self action:@selector(clickSqView) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *sqLbl = [self createLabelWithFont:[Util modifyBoldSystemFontWithSize:16]];
        sqLbl.textColor = [UIColor whiteColor];
        sqLbl.textAlignment = NSTextAlignmentCenter;
        sqLbl.text = @"微信公众号: BLUEPIANTS ";
        [sv_sub addSubview:sqLbl];
        [sqLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(sqView.mas_bottom).offset(10);
            make.left.right.mas_equalTo(sv_sub);
            make.height.mas_equalTo(20);
        }];
        
        [sv_sub mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(sqLbl.mas_bottom).offset(20);
        }];
    }
    
    return _logoPopView;
}

-(HEShareView *)shareView
{
    if (!_shareView) {
        _shareView = [[HEShareView alloc] init];
        _shareView.delegate = self;
        _shareView.backgroundColor = [UIColor colorWithRed:0.165 green:0.169 blue:0.173 alpha:1];
        [self.navigationController.view addSubview:_shareView];
        [_shareView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.navigationController.view.mas_bottom);
            make.left.right.mas_equalTo(self.navigationController.view);
            make.height.mas_equalTo(200);
        }];
    }
    
    return _shareView;
}

-(UIView *)dataFlowBottomView
{
    if (!_dataFlowBottomView) {
        CGFloat ht = 120 * SCREEN_SIZE.width/414.0 + 13;
        _dataFlowBottomView = [[HEDataFlowBottomView alloc] initWithFrame:CGRectMake(5, self.view.height - ht - 5, self.view.width - 10, ht)];
        _dataFlowBottomView.hidden = YES;
        [self.view addSubview:_dataFlowBottomView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDataFlowBottomView)];
        [_dataFlowBottomView addGestureRecognizer:tap];
    }
    
    return _dataFlowBottomView;
}

-(void)tapDataFlowBottomView
{
    if (autoRotate) {
        [globeViewC setAutoRotateInterval:0 degrees:0];
        autoRotate = NO;
    }
    else
    {
        [globeViewC setAutoRotateInterval:0.1 degrees:20];
        autoRotate = YES;
    }
}

#pragma mark - ViewConDelegate
-(void)setPlayButtonSelect:(BOOL)select
{
    self.playButton.selected = select;
}
-(void)setTimeText:(NSString *)text
{
    if (productAge) {
        NSDateFormatter *dateFormatter = [CWDataManager sharedInstance].dateFormatter;
        [dateFormatter setDateFormat:@"yyyy.MM.dd HH:mm"];
        NSDate *timeDate = [dateFormatter dateFromString:text];
        NSDate *date = [timeDate dateByAddingHours:[productAge integerValue]/[[productType componentsSeparatedByString:@","] count]];
        if (timeDate.year == date.year) {
            [dateFormatter setDateFormat:@"MM.dd HH:mm"];
        }
        else
        {
            [dateFormatter setDateFormat:@"yyyy.MM.dd HH:mm"];
        }
        
        NSString *timeAge = [dateFormatter stringFromDate:date];
        
        self.timeLabel.text = [text stringByAppendingFormat:@" - %@", timeAge];
    }
    else
    {
        self.timeLabel.text = text;
    }
    
}
-(void)setProgressValue:(CGFloat)radio
{
    self.progressView.value = radio;
}

#pragma mark - HEMapDataAnimDelegate
//-(void)willChangeObjs
//{
////    [self resetMapUI];
//    [self.theViewC removeObjects:self.comObjs];
//    self.comObjs = nil;
//}

-(void)changeObjs:(NSArray *)objs
{
    self.comObjs = objs;
}

-(void)clearObjs
{
    [self.theViewC removeObjects:self.comObjs];
    self.comObjs = nil;
}

#pragma makr - HESettingDelegate
-(void)show3DMap:(BOOL)flag
{
    show3D = flag;
    
    [self resetMapUI];
    [self makeMapViewAndDatas];
}
-(void)showMapLight:(BOOL)flag
{
    showLight = flag;
    if (show3D) {
        if (flag) {
            [self addSun];
        }
        else
        {
            [self.theViewC clearLights];
            [atmosObj removeFromViewC];
        }
    }
    
}
-(void)showLocation:(BOOL)flag
{
    showLocation = flag;
    if (!flag)
    {
        if (self.markerLocation) {
            [self.theViewC disableObjects:@[self.markerLocation] mode:MaplyThreadCurrent];
            [self.theViewC startChanges];
            
            [self.theViewC removeObjects:@[self.markerLocation] mode:MaplyThreadCurrent];
            
            // 修改bug : 删除markers时的黑色块
            sleep(0.2);
            INIT_WEAK_SELF;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSlef.theViewC endChanges];
            });
        }
        self.markerLocation = nil;
    }
}

-(void)changeMapType:(NSString *)mType
{
    mapDataType = mType;

    MaplyQuadImageTilesLayer *newLayer = [self createTileLayer];
    [self.theViewC addLayer:newLayer];
    
    tileLayer.enable = NO;
    [self.theViewC removeLayer:tileLayer];
    
    tileLayer = newLayer;
    tileLayer.enable = YES;
}

-(void)showDataFlow
{
    [self setData:@{@"fileMark":FILEMARK_DATAFLOW, @"name":@"数据流向"}];
}

-(void)locationed:(NSNotification *)noti
{
    NSError *error = [noti.userInfo objectForKey:@"error"];
    if (!error)
    {
        [self addUserLocationMarker];
    }
}

-(void)loadAnimFinished
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:noti_loadanim_ok object:nil];;
    self.mapAnimLogic.hideHUD = NO;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[CWLocationManager sharedInstance] updateLocation];
        
        [globeViewC setPosition:MaplyCoordinateMakeWithDegrees(0, 0) height:5];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [globeViewC animateToPosition:CHINA_CENTER_COOR height:initMapHeight heading:0 time:1.0];
        });
    });
}

#pragma mark - HEShareDelegate
-(void)clickShareCancel
{
    [self closeLogoView];
}

#pragma mark - HEMapAnimFlowDelegate
-(void)showFlowWeatherData:(NSDictionary *)data
{
    [self.dataFlowBottomView setupWithData:data];
}

#pragma mark - HEProductDelegate
-(void)setData:(NSDictionary *)data
{
    NSString *dataType = [data objectForKey:@"fileMark"];
    NSString *dataName = [data objectForKey:@"name"];
    
    productType = dataType;
    productName = dataName;
    productAge = [data objectForKey:@"timeValid"];
    [self refreshDataAndUI];
}

-(void)refreshDataAndUI
{
    if (!productName) {
        return;
    }
    
    NSString *dataType = productType;
    NSString *dataName = productName;
    
    [self.theViewC enableObjects:@[self.cityLabelsObj] mode:MaplyThreadAny];
    
    [self.mapAnimFlow hide];
    
    if ([dataType isEqualToString:FILEMARK_DATAFLOW]) {
        [self resetMapUI];
        
        self.bottomView.hidden = YES;
        self.expandButton.hidden = YES;
        self.dataFlowBottomView.hidden = NO;
        
        [self.mapAnimFlow show];
    }
    else
    {
        self.bottomView.hidden = NO;
        self.expandButton.hidden = NO;
        self.dataFlowBottomView.hidden = YES;
        
        self.animType = 0;
        if ([dataType rangeOfString:@"local"].location != NSNotFound) {
            isBottomFull = NO;
            
            [self resetMapUI];
            self.titleLbl.text = dataName;
            if ([dataType isEqualToString:FILEMARK_RADAR]) {
                isBottomFull = YES;
                self.animType = MapAnimTypeImage;
                
                [self.mapAnimLogic showImagesAnimation:MapImageTypeRain];
            }
            else if ([dataType isEqualToString:FILEMARK_CLOUD])
            {
                isBottomFull = YES;
                self.animType = MapAnimTypeImage;
                
                [self.mapAnimLogic showImagesAnimation:MapImageTypeCloud];
            }
            else if ([dataType isEqualToString:FILEMARK_NETEYE])
            {
                [self showNetEyesMarkers];
            }
            else if ([dataType isEqualToString:FILEMARK_TONGJI])
            {
                [self.theViewC startChanges];
                [self.theViewC disableObjects:@[self.cityLabelsObj] mode:MaplyThreadAny];
                [self.theViewC endChanges];
                [self showTongJiMarkers];
            }
        }
        else
        {
            isBottomFull = [dataType rangeOfString:@","].location != NSNotFound;
            
            [self resetMapUI];
            [self changeProduct_normal];
        }
        
        [self resetLocationToInit];
        self.indexButton.hidden = ![[CWDataManager sharedInstance].indexDict objectForKey:dataType];
    }
}

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [self.statisticsView hide];
    [self closeLogoView];
    if (self.dataFlowBottomView) {
        [self.dataFlowBottomView changeRotationToSize:size];
    }
}

@end
