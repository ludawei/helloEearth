//
//  HEMapAnimFlow.m
//  HelloEarth
//
//  Created by 卢大维 on 16/2/22.
//  Copyright © 2016年 weather. All rights reserved.
//

#import "HEMapAnimFlow.h"
#import "MyMaplyShapeSphere.h"
#import "PLHttpManager.h"
#import "Util.h"
#import "MBProgressHUD+Extra.h"
#import "MyMaplyShapeLinear.h"
#import "HEWorldRandItem.h"

#define ANIM_COUNT 5

@interface HEMapAnimFlow ()<MyMaplyShapeLinearDelegate, HEWorldRandItemDelegate>
{
//    NSArray *worldCitys;
}

@property (nonatomic,strong) MaplyBaseViewController *theViewC;

@property (nonatomic,strong) MaplyComponentObject *makerObjAniming, *makerObjStart, *makerObjEnd;
@property (nonatomic,strong) CADisplayLink *timer;

@property (nonatomic,copy) NSArray *datas;
@property (nonatomic,strong) NSMutableArray *randIndexs, *randMyLines, *animObjs, *nextRandIndexs;
@property (nonatomic,strong) NSMutableArray *nextRandMarkerObjs;

@property (nonatomic,strong) HEWorldRandItem *worldRandItem;

@property (nonatomic,assign) NSTimeInterval reqestTime, weatherUpdateTime;//, worldRandTime;
@property (nonatomic,assign) BOOL isShow;

@end

@implementation HEMapAnimFlow

-(void)dealloc
{
    [self clear];
    
    self.worldRandItem.delegate = nil;
    self.worldRandItem = nil;
//    worldCitys = nil;
}

-(instancetype)initWithController:(UIViewController *)theViewC
{
    if (self = [super init]) {
        self.theViewC = (MaplyBaseViewController *)theViewC;
        
        self.worldRandItem = [[HEWorldRandItem alloc] init];
        self.worldRandItem.delegate = self;
//        NSString *path = [[NSBundle mainBundle] pathForResource:@"world_cities" ofType:@"txt"];
//        NSString *fileData = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
//        worldCitys = [fileData componentsSeparatedByString:@"\r\n"];
    }
    
    return self;
}

-(NSInteger)getRandomIndex
{
    NSInteger rand = arc4random_uniform((int)self.datas.count);
    if ([self.randIndexs containsObject:@(rand)] || [self.nextRandIndexs containsObject:@(rand)]) {
        rand = [self getRandomIndex];
    }
    
    return rand;
}

-(void)randomFun
{
    if (self.datas.count <= 5) {
        return;
    }
    
    NSInteger rand = [[self.nextRandIndexs firstObject] integerValue];
    
    NSDictionary *d = [self.datas objectAtIndex:rand];

#if 0
    MaplyCoordinate startPt = MaplyCoordinateMakeWithDegrees([[[d objectForKey:@"from"] objectForKey:@"latitude"] floatValue], [[[d objectForKey:@"from"] objectForKey:@"longitude"] floatValue]);
    MaplyCoordinate endPt = MaplyCoordinateMakeWithDegrees([[[d objectForKey:@"to"] objectForKey:@"latitude"] floatValue], [[[d objectForKey:@"to"] objectForKey:@"longitude"] floatValue]);
    
    CGFloat angle = MaplyGreatCircleDistance(startPt, endPt) / 6371000.0;
    CGFloat height = 0.4 * angle / M_PI;
    NSInteger inNumCoords = 91;
    
    MaplyCoordinate3d *coords = (MaplyCoordinate3d *)malloc(sizeof(MaplyCoordinate3d)*inNumCoords);
    for (NSInteger ii=0; ii<inNumCoords; ii++) {
        CGFloat r = 1.0 * ii / (inNumCoords-1);
        CGFloat x = (endPt.x - startPt.x)*r + startPt.x;
        CGFloat y = (endPt.y - startPt.y)*r + startPt.y;
        CGFloat z = 0;
        
        if (ii >= inNumCoords/2.0) {
            z = height * (1 - r) * (1.0 + r) * (1.0 + r) * (1.0 + r);
        }
        else
        {
            z = height * r * (1.0 + 1.0 - r) * (1.0 + 1.0 - r) * (1.0 + 1.0 - r);
        }
        coords[ii] = MaplyCoordinate3dMake(y, x, z);
    }
#else
    NSMutableArray *locs = [NSMutableArray array];
    [locs addObject:[d objectForKey:@"from"]];
    
    NSDictionary *pass1 = [d objectForKey:@"pass1"];
    if (pass1) {
        [locs addObject:pass1];
    }
    
    NSDictionary *pass2 = [d objectForKey:@"pass2"];
    if (pass2) {
        [locs addObject:pass2];
    }
    [locs addObject:[d objectForKey:@"to"]];
    
    
    MaplyCoordinate3d *coords;
    NSArray *pointCounts;
    NSInteger inNumCoords = [self getCoordsFromLocations:locs coords:&coords pointCounts:&pointCounts];
    
#endif
 
    MyMaplyShapeLinear *line = [[MyMaplyShapeLinear alloc] initWithCoords:coords numCoords:(int)inNumCoords];
    line.delegate = self;
    line.delayHideCount = 30;
    line.firstIndex = 0;
    line.pointCounts = pointCounts;
    line.points = locs;
    
    free(coords);
    
    [self removeTheNextRandIndex:0];
    [self addTheNextRandIndex];
    
    [self.randIndexs addObject:@(rand)];
    [self.randMyLines addObject:line];
    if (self.randIndexs.count > ANIM_COUNT) {
        [self.randIndexs removeObjectAtIndex:0];
    }
    if (self.randMyLines.count > ANIM_COUNT) {
        [self.randMyLines removeObjectAtIndex:0];
    }
    
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    if (now - self.weatherUpdateTime > 3.0) {
        self.weatherUpdateTime = now;
        
        [self.delegate showFlowWeatherData:d];
    }
}

