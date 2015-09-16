//
//  ViewController.m
//  HelloEarth
//
//  Created by 卢大维 on 15/7/28.
//  Copyright (c) 2015年 weather. All rights reserved.
//

#import "ViewController.h"
//#import <WhirlyGlobeMaplyComponent/WhirlyGlobeComponent.h>
#import "WhirlyGlobeComponent.h"
#import "MyRemoteTileInfo.h"
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

#import "HEShareController.h"
#import "HESettingController.h"
#import "CWLocationManager.h"
#import "HELegendController.h"
#import "HEProductsController.h"
#import "UIView+Extra.h"
#import "HEMapDataAnimLogic.h"

#import "MBProgressHUD+Extra.h"
#import "HESplashController.h"
#import "UIImageView+AnimationCompletion.h"

#define VIEW_MARGIN self.view.width*0.04
#define EXPAND_MARGIN 12

#define CHINA_CENTER_COOR MaplyCoordinateMakeWithDegrees(104, 32)

NS_ENUM(NSInteger, MapAnimType)
{
    MapAnimTypeImage,
    MapAnimTypeData,
};

@interface ViewController ()<WhirlyGlobeViewControllerDelegate, HEMapAnimLogicDelegate, HEMapDataAnimDelegate, HESettingDelegate, HEProductDelegate>
{
    CGFloat globeHeight;
    
    CGFloat initMapHeight;
    NSArray *locPoints;
    
    MaplyAtmosphere *atmosObj;
    
    MPMoviePlayerViewController * player;
    
    // setting
    BOOL show3D,showLight,showLocation;
    WhirlyGlobeViewController *globeViewC;
    MaplyViewController *mapViewC;
    
    MaplyQuadImageTilesLayer *tileLayer;
    MaplyStarsModel *stars;
    
    // product data
    BOOL isBottomFull;
    NSString *productType;
    NSString *productName;
    
    UIImageView *loadingIV;
}

@property (nonatomic,strong) MaplyBaseViewController *theViewC;
//@property (nonatomic,strong) WhirlyGlobeViewController *theViewC;

@property (nonatomic,strong) HEMapDatas *mapDatas;
@property (nonatomic,copy) NSArray *comObjs;
@property (nonatomic,strong) HEMapDataAnimLogic *mapDataAnimLogic;

@property (nonatomic,strong) HEMapAnimLogic *mapAnimLogic;
@property (nonatomic,strong) MaplyComponentObject *markersObj;
@property (nonatomic,strong) MaplyComponentObject *markerLocation;

@property (nonatomic,assign) enum MapAnimType animType;

// UI
//@property (nonatomic,strong) UIView *topView;
@property (nonatomic,strong) UIButton *logoButton;

@property (nonatomic,strong) UIView *bottomView,*bottomContentView;

@property (nonatomic,strong) UIButton *playButton, *indexButton, *expandButton;
@property (nonatomic,strong) UISlider *progressView;
@property (nonatomic,strong) UILabel *titleLbl, *timeLabel;

@property (nonatomic,strong) UIControl *dimView;
@property (nonatomic,strong) UIView *logoPopView;

// 统计
@property (nonatomic,copy) NSDictionary *markerDatas;
@property (nonatomic)       NSInteger level;
@property (nonatomic,strong) MapStatisticsBottomView *statisticsView;

// 请求
@property (nonatomic,strong) AFHTTPRequestOperation *currentOperation;

@end

@implementation ViewController

// 状态栏样式
//-(UIStatusBarStyle)preferredStatusBarStyle
//{
//    return UIStatusBarStyleLightContent;
//}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    show3D = YES;
    showLight = YES;
    showLocation = NO;
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [self initViews];
    [self makeMapViewAndDatas];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationed:) name:noti_update_location object:nil];
    
    UIImageView *loadingBackView = [UIImageView new];
    loadingBackView.contentMode = UIViewContentModeScaleAspectFill;
    loadingBackView.image = [UIImage imageNamed:@"APP启动图－3.jpg"];
    [self.navigationController.view addSubview:loadingBackView];
    [loadingBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.navigationController.view);
    }];
    loadingIV = loadingBackView;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self showLoadingView];
    });
}

