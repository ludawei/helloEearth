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

#define MK_CHINA_CENTER_REGION MKCoordinateRegionMake(CLLocationCoordinate2DMake(33.2, 105.0), MKCoordinateSpanMake(42, 64))

@interface ViewController ()<WhirlyGlobeViewControllerDelegate, UIActionSheetDelegate>
{
    CGFloat globeHeight;
    
    NSArray *locPoints;
}

@property (nonatomic,strong) WhirlyGlobeViewController *theViewC;

@property (nonatomic,copy) NSArray *titles;
@property (nonatomic,copy) NSDictionary *data;
@property (nonatomic,copy) NSArray *areas;

@property (nonatomic,strong) NSMutableArray *comObjs, *vects, *descs;
@property (nonatomic,strong) MaplyComponentObject *stickersObj,*markersObj;

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
    layer.singleLevelLoading = true;
//    layer.drawPriority = 0;

    [self.theViewC addLayer:layer];
    self.theViewC.frameInterval = 2;
    self.theViewC.threadPerLayer = true;
    float minHeight,maxHeight;
    [self.theViewC getZoomLimitsMin:&minHeight max:&maxHeight];
    [self.theViewC setZoomLimitsMin:minHeight max:3.0];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"选择" style:UIBarButtonItemStyleDone target:self action:@selector(clickNavRight)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"图层" style:UIBarButtonItemStyleDone target:self action:@selector(clickNavLeft)];
    
    self.comObjs = [NSMutableArray array];
    
    [self addCountries];
    
    [self initBottomViews];
}

-(void)changetitle:(NSString *)title
{
    self.title = title;
    
    self.data = nil;
    self.areas = nil;
    
    [self initData:title];
    [self setupLayer];
}

-(void)initData:(NSString *)name
{
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:path];
    
    id data = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    
    if ([data isKindOfClass:[NSArray class]]) {
        self.areas = data;
    }
    else
    {
        self.data = data;
    }
}

-(void)setupLayer
{
    [self resetMapUI];
    
    if (self.data) {
        [self addAreasToMap];
        
        [self addLine_symbolsToMap];
        
        if ([self.data objectForKey:@"r"]) {
            [self addAreasToMap2];
        }
        //        [self addSymbolsToMap];
    }
    
    if (self.areas) {
        [self addAreasToMap1];
    }
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
                               MaplyComponentObject *compObj = [self.theViewC addVectors:[NSArray arrayWithObject:wgVecObj] desc:vectorDict];
                               // If you ever intend to remove these, keep track of the MaplyComponentObjects above.
                           }
                       }
                       
//                    NSArray *jsons = [[NSBundle mainBundle] pathsForResourcesOfType:@"json" inDirectory:nil];
//                    for (NSString *path in jsons)
//                       {
//                           NSData *jsonData = [NSData dataWithContentsOfFile:path];
//                           
//                           id data = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
//                           [self.datas addObject:data];
//                       }
                       
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
    
    [self changetitle:[self.titles firstObject]];
    
    self.statisticsView.hidden = YES;
}

-(void)addAreasToMap
{
//    全国大雾落区预报, 全国空气污染气象预报
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"全国空气污染气象预报" ofType:@"json"];
//    NSData *jsonData = [NSData dataWithContentsOfFile:path];
//    
//    id data = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
//    
//    NSArray *areas = [data objectForKey:@"areas"];
    NSArray *areas = [self.data objectForKey:@"areas"];
    for (NSDictionary *area in areas) {
        NSArray *items = [area objectForKey:@"items"];
        
        NSInteger index = [areas indexOfObject:area];
        MaplyCoordinate * points = (MaplyCoordinate *)malloc(sizeof(MaplyCoordinate) * items.count);
        
        for (NSInteger i=0; i<items.count; i++) {
            NSDictionary *point = [items objectAtIndex:i];
            
            points[i] = MaplyCoordinateMakeWithDegrees([[point objectForKey:@"x"] doubleValue], [[point objectForKey:@"y"] doubleValue]);
        }
        
        NSDictionary *vectorDict = nil;
        if ([area objectForKey:@"c"]) {
            vectorDict = @{
                           kMaplyColor: [self colorFromRGBString:[area objectForKey:@"c"]],
                           kMaplyDrawPriority: @(kMaplyLoftedPolysDrawPriorityDefault+index),
                           kMaplySelectable: @(true),
                           kMaplyFilled: @(true),
                           kMaplyDrawOffset: @(0),
//                           kMaplyLabelWidth : @(4.0),
                           };
        }
        
        MaplyVectorObject *vect = [[MaplyVectorObject alloc] initWithAreal:points numCoords:(int)items.count attributes:nil];
        vect.selectable = true;
        free(points);
        
        MaplyComponentObject *comObj = [self.theViewC addVectors:[NSArray arrayWithObject:vect] desc:vectorDict mode:MaplyThreadCurrent];
        
        [self.comObjs addObject:comObj];
    }
}

