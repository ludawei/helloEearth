//
//  MyMaplyShapeLinear.m
//  HelloEarth
//
//  Created by 卢大维 on 16/3/1.
//  Copyright © 2016年 weather. All rights reserved.
//

#import "MyMaplyShapeLinear.h"

@implementation MyMaplyShapeLinear
{
    MaplyCoordinate3d *coords;
    NSInteger numCoords;
    MaplyShapeLinear *currLine;
    MaplyComponentObject *lineObj;
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

-(void)dealloc
{
    if (coords)
        free(coords);
    coords = NULL;
    
    if (currLine) {
        currLine = nil;
    }
}

#if 0
-(MaplyShapeLinear *)updateLine
{
    if (self.firstIndex - self.indexLength >= numCoords) {
        return nil;
    }
    
    self.firstIndex++;
    
    MaplyCoordinate3d *currCoords = (MaplyCoordinate3d *)malloc(sizeof(MaplyCoordinate3d)*self.indexLength);
    for (NSInteger i=0;i<self.indexLength;i++)
    {
        NSInteger ii = self.firstIndex-self.indexLength+i;
        if (ii < 0) {
            currCoords[i] = coords[0];
        }
        else if (ii > numCoords - 1)
        {
            currCoords[i] = coords[numCoords-1];
        }
        else
        {
            currCoords[i] = coords[ii];
        }
        
    }
    
    MaplyShapeLinear *line = [[MaplyShapeLinear alloc] initWithCoords:currCoords numCoords:(int)self.indexLength];
    line.lineWidth = 15.0;
    
    free(currCoords);
    
    return line;
    
    MaplyScreenMarker *anno = [[MaplyScreenMarker alloc] init];
    anno.layoutImportance = MAXFLOAT;
    anno.loc             = MaplyCoordinateMakeWithDegrees([[loc0 firstObject] floatValue], [[loc0 lastObject] floatValue]);
    anno.size            = CGSizeMake(8, 8);
    anno.images          = self.animMakerImages;
    anno.period          = arc4random_uniform(3)+1;
    [annos addObject:anno];

}
#else
-(MaplyShapeLinear *)updateLine
{
    if (self.firstIndex >= numCoords) {
        if (self.delayHideCount > 0) {
            self.delayHideCount--;
            return currLine;
        }
        return nil;
    }
    
    if ([self.pointCounts containsObject:@(self.firstIndex)]) {
        NSInteger index = [self.pointCounts indexOfObject:@(self.firstIndex)];
        
        NSDictionary *point = [self.points objectAtIndex:index];
        if (point) {
            MaplyScreenMarker *anno = [[MaplyScreenMarker alloc] init];
            anno.layoutImportance = MAXFLOAT;
            anno.loc             = MaplyCoordinateMakeWithDegrees([[point objectForKey:@"longitude"] floatValue], [[point objectForKey:@"latitude"] floatValue]);
            anno.size            = CGSizeMake(8, 8);
            anno.images          = @[[UIImage imageNamed:@"国内－1"], [UIImage imageNamed:@"国内－2"], [UIImage imageNamed:@"国内－3"]];
            anno.period          = 0.6;
            MaplyComponentObject *obj =[self.delegate addAnimMarker:anno];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
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
    line.lineWidth = 5.0;
    currLine = line;
    
    free(currCoords);
    
    return line;
}
#endif

-(void)timeFired
{
    if (self.firstIndex >= numCoords) {
        if (self.delayHideCount > 0) {
            self.delayHideCount--;
            
            lineObj = [self.delegate updateWithLine:currLine lineObj:lineObj];
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
            MaplyComponentObject *obj =[self.delegate addAnimMarker:anno];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
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
    line.lineWidth = 5.0;
    currLine = line;
    
    free(currCoords);
    
    lineObj = [self.delegate updateWithLine:currLine lineObj:lineObj];
}
@end
