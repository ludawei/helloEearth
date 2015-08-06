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

@interface ViewController ()<WhirlyGlobeViewControllerDelegate, UIActionSheetDelegate>
{
    CGFloat globeHeight;
}

@property (nonatomic,strong) WhirlyGlobeViewController *theViewC;

@property (nonatomic,strong) NSArray *titles;
@property (nonatomic,strong) NSDictionary *data;
@property (nonatomic,strong) NSArray *areas;

@property (nonatomic,strong) NSMutableArray *comObjs, *vects, *descs;

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
    int maxZoom = 6;
    
    MyRemoteTileInfo *myTileInfo = [[MyRemoteTileInfo alloc] initWithBaseURL:@"http://api.tiles.mapbox.com/v4/ludawei.n1ppo21a/" ext:@"png" minZoom:0 maxZoom:maxZoom];
    
    MaplyRemoteTileSource *tileSource = [[MaplyRemoteTileSource alloc] initWithInfo:myTileInfo];
    
//    MyRemoteTileInfo *myTileInfo = [[MyRemoteTileInfo alloc] initWithBaseURL:@"http://otile1.mqcdn.com/tiles/1.0.0/osm/"  ext:@"png" minZoom:0 maxZoom:maxZoom];
//    
//    MaplyRemoteTileSource *tileSource = [[MaplyRemoteTileSource alloc] initWithInfo:myTileInfo];
    
    tileSource.cacheDir = aerialTilesCacheDir;
    MaplyQuadImageTilesLayer *layer = [[MaplyQuadImageTilesLayer alloc] initWithCoordSystem:tileSource.coordSys tileSource:tileSource];
    layer.handleEdges = false;
    layer.coverPoles = false;
    layer.maxTiles = 256;
//    layer.animationPeriod = 6.0;
    layer.singleLevelLoading = true;
//    layer.drawPriority = 0;

    [self.theViewC addLayer:layer];
    self.theViewC.frameInterval = 2;
    self.theViewC.threadPerLayer = true;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"选择" style:UIBarButtonItemStyleDone target:self action:@selector(clickNavRight)];
    
    self.comObjs = [NSMutableArray array];
    
    [self addCountries];
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
    [self.theViewC removeObjects:self.comObjs];
    [self.comObjs removeAllObjects];
    
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
    MaplySun *sun = [[MaplySun alloc] initWithDate:[NSDate date]];
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
    
#if 0
    BOOL needReload = NO;
    if (globeHeight != 0)
    {
        if (globeHeight < 0.5 && viewC.height > 0.5) {
            needReload = YES;
        }
        
        if (globeHeight > 0.5 && viewC.height < 0.5) {
            needReload = YES;
        }
    }
    globeHeight = viewC.height;
    
    if (needReload) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
                [viewC removeObjects:self.comObjs];
                
                for (NSInteger i=0; i<self.comObjs.count; i++) {
                    MaplyVectorObject *vect = [self.vects objectAtIndex:i];
                    NSDictionary *desc = [self.descs objectAtIndex:i];
                    [viewC addVectors:@[vect] desc:desc];
                }
                
            });
        });
    }
#endif
}

-(UIColor *)colorFromRGBString:(NSString *)rbgString
{
    if ([rbgString hasPrefix:@"rgba"]) {
        return [UIColor clearColor];
    }
    unsigned long rgbValue = strtoul([[rbgString stringByReplacingOccurrencesOfString:@"#" withString:@"0x"] UTF8String], 0, 16);
    
    return [[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0] colorWithAlphaComponent:0.7];
}

-(void)clickNavRight
{
    UIActionSheet *actSheet = [[UIActionSheet alloc] initWithTitle:@"请选择" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:nil];
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
    
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    [self changetitle:title];
}
@end