-(void)showLoadingView
{
    HESplashController *next = [HESplashController new];
    next.transitioningDelegate = next;
    [self.navigationController presentViewController:next animated:YES completion:^{
        [loadingIV removeFromSuperview];
        loadingIV = nil;
    }];
}

#pragma mark - inits
-(void)initDatas
{
    self.mapDatas = [[HEMapDatas alloc] initWithController:self.theViewC];
    self.mapDataAnimLogic = [[HEMapDataAnimLogic alloc] initWithMapDatas:self.mapDatas];
    self.mapDataAnimLogic.delegate = self;
    self.mapAnimLogic = [[HEMapAnimLogic alloc] initWithController:self.theViewC];
    self.mapAnimLogic.delegate = self;
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
            mapViewC.doubleTapZoomGesture = true;
            mapViewC.twoFingerTapGesture = true;
            //        mapViewC.delegate = self;
        }
        
        self.theViewC = mapViewC;
    }
    [self.view addSubview:self.theViewC.view];
    [self.view sendSubviewToBack:self.theViewC.view];
    self.theViewC.view.frame = self.view.bounds;
    self.theViewC.view.layer.shadowOffset = CGSizeMake(1, 1);
    self.theViewC.view.layer.shadowColor = [[UIColor greenColor] colorWithAlphaComponent:0.3].CGColor;
    [self addChildViewController:self.theViewC];
    
    NSString *baseCacheDir =
    [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)
     objectAtIndex:0];
    NSString *aerialTilesCacheDir = [NSString stringWithFormat:@"%@/osmtiles/",baseCacheDir];
    int maxZoom = 16;
    
    if (!tileLayer) {
        MyRemoteTileInfo *myTileInfo = [[MyRemoteTileInfo alloc] initWithBaseURL:@"http://api.tiles.mapbox.com/v4/ludawei.ndkap6n1/" ext:@"png" minZoom:0 maxZoom:maxZoom];
        
        MaplyRemoteTileSource *tileSource = [[MaplyRemoteTileSource alloc] initWithInfo:myTileInfo];
        tileSource.cacheDir = aerialTilesCacheDir;
        MaplyQuadImageTilesLayer *layer = [[MaplyQuadImageTilesLayer alloc] initWithCoordSystem:tileSource.coordSys tileSource:tileSource];
        layer.handleEdges = false;
        layer.coverPoles = true;
        layer.maxTiles = 256;
        //    layer.animationPeriod = 6.0;
        //    layer.singleLevelLoading = true;
        //    layer.drawPriority = 0;
        
        tileLayer = layer;
    }
    [self.theViewC addLayer:tileLayer];
    
    self.theViewC.frameInterval = 2;
    self.theViewC.threadPerLayer = true;
    
    if (show3D) {
        float minHeight,maxHeight;
        [globeViewC getZoomLimitsMin:&minHeight max:&maxHeight];
        [globeViewC setZoomLimitsMin:minHeight max:3.0];
        
        initMapHeight = globeViewC.height;
    }
    else
    {
        mapViewC.heading = 0;
        mapViewC.height = M_PI/2;
        
        initMapHeight = mapViewC.height;
    }
    
    [self addCountry_china];
}

