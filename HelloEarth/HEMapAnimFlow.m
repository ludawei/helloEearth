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

@interface HEMapAnimFlow ()<MyMaplyShapeLinearDelegate>

@property (nonatomic,strong) MaplyBaseViewController *theViewC;

@property (nonatomic,strong) MaplyComponentObject *makerObjAniming, *makerObjStart, *makerObjEnd;
//@property (nonatomic,strong) NSMutableArray *circles;
//@property (nonatomic,strong) NSMutableDictionary *animShapes;
@property (nonatomic,strong) CADisplayLink *timer;

@property (nonatomic,copy) NSArray *datas;
@property (nonatomic,strong) NSMutableArray *randIndexs, *randMyLines, *animObjs;

@property (nonatomic,assign) NSTimeInterval reqestTime;

@end

@implementation HEMapAnimFlow

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

//- (void)addGreatCircles:(NSArray *)locations desc:(NSDictionary *)desc
//{
//    self.circles = [NSMutableArray array];
//    self.animShapes = [NSMutableDictionary dictionary];
//    NSMutableArray *annos = [NSMutableArray array];
//    
//    for (NSInteger i=0; i<locations.count; i++)
//    {
//        NSDictionary *dict = [[locations objectAtIndex:i] objectForKey:@"properties"];
//        if ([[dict objectForKey:@"cname"] isEqualToString:@"北京"]) {
//            continue;
//        }
//        NSArray *loc0 = [dict objectForKey:@"cp"];
//        NSArray *loc1 = @[@"116.380943", @"39.923615"];
//        
//        MaplyCoordinate startPt = MaplyCoordinateMakeWithDegrees([[loc0 lastObject] floatValue], [[loc0 firstObject] floatValue]);
//        MaplyCoordinate endPt = MaplyCoordinateMakeWithDegrees([[loc1 lastObject] floatValue], [[loc1 firstObject] floatValue]);
//        
//        MaplyScreenMarker *anno = [[MaplyScreenMarker alloc] init];
//        anno.layoutImportance = MAXFLOAT;
//        anno.loc             = MaplyCoordinateMakeWithDegrees([[loc0 firstObject] floatValue], [[loc0 lastObject] floatValue]);
//        anno.size            = CGSizeMake(8, 8);
//        anno.images          = self.animMakerImages;
//        anno.period          = arc4random_uniform(3)+1;
//        [annos addObject:anno];
//
//        CGFloat angle = MaplyGreatCircleDistance(startPt, endPt) / 6371000.0;
//        CGFloat height = 0.4 * angle / M_PI;
//        NSInteger inNumCoords = 91;
//        
//        MaplyCoordinate3d *coords = (MaplyCoordinate3d *)malloc(sizeof(MaplyCoordinate3d)*inNumCoords);
//        for (NSInteger ii=0; ii<inNumCoords; ii++) {
//            CGFloat r = 1.0 * ii / (inNumCoords-1);
//            CGFloat x = (endPt.x - startPt.x)*r + startPt.x;
//            CGFloat y = (endPt.y - startPt.y)*r + startPt.y;
//            CGFloat z = 0;
//            
//            if (ii >= inNumCoords/2.0) {
//                z = height * (1 - r) * (1.0 + r) * (1.0 + r) * (1.0 + r);
//            }
//            else
//            {
//                z = height * r * (1.0 + 1.0 - r) * (1.0 + 1.0 - r) * (1.0 + 1.0 - r);
//            }
//            coords[ii] = MaplyCoordinate3dMake(y, x, z);
//        }
//        
//        MaplyShapeLinear *line = [[MaplyShapeLinear alloc] initWithCoords:coords numCoords:(int)inNumCoords];
//        line.lineWidth = 5.0;
//        [self.circles addObject:line];
//        
//        MyMaplyShapeSphere *sphere = [[MyMaplyShapeSphere alloc] init];
//        sphere.center = MaplyCoordinateMake(coords[0].x, coords[0].y);
//        sphere.radius = 0.003;
//        sphere.height = coords[0].z;
//        sphere.speed = 2;//(int)(arc4random_uniform(2) + 2);
//        sphere.index = arc4random_uniform(45);
//        sphere.color = UIColorFromRGB(0xff83fb);
//        [self.animShapes setObject:sphere forKey:[NSString stringWithFormat:@"%td-0", i]];
//        
//        MyMaplyShapeSphere *sphere1 = [[MyMaplyShapeSphere alloc] init];
//        sphere1.center = MaplyCoordinateMake(coords[0].x, coords[0].y);
//        sphere1.radius = 0.003;
//        sphere1.height = -0.1;
//        sphere1.speed = 2;//(int)(arc4random_uniform(2) + 2);
//        sphere1.index = sphere.index - 45;
//        sphere1.color = UIColorFromRGB(0xff83fb);
//        [self.animShapes setObject:sphere1 forKey:[NSString stringWithFormat:@"%td-1", i]];
//
//        free(coords);
//    }
//    
//    NSArray *tempBills = [self.animShapes allValues];
//    
//    self.makerObj = [self.theViewC addScreenMarkers:annos desc:@{kMaplyFade: @(1.0), kMaplyDrawPriority: @(kMaplyModelDrawPriorityDefault+200)}];
//    self.circleObj = [self.theViewC addShapes:self.circles desc:desc];
//    [self.theViewC removeObject:self.animObj];
//    self.animObj = [self.theViewC addShapes:tempBills desc:@{kMaplyShader: kMaplyShaderDefaultLine,
//                                                             kMaplyDrawPriority: @(kMaplyShapeDrawPriorityDefault + 100001),
//                                                         }];
//    
////    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timeFired) userInfo:nil repeats:YES];
//}

