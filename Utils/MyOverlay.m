//
//  MyOverlay.m
//  MapAnimCover
//
//  Created by 卢大维 on 15/1/29.
//  Copyright (c) 2015年 weather. All rights reserved.
//

#import "MyOverlay.h"

@interface MyOverlay ()

@property (nonatomic) CLLocationCoordinate2D northEast,southWest;

@end

@implementation MyOverlay

-(instancetype)initWithNorthEast:(CLLocationCoordinate2D)northEast southWest:(CLLocationCoordinate2D)southWest
{
    if (self = [super init]) {
        self.northEast = northEast;
        self.southWest = southWest;
    }
    
    return self;
}

-(instancetype)initWithRegion:(MKCoordinateRegion)region
{
    if (self = [super init]) {
        self.northEast = CLLocationCoordinate2DMake(region.center.latitude+region.span.latitudeDelta/2, region.center.longitude-region.span.longitudeDelta/2);
        self.southWest = CLLocationCoordinate2DMake(region.center.latitude-region.span.latitudeDelta/2, region.center.longitude+region.span.longitudeDelta/2);
    }
    
    return self;
}

-(CLLocationCoordinate2D)coordinate
{
    return CLLocationCoordinate2DMake(self.northEast.latitude-(self.northEast.latitude-self.southWest.latitude)/2.0, self.southWest.longitude-(self.southWest.longitude-self.northEast.longitude)/2.0);
}

-(MKMapRect)boundingMapRect
{
    //Latitue and longitude for each corner point
    MKMapPoint upperLeft   = MKMapPointForCoordinate(self.northEast);
    MKMapPoint bottomRight  = MKMapPointForCoordinate(self.southWest);
    
    //Building a map rect that represents the image projection on the map
    MKMapRect bounds = MKMapRectMake(upperLeft.x, upperLeft.y, fabs(upperLeft.x - bottomRight.x), fabs(upperLeft.y - bottomRight.y));
    
    return bounds;
}
@end