-(void)makeMapViewAndDatas
{
    if (!self.theViewC || (show3D && mapViewC) || (!show3D && globeViewC)) {
        [self initMapView];
        [self initDatas];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (show3D) {
                globeViewC.heading = 0;
                globeViewC.keepNorthUp = true;
                [globeViewC animateToPosition:CHINA_CENTER_COOR time:0.3];
                //                [globeViewC setAutoRotateInterval:0.2 degrees:20];
                
                [self addStars:@"starcatalog_orig"];
                if (showLight) {
                    [self addSun];
                }
            }
            else
            {
                [mapViewC animateToPosition:CHINA_CENTER_COOR height:initMapHeight time:0.3];
            }
            
            // 重新设置地图显示
            [self changeProduct_normal];
            
            if (showLocation) {
                [self addUserLocationMarker];
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
}

-(void)initTopViews
{
    UIView *view = [[UIView alloc] initWithFrame:self.navigationController.navigationBar.bounds];
//    self.topView = view;
    
    NSArray *images = @[@[@"未选中－1", @"选中－1"],
                        @[@"产品－未选中", @"产品－选中"],
                        @[@"分享－未选中", @"分享－选中"],
                        @[@"回位－未选中", @"回位－选中"],
                        @[@"设置－未选中", @"设置－选中"]];
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
        if (i == 0) {
            self.logoButton = button;
        }
    }
    
    lastButton = nil;
    
    self.navigationItem.titleView = view;
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
        make.height.mas_equalTo(32);
        make.right.mas_equalTo(-margin);
    }];
    self.titleLbl = titleLbl;
    
    self.indexButton = [self createButtonWithImg:[UIImage imageNamed:@"图例"] selectImg:nil];
    [view addSubview:self.indexButton];
    [self.indexButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-10);
        make.bottom.mas_equalTo(titleLbl.mas_bottom);
        make.width.mas_equalTo(50);
        make.top.mas_greaterThanOrEqualTo(5);
    }];
    [self.indexButton addTarget:self action:@selector(clickLegend) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *bView = [UIView new];
//    bView.backgroundColor = [UIColor colorWithRed:45/255.0 green:40/255.0 blue:16/255.0 alpha:0.1];
    [view addSubview:bView];
    [bView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLbl.mas_bottom);
        make.bottom.mas_equalTo(view.mas_bottom).offset(-9);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(view);
    }];
    
    self.timeLabel = [self createLabelWithFont:[Util modifyFontWithName:@"Helvetica" size:14]];
    self.timeLabel.textColor = [UIColor whiteColor];
    [bView addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(5);
        make.left.mas_equalTo(margin+buttonWidth);
        make.height.mas_greaterThanOrEqualTo(15);
    }];
    
    UIImageView *slideBack = [UIImageView new];
    slideBack.userInteractionEnabled = YES;
    slideBack.image = [UIImage imageNamed:@"刻度－20"];
    [bView addSubview:slideBack];
    [slideBack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.timeLabel.mas_left);
        make.top.mas_equalTo(self.timeLabel.mas_bottom).offset(5);
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
        make.top.mas_equalTo(self.timeLabel.mas_bottom);
        make.bottom.mas_equalTo(slideBack.mas_bottom).offset(5);
//        make.width.mas_equalTo(buttonWidth);
        make.right.mas_equalTo(self.timeLabel.mas_left);
    }];
    
    self.progressView = [[UISlider alloc] init];
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
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setBackgroundImage:[Util createImageWithColor:[UIColor colorWithWhite:0 alpha:0.3] width:1 height:(STATUS_HEIGHT+SELF_NAV_HEIGHT)] forBarMetrics:UIBarMetricsDefault];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.statisticsView.hidden = YES;
    
    if (isBottomFull) {
        [self setFullBottomLayout];
    }
    else
    {
        // 默认显示一半的
        [self setHalfBottomLayout];
    }
    
    [self.view layoutIfNeeded];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
