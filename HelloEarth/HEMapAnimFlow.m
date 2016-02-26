//
//  HEMapAnimFlow.m
//  HelloEarth
//
//  Created by 卢大维 on 16/2/22.
//  Copyright © 2016年 weather. All rights reserved.
//

#import "HEMapAnimFlow.h"

@interface HEMapAnimFlow ()

@property (nonatomic,strong) MaplyBaseViewController *theViewC;

@property (nonatomic,strong) MaplyComponentObject *circleObj, *animObj;
@property (nonatomic,strong) NSMutableArray *animShapes;

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

- (void)addGreatCircles:(NSArray *)locations desc:(NSDictionary *)desc
{
//    MaplyCoordinateSystem *coordSys = [[MaplySphericalMercator alloc] initWebStandard];
    
    NSMutableArray *circles = [[NSMutableArray alloc] init];
    NSMutableArray *bills = [[NSMutableArray alloc] init];
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

        CGFloat angle = MaplyGreatCircleDistance(startPt, endPt) / 6371000.0;
        CGFloat height = 0.4 * angle / M_PI;
        int inNumCoords = 100;
        
        MaplyCoordinate3d *coords = (MaplyCoordinate3d *)malloc(sizeof(MaplyCoordinate3d)*inNumCoords);
        for (int i=0; i<inNumCoords; i++) {
            CGFloat r = 1.0 * i / (inNumCoords-1);
            CGFloat x = (endPt.x - startPt.x)*r + startPt.x;
            CGFloat y = (endPt.y - startPt.y)*r + startPt.y;
            CGFloat z = 0;
            
            
            if (i >= inNumCoords/2.0) {
                z = height * (1 - r) * (1.0 + r) * (1.0 + r) * (1.0 + r);
            }
            else
            {
                z = height * r * (1.0 + 1.0 - r) * (1.0 + 1.0 - r) * (1.0 + 1.0 - r);
            }
            coords[i] = MaplyCoordinate3dMake(y, x, z);
        }
        
        MaplyShapeLinear *line = [[MaplyShapeLinear alloc] initWithCoords:coords numCoords:inNumCoords];
        line.lineWidth = 3.0;
        [circles addObject:line];
//        CGFloat centX = ([[loc1 firstObject] floatValue] + [[loc0 firstObject] floatValue])/2.0;//([[loc1 firstObject] floatValue] - [[loc0 firstObject] floatValue])/2.0 + [[loc0 firstObject] floatValue];
//        CGFloat centY = ([[loc1 lastObject] floatValue] + [[loc0 lastObject] floatValue])/2.0;//([[loc1 lastObject] floatValue] - [[loc0 lastObject] floatValue])/2.0 + [[loc0 lastObject] floatValue];
//        MaplyCoordinate centCoor = [self getCenterWithP0:greatCircle.startPt p1:greatCircle.endPt];//MaplyCoordinateMakeWithDegrees(centX, centY);

//        MaplyBoundingBox boundingBox;
//        boundingBox.ll = greatCircle.startPt;
//        boundingBox.ur = greatCircle.endPt;
        
        
//        MaplyShapeSphere *sphere = [[MaplyShapeSphere alloc] init];
//        sphere.center = MaplyCoordinateMakeWithDegrees(certCoor.x, certCoor.y);
//        sphere.radius = 0.0015;
//        sphere.height = 0;
//        sphere.color = [UIColor whiteColor];

//        MaplyBillboard *bill = [[MaplyBillboard alloc] init];
//        bill.center = MaplyCoordinate3dMake(centCoor.x, centCoor.y, greatCircle.height + 1);
//        bill.selectable = false;
//        bill.screenObj = [[MaplyScreenObject alloc] init];
//        UIImage *moonImage = [UIImage imageNamed:@"star_background"];
//        [bill.screenObj addImage:moonImage color:[UIColor whiteColor] size:CGSizeMake(0.05, 0.05)];
//        [bills addObject:sphere];
        
    }
    
    self.circleObj = [self.theViewC addShapes:circles desc:desc];
//    [self.theViewC addShapes:bills desc:desc];
//    [self.theViewC addBillboards:bills desc:@{kMaplyDrawPriority: @(100000),
//                                              kMaplyBillboardOrient: kMaplyBillboardOrientEye} mode:MaplyThreadCurrent];
}

-(void)show
{
    self.animShapes = [NSMutableArray array];
    
    NSString *fileName = [[NSBundle mainBundle] pathForResource:@"china_pros" ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:fileName];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    NSArray *locations = [json objectForKey:@"features"];
    [self addGreatCircles:locations desc:@{kMaplyColor : UIColorFromRGB(0xff83fb),
//                                           kMaplyFade: @(1.0),
                                           kMaplyDrawPriority: @(kMaplyShapeDrawPriorityDefault + 100000),
//                                           kMaplyZBufferRead: @(NO),
//                                           kMaplySubdivType:kMaplySubdivGreatCircle,
//                                           kMaplySubdivEpsilon:@(0.00001),
//                                           kMaplyDrawOffset:@0.0,
                                           }];
}

-(void)hide
{
    [self clear];
}

-(void)clear
{
    [self.theViewC removeObject:self.circleObj];
    [self.theViewC removeObject:self.animObj];
    
    self.circleObj = nil;
    self.animObj = nil;
    [self.animShapes removeAllObjects];
}
@end
