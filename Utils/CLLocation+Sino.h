//
//  CLLocation+Sino.h
//  ChinaWeather
//
//  Created by 卢大维 on 15/3/13.
//  Copyright (c) 2015年 Platomix. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface CLLocation (Sino)

- (CLLocation*)locationMarsFromEarth;
//- (CLLocation*)locationEarthFromMars; // 未实现

- (CLLocation*)locationBearPawFromMars;
- (CLLocation*)locationMarsFromBearPaw;

@end
