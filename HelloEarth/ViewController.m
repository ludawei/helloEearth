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

@interface ViewController ()<WhirlyGlobeViewControllerDelegate, UIActionSheetDelegate>
{
    CGFloat globeHeight;
    BOOL loadOk;
    
    NSArray *locPoints;
    
    MPMoviePlayerViewController * player;
}

@property (nonatomic,strong) WhirlyGlobeViewController *theViewC;

@property (nonatomic,copy) NSArray *titles;

@property (nonatomic,strong) HEMapDatas *mapDatas;
@property (nonatomic,copy) NSArray *comObjs;

@property (nonatomic,strong) HEMapAnimLogic *mapAnimLogic;
@property (nonatomic,strong) MaplyComponentObject *markersObj;

// 统计
@property (nonatomic,copy) NSDictionary *markerDatas;
@property (nonatomic)       NSInteger level;
@property (nonatomic,strong) MapStatisticsBottomView *statisticsView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSArray *paths = [[NSBundle mainBundle] pathsForResourcesOfType:@"json" inDirectory:nil];
    
    NSMutableArray *arr = [NSMutableArray array];
    for (NSString *path in paths) {
        NSString *title = [[path lastPathComponent] stringByDeletingPathExtension];
        if ([title isEqualToString:@"china"]) {
            continue;
        };
        [arr addObject:[[path lastPathComponent] stringByDeletingPathExtension]];
    }
    self.titles = arr;
    
    self.theViewC = [[WhirlyGlobeViewController alloc] init];
    self.theViewC.delegate = self;
    [self.view addSubview:self.theViewC.view];
    self.theViewC.view.frame = self.view.bounds;
    self.theViewC.view.layer.shadowOffset = CGSizeMake(1, 1);
    self.theViewC.view.layer.shadowColor = [[UIColor greenColor] colorWithAlphaComponent:0.3].CGColor;
    [self addChildViewController:self.theViewC];
    
    NSString *baseCacheDir =
    [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)
     objectAtIndex:0];
    NSString *aerialTilesCacheDir = [NSString stringWithFormat:@"%@/osmtiles/",baseCacheDir];
    int maxZoom = 16;
    
    MyRemoteTileInfo *myTileInfo = [[MyRemoteTileInfo alloc] initWithBaseURL:@"http://api.tiles.mapbox.com/v4/ludawei.n1ppo21a/" ext:@"png" minZoom:0 maxZoom:maxZoom];
    
    MaplyRemoteTileSource *tileSource = [[MaplyRemoteTileSource alloc] initWithInfo:myTileInfo];
    
//    MyRemoteTileInfo *myTileInfo = [[MyRemoteTileInfo alloc] initWithBaseURL:@"http://otile1.mqcdn.com/tiles/1.0.0/osm/"  ext:@"png" minZoom:0 maxZoom:maxZoom];
//    
//    MaplyRemoteTileSource *tileSource = [[MaplyRemoteTileSource alloc] initWithInfo:myTileInfo];
    
    tileSource.cacheDir = aerialTilesCacheDir;
    MaplyQuadImageTilesLayer *layer = [[MaplyQuadImageTilesLayer alloc] initWithCoordSystem:tileSource.coordSys tileSource:tileSource];
    layer.handleEdges = false;
    layer.coverPoles = true;
    layer.maxTiles = 256;
//    layer.animationPeriod = 6.0;
//    layer.singleLevelLoading = true;
//    layer.drawPriority = 0;

    [self.theViewC addLayer:layer];
    self.theViewC.frameInterval = 2;
    self.theViewC.threadPerLayer = true;
    float minHeight,maxHeight;
    [self.theViewC getZoomLimitsMin:&minHeight max:&maxHeight];
    [self.theViewC setZoomLimitsMin:minHeight max:3.0];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"选择" style:UIBarButtonItemStyleDone target:self action:@selector(clickNavRight)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"图层" style:UIBarButtonItemStyleDone target:self action:@selector(clickNavLeft)];
    
    [self addCountries];
    
    self.mapDatas = [[HEMapDatas alloc] initWithController:self.theViewC];
    self.mapAnimLogic = [[HEMapAnimLogic alloc] initWithController:self.theViewC];
}