-(NSInteger)getCoordsFromLocations:(NSArray *)locs coords:(MaplyCoordinate3d **)coords pointCounts:(NSArray **)pointsCount;
{
    NSMutableArray *tempAngles = [NSMutableArray array];
    CGFloat subAngles = 0;
    for (NSInteger i=0; i<locs.count-1; i++) {
        MaplyCoordinate startPt = MaplyCoordinateMakeWithDegrees([[[locs objectAtIndex:i] objectForKey:@"latitude"] floatValue], [[[locs objectAtIndex:i] objectForKey:@"longitude"] floatValue]);
        MaplyCoordinate endPt = MaplyCoordinateMakeWithDegrees([[[locs objectAtIndex:i+1] objectForKey:@"latitude"] floatValue], [[[locs objectAtIndex:i+1] objectForKey:@"longitude"] floatValue]);
        
        CGFloat angle = MaplyGreatCircleDistance(startPt, endPt) / 6371000.0;
        subAngles += angle;
        [tempAngles addObject:@(angle)];
    }
    
    NSInteger totalCount = 0;
    NSMutableArray *countArr = [NSMutableArray array];
    for (NSInteger i=0; i<tempAngles.count; i++) {
        NSInteger count = 91 * [[tempAngles objectAtIndex:i] floatValue] / subAngles;
        count = MAX(count, 2);
        [countArr addObject:@(count)];
        totalCount += count;
    }
    
    totalCount = totalCount - (tempAngles.count - 1);
    
    NSMutableArray *tempCounts = [NSMutableArray array];
    
    NSInteger lastCount = 0;
    [tempCounts addObject:@(lastCount)];
    
    MaplyCoordinate3d *totalCoords = (MaplyCoordinate3d *)malloc(sizeof(MaplyCoordinate3d)*totalCount);
    
    for (NSInteger i=0; i<locs.count-1; i++) {
        MaplyCoordinate startPt = MaplyCoordinateMakeWithDegrees([[[locs objectAtIndex:i] objectForKey:@"latitude"] floatValue], [[[locs objectAtIndex:i] objectForKey:@"longitude"] floatValue]);
        MaplyCoordinate endPt = MaplyCoordinateMakeWithDegrees([[[locs objectAtIndex:i+1] objectForKey:@"latitude"] floatValue], [[[locs objectAtIndex:i+1] objectForKey:@"longitude"] floatValue]);
        
        CGFloat angle = MaplyGreatCircleDistance(startPt, endPt) / 6371000.0;
        CGFloat height = 0.4 * angle / M_PI;
        NSInteger inNumCoords = [[countArr objectAtIndex:i] floatValue];
        
        for (NSInteger ii=0; ii<inNumCoords; ii++) {
            CGFloat r = 1.0 * ii / (inNumCoords-1);
            CGFloat x = (endPt.x - startPt.x)*r + startPt.x;
            CGFloat y = (endPt.y - startPt.y)*r + startPt.y;
            CGFloat z = 0;
            
            if (ii >= inNumCoords/2.0) {
                z = height * (1 - r) * (1.0 + r) * (1.0 + r) * (1.0 + r);
            }
            else
            {
                z = height * r * (1.0 + 1.0 - r) * (1.0 + 1.0 - r) * (1.0 + 1.0 - r);
            }
            
            if (i == 0) {
                totalCoords[ii + lastCount] = MaplyCoordinate3dMake(y, x, z);
//                LOG(@"%f, %f, %f -- %td -- %td", y, x, z, ii, ii + lastCount);
            }
            else
            {
                if (ii > 0) {
                    totalCoords[ii - 1 + lastCount] = MaplyCoordinate3dMake(y, x, z);
//                    LOG(@"%f, %f, %f -- %td -- %td", y, x, z, ii, ii - 1 + lastCount);
                }
            }
        }
        
        if (i == 0) {
            lastCount += inNumCoords;
        }
        else
        {
            lastCount += inNumCoords - 1;
        }
        [tempCounts addObject:@(lastCount-1)];
        //        free(coords);
    }
    
    *coords = totalCoords;
    *pointsCount = tempCounts;
    
    return totalCount;
}

