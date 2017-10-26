//
//  MapStatistTempView.m
//  TestMapCover-Pad
//
//  Created by 卢大维 on 15/5/25.
//  Copyright (c) 2015年 weather. All rights reserved.
//

#import "MapStatistTempView.h"

#import "PLHttpManager.h"
#import "Util.h"
#import "NSDate+Utilities.h"
#import "CWChartView.h"
#import <Masonry/Masonry.h>

#define BOTTOM_HEIGHT 220

@interface MapStatistTempView ()

@property (nonatomic,copy) NSString *stationId;
@property (nonatomic,strong) UIView *contentView;
@property (nonatomic,strong) UIActivityIndicatorView *actView;

@property (nonatomic,strong) CWChartView *chartView;

@property (nonatomic,strong) UIView *fatherView;

@end

@implementation MapStatistTempView

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        
        self.contentView = [[UIView alloc] init];
        self.contentView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
        [self addSubview:self.contentView];
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.bottom.and.right.mas_equalTo(self);
            make.height.mas_greaterThanOrEqualTo(BOTTOM_HEIGHT);
        }];
        
//        self.dateFormatter = [CWDataManager sharedInstance].dateFormatter;
//        [self.dateFormatter setDateFormat:@"yyyyMMdd"];
        
        self.actView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        //        self.actView.center = self.contentView.center;
        [self.actView startAnimating];
        [self addSubview:self.actView];
        [self.actView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.contentView.mas_centerX);
            make.centerY.mas_equalTo(self.contentView.mas_centerY);
        }];
        
        self.hidden = YES;
        
        self.chartView = [[CWChartView alloc] initWithFrame:CGRectMake(0, 220, self.contentView.width, 150)];
        self.chartView.isShowQuadCurve = YES;
        CWChartAxis* _yAxis = [[CWChartAxis alloc] init];
        _yAxis.lineColor = [UIColor grayColor];
        self.chartView.yAxis = _yAxis;
        CWChartAxis* _xAxis = [[CWChartAxis alloc] init];
        _xAxis.showLines = YES;
        self.chartView.xAxis = _xAxis;
        
        self.chartView.yAxis.lineStyle = CWChartAxisLineStyleSolid;
        self.chartView.xAxis.lineStyle = CWChartAxisLineStyleNone;
    }
    
    return self;
}

-(void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
    self.fatherView = newSuperview;
}

-(void)showWithStationId:(NSString *)stationid
{
    self.stationId = [[stationid componentsSeparatedByString:@"-"] firstObject];
    NSString *statId = [[stationid componentsSeparatedByString:@"-"] firstObject];
    NSString *areaId = [[stationid componentsSeparatedByString:@"-"] lastObject];
    
    self.hidden = NO;
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
    }];
    
    
    [UIView animateWithDuration:0.4f delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.fatherView layoutIfNeeded];
    } completion:^(BOOL finished) {
        NSString *url = [Util requestEncodeWithString:[NSString stringWithFormat:@"http://scapi.weather.com.cn/weather/historycount?stationid=%@&areaid=%@&", statId, areaId]
                                                appId:@"f63d329270a44900"
                                           privateKey:@"sanx_data_99"];
        [[PLHttpManager sharedInstance] GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            if (responseObject) {
                [self setupViewsWitnData:(NSDictionary *)responseObject];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self setupViewsWitnData:nil];
        }];
    }];
}

-(void)hide
{
    if (self.hidden) {
        return;
    }
    
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.height);
    }];
    [UIView animateWithDuration:0.4f delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.fatherView layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self clearViews];
        self.hidden = YES;
    }];
}

