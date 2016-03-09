//
//  HEWorldRandItem.m
//  HelloEarth
//
//  Created by 卢大维 on 16/3/9.
//  Copyright © 2016年 weather. All rights reserved.
//

#import "HEWorldRandItem.h"

@interface HEWorldRandItem ()
{
    NSArray *worldCitys;
}

@property (nonatomic,strong) NSMutableArray *labelObjs, *markObjs, *animMarkObjs;
@property (nonatomic,strong) NSMutableArray *randWorldIndexs;

@end

@implementation HEWorldRandItem

- (void)dealloc
{
    [self hide];
    worldCitys = nil;
}

-(instancetype)init
{
    if (self = [super init]) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"world_cities" ofType:@"txt"];
        NSString *fileData = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        worldCitys = [fileData componentsSeparatedByString:@"\r\n"];
    }
    return self;
}

-(void)addPointWithIndex:(NSInteger)index
{
    NSString *loc = [worldCitys objectAtIndex:index];
    NSArray *items = [loc componentsSeparatedByString:@","];
    if (items.count == 3) {
        NSString *name = [items firstObject];
        NSString *lat = [items objectAtIndex:1];
        NSString *lon = [items lastObject];
        
        MaplyScreenLabel *label = [[MaplyScreenLabel alloc] init];
        label.loc = MaplyCoordinateMakeWithDegrees(lon.floatValue, lat.floatValue);
        //        label.keepUpright = true;
        //        label.layoutPlacement = kMaplyLayoutRight;
        label.layoutImportance = 2;
        label.offset = CGPointMake(4, 3);
        label.text = name;//[@"•" stringByAppendingString:name];
        MaplyComponentObject *labelObj = [self.delegate addLabels:@[label]];
        
        NSInteger randSizeWidth = arc4random_uniform(4);
        MaplyScreenMarker *anno = [[MaplyScreenMarker alloc] init];
        anno.layoutImportance   = MAXFLOAT;
        anno.loc                = MaplyCoordinateMakeWithDegrees(lon.floatValue, lat.floatValue);
        anno.size               = CGSizeMake(10-randSizeWidth, 10-randSizeWidth);
        anno.image              = [UIImage imageNamed:@"city_data_mark1"];
        MaplyComponentObject *annoObj = [self.delegate addAnimMarkers:@[anno]];
        
        MaplyScreenMarker *animAnno = [[MaplyScreenMarker alloc] init];
        animAnno.layoutImportance   = MAXFLOAT;
        animAnno.loc                = MaplyCoordinateMakeWithDegrees(lon.floatValue, lat.floatValue);
        animAnno.size               = CGSizeMake(50 - randSizeWidth * 4, 50 - randSizeWidth * 4);
        animAnno.images             = @[[UIImage imageNamed:@"国外－1"], [UIImage imageNamed:@"国外－2"], [UIImage imageNamed:@"国外－3"]];
        animAnno.period             = 0.8;
        MaplyComponentObject *animAnnoObj =[self.delegate addAnimMarkers:@[animAnno]];
        
        CGFloat randTime = arc4random_uniform(10);
        CGFloat randTime1 = randTime / 10.0 * 2.0 + 2;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(randTime1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.delegate removeAnimMarkers:@[animAnnoObj]];
            [self.animMarkObjs removeObject:animAnnoObj];
            
            CGFloat randTime2 = randTime/10.0 * 4 + 2.5;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(randTime2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                [self.delegate removeAnimMarkers:@[labelObj, annoObj]];
                [self.labelObjs removeObject:labelObj];
                [self.markObjs removeObject:annoObj];
                
                [self.randWorldIndexs removeObject:@(index)];
                
                CGFloat randTime3 = randTime/10.0 * 5 + 0.5;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(randTime3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    NSInteger index = [self getRandomIndex];
                    [self addPointWithIndex:index];
                });
            });
        });
        
        [self.randWorldIndexs addObject:@(index)];
        [self.labelObjs addObject:labelObj];
        [self.markObjs addObject:annoObj];
        [self.animMarkObjs addObject:animAnnoObj];
        
    }
}

-(NSInteger)getRandomIndex
{
    NSInteger rand = arc4random_uniform((int)worldCitys.count);
//    if (self.randWorldIndexs.count > 0) {
//        rand = ([self.randWorldIndexs.lastObject integerValue] + 500)%worldCitys.count;
//    }
    if ([self.randWorldIndexs containsObject:@(rand)]) {
        rand = [self getRandomIndex];
    }
    
    return rand;
}

-(void)show
{
    self.randWorldIndexs = [NSMutableArray array];
    self.labelObjs = [NSMutableArray array];
    self.markObjs = [NSMutableArray array];
    self.animMarkObjs = [NSMutableArray array];
    
    for (NSInteger i=0; i<10; i++) {
        NSInteger index = [self getRandomIndex];
        [self addPointWithIndex:index];
    }
}

-(void)hide
{
    [self.delegate removeAnimMarkers:self.labelObjs];
    [self.delegate removeAnimMarkers:self.markObjs];
    [self.delegate removeAnimMarkers:self.animMarkObjs];
    
    [self.randWorldIndexs removeAllObjects];
    [self.labelObjs removeAllObjects];
    [self.markObjs removeAllObjects];
    [self.animMarkObjs removeAllObjects];
}

@end
