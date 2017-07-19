//
//  CWChartView.h
//  ChinaWeather
//
//  Created by ludawei on 7/16/13.
//  Copyright (c) 2013 Platomix. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CWChartAxis.h"
#import "CWChartPlot.h"


@interface CWChartView : UIView

@property (nonatomic, strong) CWChartAxis *xAxis;
@property (nonatomic, strong) CWChartAxis *yAxis;
@property (nonatomic, strong) NSArray *plots;

@property (nonatomic, strong) NSArray *otherxAxis;

// 是否是柱状图
@property (nonatomic) BOOL isColumnar;
@property (nonatomic) BOOL isShowQuadCurve;     // 曲线
@property (nonatomic) CGFloat columnarWidth;
@property (nonatomic,strong) UIColor *columnarColor;

// 是否画 ＸＹ 轴线
@property (nonatomic) BOOL isXYLine;
@property (nonatomic) CGFloat leftMarginModify;

@end