-(void)addTheNextRandIndex
{
    NSInteger rand = [self getRandomIndex];
    
    NSDictionary *d = [self.datas objectAtIndex:rand];
    
    NSMutableArray *locs = [NSMutableArray array];
    [locs addObject:[d objectForKey:@"from"]];
    
    NSDictionary *pass1 = [d objectForKey:@"pass1"];
    if (pass1) {
        [locs addObject:pass1];
    }
    
    NSDictionary *pass2 = [d objectForKey:@"pass2"];
    if (pass2) {
        [locs addObject:pass2];
    }
    [locs addObject:[d objectForKey:@"to"]];
    
    NSMutableArray *marks = [NSMutableArray array];
    for (NSInteger i=0; i<locs.count; i++) {
        NSDictionary *point = [locs objectAtIndex:i];
        
        CGFloat sizeWidth = 8;
        if (i < locs.count-1) {
            sizeWidth = 9 - (locs.count - 1 - i) * 2;
        }
        
        if (point) {
            MaplyScreenMarker *anno = [[MaplyScreenMarker alloc] init];
            anno.layoutImportance = MAXFLOAT;
            anno.loc              = MaplyCoordinateMakeWithDegrees([[point objectForKey:@"longitude"] floatValue], [[point objectForKey:@"latitude"] floatValue]);
            anno.size             = CGSizeMake(sizeWidth, sizeWidth);
//            anno.color            = UIColorFromRGB(0x0f6c26);
            anno.image            = [UIImage imageNamed:@"city_data_mark1"];
            [marks addObject:anno];
        }
    }
    MaplyComponentObject *obj = [self addAnimMarkers:marks];
    [self.nextRandMarkerObjs addObject:obj];
    
    [self.nextRandIndexs addObject:@(rand)];
}

-(void)removeTheNextRandIndex:(NSInteger)index
{
    if (index < self.nextRandIndexs.count) {
        [self.nextRandIndexs removeObjectAtIndex:index];
    }
    
    if (index < self.nextRandMarkerObjs.count) {
        MaplyComponentObject *obj = [self.nextRandMarkerObjs objectAtIndex:index];
        [self.theViewC removeObject:obj];
        [self.nextRandMarkerObjs removeObjectAtIndex:index];
    }
    
}

