//
//  HEMapAnimFlow.m
//  HelloEarth
//
//  Created by 卢大维 on 16/2/22.
//  Copyright © 2016年 weather. All rights reserved.
//

#import "HEMapAnimFlow.h"
#import "MyMaplyShapeSphere.h"

@interface HEMapAnimFlow ()

@property (nonatomic,strong) MaplyBaseViewController *theViewC;

@property (nonatomic,strong) MaplyComponentObject *makerObj, *circleObj, *animObj;
@property (nonatomic,strong) NSMutableArray *circles;
@property (nonatomic,strong) NSMutableDictionary *animShapes;
@property (nonatomic,strong) NSTimer *timer;

@property (nonatomic,copy) NSArray *animMakerImages;

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
        
        NSMutableArray *temp = [NSMutableArray array];
        for (NSInteger i=1; i<11; i++) {
            NSString *imageName = [NSString stringWithFormat:@"star_%td", i];
            [temp addObject:[UIImage imageNamed:imageName]];
        }
        self.animMakerImages = temp;
    }
    
    return self;
}

- (void)addGreatCircles:(NSArray *)locations desc:(NSDictionary *)desc
{
    self.circles = [NSMutableArray array];
    self.animShapes = [NSMutableDictionary dictionary];
    NSMutableArray *annos = [NSMutableArray array];
    
    for (NSInteger i=0; i<locations.count; i++)
    {
        NSDictionary *dict = [[locations objectAtIndex:i] objectForKey:@"properties"];
        if ([[dict objectForKey:@"cname"] isEqualToString:@"北京"]) {
            continue;
        }
        NSArray *loc0 = [dict objectForKey:@"cp"];
        NSArray *loc1 = @[@"116.380943", @"39.923615"];
//        MaplyShapeGreatCircle *greatCircle = [[MaplyShapeGreatCircle alloc] init];
//        greatCircle.startPt = MaplyCoordinateMakeWithDegrees([[loc0 firstObject] floatValue], [[loc0 lastObject] floatValue]);
//        greatCircle.endPt = MaplyCoordinateMakeWithDegrees([[loc1 firstObject] floatValue], [[loc1 lastObject] floatValue]);
//        greatCircle.lineWidth = 3.0;
////        greatCircle.selectable = true;
//        // This limits the height based on the length of the great circle
//        float angle = [greatCircle calcAngleBetween];
//        greatCircle.height = 0;//0.6*angle / M_PI;
//        [circles addObject:greatCircle];
        
        MaplyCoordinate startPt = MaplyCoordinateMakeWithDegrees([[loc0 lastObject] floatValue], [[loc0 firstObject] floatValue]);
        MaplyCoordinate endPt = MaplyCoordinateMakeWithDegrees([[loc1 lastObject] floatValue], [[loc1 firstObject] floatValue]);
        
        MaplyScreenMarker *anno = [[MaplyScreenMarker alloc] init];
        anno.layoutImportance = MAXFLOAT;
        anno.loc             = MaplyCoordinateMakeWithDegrees([[loc0 firstObject] floatValue], [[loc0 lastObject] floatValue]);
        anno.size            = CGSizeMake(8, 8);
        anno.images          = self.animMakerImages;
        anno.period          = arc4random_uniform(3)+1;
        [annos addObject:anno];

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
        
        MaplyShapeLinear *line = [[MaplyShapeLinear alloc] initWithCoords:coords numCoords:(int)inNumCoords];
        line.lineWidth = 3.0;
        [self.circles addObject:line];
        
        MyMaplyShapeSphere *sphere = [[MyMaplyShapeSphere alloc] init];
        sphere.center = MaplyCoordinateMake(coords[0].x, coords[0].y);
        sphere.radius = 0.003;
        sphere.height = coords[0].z;
        sphere.speed = 2;//(int)(arc4random_uniform(2) + 2);
        sphere.index = arc4random_uniform(45);
        sphere.color = UIColorFromRGB(0xff83fb);
        [self.animShapes setObject:sphere forKey:[NSString stringWithFormat:@"%td-0", i]];
        
        MyMaplyShapeSphere *sphere1 = [[MyMaplyShapeSphere alloc] init];
        sphere1.center = MaplyCoordinateMake(coords[0].x, coords[0].y);
        sphere1.radius = 0.003;
        sphere1.height = -0.1;
        sphere1.speed = 2;//(int)(arc4random_uniform(2) + 2);
        sphere1.index = sphere.index - 45;
        sphere1.color = UIColorFromRGB(0xff83fb);
        [self.animShapes setObject:sphere1 forKey:[NSString stringWithFormat:@"%td-1", i]];

        free(coords);
    }
    
    NSArray *tempBills = [self.animShapes allValues];
    
    self.makerObj = [self.theViewC addScreenMarkers:annos desc:@{kMaplyFade: @(1.0), kMaplyDrawPriority: @(kMaplyModelDrawPriorityDefault+200)}];
    self.circleObj = [self.theViewC addShapes:self.circles desc:desc];
    [self.theViewC removeObject:self.animObj];
    self.animObj = [self.theViewC addShapes:tempBills desc:@{kMaplyShader: kMaplyShaderDefaultLine,
                                                             kMaplyDrawPriority: @(kMaplyShapeDrawPriorityDefault + 100001),
                                                         }];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timeFired) userInfo:nil repeats:YES];
}