-(NSInteger)getRandomIndex
{
    NSInteger rand = arc4random_uniform((int)self.datas.count);
    if ([self.randIndexs containsObject:@(rand)]) {
        rand = [self getRandomIndex];
    }
    
    return rand;
}

-(void)randomFun
{
    if (self.datas.count <= 5) {
        return;
    }
    
    NSInteger rand = [self getRandomIndex];
    
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
    line.delayHideCount = 25;
    line.firstIndex = 0;
    line.pointCounts = pointCounts;
    line.points = locs;
    line.delegate = self;
    
    free(coords);
    
    [self.randIndexs addObject:@(rand)];
    [self.randMyLines addObject:line];
    if (self.randIndexs.count > 5) {
        [self.randIndexs removeObjectAtIndex:0];
    }
    if (self.randMyLines.count > 5) {
        [self.randMyLines removeObjectAtIndex:0];
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

-(void)startAnim
{
    [self clear];
    
    self.randIndexs = [NSMutableArray array];
    self.randMyLines = [NSMutableArray array];
    self.animObjs = [NSMutableArray array];
    
    for (NSInteger i=0; i<5; i++) {
        [self randomFun];
    }
    
    self.timer = [CADisplayLink displayLinkWithTarget:self selector:@selector(timeFired)];
    self.timer.frameInterval = 2;
    [self.timer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
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
    [self clear];
}

-(void)timeFired
{
    for (NSInteger i=0; i<self.randMyLines.count; i++) {
        MyMaplyShapeLinear *line = [self.randMyLines objectAtIndex:i];
        [line timeFired];
    }
    
    if (self.randMyLines.count < 5) {
        [self randomFun];
    }
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
    
    self.makerObjAniming = nil;
    self.makerObjStart = nil;
    self.makerObjEnd = nil;
    [self.animObjs removeAllObjects];
//    self.circles = nil;
//    [self.animShapes removeAllObjects];
    
    [self.timer invalidate];
    self.timer = nil;
}

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
                                      //       kMaplyDrawPriority: @(kMaplyShapeDrawPriorityDefault + 100000),
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
    
    [self randomFun];
}

-(MaplyComponentObject *)addAnimMarker:(MaplyScreenMarker *)marker
{
    return [self.theViewC addScreenMarkers:@[marker] desc:@{kMaplyFade: @(0.6), kMaplyDrawPriority: @(kMaplyModelDrawPriorityDefault+200)}];
}
-(void)removeAnimMarker:(MaplyComponentObject *)markerObj
{
    [self.theViewC removeObjects:@[markerObj]];
}
@end
