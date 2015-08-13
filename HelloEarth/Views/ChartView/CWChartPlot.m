//
//  CWChartPlot.m
//  ChinaWeather
//
//  Created by 曹 君平 on 7/17/13.
//  Copyright (c) 2013 Platomix. All rights reserved.
//

#import "CWChartPlot.h"

@implementation CWChartPlot

- (id)init
{
    self = [super init];
    if(self)
    {
        // set default
        self.pointLabelPosition = CWChartPlotPointLabelPositionUp;
        self.color = [UIColor whiteColor];
        self.width = 2.0f;
        self.keyDiameter = 8;
        self.labelColor = [UIColor whiteColor];
        self.labelFont = [UIFont systemFontOfSize:12];
    }
    return self;
}

@end
