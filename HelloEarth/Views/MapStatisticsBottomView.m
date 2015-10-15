//
//  MapStatisticsBottomView.m
//  chinaweathernews
//
//  Created by 卢大维 on 15/5/20.
//  Copyright (c) 2015年 weather. All rights reserved.
//

#import "MapStatisticsBottomView.h"
#import "TJPieView.h"
#import "PLHttpManager.h"
#import "Util.h"
#import "NSDate+Utilities.h"
#import "CWChartView.h"

#import "Masonry.h"

#define BOTTOM_HEIGHT 220
//#define START_DATE    @"2015-01-01"

@interface MapStatisticsBottomView ()

@property (nonatomic,copy) NSString *stationId;
@property (nonatomic,strong) UIView *contentView;
@property (nonatomic,strong) NSDateFormatter *dateFormatter;
@property (nonatomic,strong) UIActivityIndicatorView *actView;

@property (nonatomic,strong) UIView *fatherView;

@property (nonatomic,strong) CWChartView *chartView;

@end

@implementation MapStatisticsBottomView

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
        
        self.dateFormatter = [CWDataManager sharedInstance].dateFormatter;
        
        self.actView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
//        self.actView.center = self.contentView.center;
        [self.actView startAnimating];
        [self addSubview:self.actView];
        [self.actView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.contentView.mas_centerX);
            make.centerY.mas_equalTo(self.contentView.mas_centerY);
        }];
        
        self.hidden = YES;
        
#if 0
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
#endif
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
    
    [UIView animateWithDuration:0.4 delay:0.0 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.fatherView layoutIfNeeded];
    } completion:^(BOOL finished) {
        NSString *url = [Util requestEncodeWithString:[NSString stringWithFormat:@"http://scapi.weather.com.cn/weather/historycount?stationid=%@&areaid=%@&", statId, areaId]
                                                appId:@"f63d329270a44900"
                                           privateKey:@"sanx_data_99"];
        [[PLHttpManager sharedInstance].manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
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
    
    [UIView animateWithDuration:0.4 delay:0.0 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
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
    
    self.actView.hidden = YES;
//    [self.actView removeFromSuperview];
    
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
        NSArray *tqxx = [data objectForKey:@"tqxxcount"];
        NSInteger days = [[data objectForKey:@"days"] integerValue];
        
        CGFloat margin = 10.0f;
        CGFloat pieWidth = (self.contentView.width - margin*(tqxx.count+1))/tqxx.count;
        for (NSDictionary *dict in tqxx) {
            NSInteger i = [tqxx indexOfObject:dict];
            NSInteger dictDays = [[dict objectForKey:@"value"] integerValue];
            
            TJPieView *pieView = [[TJPieView alloc] initRadiuses:@[dict, @{@"name":@"其它", @"value":@(days-dictDays)}] total:days];
//            pieView.frame = CGRectMake(margin + (pieWidth+margin)*i, CGRectGetMaxY(titleLabel.frame)+margin, pieWidth, pieWidth);
            [self.contentView addSubview:pieView];
            [pieView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(margin+(pieWidth+margin)*i);
                make.top.mas_equalTo(titleLabel.mas_bottom).offset(margin);
                make.width.and.height.mas_equalTo(pieWidth);
            }];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [pieView startAnim];
            });
        }
        
        UILabel *lbl = [[UILabel alloc] init];
        lbl.numberOfLines = 0;
        lbl.preferredMaxLayoutWidth = self.width;
        {
            NSString *htmlString = @"<div style='color:#FFFFFF; font-size:18px'>自%@至%@：<br />"
            "日最高气温<a style='color:#d87a80;'>%@</a>,日最低气温<a style='color:#d87a80;'>%@</a>,日最大风速<a style='color:#d87a80;'>%@</a>，日最大降水量<a style='color:#d87a80;'>%@</a>，连续无降水日数<a style='color:#d87a80;'>%@</a>，连续霾日数<a style='color:#d87a80;'>%@</a>。</div>";
            
            [self.dateFormatter setDateFormat:@"yyyyMMdd"];
            NSDate *startDate = [self.dateFormatter dateFromString:data[@"starttime"]];
            NSString *startDateString = [NSString stringWithFormat:@"%ld-%02ld-%02ld", (long)startDate.year, (long)startDate.month, (long)startDate.day];
            
            NSDate *endDate = [self.dateFormatter dateFromString:data[@"endtime"]];
            NSString *endDateString = [NSString stringWithFormat:@"%ld-%02ld-%02ld", (long)endDate.year, (long)endDate.month, (long)endDate.day];
            
            NSString *temp_max = [NSString stringWithFormat:@"%@", [[data[@"count"] firstObject] objectForKey:@"max"]];
            temp_max = [self formatShowText:temp_max ext:@"°C"];
            
            NSString *temp_min = [NSString stringWithFormat:@"%@", [[data[@"count"] firstObject] objectForKey:@"min"]];
            temp_min = [self formatShowText:temp_min ext:@"°C"];
            
            NSString *wind_max = [NSString stringWithFormat:@"%@", [[data[@"count"] lastObject] objectForKey:@"max"]];
            wind_max = [self formatShowText:wind_max ext:@"m/s"];
            
            NSString *rain_max = [NSString stringWithFormat:@"%@", [[data[@"count"] objectAtIndex:1] objectForKey:@"max"]];
            rain_max = [self formatShowText:rain_max ext:@"mm"];
            
            NSString *no_rain_count = [NSString stringWithFormat:@"%@", data[@"no_rain_lx"]];
            no_rain_count = [self formatShowText:no_rain_count ext:@"天"];
            
            NSString *mai_count = [NSString stringWithFormat:@"%@", data[@"mai_lx"]];
            mai_count = [self formatShowText:mai_count ext:@"天"];
            
            htmlString = [NSString stringWithFormat:htmlString, startDateString, endDateString, temp_max, temp_min, wind_max, rain_max, no_rain_count,  mai_count];
            
            NSMutableAttributedString * attrStr = [[NSMutableAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
            
            lbl.attributedText = attrStr;
        }
//        lbl.backgroundColor = [UIColor lightGrayColor];
        [lbl sizeToFit];
        [self.contentView addSubview:lbl];
        [lbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(20);
            make.right.mas_equalTo(-20);
            make.top.mas_equalTo(titleLabel.mas_bottom).offset(margin*2+pieWidth);
            make.bottom.mas_equalTo(-margin);
        }];
        
//        self.contentView.height = CGRectGetMaxY(lbl.frame);
        [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_greaterThanOrEqualTo(lbl.mas_height);
        }];