//-(void)addLinesToMap
//{
//    NSArray *areas = [self.data objectForKey:@"lines"];
//    /********* 目前没有，暂时不处理 *********/
//
//    for (NSDictionary *area in areas) {
//        NSArray *items = [area objectForKey:@"items"];
//
//        CLLocationCoordinate2D * points = (CLLocationCoordinate2D *)malloc(sizeof(CLLocationCoordinate2D) * items.count);
//
//        for (NSInteger i=0; i<items.count; i++) {
//            NSDictionary *point = [items objectAtIndex:i];
//
//            points[i] = CLLocationCoordinate2DMake([[point objectForKey:@"y"] doubleValue], [[point objectForKey:@"x"] doubleValue]);
//        }
//
//        MKPolygon *line = [MKPolygon polygonWithCoordinates:points count:items.count];
////        line.subtitle = [self colorStringFromDataInfoWithCode:[area objectForKey:@"code"] text:[[area objectForKey:@"symbols"] objectForKey:@"text"]];
//        free(points);
//
//        [self.mapView addOverlay:line];
//    }
//}

-(void)addLine_symbolsToMap
{
    NSArray *areas = [self.data objectForKey:@"line_symbols"];
    for (NSDictionary *area in areas) {
        
        if ([[area objectForKey:@"code"] integerValue] != 38) {
            continue;
        }
        
        NSArray *items = [area objectForKey:@"items"];
        
        MaplyCoordinate * points = (MaplyCoordinate *)malloc(sizeof(MaplyCoordinate) * items.count);
        
        for (NSInteger i=0; i<items.count; i++) {
            NSDictionary *point = [items objectAtIndex:i];
            
            points[i] = MaplyCoordinateMake([[point objectForKey:@"x"] doubleValue], [[point objectForKey:@"y"] doubleValue]);
        }
        
        NSDictionary *vectorDict = @{
                                     kMaplyColor: [UIColor redColor],
                                     kMaplySelectable: @(true),
                                     kMaplyDrawOffset: @(0),
                                     kMaplyLabelWidth : @(3.0),
                                     };
        
        MaplyVectorObject *vect = [[MaplyVectorObject alloc] initWithLineString:points numCoords:(int)items.count attributes:nil];
        vect.selectable = true;
        free(points);
        
        MaplyComponentObject *comObj = [self.theViewC addVectors:[NSArray arrayWithObject:vect] desc:vectorDict mode:MaplyThreadCurrent];
        
        [self.comObjs addObject:comObj];
    }
}

//-(void)addSymbolsToMap
//{
//    NSArray *areas = [self.data objectForKey:@"symbols"];
//    for (NSDictionary *area in areas) {
//        
//        MKPointAnnotation *ann = [[MKPointAnnotation alloc] init];
//        ann.coordinate = CLLocationCoordinate2DMake([[area objectForKey:@"y"] doubleValue], [[area objectForKey:@"x"] doubleValue]);
//        ann.title = [area objectForKey:@"text"];
//        
//        [self.mapView addAnnotation:ann];
//    }
//}

