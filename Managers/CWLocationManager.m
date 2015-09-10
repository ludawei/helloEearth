//
//  CWLocationManager.m
//  ChinaWeather
//
//  Created by ludawei on 13-8-28.
//  Copyright (c) 2013年 Platomix. All rights reserved.
//

#import "CWLocationManager.h"
#import "CLLocation+Sino.h"

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
    self.locationManager.distanceFilter = 10.0f;
    
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
}

#pragma mark - CLLocationManagerDelegate
-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    newLocation = [newLocation locationMarsFromEarth];
    NSString *latitudeText = [NSString stringWithFormat:@"%lf",newLocation.coordinate.latitude];
    NSString *longitudeText = [NSString stringWithFormat:@"%lf",newLocation.coordinate.longitude];
    LOG(@"定位成功!%@,%@", latitudeText,longitudeText);
    
    // 只定位一次,不更新位置
    [self.locationManager stopUpdatingLocation];
    self.locationManager.delegate = nil;
    self.locationManager = nil;
    // 请求完成

    [[NSNotificationCenter defaultCenter] postNotificationName:noti_update_location object:nil userInfo:@{LATITUDE_KEY: latitudeText, LONGITUDE_KEY: longitudeText}];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    LOG(@"定位失败!");
    
    // 请求完成
    [[NSNotificationCenter defaultCenter] postNotificationName:noti_update_location object:nil userInfo:@{@"error": error}];
}

@end