-(void)startAnim
{
    [self clear];
    
    self.randIndexs = [NSMutableArray array];
    self.randMyLines = [NSMutableArray array];
    self.nextRandIndexs = [NSMutableArray array];
    self.nextRandMarkerObjs = [NSMutableArray array];
    self.animObjs = [NSMutableArray array];
    
//    self.randWorldIndexs = [NSMutableArray array];
//    self.randWorldObjs = [NSMutableArray array];
    
    for (NSInteger i=0; i<ANIM_COUNT; i++) {
        [self addTheNextRandIndex];
    }
    
    for (NSInteger i=0; i<ANIM_COUNT; i++) {
        [self randomFun];
    }
    
    self.timer = [CADisplayLink displayLinkWithTarget:self selector:@selector(timeFired)];
    self.timer.frameInterval = 2;
    [self.timer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    
    self.isShow = YES;
    
    [self.worldRandItem show];
}

-(void)show
{
    if ([[NSDate date] timeIntervalSince1970] - self.reqestTime < 5 * 60) {
        [self startAnim];
    }
    else
    {
        NSString *url = [Util requestEncodeWithString:@"http://scapi.weather.com.cn/weather/fromto?" appId:@"f63d329270a44900" privateKey:@"sanx_data_99"];
        
        [MBProgressHUD showHUDInView:self.theViewC.view andText:nil];
        [[PLHttpManager sharedInstance].manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            self.reqestTime = [[NSDate date] timeIntervalSince1970];
            
            [MBProgressHUD hideAllHUDsForView:self.theViewC.view animated:YES];
            if (responseObject) {
                self.datas = responseObject;
                
                [self startAnim];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [MBProgressHUD hideAllHUDsForView:self.theViewC.view animated:YES];
            [MBProgressHUD showHUDInView:self.theViewC.view andText:@"数据请求失败"];
        }];
    }
}

-(void)hide
{
    self.isShow = NO;
    [self clear];
}

-(void)timeFired
{
    for (NSInteger i=0; i<self.randMyLines.count; i++) {
        MyMaplyShapeLinear *line = [self.randMyLines objectAtIndex:i];
        [line timeFired];
    }
    
//    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
//    if (now - self.worldRandTime > 3.0) {
//        self.worldRandTime = now;
//        
//        [self showWorldLocations];
//    }
}

-(void)clear
{
    NSMutableArray *temp = [NSMutableArray array];
    if (self.makerObjAniming) {
        [temp addObject:self.makerObjAniming];
    }
    if (self.makerObjStart) {
        [temp addObject:self.makerObjStart];
    }
    if (self.makerObjEnd) {
        [temp addObject:self.makerObjEnd];
    }
    [self.theViewC removeObjects:temp];
    temp = nil;
    
    if (self.animObjs.count > 0) {
        [self.theViewC removeObjects:self.animObjs];
    }
    
    if (self.nextRandMarkerObjs.count > 0) {
        [self.theViewC removeObjects:self.nextRandMarkerObjs];
        [self.nextRandMarkerObjs removeAllObjects];
    }
    
    for (MyMaplyShapeLinear *line in self.randMyLines) {
        [line removeStaticMarkers];
    }
    
//    if (self.randWorldObjs.count > 0) {
//        for (NSArray *arr in self.randWorldObjs) {
//            [self .theViewC removeObjects:@[arr.firstObject, arr.lastObject]];
//        }
//        [self.theViewC removeObjects:self.randWorldObjs];
////        [self.randWorldObjs removeAllObjects];
//    }
    
    self.makerObjAniming = nil;
    self.makerObjStart = nil;
    self.makerObjEnd = nil;
    [self.animObjs removeAllObjects];
    [self.randMyLines removeAllObjects];
    
    [self.worldRandItem hide];
    
    [self.timer invalidate];
    self.timer = nil;
}

//-(void)showWorldLocations
//{
//    
//    NSInteger index = 0;
//    if (self.randWorldIndexs.count > 0) {
//        index = ([self.randWorldIndexs.lastObject integerValue] + 500)%worldCitys.count;
//    }
//    else
//    {
//        index = arc4random_uniform((int)worldCitys.count);
//    }
//    
//    NSString *loc = [worldCitys objectAtIndex:index];
//    NSArray *items = [loc componentsSeparatedByString:@","];
//    if (items.count == 3) {
//        NSString *name = [items firstObject];
//        NSString *lat = [items objectAtIndex:1];
//        NSString *lon = [items lastObject];
//        
//        MaplyScreenLabel *label = [[MaplyScreenLabel alloc] init];
//        label.loc = MaplyCoordinateMakeWithDegrees(lon.floatValue, lat.floatValue);
////        label.keepUpright = true;
////        label.layoutPlacement = kMaplyLayoutRight;
//        label.layoutImportance = 2;
//        label.offset = CGPointMake(3, 3);
//        label.text = name;//[@"•" stringByAppendingString:name];
//        MaplyComponentObject *labelObj = [self.theViewC addScreenLabels:@[label]
//                                                                   desc:@{kMaplyTextOutlineSize: @(0.6),
//                                                                          kMaplyTextOutlineColor: [UIColor blackColor],
//                                                                          kMaplyFont: [UIFont systemFontOfSize:10.0],
//                                                                          kMaplyDrawPriority: @(200),
//                                                                          kMaplyMaxVis:@1.8,
//                                                                          kMaplyMinVis:@0.0,
//                                                                          kMaplyFade: @(0.6),
//                                                                          }];
//        
//        NSInteger randSizeWidth = arc4random_uniform(4);
//        MaplyScreenMarker *anno = [[MaplyScreenMarker alloc] init];
//        anno.layoutImportance   = MAXFLOAT;
//        anno.loc                = MaplyCoordinateMakeWithDegrees(lon.floatValue, lat.floatValue);
//        anno.size               = CGSizeMake(10-randSizeWidth, 10-randSizeWidth);
//        anno.image              = [UIImage imageNamed:@"city_data_mark1"];
//        
//        MaplyScreenMarker *animAnno = [[MaplyScreenMarker alloc] init];
//        animAnno.layoutImportance   = MAXFLOAT;
//        animAnno.loc                = MaplyCoordinateMakeWithDegrees(lon.floatValue, lat.floatValue);
//        animAnno.size               = CGSizeMake(35 - randSizeWidth * 3, 35 - randSizeWidth * 3);
//        animAnno.images             = @[[UIImage imageNamed:@"国外－1"], [UIImage imageNamed:@"国外－2"], [UIImage imageNamed:@"国外－3"]];
//        animAnno.period             = 0.8;
//        MaplyComponentObject *annoObj =[self addAnimMarkers:@[anno, animAnno]];
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            
//        });
//        
//        [self.randWorldIndexs addObject:@(index)];
//        [self.randWorldObjs addObject:@[labelObj, annoObj]];
//        
//        if (self.randWorldIndexs.count > 10) {
//            [self.randWorldIndexs removeObjectAtIndex:0];
//        }
//        if (self.randWorldObjs.count > 10) {
//            NSArray *temp = [self.randWorldObjs firstObject];
//            [self.theViewC removeObjects:@[temp.firstObject, temp.lastObject]];
//            [self.randWorldObjs removeObjectAtIndex:0];
//        }
//    }
//}

#pragma mark - MyMaplyShapeLinearDelegate
-(MaplyComponentObject *)updateWithLine:(MaplyShapeLinear *)line lineObj:(MaplyComponentObject *)lineObj
{
    if (lineObj) {
        [self.theViewC disableObjects:@[lineObj] mode:MaplyThreadCurrent];
        [self.theViewC removeObjects:@[lineObj] mode:MaplyThreadCurrent];
        [self.animObjs removeObject:lineObj];
    }
    
    MaplyComponentObject *obj = [self.theViewC addShapes:@[line]
                               desc:@{//kMaplyShader: kMaplyShaderDefaultLine,
                                      kMaplyDrawPriority: @(kMaplyShapeDrawPriorityDefault + 100000),
                                      kMaplyColor : UIColorFromRGB(0x00ff00),
                                      kMaplySubdivEpsilon:@(0.00001),
                                      }
                               mode:MaplyThreadCurrent];
    
    [self.animObjs addObject:obj];
    return obj;
}

-(void)removeMyLine:(MyMaplyShapeLinear *)myLine lineObj:(MaplyComponentObject *)lineObj
{
    NSInteger index = [self.randMyLines indexOfObject:myLine];
    [self.randMyLines removeObjectAtIndex:index];
    [self.randIndexs removeObjectAtIndex:index];
    
    if (lineObj) {
        [self.theViewC disableObjects:@[lineObj] mode:MaplyThreadCurrent];
        [self.theViewC removeObjects:@[lineObj] mode:MaplyThreadCurrent];
        [self.animObjs removeObject:lineObj];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(arc4random_uniform(5) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.isShow) {
            [self randomFun];
        }
    });
}

-(MaplyComponentObject *)addAnimMarkers:(NSArray *)markers
{
    return [self.theViewC addScreenMarkers:markers desc:@{kMaplyFade: @(0.6), kMaplyDrawPriority: @(kMaplyShapeDrawPriorityDefault+10000)}];
}
-(void)removeAnimMarkers:(NSArray *)markerObjs
{
    [self.theViewC removeObjects:markerObjs];
}

#pragma mark - HEWorldRandItemDelegate
-(MaplyComponentObject *)addLabels:(NSArray *)labels
{
    return [self.theViewC addScreenLabels:labels
                                     desc:@{kMaplyTextOutlineSize: @(0.6),
                                            kMaplyTextOutlineColor: [UIColor blackColor],
                                            kMaplyFont: [UIFont systemFontOfSize:10.0],
                                            kMaplyDrawPriority: @(200),
                                            kMaplyMaxVis:@1.8,
                                            kMaplyMinVis:@0.0,
                                            kMaplyFade: @(0.6),
                                            }];
}
@end
