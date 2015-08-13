//
//  WeatherData.m
//  NextRain
//
//  Created by 卢大维 on 14-10-24.
//  Copyright (c) 2014年 weather. All rights reserved.
//

#import "WeatherData.h"
#import "Util.h"

#define KEY_WEATHERFACTINFO         @"l"
#define KEY_AIRQUALITYINFO          @"k"
#define KEY_WEATHERFORECASTINFO     @"f"
#define KEY_TIMEINFO                @"t"
#define KEY_HOURS_FINEFORECAST      @"jh"

@implementation WeatherDayData

@end

@implementation WeatherHourData

@end

@interface WeatherData ()

@end

@implementation WeatherData

-(instancetype)initWithWeather:(NSDictionary *)weather
{
    if (self = [super init]) {
        
        [self initCurrentData:weather];
        
        [self initHoursData:weather];
        
        [self initDaysData:weather];
        
    }
    
    return self;
}

-(void)initCurrentData:(NSDictionary *)weather
{
    id currDict = [weather objectForKey:KEY_WEATHERFACTINFO];                                                    //天气实况数据
    if ([currDict isKindOfClass:[NSDictionary class]]) {
        NSArray *weatherArray = [[currDict objectForKey:@"l5"] componentsSeparatedByString:@"|"];                    //过去24小时实况天气
        self.currWeather = [Util parseWeather:weatherArray.lastObject];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"HH"];
        int hour = [[formatter stringFromDate:[NSDate date]] intValue];
        if (hour > 5 && hour < 18) {
            self.iconCurrWeather = [NSString stringWithFormat:@"icon_weather_day_%@", weatherArray.lastObject];
        }
        else
        {
            self.iconCurrWeather = [NSString stringWithFormat:@"icon_weather_night_%@",weatherArray.lastObject];
        }
        
        NSArray *visibilityArray = [[currDict objectForKey:@"l9"] componentsSeparatedByString:@"|"];           // 24小时能见度
        self.visibility = [NSString stringWithFormat:@"能见度:%.1fkm", [visibilityArray.lastObject intValue]/1000.0];
        
        NSArray *tempratureArray = [[currDict objectForKey:@"l1"] componentsSeparatedByString:@"|"];                 //过去24小时温度
        self.currTemprature = [NSString stringWithFormat:@"%.f˚C", [[tempratureArray lastObject] floatValue]];
        
        NSArray *bodyTempratureArray = [[currDict objectForKey:@"l12"] componentsSeparatedByString:@"|"];          // 过去24小时体感温度
        NSString *bodyTem = [bodyTempratureArray lastObject];
        self.bodyTemprature = [NSString stringWithFormat:@"体感%.f˚C", [bodyTem floatValue]];
        
        NSArray *windArray = [[currDict objectForKey:@"l4"] componentsSeparatedByString:@"|"];                       //过去24小时风向
        NSArray *windSpeedArray = [[currDict objectForKey:@"l3"] componentsSeparatedByString:@"|"];
        self.currWindStatus = [NSString stringWithFormat:@"%@ %@", [Util parseWindDirection:windArray.lastObject], [Util parseWindForce:windSpeedArray.lastObject]];
        
        NSArray *humidityArray = [[currDict objectForKey:@"l2"] componentsSeparatedByString:@"|"];                   //过去24小时湿度
        self.currHumidity = [NSString stringWithFormat:@"湿度 %.f％",[humidityArray.lastObject floatValue]];
    }
    
    NSDictionary *airQualityDic = [weather objectForKey:KEY_AIRQUALITYINFO];
    if (airQualityDic) {
        NSString *k3Str = [airQualityDic objectForKey:@"k3"];
        NSArray *k3Array = [k3Str componentsSeparatedByString:@"|"];            //24小时空气质量指数（ＡＱＩ）
        NSString *airQuallityValueStr = [k3Array lastObject];
        if (airQuallityValueStr && airQuallityValueStr.length > 0) {
            NSDictionary *dic = [self infoDictByLevel:[airQuallityValueStr intValue]];
            self.airQuallity = [NSString stringWithFormat:@"空气质量 %@%@", [dic objectForKey:@"level_in"], airQuallityValueStr];
        }
    }
}