#if 0
        [self.contentView addSubview:self.chartView];
        self.chartView.y = CGRectGetMaxY(lbl.frame)+margin-20;
        
        NSDictionary *chartData = [self chartDataWithDatas:[data objectForKey:@"array"]];
        
        CWChartAxis *xAxis = self.chartView.xAxis;
        CWChartAxis *yAxis = self.chartView.yAxis;
        
        xAxis.minValue = 0;
        xAxis.maxValue = (int)[[chartData objectForKey:@"data1"] count]-1;
        
        yAxis.maxValue = [[chartData objectForKey:@"max"] floatValue];
        yAxis.minValue = [[chartData objectForKey:@"min"] floatValue];
        yAxis.values = [chartData objectForKey:@"yAxisValue"];
        yAxis.labels = [chartData objectForKey:@"yAxisLabel"];
        
        CWChartPlot *plot1 = [[CWChartPlot alloc] init];
        plot1.width = 2.0f;
        plot1.points = [chartData objectForKey:@"data1"];
        plot1.color = [UIColor colorWithRed:0.898 green:0.247 blue:0.090 alpha:1];
        
        CWChartPlot *plot2 = [[CWChartPlot alloc] init];
        plot2.width = 2.0f;
        plot2.points = [chartData objectForKey:@"data2"];
        plot2.color = UIColorFromRGB(0x0095ff);
        
        self.chartView.plots = @[plot1, plot2];
        
        [self.chartView setNeedsDisplay];
#endif
    }
}

-(NSString *)formatShowText:(NSString *)count ext:(NSString *)ext
{
    if (count.integerValue == -1) {
        return @"未统计";
    }
    else
    {
        return [count stringByAppendingString:ext];
    }
}

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
        [arrayLabely addObject:[NSString stringWithFormat:@"%td°", i]];
        [arrayValuey addObject:[NSString stringWithFormat:@"%td", i]];
    }
    
    [dict setObject:arrayValuey forKey:@"yAxisValue"];
    [dict setObject:arrayLabely forKey:@"yAxisLabel"];
    [dict setObject:[NSNumber numberWithInteger:max] forKey:@"max"];
    [dict setObject:[NSNumber numberWithInteger:min] forKey:@"min"];
    [dict setObject:maxArray forKey:@"data1"];
    [dict setObject:minArray forKey:@"data2"];
    
    return dict;
}

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