//    [self closeLogoView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)changeProduct_normal
{
    if (!productName) {
        return;
    }
    
    self.titleLbl.text = productName;

    [self resetMapUI];
    
    [MBProgressHUD showHUDInView:self.view andText:@"请求数据..."];
    NSString *url = [Util requestEncodeWithString:[NSString stringWithFormat:@"http://scapi.weather.com.cn/weather/micapsfile?fileMark=%@&isChina=true&", productType] appId:@"f63d329270a44900" privateKey:@"sanx_data_99"];
    
    [self.currentOperation cancel];
    self.currentOperation = [[PLHttpManager sharedInstance].manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (responseObject && [responseObject isKindOfClass:[NSArray class]]) {
            if (isBottomFull) {
                NSArray *types = [productType componentsSeparatedByString:@","];
                if (types.count == [responseObject count]) {
                    for (NSInteger i=0; i<types.count; i++) {
                        [[CWDataManager sharedInstance] setMapdata:[responseObject objectAtIndex:i] fileMark:[types objectAtIndex:i]];
                    }
                }
                
                self.animType = MapAnimTypeData;
                [self.mapDataAnimLogic showProductWithTypes:types];
            }
            else
            {
                [[CWDataManager sharedInstance] setMapdata:[responseObject firstObject] fileMark:productType];
                self.comObjs = [self.mapDatas changeType:productType];
            }
        }
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
}

-(void)resetMapUI
{
    [self.theViewC removeObjects:self.comObjs];
    self.comObjs = nil;
    
    [self.mapAnimLogic clear];
    [self.theViewC removeObject:self.mapAnimLogic.stickersObj];
    self.mapAnimLogic.stickersObj = nil;
    
    if (self.markersObj) {
        [self.theViewC disableObjects:@[self.markersObj] mode:MaplyThreadCurrent];
        [self.theViewC startChanges];
        
        [self.theViewC removeObjects:@[self.markersObj] mode:MaplyThreadCurrent];
        
        // 修改bug : 删除markers时的黑色块
        sleep(0.2);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.theViewC endChanges];
        });
    }
    self.markersObj = nil;
    
    if (!self.statisticsView.hidden) {
        self.statisticsView.hidden = YES;
    }
}

#pragma mark - map actions
- (void)addCountry_china
{
    NSDictionary *vectorDict = @{
                                 kMaplyColor: [UIColor whiteColor],
                                 kMaplySelectable: @(true),
                                 kMaplyVecWidth: @(4.0)};
    
    // handle this in another thread
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0),
                   ^{
                       NSArray *allOutlines = [[NSBundle mainBundle] pathsForResourcesOfType:@"geojson" inDirectory:nil];
                       
                       for (NSString *outlineFile in allOutlines)
                       {
                           NSData *jsonData = [NSData dataWithContentsOfFile:outlineFile];
                           if (jsonData)
                           {
                               MaplyVectorObject *wgVecObj = [MaplyVectorObject VectorObjectFromGeoJSON:jsonData];
                               
                               // the admin tag from the country outline geojson has the country name ­ save
                               NSString *vecName = [[wgVecObj attributes] objectForKey:@"name"];
                               wgVecObj.userObject = vecName;
                               
                               // add the outline to our view
                               [self.theViewC addVectors:[NSArray arrayWithObject:wgVecObj] desc:vectorDict];
                               // If you ever intend to remove these, keep track of the MaplyComponentObjects above.
                           }
                       }
                       
                   });
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
    if (location) {
        if (self.markerLocation) {
            [self.theViewC removeObject:self.markerLocation];
        }
        
        location = [location locationMarsFromEarth];
        
        UIImage *img = [UIImage imageNamed:@"map_anni_point"];
        MaplyScreenMarker *anno = [[MaplyScreenMarker alloc] init];
        anno.loc             = MaplyCoordinateMakeWithDegrees(location.coordinate.longitude, location.coordinate.latitude);
        anno.size            = img.size;//CGSizeMake(30, 30);
        //    anno.userObject      = @{@"type": @"eyes", @"title": dict[@"name"], @"subTitle": dict[@"url"]};
        anno.image = img;
        
        self.markerLocation = [self.theViewC addScreenMarkers:@[anno] desc:@{kMaplyFade: @(1.0), kMaplyDrawPriority: @(kMaplyModelDrawPriorityDefault+200)}];
    }
    
}

