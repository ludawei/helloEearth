//
//  CWHttpCmdNewGeoArea.h
//  ChinaWeather
//
//  Created by 卢大维 on 14-7-22.
//  Copyright (c) 2014年 Platomix. All rights reserved.
//

#import "PLHttpCmd.h"

@interface CWHttpCmdNewGeoArea : PLHttpCmd

@property (nonatomic, strong) NSString *longitude;
@property (nonatomic, strong) NSString *latitude;

@end