-(void)addAreasToMap1
{
//    MaplyCoordinateSystem *coorSys = [[MaplySphericalMercator alloc] initWebStandard];
    for (NSDictionary *area in self.areas) {
        NSArray *items = [area objectForKey:@"items"];
        
        NSInteger index = [self.areas indexOfObject:area];
        MaplyCoordinate * points = (MaplyCoordinate *)malloc(sizeof(MaplyCoordinate) * items.count);
        
        for (NSInteger i=0; i<items.count; i++) {
            NSDictionary *point = [items objectAtIndex:i];
            
            points[i] = MaplyCoordinateMake([[point objectForKey:@"lng"] doubleValue], [[point objectForKey:@"lat"] doubleValue]);
        }
        
        NSDictionary *vectorDict = nil;
        if ([area objectForKey:@"color"]) {
            vectorDict = @{
                           kMaplyColor: [self colorFromRGBString:[area objectForKey:@"color"]],
                           kMaplyDrawPriority: @(kMaplyLoftedPolysDrawPriorityDefault+index),
                           kMaplySelectable: @(true),
                           kMaplyFilled: @(true),
                           kMaplyDrawOffset: @(0),
                           };
        }
        
        MaplyVectorObject *vect = [[MaplyVectorObject alloc] initWithAreal:points numCoords:(int)items.count attributes:nil];
        vect.selectable = true;
        free(points);
        
        MaplyComponentObject *comObj = [self.theViewC addVectors:[NSArray arrayWithObject:vect] desc:vectorDict mode:MaplyThreadCurrent];
        
        [self.comObjs addObject:comObj];
    }
}


-(void)addAreasToMap2
{
    NSArray *r = [self.data objectForKey:@"r"];
    NSArray *lists = [self.data objectForKey:@"list"];
    
    for (NSArray *arr in r) {
        NSInteger index = [[arr firstObject] integerValue];
        NSString *color = [arr lastObject];
        
        NSArray *items = [lists objectAtIndex:index];
//        CGFloat bool_items = [self getArea:items];
        
        MaplyCoordinate * points = (MaplyCoordinate *)malloc(sizeof(MaplyCoordinate) * items.count);
        
        NSInteger j=0;
//        if (bool_items < 0) {
//            for (NSInteger i=0; i<items.count; i++) {
//                NSDictionary *point = [items objectAtIndex:i];
//                
//                points[j] = MaplyCoordinateMake([[point objectForKey:@"x"] doubleValue], [[point objectForKey:@"y"] doubleValue]);
//                j++;
//            }
//        }
//        else
        {
            for (NSInteger i=items.count-1; i>=0; i--) {
                NSDictionary *point = [items objectAtIndex:i];
                
                points[j] = MaplyCoordinateMake([[point objectForKey:@"x"] doubleValue], [[point objectForKey:@"y"] doubleValue]);
                j++;
            }
        }
        
        
        NSDictionary *vectorDict = nil;
        if (color) {
            vectorDict = @{
                           kMaplyColor: [self colorFromRGBString:color],
                           kMaplyDrawPriority: @(kMaplyLoftedPolysDrawPriorityDefault+index),
                           kMaplySelectable: @(true),
                           kMaplyFilled: @(true),
                           kMaplyDrawOffset: @(0),
                           };
        }
        
        MaplyVectorObject *vect = [[MaplyVectorObject alloc] initWithAreal:points numCoords:(int)items.count attributes:nil];
        vect.selectable = true;
        free(points);
        
        MaplyComponentObject *comObj = [self.theViewC addVectors:[NSArray arrayWithObject:vect] desc:vectorDict mode:MaplyThreadCurrent];
        
        [self.comObjs addObject:comObj];
        
        break;
    }
}

