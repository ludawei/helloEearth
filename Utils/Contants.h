//
//  Contants.h
//  chinaweathernews
//
//  Created by 卢大维 on 14-10-17.
//  Copyright (c) 2014年 weather. All rights reserved.
//

#ifndef chinaweathernews_Contants_h
#define chinaweathernews_Contants_h

#define SCREEN_SIZE ((CGSize)[UIScreen mainScreen].bounds.size)

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#import "UIView+ModifyFrame.h"

#define LATITUDE_KEY @"latitude"
#define LONGITUDE_KEY @"longitude"

static NSString *weather_appId = @"6f688d62594549a2";
static NSString *weather_priKey = @"chinaweather_data";

/*************** keys ********************/
static NSString *UM_SHARE_KEY = @"546559d6fd98c5d052006702";
/*************** keys ********************/

static NSString *noti_update_location = @"noti_update_location";

#endif
