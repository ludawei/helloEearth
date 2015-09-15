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
#define STATUS_HEIGHT [UIApplication sharedApplication].statusBarFrame.size.height
#define SELF_NAV_HEIGHT self.navigationController.navigationBar.frame.size.height

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#import "UIView+ModifyFrame.h"

#define LATITUDE_KEY @"latitude"
#define LONGITUDE_KEY @"longitude"

static NSString *weather_appId = @"6f688d62594549a2";
static NSString *weather_priKey = @"chinaweather_data";

#define UM_APP_KEY      @"55f0daec67e58e0575005f7a"
#define WX_APP_ID       @"wxbc89693e04ffe96d"
#define WX_APP_SECRET   @"45e671165935476d5afe75b60d2e81de"
#define QQ_APP_ID       @"1104849710"
#define QQ_APP_KEY      @"kZt9WFoWgv9bVpjI"

static NSString *noti_update_location = @"noti_update_location";

#endif
