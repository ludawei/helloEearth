//
//  CWChartAxis.m
//  ChinaWeather
//
//  Created by ludawei on 7/17/13.
//  Copyright (c) 2013 Platomix. All rights reserved.
//

#import "CWChartAxis.h"

#define UNDEFINED -1

@implementation CWChartAxis

- (id)init
{
    self = [super init];
    if(self)
    {
        // set default
        self.labelColor = [UIColor whiteColor];
        self.labelFont = [UIFont systemFontOfSize:12];
        self.labelAlignment = NSTextAlignmentCenter;
        self.minValue = UNDEFINED;
        self.maxValue = UNDEFINED;
        self.showLabels = YES;
    }
    return self;
}

- (void)setValues:(NSArray *)values
{
    if(_values != values)
    {
        _values = values;
        
        if(_values && _values.count > 0)
        {
            if(self.minValue == UNDEFINED)
                self.minValue = [_values[0] intValue];
            if(self.maxValue == UNDEFINED)
                self.maxValue = [_values[_values.count - 1] intValue];
        }
    }
}

@end


@implementation CWChartWeekAxis

- (id)init
{
    self = [super init];
    if(self)
    {
        // set default
        self.minValue = 1;
        self.maxValue = 7;
        self.showLabels = YES;
        self.labels = @[@"周一", @"周二", @"周三", @"周四", @"周五", @"周六", @"周日"];
        self.values = @[@1, @2, @3, @4, @5, @6, @7];
    }
    return self;
}

@end

