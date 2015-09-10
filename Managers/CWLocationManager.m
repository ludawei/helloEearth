//
//  CWLocationManager.m
//  ChinaWeather
//
//  Created by ludawei on 13-8-28.
//  Copyright (c) 2013年 Platomix. All rights reserved.
//

#import "CWLocationManager.h"

@interface CWLocationManager ()

@property (nonatomic,strong) CLGeocoder *geocoder;

@end

@implementation CWLocationManager

+ (CWLocationManager *)sharedInstance {
    static CWLocationManager *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

-(void)updateLocation
{
    // 定位
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    self.locationManager.distanceFilter = 100.0f;
    
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
}

-(void)stopLocation
{
    [self.locationManager stopUpdatingLocation];
    self.locationManager.delegate = nil;
    self.locationManager = nil;
    
    self.plackMark = nil;
}

#pragma mark - CLLocationManagerDelegate
-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    newLocation = [newLocation locationMarsFromEarth];
    NSString *latitudeText = [NSString stringWithFormat:@"%lf",newLocation.coordinate.latitude];
    NSString *longitudeText = [NSString stringWithFormat:@"%lf",newLocation.coordinate.longitude];
    LOG(@"定位成功!%@,%@", latitudeText,longitudeText);
    
    // 只定位一次,不更新位置
//    [self.locationManager stopUpdatingLocation];
//    self.locationManager.delegate = nil;
//    self.locationManager = nil;
    // 请求完成
    if (!self.geocoder) {
        self.geocoder = [[CLGeocoder alloc] init];
    }
    
    if (self.geocoder.isGeocoding) {
        [self.geocoder cancelGeocode];
    }
    
    [self.geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray* placemarks,NSError *error)
     {
         NSString *mapName;
         if (placemarks.count > 0   )
         {
             CLPlacemark * plmark = [placemarks objectAtIndex:0];
             
             mapName = plmark.name;
             
             LOG(@"1:%@2:%@3:%@4:%@",  plmark.locality, plmark.subLocality,plmark.thoroughfare,plmark.subThoroughfare);
             
             self.plackMark = plmark;
             
             [[NSNotificationCenter defaultCenter] postNotificationName:noti_update_location object:nil userInfo:nil];
         }
     }];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    LOG(@"定位失败!");
    
    // 请求完成
    [[NSNotificationCenter defaultCenter] postNotificationName:noti_update_location object:nil userInfo:@{@"error": error}];
}

@end
