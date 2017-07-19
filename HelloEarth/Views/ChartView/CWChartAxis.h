//
//  CWChartAxis.h
//  ChinaWeather
//
//  Created by ludawei on 7/17/13.
//  Copyright (c) 2013 Platomix. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CWChartAxisLineStyle) {
    CWChartAxisLineStyleNone,
    CWChartAxisLineStyleSolid,      // 实线
    CWChartAxisLineStyleDash        // 虚线
};

@interface CWChartAxis : NSObject

@property (nonatomic, strong) NSArray *values, *otherValues;
@property (nonatomic, strong) NSArray *labels, *otherLabels;
@property (nonatomic, strong) NSArray *images;

@property (nonatomic, assign) int minValue;
@property (nonatomic, assign) int maxValue;
@property (nonatomic, assign) CWChartAxisLineStyle lineStyle;
@property (nonatomic, strong) UIColor *lineColor;

@property (nonatomic, assign) BOOL showLabels;                      //显示Ｙ轴的数据
@property (nonatomic, assign) BOOL showLines;

@property (nonatomic, strong) UIColor *labelColor;
@property (nonatomic, strong) UIFont *labelFont;
@property (nonatomic, assign) NSTextAlignment labelAlignment;

@end


@interface CWChartWeekAxis : CWChartAxis
@end

