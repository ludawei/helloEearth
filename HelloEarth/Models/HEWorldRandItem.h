//
//  HEWorldRandItem.h
//  HelloEarth
//
//  Created by 卢大维 on 16/3/9.
//  Copyright © 2016年 weather. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WhirlyGlobeMaplyComponent/WhirlyGlobeComponent.h>

@protocol HEWorldRandItemDelegate <NSObject>

-(MaplyComponentObject *)addAnimMarkers:(NSArray *)markers;
-(MaplyComponentObject *)addLabels:(NSArray *)labels;
-(void)removeAnimMarkers:(NSArray *)markerObjs;


@end

@interface HEWorldRandItem : NSObject

@property (nonatomic,weak) id<HEWorldRandItemDelegate> delegate;

-(void)show;
-(void)hide;

@end
