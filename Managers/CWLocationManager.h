//
//  CWLocationManager.h
//  ChinaWeather
//
//  Created by ludawei on 13-8-28.
//  Copyright (c) 2013年 Platomix. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "CLLocation+Sino.h"

@interface CWLocationManager : NSObject
<CLLocationManagerDelegate>

@property (nonatomic,strong) CLLocationManager* locationManager;
@property (nonatomic,strong) CLPlacemark *plackMark;

+ (CWLocationManager *)sharedInstance;

-(void)updateLocation;
-(void)stopLocation;
@end