-(void)addTongJiMarkers
{
    //    CGFloat zoomLevel = [self.theViewC height];
    //    NSMutableArray *annos = [NSMutableArray array];
    //
    //    NSInteger level = 1;
    //    [annos addObjectsFromArray:[self annotationsWithServerDatas:@"level1"]];
    //
    //    if (zoomLevel >= 2.5)
    //    {
    //        level = 2;
    //        [annos addObjectsFromArray:[self annotationsWithServerDatas:@"level2"]];
    //    }
    //
    //    if (zoomLevel >= 4.5) {
    //        level = 3;
    //        [annos addObjectsFromArray:[self annotationsWithServerDatas:@"level3"]];
    //    }
    //
    //    if (level == self.level) {
    //        return;
    //    }
    //
    //    self.level = level;
    
    [MBProgressHUD showHUDInView:self.view andText:@"处理中..."];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *annos = [self annotationsWithServerDatas:@"level3"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self resetMapUI];
            self.markersObj = [self.theViewC addScreenMarkers:annos desc:@{kMaplyFade: @(1.0), kMaplyDrawPriority: @(kMaplyModelDrawPriorityDefault+200)}];
        });
    });
}

-(void)setMarkersObj:(MaplyComponentObject *)markersObj
{
    _markersObj = markersObj;
    if (markersObj && [productType isEqualToString:@"local_tongji"]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        });

    }
}


-(void)addNetEyeMarkers:(NSArray *)datas
{
    NSMutableArray *annos = [NSMutableArray arrayWithCapacity:datas.count];
    for (NSInteger i=0; i<datas.count; i++) {
        NSDictionary *dict = [datas objectAtIndex:i];
        
        MaplyScreenMarker *anno = [[MaplyScreenMarker alloc] init];
        anno.loc             = MaplyCoordinateMakeWithDegrees([dict[@"lon"] floatValue], [dict[@"lat"] floatValue]);
        anno.size            = CGSizeMake(30, 30);
        anno.userObject      = @{@"type": @"eyes", @"title": dict[@"name"], @"subTitle": dict[@"url"]};
        anno.image           = [UIImage imageNamed:@"weather_camera_icon"];
        [annos addObject:anno];
    }
    
    [self resetMapUI];
    self.markersObj = [self.theViewC addScreenMarkers:annos desc:@{kMaplyFade: @(1.0), kMaplyDrawPriority: @(kMaplyModelDrawPriorityDefault+200)}];
}

#pragma mark - Whirly Globe Delegate
- (void)globeViewController:(WhirlyGlobeViewController *)viewC layerDidLoad:(WGViewControllerLayer *)layer
{
    LOG(@"layerDidLoad");
}

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
    }
}

#pragma mark - private actions
- (void)doVideoPlayFinished:(id)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    player = nil;
}

-(void)clickMenu:(UIButton *)button
{
    switch (button.tag) {
        case 0:
        {
            // logo
            if (self.logoPopView.hidden) {
                button.selected = !button.selected;
                
                self.theViewC.view.userInteractionEnabled = NO;
                
                self.logoPopView.hidden = NO;
                self.logoPopView.alpha = 1;
                self.dimView.hidden = NO;
                self.dimView.alpha = 0;
                [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:0 animations:^{
                    self.logoPopView.transform = CGAffineTransformIdentity;
                    self.dimView.alpha = 1;
                } completion:^(BOOL finished) {
                    
                }];
            }
            else
            {
                [self closeLogoView];
            }
            
            break;
        }
        case 1:
        {
            // products
            HEProductsController *next = [HEProductsController new];
            next.delegate = self;
            next.fileMark = productType;
            [self.navigationController pushViewController:next animated:YES];
            break;
        }
        case 2:
        {
            // share
            HEShareController *next = [HEShareController new];
            UIImage *mapImage = [self.theViewC snapshot];
            self.theViewC.view.hidden = YES;
            UIImage *viewImage = [self.navigationController.view viewShot];
            self.theViewC.view.hidden = NO;
            next.image = [Util addImage:viewImage toImage:mapImage toRect:CGRectMake(0, 0, mapImage.size.width, mapImage.size.height)];
            [self.navigationController pushViewController:next animated:YES];
            break;
        }
        case 3:
        {
            // reset
            if (show3D) {
                [globeViewC animateToPosition:CHINA_CENTER_COOR height:initMapHeight heading:0 time:0.3];
            }
            else
            {
                [mapViewC animateToPosition:CHINA_CENTER_COOR height:initMapHeight time:0.3];
            }
            break;
        }
        case 4:
        {
            // setting
            UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            HESettingController *next = (HESettingController *)[board instantiateViewControllerWithIdentifier:@"setting"];
            next.delegate = self;
            next.set3D = show3D;
            next.setLight = showLight;
            next.setLocation = showLocation;
            [self.navigationController pushViewController:next animated:YES];
            break;
        }
        default:
        break;
    }
}