-(void)show
{
    [self clear];
    
    NSString *fileName = [[NSBundle mainBundle] pathForResource:@"china_pros" ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:fileName];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    NSArray *locations = [json objectForKey:@"features"];
    [self addGreatCircles:locations desc:@{kMaplyColor : UIColorFromRGB(0xff83fb),
                                           kMaplyDrawPriority: @(kMaplyShapeDrawPriorityDefault + 100000),
//                                           kMaplySubdivType:kMaplySubdivGreatCircle,
//                                           kMaplySubdivEpsilon:@(0.00001),
                                           }];
}

-(void)hide
{
    [self clear];
}

-(void)timeFired
{
    for (NSInteger i=0; i<self.circles.count; i++) {
        MaplyShapeLinear *line = [self.circles objectAtIndex:i];
        
        MaplyCoordinate3d *coords;
        [line getCoords:&coords];
        
        NSString *key = [NSString stringWithFormat:@"%td-0", i];
        NSString *key1 = [NSString stringWithFormat:@"%td-1", i];
        
        [self modifySphereKey:key withCoors:coords];
        [self modifySphereKey:key1 withCoors:coords];
    }
    
    NSArray *tempBills = [self.animShapes allValues];
    
    [self.theViewC removeObject:self.animObj];
    self.animObj = [self.theViewC addShapes:tempBills desc:@{kMaplyShader: kMaplyShaderDefaultLine,
                                                       kMaplyDrawPriority: @(kMaplyShapeDrawPriorityDefault + 100001),
                                                                   }];
}

-(void)modifySphereKey:(NSString *)key withCoors:(MaplyCoordinate3d *)coors
{
    MyMaplyShapeSphere *sphere = [self.animShapes objectForKey:key];
    if (!sphere) {
        return;
    }
    
//    LOG(@"key:%@, %f, %f, %f", key, sphere.center.x, sphere.center.y, sphere.height);
    NSInteger index = sphere.index + sphere.speed;
    if (index > 90) {
        index = 0;
    }
    if (index >= 0) {
        sphere.center = MaplyCoordinateMake(coors[index].x, coors[index].y);
        sphere.height = coors[index].z;
    }
    sphere.index = index;
    
//    LOG(@"key:%@, %f, %f, %f", key, sphere.center.x, sphere.center.y, sphere.height);
    [self.animShapes setObject:sphere forKey:key];
}

-(void)clear
{
    [self.theViewC removeObject:self.makerObj];
    [self.theViewC removeObject:self.circleObj];
    [self.theViewC removeObject:self.animObj];
    
    self.circleObj = nil;
    self.animObj = nil;
    self.circles = nil;
    [self.animShapes removeAllObjects];
}
@end