-(void)setupViewsWitnData:(NSDictionary *)data
{
    if (self.hidden) {
        return;
    }
    
    UILabel *titleLabel = [self createLabel];
    titleLabel.text = [NSString stringWithFormat:@"%@ %@", self.addr, self.stationId];
    [self.contentView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        //        WithFrame:CGRectMake(0, 10, self.contentView.width, 20)
        make.left.and.width.mas_equalTo(self.contentView);
        make.top.mas_equalTo(10);
        make.height.mas_equalTo(20);
    }];
    
    if (!data || data.count == 0) {
        UILabel *tipLabel = [self createLabel];
        tipLabel.text = data?@"暂无数据":@"请求失败";
        [self.contentView addSubview:tipLabel];
        [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            //            WithFrame:CGRectMake(0, CGRectGetMaxY(titleLabel.frame), self.contentView.width, 25)
            make.left.and.width.mas_equalTo(self.contentView);
            make.top.mas_equalTo(titleLabel.mas_bottom);
            make.height.mas_equalTo(25);
        }];
    }
    else
    {
        
        [self.contentView addSubview:self.chartView];
        [self.chartView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.and.right.mas_equalTo(self.contentView);
            make.top.mas_equalTo(titleLabel.mas_bottom).offset(10);
        }];
        
        
        NSDictionary *l = [[[data objectForKey:@"details"] objectForKey:@"observe"] objectForKey:@"l"];
        NSArray *chartArray = [[l objectForKey:@"l1"] componentsSeparatedByString:@"|"];
        NSDictionary *chartData = [self chartDataWithDatas:chartArray withTime:[l objectForKey:@"l7"]];
        
        CWChartAxis *xAxis = self.chartView.xAxis;
        CWChartAxis *yAxis = self.chartView.yAxis;
        
        xAxis.minValue = 0;
        xAxis.maxValue = (int)[[chartData objectForKey:@"data"] count];
        xAxis.values = [chartData objectForKey:@"xAxisValue"];
        xAxis.labels = [chartData objectForKey:@"xAxisLabel"];
        
        yAxis.maxValue = [[chartData objectForKey:@"max"] floatValue];
        yAxis.minValue = [[chartData objectForKey:@"min"] floatValue];
        yAxis.values = [chartData objectForKey:@"yAxisValue"];
        yAxis.labels = [chartData objectForKey:@"yAxisLabel"];
        
        CWChartPlot *plot1 = [[CWChartPlot alloc] init];
        plot1.width = 3.0f;
        plot1.points = [chartData objectForKey:@"data"];
        plot1.pointLabels = [chartData objectForKey:@"data"];
        plot1.color = [UIColor colorWithRed:0.898 green:0.247 blue:0.090 alpha:1];
        plot1.keyPoints = [chartData objectForKey:@"keyPoints"];
        
        self.chartView.plots = @[plot1];
//        CWChartPlot *plot2 = [[CWChartPlot alloc] init];
//        plot2.width = 2.0f;
//        plot2.points = [chartData objectForKey:@"data2"];
//        plot2.color = UIColorFromRGB(0x0095ff);
//        
//        self.chartView.plots = @[plot1, plot2];
        
        [self.chartView setNeedsDisplay];
    }
    
    self.actView.hidden = YES;
    [self.actView removeFromSuperview];
}