-(void)showNetEyesMarkers
{
    [self.currentOperation cancel];
    self.currentOperation = [[PLHttpManager sharedInstance].manager GET:@"http://decision.tianqi.cn//data/video/videoweather.html" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (responseObject) {
            self.markerDatas = (NSDictionary *)responseObject;
            [self addNetEyeMarkers:responseObject];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

-(void)showTongJiMarkers
{
    NSString *url = [Util requestEncodeWithString:@"http://scapi.weather.com.cn/weather/stationinfo?" appId:@"f63d329270a44900" privateKey:@"sanx_data_99"];
    
    [self.currentOperation cancel];
    self.currentOperation = [[PLHttpManager sharedInstance].manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (responseObject) {
            self.markerDatas = (NSDictionary *)responseObject;
            [self addTongJiMarkers];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
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
    if ([UIApplication sharedApplication].statusBarHidden) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        
        if (isBottomFull)
        {
            [self setFullBottomLayout];
        }
    }
    else
    {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        
        if (isBottomFull) {
            [self setHalfBottomLayout];
        }
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
    
    [self.bottomContentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.bottomView);
    }];
    
    [self.indexButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-VIEW_MARGIN);
        make.bottom.mas_equalTo(self.titleLbl.mas_bottom);
        make.width.mas_equalTo(50);
        make.top.mas_greaterThanOrEqualTo(5);
    }];
}

-(void)setHalfBottomLayout
{
    [self.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.bottomView.height-MAX(self.titleLbl.height, self.expandButton.height+EXPAND_MARGIN*2)+5);
    }];
    
    CGFloat topModify = ((self.expandButton.height+EXPAND_MARGIN*2)-self.titleLbl.height)/2;
    UIEdgeInsets padding = UIEdgeInsetsMake(topModify, 0, 0, 0);
    [self.bottomContentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.bottomView).insets(padding);
    }];
    
    [self.indexButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.titleLbl.mas_centerY);
        make.right.mas_equalTo(self.expandButton.mas_left).offset(-VIEW_MARGIN);
        make.width.mas_equalTo(50);
        make.top.mas_greaterThanOrEqualTo(5);
    }];
}

-(void)clickLegend
{
    HELegendController *next = [HELegendController new];
    [self.navigationController pushViewController:next animated:YES];
}

-(void)closeLogoView
{
    self.logoButton.selected = NO;
    self.theViewC.view.userInteractionEnabled = YES;
    
    if (!self.logoPopView.hidden) {
        
        self.dimView.alpha = 1;
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.logoPopView.transform = CGAffineTransformMakeScale(0.01, 0.01);
            self.logoPopView.alpha = 0;
            self.dimView.alpha = 0;
        } completion:^(BOOL finished) {
            self.logoPopView.hidden = YES;
            self.dimView.hidden = YES;
        }];
    }
}