-(void)initDaysData:(NSDictionary *)weather
{
    NSArray *timeArray = [weather objectForKey:KEY_TIMEINFO];
    NSArray *weatherForecastInfoTemp = [[weather objectForKey:KEY_WEATHERFORECASTINFO] objectForKey:@"f1"];       //一周数据
    if (timeArray && weatherForecastInfoTemp && timeArray.count == weatherForecastInfoTemp.count) {
        
        self.todayTopTemprature = [[weatherForecastInfoTemp objectAtIndex:0] objectForKey:@"fc"];
        self.todayLowestTemprature = [[weatherForecastInfoTemp objectAtIndex:0] objectForKey:@"fd"];
        
        NSString *fa = [[weatherForecastInfoTemp objectAtIndex:0] objectForKey:@"fa"];
        if (fa && fa.length > 0) {
            self.iconTodayDayStr = [NSString stringWithFormat:@"icon_weather_day_%@",fa];
        }
        NSString *fb = [[weatherForecastInfoTemp objectAtIndex:0] objectForKey:@"fb"];
        if (fb && fb.length > 0) {
            self.iconTodayNightStr = [NSString stringWithFormat:@"icon_weather_night_%@",fb];
        }
        self.todayWeekStr = [[timeArray objectAtIndex:0] objectForKey:@"t4"];
        self.todayDateStr = [[timeArray objectAtIndex:0] objectForKey:@"t1"];
        
        NSMutableArray *dayInfos = [NSMutableArray arrayWithCapacity:timeArray.count];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        for (int i=0; i<timeArray.count; i++) {
            WeatherDayData *dayData = [[WeatherDayData alloc] init];
            
            NSString *t4 = [[timeArray objectAtIndex:i] objectForKey:@"t4"];
            if (t4 && t4.length > 0) {
                dayData.weekStr = t4;
            }
            
            NSString *t1 = [[timeArray objectAtIndex:i] objectForKey:@"t1"];
            if (t1 && t1.length >= 8) {
                [formatter setDateFormat:@"yyyyMMdd"];
                NSDate *date = [formatter dateFromString:t1];
                [formatter setDateFormat:@"MM/dd"];
                NSString *dayStr = [formatter stringFromDate:date];
                dayData.dateStr = dayStr;//[NSString stringWithFormat:@"%d", [dayStr intValue]];
            }
            
            NSString *fa = [[weatherForecastInfoTemp objectAtIndex:i] objectForKey:@"fa"];
            if (fa && fa.length > 0) {
                dayData.iconDayStr = [NSString stringWithFormat:@"icon_weather_day_%@",fa];
            }
            else
            {
                continue;
            }
            
            NSString *fb = [[weatherForecastInfoTemp objectAtIndex:i] objectForKey:@"fb"];
            if (fb && fb.length > 0) {
                dayData.iconNightStr = [NSString stringWithFormat:@"icon_weather_night_%@",fb];
            }
            else
            {
                continue;
            }
            
            NSString *fc = [[weatherForecastInfoTemp objectAtIndex:i] objectForKey:@"fc"];
            if (fc && fc.length > 0) {
                dayData.topTemprature = [NSString stringWithFormat:@"%@˚C",fc];
            }
            else
            {
                continue;
            }
            
            NSString *fd = [[weatherForecastInfoTemp objectAtIndex:i] objectForKey:@"fd"];
            if (fd && fd.length > 0) {
                dayData.lowestTemprature = [NSString stringWithFormat:@"%@˚C",fd];
            }
            else
            {
                continue;
            }
            
            [dayInfos addObject:dayData];
        }
        
        self.daysWeatherDatas = dayInfos;
    }
}

