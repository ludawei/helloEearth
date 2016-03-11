//
//  HEMapDatas.m
//  HelloEarth
//
//  Created by 卢大维 on 15/8/14.
//  Copyright (c) 2015年 weather. All rights reserved.
//

#import "HEMapDatas.h"
#import "Util.h"
//#import "WhirlyGlobeComponent.h"
#import <WhirlyGlobeMaplyComponent/WhirlyGlobeComponent.h>
#import "CWDataManager.h"

#define COLOR_APHLE 0.7

@interface HEMapDatas ()

@property (nonatomic,strong) MaplyBaseViewController *theViewC;

@property (nonatomic,copy) NSDictionary *data;
@property (nonatomic,copy) NSArray *areas;

@end

@implementation HEMapDatas

-(instancetype)initWithController:(UIViewController *)theViewC
{
    if (self = [super init]) {
        self.theViewC = (MaplyBaseViewController *)theViewC;
    }
    
    return self;
}

-(NSArray *)changeType:(NSString *)type
{
    self.data = nil;
    self.areas = nil;
    
    [self initData:type];
    return [self setupLayer];
}

-(void)initData:(NSString *)name
{
    id data = [[CWDataManager sharedInstance] mapdataByFileMark:name];
    
    if ([data isKindOfClass:[NSArray class]]) {
        self.areas = data;
    }
    else
    {
        self.data = data;
    }
}

-(NSArray *)setupLayer
{
    NSMutableArray *comObjs = [NSMutableArray array];
    
    if (self.data) {
        if ([self.data objectForKey:@"r"]) {
            [comObjs addObjectsFromArray:[self addAreasToMap2]];
        }
        else
        {
            [comObjs addObjectsFromArray:[self addAreasToMap]];
            
//            [comObjs addObjectsFromArray:[self addLine_symbolsToMap]];
        }
        //        [self addSymbolsToMap];
    }
    
    if (self.areas) {
        [comObjs addObjectsFromArray:[self addAreasToMap1]];
    }
    
    return comObjs;
}

-(NSArray *)addAreasToMap
{
    NSMutableArray *comObjs = [NSMutableArray array];
    
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
            UIColor *color = [Util colorFromRGBString:[area objectForKey:@"c"] alpha:COLOR_APHLE];
            
//            BOOL isStripe = [[area objectForKey:@"is_stripe"] integerValue] == 1;
//            if (isStripe) {
//                
//                UIImage *image = [UIImage imageNamed:@"图例_stripe"];
//                image = [Util imageChangedWithColor:color image:image];
//                MaplyTexture *imageTex = [self.theViewC addTexture:image imageFormat:MaplyImageUShort5551 wrapFlags:0 mode:MaplyThreadAny];
//                
//                vectorDict = @{
////                               kMaplyColor: color,
//                               kMaplyFilled: @(true),
//                               kMaplyVecTexture: imageTex,
//                               kMaplyVecTextureProjection:kMaplyProjectionScreen,
//                               kMaplyVecTexScaleX:@(10.0/image.size.width),
//                               kMaplyVecTexScaleY:@(10.0/image.size.width),
//                               kMaplyDrawPriority: @(kMaplyLoftedPolysDrawPriorityDefault+index),
//                               kMaplySubdivType:kMaplySubdivGrid,
//                               kMaplySubdivEpsilon:@(0.01),
//                               };
//            }
//            else
            {
                vectorDict = @{
                               kMaplyColor: color,
                               kMaplyDrawPriority: @(kMaplyLoftedPolysDrawPriorityDefault+index),
                               kMaplyFilled: @(true),
                               kMaplySubdivType:kMaplySubdivGrid,
                               kMaplySubdivEpsilon:@(0.01),
                               };
            }
        }
        
        MaplyVectorObject *vect = [[MaplyVectorObject alloc] initWithAreal:points numCoords:(int)items.count attributes:nil];
        vect.selectable = true;
        free(points);
        
        MaplyComponentObject *comObj = [self.theViewC addVectors:[NSArray arrayWithObject:vect] desc:vectorDict mode:MaplyThreadCurrent];
        
        [comObjs addObject:comObj];
    }
    
    return comObjs;
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

-(NSArray *)addLine_symbolsToMap
{
    NSMutableArray *comObjs = [NSMutableArray array];
    
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
        
        [comObjs addObject:comObj];
    }
    
    return comObjs;
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

-(NSArray *)addAreasToMap1
{
    NSMutableArray *comObjs = [NSMutableArray array];
    
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
            UIColor *color = [Util colorFromRGBString:[area objectForKey:@"color"] alpha:COLOR_APHLE];
            vectorDict = @{
                           kMaplyColor: color,
                           kMaplyDrawPriority: @(kMaplyLoftedPolysDrawPriorityDefault+index),
                           kMaplySelectable: @(true),
                           kMaplyFilled: @(true),
                           kMaplySubdivType:kMaplySubdivGrid,
                           kMaplySubdivEpsilon:@(0.01),
                           kMaplyDrawOffset: @(0),
                           };
        }
        
        MaplyVectorObject *vect = [[MaplyVectorObject alloc] initWithAreal:points numCoords:(int)items.count attributes:nil];
        vect.selectable = true;
        free(points);
        
        MaplyComponentObject *comObj = [self.theViewC addVectors:[NSArray arrayWithObject:vect] desc:vectorDict mode:MaplyThreadCurrent];
        
        [comObjs addObject:comObj];
    }
    
    return comObjs;
}


-(NSArray *)addAreasToMap2
{
    NSArray *r = [self.data objectForKey:@"r"];
    NSArray *lists = [self.data objectForKey:@"list"];
    
    NSMutableArray *comObjs = [NSMutableArray array];
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
            UIColor *c = [Util colorFromRGBString:color alpha:COLOR_APHLE];
            vectorDict = @{
                           kMaplyColor: c,
                           kMaplyDrawPriority: @(kMaplyLoftedPolysDrawPriorityDefault+index),
                           kMaplySelectable: @(true),
                           kMaplyFilled: @(true),
                           kMaplySubdivType:kMaplySubdivGrid,
                           kMaplySubdivEpsilon:@(0.01),
                           kMaplyDrawOffset: @(0),
                           };
        }
        
        MaplyVectorObject *vect = [[MaplyVectorObject alloc] initWithAreal:points numCoords:(int)items.count attributes:nil];
        vect.selectable = true;
        free(points);
        
        MaplyComponentObject *comObj = [self.theViewC addVectors:[NSArray arrayWithObject:vect] desc:vectorDict mode:MaplyThreadCurrent];
        
        [comObjs addObject:comObj];
    }
    
    return comObjs;
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
@end