-(void)clickSqView
{
    NSString *str = @"weixin://qr/wTnL0yLEQX8_rWaw92zT";//@"http://weixin.qq.com/r/wTnL0yLEQX8_rWaw92zT";//
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
}

#pragma mark - tool methods
-(NSArray *)annotationsWithServerDatas:(NSString *)level
{
    NSArray *datas = [self.markerDatas objectForKey:level];
    
    NSMutableArray *annos = [NSMutableArray arrayWithCapacity:datas.count];
    for (NSInteger i=0; i<datas.count; i++) {
        NSDictionary *dict = [datas objectAtIndex:i];
        
        UIImage *newImage = [Util drawText:dict[@"name"] inImage:[UIImage imageNamed:@"circle39"] font:[UIFont systemFontOfSize:12] textColor:[UIColor whiteColor]];
        
        MaplyScreenMarker *anno = [[MaplyScreenMarker alloc] init];
        anno.layoutImportance = 1.0f;
        anno.loc             = MaplyCoordinateMakeWithDegrees([dict[@"lon"] floatValue], [dict[@"lat"] floatValue]);
        anno.size            = CGSizeMake(30, 30);
        anno.userObject      = @{@"type": @"tongji", @"title": dict[@"name"], @"subTitle": [dict[@"stationid"] stringByAppendingFormat:@"-%@", dict[@"areaid"]]};
        anno.image           = newImage;
        [annos addObject:anno];
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
            make.height.mas_equalTo(self.navigationController.view).multipliedBy(0.5);
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
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:@"      欢迎您使用 “蓝π蚂蚁” 气象数据3D展示系统，它将带您进入全新的气象数据视觉化体验！"];
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
        
        [sv_sub mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(sqView.mas_bottom).offset(20);
        }];
    }
    
    return _logoPopView;
}

#pragma mark - ViewConDelegate
-(void)setPlayButtonSelect:(BOOL)select
{
    self.playButton.selected = select;
}
-(void)setTimeText:(NSString *)text
{
    self.timeLabel.text = text;
}
-(void)setProgressValue:(CGFloat)radio
{
    self.progressView.value = radio;
}

#pragma mark - HEMapDataAnimDelegate
-(void)willChangeObjs
{
    [self resetMapUI];
}

-(void)changeObjs:(NSArray *)objs
{
    self.comObjs = objs;
}

#pragma makr - HESettingDelegate
-(void)show3DMap:(BOOL)flag
{
    show3D = flag;
    
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
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.theViewC endChanges];
            });
        }
        self.markerLocation = nil;
    }
}

-(void)locationed:(NSNotification *)noti
{
    NSError *error = [noti.userInfo objectForKey:@"error"];
    if (!error)
    {
        [self addUserLocationMarker];
    }
}

#pragma makr - HEProductDelegate
-(void)setData:(NSDictionary *)data
{
    NSString *dataType = [data objectForKey:@"fileMark"];
    NSString *dataName = [data objectForKey:@"name"];
    
    if ([dataType rangeOfString:@"local"].location != NSNotFound) {
        productType = dataType;
        productName = dataName;
        isBottomFull = NO;
        
        [self resetMapUI];
        self.titleLbl.text = dataName;
        if ([dataType isEqualToString:@"local_radar"]) {
            isBottomFull = YES;
            
            [self.mapAnimLogic showImagesAnimation:MapImageTypeRain];
        }
        else if ([dataType isEqualToString:@"local_cloud"])
        {
            isBottomFull = YES;
            
            [self.mapAnimLogic showImagesAnimation:MapImageTypeCloud];
        }
        else if ([dataType isEqualToString:@"local_neteye"])
        {
            [self showNetEyesMarkers];
        }
        else if ([dataType isEqualToString:@"local_tongji"])
        {
            [self showTongJiMarkers];
        }
    }
    else
    {
        isBottomFull = [dataType rangeOfString:@","].location != NSNotFound;
        productType = dataType;
        productName = dataName;
        
        [self changeProduct_normal];
    }
}

@end