-(NSDictionary *)chartDataWithDatas:(NSArray *)array withTime:(NSString *)time
{
    NSInteger hour = [[[time componentsSeparatedByString:@":"] firstObject] integerValue];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    CGFloat max = -100.0,min = 100.0;
    NSInteger maxIndex = -1;
    NSInteger minIndex = -1;
    
    NSMutableArray *temps = [NSMutableArray array];
    
    NSMutableArray *arrayValueX = [[NSMutableArray alloc] init];
    NSMutableArray *arrayLabelX = [[NSMutableArray alloc] init];
    
    NSMutableArray *keyPoints = [[NSMutableArray alloc] init];
    
    for (NSInteger i=0; i<array.count; i=i+1) {
        NSString *obj = [array objectAtIndex:i];
        
        if ([obj floatValue] > max) {
            max = [obj floatValue];
            maxIndex = i;
        }
        if ([obj floatValue] < min) {
            min = [obj floatValue];
            minIndex = i;
        }
        [temps addObject:obj];
        
        NSInteger showHour = (hour-24+i);
        if (showHour<0) {
            showHour += 24;
        }
        if (i%2 == 0) {
            [arrayLabelX addObject:[NSString stringWithFormat:@"%td时", showHour]];
        }
        else
        {
            [arrayLabelX addObject:@""];
        }
        
        [arrayValueX addObject:@(i)];
        
        [keyPoints addObject:@(0)];
    }
    
    [keyPoints replaceObjectAtIndex:maxIndex withObject:@(1)];
    [keyPoints replaceObjectAtIndex:minIndex withObject:@(1)];
    
    NSInteger temp = max - min;
    max += temp/5 + 1;
    min -= temp/5 + 1;
    
    NSMutableArray *arrayValuey = [[NSMutableArray alloc] init];
    NSMutableArray *arrayLabely = [[NSMutableArray alloc] init];
    for (NSInteger i=(int)(min/10)*10; i<=(int)ceil(max/10)*10; i=i+10) {
        [arrayLabely addObject:[NSString stringWithFormat:@"%td°", i]];
        [arrayValuey addObject:[NSString stringWithFormat:@"%td", i]];
    }
    
    [dict setObject:arrayValueX forKey:@"xAxisValue"];
    [dict setObject:arrayLabelX forKey:@"xAxisLabel"];
    [dict setObject:keyPoints forKey:@"keyPoints"];
    [dict setObject:arrayValuey forKey:@"yAxisValue"];
    [dict setObject:arrayLabely forKey:@"yAxisLabel"];
    [dict setObject:[NSNumber numberWithInteger:max] forKey:@"max"];
    [dict setObject:[NSNumber numberWithInteger:min] forKey:@"min"];
    [dict setObject:temps forKey:@"data"];
    
    return dict;
}

#if 0
-(NSDictionary *)chartDataWithDatas:(NSArray *)array
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    CGFloat max = -100.0,min = 100.0;
    NSMutableArray *maxArray = [NSMutableArray array];
    NSMutableArray *minArray = [NSMutableArray array];
    
    for (NSInteger i=0; i<array.count; i=i+1) {
        NSDictionary *obj = [array objectAtIndex:i];
        
        max = MAX([[obj objectForKey:@"maxtemp"] floatValue], max);
        min = MIN([[obj objectForKey:@"mintemp"] floatValue], min);
        [maxArray addObject:[obj objectForKey:@"maxtemp"]];
        [minArray addObject:[obj objectForKey:@"mintemp"]];
    }
    
    NSInteger temp = max - min;
    max += temp/5 + 1;
    min -= temp/5 + 1;
    
    NSMutableArray *arrayValuey = [[NSMutableArray alloc] init];
    NSMutableArray *arrayLabely = [[NSMutableArray alloc] init];
    for (NSInteger i=(int)(min/10)*10; i<=(int)(max/10)*10; i=i+10) {
        [arrayLabely addObject:[NSString stringWithFormat:@"%ld°", i]];
        [arrayValuey addObject:[NSString stringWithFormat:@"%ld", i]];
    }
    
    [dict setObject:arrayValuey forKey:@"yAxisValue"];
    [dict setObject:arrayLabely forKey:@"yAxisLabel"];
    [dict setObject:[NSNumber numberWithInteger:max] forKey:@"max"];
    [dict setObject:[NSNumber numberWithInteger:min] forKey:@"min"];
    [dict setObject:maxArray forKey:@"data1"];
    [dict setObject:minArray forKey:@"data2"];
    
    return dict;
}
#endif

-(UILabel *)createLabel
{
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    
    return titleLabel;
}

-(void)clearViews
{
    for (UIView *sub in self.contentView.subviews) {
        [sub removeFromSuperview];
    }
    
    self.actView.hidden = NO;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    //    CGPoint point = [touches.anyObject locationInView:self];
    //
    //    if (CGRectContainsPoint(self.contentView.frame, point)) {
    //
    //    }
    [self hide];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self hide];
}

@end
