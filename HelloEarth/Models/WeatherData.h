//
//  WeatherData.h
//  NextRain
//
//  Created by 卢大维 on 14-10-24.
//  Copyright (c) 2014年 weather. All rights reserved.
//

#import "PLBaseObject.h"

@interface WeatherData : PLBaseObject

-(instancetype)initWithWeather:(NSDictionary *)weather;

/******************** 当天天气数据 *********************/
@property (nonatomic,copy) NSString *todayWeekStr;
@property (nonatomic,copy) NSString *todayDateStr;
@property (nonatomic,copy) NSString *currWeather;
@property (nonatomic,copy) NSString *iconCurrWeather;
@property (nonatomic,copy) NSString *visibility;
@property (nonatomic,copy) NSString *iconTodayDayStr;
@property (nonatomic,copy) NSString *iconTodayNightStr;
@property (nonatomic,copy) NSString *todayTopTemprature;
@property (nonatomic,copy) NSString *todayLowestTemprature;
@property (nonatomic,copy) NSString *currTemprature;
@property (nonatomic,copy) NSString *bodyTemprature;
@property (nonatomic,copy) NSString *airQuallity;
@property (nonatomic,copy) NSString *currWindStatus;
@property (nonatomic,copy) NSString *currHumidity;
@property (nonatomic,strong) NSArray *daysWeatherDatas;
@property (nonatomic,strong) NSArray *hoursWeatherDatas;

@end

/******************** 15天天气数据 *********************/
@interface WeatherDayData : PLBaseObject

@property (nonatomic,copy) NSString *weekStr;
@property (nonatomic,copy) NSString *dateStr;
@property (nonatomic,copy) NSString *iconDayStr;
@property (nonatomic,copy) NSString *iconNightStr;
@property (nonatomic,copy) NSString *topTemprature;
@property (nonatomic,copy) NSString *lowestTemprature;

@end

/******************** 15天天气数据 *********************/

/******************** 小时天气数据 *********************/
@interface WeatherHourData : PLBaseObject

@property (nonatomic,copy) NSString *time;
@property (nonatomic,copy) NSString *weatherIcon;
@property (nonatomic,copy) NSString *weather;
@property (nonatomic,copy) NSString *temprature;

@end

/******************** 小时天气数据 *********************/