-(CGFloat)getArea:(NSArray *)points
{
    CGFloat s = 0;
    for (NSInteger i=0; i<points.count-1; i++) {
        NSDictionary *point_a = [points objectAtIndex:i];
        NSDictionary *point_b = [points objectAtIndex:i+1];
        
        s += [point_a[@"x"] floatValue]*[point_b[@"y"] floatValue] - [point_b[@"x"] floatValue]*[point_a[@"y"] floatValue];
    }
    
    NSDictionary *point_a = [points lastObject];
    NSDictionary *point_b = [points firstObject];
    s += [point_a[@"x"] floatValue]*[point_b[@"y"] floatValue] - [point_b[@"x"] floatValue]*[point_a[@"y"] floatValue];
    
    return s/2;
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
}

-(UIColor *)colorFromRGBString:(NSString *)rbgString
{
    if ([rbgString hasPrefix:@"rgba"]) {
        return [UIColor clearColor];
    }
    unsigned long rgbValue = strtoul([[rbgString stringByReplacingOccurrencesOfString:@"#" withString:@"0x"] UTF8String], 0, 16);
    
    return [[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0] colorWithAlphaComponent:0.7];
}

-(void)clickNavLeft
{
    UIActionSheet *actSheet = [[UIActionSheet alloc] initWithTitle:@"请选择" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:nil];
    actSheet.tag = 1000;
    [actSheet addButtonWithTitle:@"雷达图"];
//    [actSheet addButtonWithTitle:@"网眼"];
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
        if ([title isEqualToString:@"雷达图"]) {
            [self showImagesAnimation:MapImageTypeRain];
        }
        else if ([title isEqualToString:@"天气统计"])
        {
            [self showTongJiMarkers];
        }
    }
}

-(void)resetMapUI
{
    [self.theViewC removeObjects:self.comObjs];
    [self.comObjs removeAllObjects];
    
    [self.theViewC removeObject:self.stickersObj];
    self.stickersObj = nil;
    
    [self.theViewC removeObject:self.markersObj];
    self.markersObj = nil;
}

-(void)showTongJiMarkers
{
    NSString *url = [Util requestEncodeWithString:@"http://scapi.weather.com.cn/weather/stationinfo?" appId:@"f63d329270a44900" privateKey:@"sanx_data_99"];
    
    [[PLHttpManager sharedInstance].manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (responseObject) {
            self.markerDatas = (NSDictionary *)responseObject;
            [self addAnnotations];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

-(void)showImagesAnimation:(enum MapImageType)type
{
    if (!self.mapImagesManager) {
        self.mapImagesManager = [[MapImagesManager alloc] init];
    }
    
    self.bottomView.hidden = NO;
    [self requestImage:MapImageTypeRain];
}

-(void)addAnnotations
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
    self.markersObj = [self.theViewC addScreenMarkers:[self annotationsWithServerDatas:@"level3"] desc:@{kMaplyFade: @(1.0),
                                                                           kMaplyDrawPriority: @(kMaplyModelDrawPriorityDefault+200)}];
}

-(NSArray *)annotationsWithServerDatas:(NSString *)level
{
    NSArray *datas = [self.markerDatas objectForKey:level];
    
    NSMutableArray *annos = [NSMutableArray arrayWithCapacity:datas.count];
    for (NSInteger i=0; i<datas.count; i++) {
        NSDictionary *dict = [datas objectAtIndex:i];
        
        UIImage *newImage = [Util drawText:dict[@"name"] inImage:[UIImage imageNamed:@"circle39"] font:[UIFont systemFontOfSize:12] textColor:[UIColor whiteColor]];
        
        MaplyScreenMarker *anno = [[MaplyScreenMarker alloc] init];
        anno.loc             = MaplyCoordinateMakeWithDegrees([dict[@"lon"] floatValue], [dict[@"lat"] floatValue]);
        anno.size            = CGSizeMake(30, 30);
        anno.userObject   = @{@"title": dict[@"name"], @"subTitle": [dict[@"stationid"] stringByAppendingFormat:@"-%@", dict[@"areaid"]]};
        anno.image           = newImage;
        [annos addObject:anno];
    }
    
    return annos;
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
    
    self.mapImagesManager.hudView = self.view;
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
//        MK_CHINA_CENTER_REGION.
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
    [self.view addSubview:bottomView];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.mas_equalTo(self.view);
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
