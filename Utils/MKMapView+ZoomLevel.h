//
//  MKMapView+ZoomLevel.h
//  ChinaWeather
//
//  Created by 卢大维 on 15/2/2.
//  Copyright (c) 2015年 Platomix. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MKMapView (ZoomLevel)

-(CGFloat)zoomLevel;
-(void)setZoomLevel:(CGFloat)zoomLevel;
-(void)setZoomLevel:(CGFloat)zoomLevel center:(CLLocationCoordinate2D)center animated:(BOOL)animated;
-(CGFloat)maxZoomLevel;

@end
