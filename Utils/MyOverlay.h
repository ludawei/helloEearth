//
//  MyOverlay.h
//  MapAnimCover
//
//  Created by 卢大维 on 15/1/29.
//  Copyright (c) 2015年 weather. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MyOverlay : NSObject<MKOverlay>

-(instancetype)initWithNorthEast:(CLLocationCoordinate2D)northEast southWest:(CLLocationCoordinate2D)southWest;
-(instancetype)initWithRegion:(MKCoordinateRegion)region;

@end
