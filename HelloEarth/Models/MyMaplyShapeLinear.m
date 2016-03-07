//
//  MyMaplyShapeLinear.m
//  HelloEarth
//
//  Created by 卢大维 on 16/3/1.
//  Copyright © 2016年 weather. All rights reserved.
//

#import "MyMaplyShapeLinear.h"
#import "Util.h"

@implementation MyMaplyShapeLinear
{
    MaplyCoordinate3d *coords;
    NSInteger numCoords;
    MaplyShapeLinear *currLine;
    MaplyComponentObject *lineObj, *staticMarkerObj;
}

-(id)initWithCoords:(MaplyCoordinate3d *)inCoords numCoords:(int)inNumCoords
{
    if (self = [super init]) {
        
        numCoords = inNumCoords;
        coords = (MaplyCoordinate3d *)malloc(sizeof(MaplyCoordinate3d)*inNumCoords);
        for (unsigned int ii=0;ii<numCoords;ii++)
        {
            coords[ii] = inCoords[ii];
        }
    }
    
    return self;
}

-(void)setPoints:(NSArray *)points
{
    _points = points;
    if (points) {
        NSMutableArray *marks = [NSMutableArray array];
        for (NSInteger i=0; i<points.count; i++) {
            NSDictionary *point = [self.points objectAtIndex:i];
            
            CGFloat sizeWidth = 8;
            if (i < self.points.count-1) {
                sizeWidth = 9 - (self.points.count - 1 - i) * 2;
            }
            
            if (point) {
                MaplyScreenMarker *anno = [[MaplyScreenMarker alloc] init];
                anno.layoutImportance = MAXFLOAT;
                anno.loc             = MaplyCoordinateMakeWithDegrees([[point objectForKey:@"longitude"] floatValue], [[point objectForKey:@"latitude"] floatValue]);
                anno.size            = CGSizeMake(sizeWidth, sizeWidth);
//                anno.color           = [Util colorFromRGBString:@"#00ff00" alpha:1.0];
                anno.image           = [UIImage imageNamed:@"city_data_mark"];
                [marks addObject:anno];
            }
        }
        staticMarkerObj = [self.delegate addAnimMarkers:marks];
    }
}

-(void)dealloc
{
    if (coords)
        free(coords);
    coords = NULL;
    
    if (currLine) {
        currLine = nil;
    }
    
    [self removeStaticMarkers];
}

-(void)removeStaticMarkers
{
    if (staticMarkerObj) {
        [self.delegate removeAnimMarker:staticMarkerObj];
        staticMarkerObj = nil;
    }
}

-(void)timeFired
{
    if (self.firstIndex >= numCoords) {
        if (self.delayHideCount > 0) {
            self.delayHideCount--;
            
            lineObj = [self.delegate updateWithLine:currLine lineObj:lineObj];
            if (staticMarkerObj) {
                [self.delegate removeAnimMarker:staticMarkerObj];
                staticMarkerObj = nil;
            }
        }
        else
        {
            [self.delegate removeMyLine:self lineObj:lineObj];
        }
        return;
    }
    
    if ([self.pointCounts containsObject:@(self.firstIndex)])
    {
        NSInteger index = [self.pointCounts indexOfObject:@(self.firstIndex)];
        
        CGFloat sizeWidth = 30;
        if (index < self.pointCounts.count-1) {
            sizeWidth = 37 - (self.pointCounts.count - 1 - index) * 9;
        }
        
        NSDictionary *point = [self.points objectAtIndex:index];
        if (point) {
            MaplyScreenMarker *anno = [[MaplyScreenMarker alloc] init];
            anno.layoutImportance = MAXFLOAT;
            anno.loc             = MaplyCoordinateMakeWithDegrees([[point objectForKey:@"longitude"] floatValue], [[point objectForKey:@"latitude"] floatValue]);
            anno.size            = CGSizeMake(sizeWidth, sizeWidth);
            anno.images          = @[[UIImage imageNamed:@"国内－1"], [UIImage imageNamed:@"国内－2"], [UIImage imageNamed:@"国内－3"]];
            anno.period          = 0.8;
            MaplyComponentObject *obj =[self.delegate addAnimMarkers:@[anno]];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.delegate removeAnimMarker:obj];
            });
        }
        
    }
    
    self.firstIndex++;
    
    MaplyCoordinate3d *currCoords = (MaplyCoordinate3d *)malloc(sizeof(MaplyCoordinate3d)*self.firstIndex);
    for (NSInteger i=0;i<self.firstIndex;i++)
    {
        currCoords[i] = coords[i];
    }
    
    MaplyShapeLinear *line = [[MaplyShapeLinear alloc] initWithCoords:currCoords numCoords:(int)self.firstIndex];
    line.lineWidth = 2.0;
    currLine = line;
    
    free(currCoords);
    
    lineObj = [self.delegate updateWithLine:currLine lineObj:lineObj];
}
@end
