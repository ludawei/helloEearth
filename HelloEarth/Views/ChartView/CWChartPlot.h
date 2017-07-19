//
//  CWChartPlot.h
//  ChinaWeather
//
//  Created by ludawei on 7/17/13.
//  Copyright (c) 2013 Platomix. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CWChartPlotPointLabelPosition) {
    CWChartPlotPointLabelPositionUp,
    CWChartPlotPointLabelPositionDown
};

@interface CWChartPlot : NSObject

@property (nonatomic, strong) NSArray *points;              // 普通点，如 @[@20, @35, @11, @35, @13, @20, @26, @20, @35, @11, @35, @23, @20, @26]
@property (nonatomic, strong) NSArray *keyPoints;           // 关键点，如 @[@1, @0, @1, @0, @0, @1, @1, @0, @0, @1, @1, @1, @0, @1]
@property (nonatomic, strong) NSArray *pointLabels;         // 点的文字信息
@property (nonatomic, assign) CWChartPlotPointLabelPosition pointLabelPosition;   // 点信息的显示位置

@property (nonatomic, strong) UIColor *color;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat keyDiameter;

@property (nonatomic, strong) UIColor *labelColor;
@property (nonatomic, strong) UIFont *labelFont;

@end