-(void)changetitle:(NSString *)title
{
    self.title = title;

    [self resetMapUI];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.comObjs = [self.mapDatas changetitle:title];
    });
}

- (void)addCountries
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
    if (!self.theViewC)
        return;
    
    // Load the stars
    NSString *fileName = [[NSBundle mainBundle] pathForResource:inFile ofType:@"txt"];
    if (fileName)
    {
        MaplyStarsModel *stars = [[MaplyStarsModel alloc] initWithFileName:fileName];
        stars.image = [UIImage imageNamed:@"star_background"];
        [stars addToViewC:self.theViewC date:[NSDate date] desc:nil mode:MaplyThreadCurrent];
    }
}

- (void)addSun
{
    if (!self.theViewC)
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
    
    // And a model, because why not
//    if (1)
//    {
//        MaplyShapeSphere *sphere = [[MaplyShapeSphere alloc] init];
//        sphere.center = [sun asPosition];
//        sphere.radius = 0.2;
//        sphere.height = 4.0;
//        [self.theViewC addShapes:@[sphere] desc:
//                  @{kMaplyColor: [UIColor yellowColor],
//                    kMaplyShader: kMaplyShaderDefaultTriNoLighting}];
//    }
//    else {
//        MaplyBillboard *bill = [[MaplyBillboard alloc] init];
//        MaplyCoordinate centerGeo = [sun asPosition];
//        bill.center = MaplyCoordinate3dMake(centerGeo.x, centerGeo.y, 5.4*EarthRadius);
//        bill.selectable = false;
//        bill.screenObj = [[MaplyScreenObject alloc] init];
//        UIImage *globeImage = [UIImage imageNamed:@"SunImage"];
//        [bill.screenObj addImage:globeImage color:[UIColor whiteColor] size:CGSizeMake(0.9, 0.9)];
//        sunObj = [globeViewC addBillboards:@[bill] desc:@{kMaplyBillboardOrient: kMaplyBillboardOrientEye,kMaplyDrawPriority: @(kMaplySunDrawPriorityDefault)} mode:MaplyThreadAny];
//    }
    
    // Position for the moon
//    MaplyMoon *moon = [[MaplyMoon alloc] initWithDate:[NSDate date]];
//    if (UseMoonSphere)
//    {
//        MaplyShapeSphere *sphere = [[MaplyShapeSphere alloc] init];
//        sphere.center = [moon asCoordinate];
//        sphere.radius = 0.2;
//        sphere.height = 4.0;
//        moonObj = [globeViewC addShapes:@[sphere] desc:
//                   @{kMaplyColor: [UIColor grayColor],
//                     kMaplyShader: kMaplyShaderDefaultTriNoLighting}];
//    } else {
//        MaplyBillboard *bill = [[MaplyBillboard alloc] init];
//        MaplyCoordinate3d centerGeo = [moon asPosition];
//        bill.center = MaplyCoordinate3dMake(centerGeo.x, centerGeo.y, 5.4*EarthRadius);
//        bill.selectable = false;
//        bill.screenObj = [[MaplyScreenObject alloc] init];
//        UIImage *moonImage = [UIImage imageNamed:@"moon"];
//        [bill.screenObj addImage:moonImage color:[UIColor colorWithWhite:moon.illuminatedFraction alpha:1.0] size:CGSizeMake(0.75, 0.75)];
//        moonObj = [globeViewC addBillboards:@[bill] desc:@{kMaplyBillboardOrient: kMaplyBillboardOrientEye, kMaplyDrawPriority: @(kMaplyMoonDrawPriorityDefault)} mode:MaplyThreadAny];
//    }
    
    // And some atmosphere, because the iDevice fill rate is just too fast
    MaplyAtmosphere *atmosObj = [[MaplyAtmosphere alloc] initWithViewC:self.theViewC];
    [atmosObj setSunPosition:[sun getDirection]];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (loadOk) {
        return;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.theViewC.heading = 0;
        self.theViewC.keepNorthUp = true;
        [self.theViewC animateToPosition:MaplyCoordinateMakeWithDegrees(116.46, 39.92) time:0.3];
//        [self.theViewC setAutoRotateInterval:0.2 degrees:20];
        
        [self addSun];
        [self addStars:@"starcatalog_orig"];
    });
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (loadOk) {
        return;
    }
    
    [self changetitle:[self.titles firstObject]];
    
    self.statisticsView.hidden = YES;
    
    loadOk = YES;
}