-(void)initHoursData:(NSDictionary *)weather
{
    NSArray *jh = [weather objectForKey:KEY_HOURS_FINEFORECAST];       //一周数据
    if (jh) {
        
        NSMutableArray *hoursData = [NSMutableArray arrayWithCapacity:jh.count];
        for (int i=0; i<jh.count; i++) {
            WeatherHourData *data = [[WeatherHourData alloc] init];
            
            NSString *jf = [[jh objectAtIndex:i] objectForKey:@"jf"];
            if (jf && jf.length >= 10) {
                int temp = [[jf substringWithRange:NSMakeRange(8, 2)] intValue];
                data.time = [NSString stringWithFormat:@"%d时", temp];
            }
            
            NSString *ja = [[jh objectAtIndex:i] objectForKey:@"ja"];
            if (ja) {
                data.weather = [Util parseWeather:ja];
                if ([data.time intValue] > 5 && [data.time intValue] < 18) {
                    data.weatherIcon = [NSString stringWithFormat:@"icon_weather_day_%@",ja];
                }
                else
                {
                    data.weatherIcon = [NSString stringWithFormat:@"icon_weather_night_%@",ja];
                }
            }
            
            NSString *jb = [[jh objectAtIndex:i] objectForKey:@"jb"];
            if (jb) {
                data.temprature = [NSString stringWithFormat:@"%@˚C", jb];
            }
            [hoursData addObject:data];
        }
        
        self.hoursWeatherDatas = hoursData;
    }
}

/************************************************************/
- (NSDictionary *)infoDictByLevel:(int)level
{
    if(level >= 0 && level <= 50)
    {
        return @{
                 @"level" : @"一级",
                 @"measure" : @"各类人群可正常活动。",
                 @"effect" : @"空气质量令人满意，基本无空气污染。",
                 @"level_in" : @"优",
                 @"color" : @"绿色",
                 @"rgb" : @"#00E400"
                 };
    }
    else if(level >= 51 && level <= 100)
    {
        return @{
                 @"level" : @"二级",
                 @"measure" : @"极少数异常敏感人群应减少户外活动。",
                 @"effect" : @"空气质量可接受，但某些污染物可能对极少数异常敏感人群健康有较弱影响。",
                 @"level_in" : @"良",
                 @"color" : @"黄色",
                 @"rgb" : @"#FFFF00"
                 };
    }
    else if(level >= 101 && level <= 150)
    {
        return @{
                 @"level" : @"三级",
                 @"measure" : @"儿童、老年人及心脏病、呼吸系统疾病患者应减少长时间、高强度的户外锻炼。",
                 @"effect" : @"易感人群症状有轻度加剧，健康人群出现刺激症状。",
                 @"level_in" : @"轻度污染",
                 @"color" : @"橙色",
                 @"rgb" : @"#FF7E00"
                 };
    }
    else if(level >= 151 && level <= 200)
    {
        return @{
                 @"level" : @"四级",
                 @"measure" : @"儿童、老年人及心脏病、呼吸系统疾病患者避免长时间、高强度的户外锻炼，一般人群适量减少户外运动。",
                 @"effect" : @"进一步加剧易感人群症状，可能对健康人群心脏、呼吸系统有影响。",
                 @"level_in" : @"中度污染",
                 @"color" : @"红色",
                 @"rgb" : @"#FF0000"
                 };
    }
    else if(level >= 201 && level <= 300)
    {
        return @{
                 @"level" : @"五级",
                 @"measure" : @"儿童、老年人和心脏病、肺病患者应停留在室内，停止户外运动，一般人群减少户外运动。",
                 @"effect" : @"心脏病和肺病患者症状显著加剧，运动耐受力降低，健康人群普遍出现症状。",
                 @"level_in" : @"重度污染",
                 @"color" : @"紫色",
                 @"rgb" : @"#800080"
                 };
    }
    else if(level >= 301)
    {
        return @{
                 @"level" : @"六级",
                 @"measure" : @"儿童、老年人和病人应当停留在室内，避免体力消耗，一般人群应避免户外活动。",
                 @"effect" : @"健康人运动耐受力降低，有明显强烈症状，提前出现某些疾病。",
                 @"level_in" : @"严重污染",
                 @"color" : @"褐红色",
                 @"rgb" : @"#7E0080"
                 };
    }
    
    return nil;
}

@end
