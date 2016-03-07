//
//  MyMaplyShapeLinear.h
//  HelloEarth
//
//  Created by 卢大维 on 16/3/1.
//  Copyright © 2016年 weather. All rights reserved.
//

#import <WhirlyGlobeMaplyComponent/WhirlyGlobeComponent.h>

@protocol MyMaplyShapeLinearDelegate;

@interface MyMaplyShapeLinear : NSObject

@property (nonatomic,assign) NSInteger firstIndex;
@property (nonatomic,assign) NSInteger indexLength;
@property (nonatomic,assign) NSInteger delayHideCount;
@property (nonatomic,copy) NSArray *pointCounts;
@property (nonatomic,copy) NSArray *points;


@property (nonatomic,weak) id<MyMaplyShapeLinearDelegate> delegate;

-(id)initWithCoords:(MaplyCoordinate3d *)coords numCoords:(int)numCoords;
//-(MaplyShapeLinear *)updateLine;
-(void)timeFired;
-(void)removeStaticMarkers;

@end

@protocol MyMaplyShapeLinearDelegate  <NSObject>

-(MaplyComponentObject *)updateWithLine:(MaplyShapeLinear *)line lineObj:(MaplyComponentObject *)lineObj;
-(void)removeMyLine:(MyMaplyShapeLinear *)myLine lineObj:(MaplyComponentObject *)lineObj;

-(MaplyComponentObject *)addAnimMarkers:(NSArray *)markers;
-(void)removeAnimMarker:(MaplyComponentObject *)markerObj;


@end