#pragma mark - Whirly Globe Delegate
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)globeViewController:(WhirlyGlobeViewController *)viewC layerDidLoad:(WGViewControllerLayer *)layer
{
    viewC.heading = 0;
    viewC.keepNorthUp = true;
}

- (void)globeViewControllerDidStartMoving:(WhirlyGlobeViewController *)viewC userMotion:(bool)userMotion
{
    NSLog(@"Started moving");
}

- (void)globeViewController:(WhirlyGlobeViewController *)viewC didStopMoving:(MaplyCoordinate *)corners userMotion:(bool)userMotion
{
    NSLog(@"Stopped moving %f, %f", viewC.height, viewC.heading);
    
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

- (void)doVideoPlayFinished:(id)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    player = nil;
}

-(void)clickNavLeft
{
    UIActionSheet *actSheet = [[UIActionSheet alloc] initWithTitle:@"请选择" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:nil];
    actSheet.tag = 1000;
    [actSheet addButtonWithTitle:@"雷达图"];
    [actSheet addButtonWithTitle:@"云图"];
    [actSheet addButtonWithTitle:@"网眼"];
    [actSheet addButtonWithTitle:@"天气统计"];
//    [actSheet addButtonWithTitle:@""];
    [actSheet showInView:self.view];
}

-(void)clickNavRight
{
    UIActionSheet *actSheet = [[UIActionSheet alloc] initWithTitle:@"请选择" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:nil];
    actSheet.tag = 1001;
    for (NSString *title in self.titles) {
        [actSheet addButtonWithTitle:title];
    }
    [actSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    if (actionSheet.tag == 1001) {
        NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
        [self changetitle:title];
    }
    else if (actionSheet.tag == 1000)
    {
        [self resetMapUI];
        
        NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
        
        self.title = title;
        if ([title isEqualToString:@"雷达图"]) {
            [self.mapAnimLogic showImagesAnimation:MapImageTypeRain];
        }
        else if ([title isEqualToString:@"云图"]) {
            [self.mapAnimLogic showImagesAnimation:MapImageTypeCloud];
        }
        else if ([title isEqualToString:@"网眼"]) {
            UIActivityIndicatorView *act = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [act startAnimating];
            self.navigationItem.titleView = act;
            
            [self showNetEyesMarkers];
        }
        else if ([title isEqualToString:@"天气统计"])
        {
            UIActivityIndicatorView *act = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [act startAnimating];
            self.navigationItem.titleView = act;
            
            [self showTongJiMarkers];
        }
    }
}

-(void)resetMapUI
{
    [self.theViewC removeObjects:self.comObjs];
    self.comObjs = nil;
    
    [self.mapAnimLogic hide];
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

-(void)showNetEyesMarkers
{
    [[PLHttpManager sharedInstance].manager GET:@"http://decision.tianqi.cn//data/video/videoweather.html" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
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
    
    [[PLHttpManager sharedInstance].manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (responseObject) {
            self.markerDatas = (NSDictionary *)responseObject;
            [self addTongJiMarkers];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
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
    
    self.navigationItem.titleView = nil;
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
    
    [self resetMapUI];
    self.markersObj = [self.theViewC addScreenMarkers:[self annotationsWithServerDatas:@"level3"] desc:@{kMaplyFade: @(1.0), kMaplyDrawPriority: @(kMaplyModelDrawPriorityDefault+200)}];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.navigationItem.titleView = nil;
    });
}

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
@end
