//
//  CWWindMapBottomView.m
//  ChinaWeather
//
//  Created by 卢大维 on 15/1/23.
//  Copyright (c) 2015年 Platomix. All rights reserved.
//

#import "CWWindMapBottomView.h"
#import "CWChartView.h"

@interface CWWindMapBottomView ()

@property (nonatomic,strong) UIActivityIndicatorView *actView;
@property (nonatomic,strong) CWChartView *chartView;
@property (nonatomic,strong) UIImageView *addrIcon;
@property (nonatomic,strong) UILabel *addrLabel;
@property (nonatomic,strong) UIButton *deleteButton;

@end

@implementation CWWindMapBottomView

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.initY = frame.origin.y;
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, frame.size.width, 25)];
        titleLabel.text = @"未来24小时风速预报";
        titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = [UIColor whiteColor];
        [self addSubview:titleLabel];
        
        UIImage *locationImage = [UIImage imageNamed:@"map_anni"];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, locationImage.size.width*0.6, locationImage.size.height*0.6)];
        imageView.image = locationImage;
        [self addSubview:imageView];
        self.addrIcon = imageView;
        
        self.addrLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 20)];
        self.addrLabel.textColor = [UIColor redColor];
        self.addrLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:self.addrLabel];
        
        self.chartView = [[CWChartView alloc] initWithFrame:CGRectMake(10, 65, frame.size.width-20, frame.size.height-65)];
        self.chartView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.chartView.isShowQuadCurve = YES;
//        self.chartView.isXYLine = YES;
        self.chartView.leftMarginModify = 15.0;
        CWChartAxis* _yAxis = [[CWChartAxis alloc] init];
        _yAxis.lineColor = [UIColor redColor];
        self.chartView.yAxis = _yAxis;
        CWChartAxis* _xAxis = [[CWChartAxis alloc] init];
        _xAxis.showLabels = YES;
        _xAxis.showLines = YES;
        self.chartView.xAxis = _xAxis;
        
        self.chartView.yAxis.lineStyle = CWChartAxisLineStyleDash;
        self.chartView.xAxis.lineStyle = CWChartAxisLineStyleNone;
        [self addSubview:self.chartView];
        
        self.actView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.actView.center = self.chartView.center;
        [self.actView startAnimating];
        [self addSubview:self.actView];
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width-60, 0, 60, 35)];
//        [button setTitle:@"关闭" forState:UIControlStateNormal];
        button.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin;
        [button setTitle:@"×" forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:40];
        [button addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        self.deleteButton = button;
    }
    
    return self;
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    self.deleteButton.frame = CGRectMake(frame.size.width-60, 0, 60, 35);
}

-(void)setupWithData:(NSDictionary *)data
{
    self.actView.hidden = YES;
    self.chartView.hidden = NO;
    
    CWChartAxis *xAxis = self.chartView.xAxis;
    CWChartAxis *yAxis = self.chartView.yAxis;
    
    CWChartPlot *plot1 = [[CWChartPlot alloc] init];
//    plot1.color = [UIColor blueColor];
    plot1.width = 3.0f;
    plot1.keyDiameter = 9.0f;
    xAxis.minValue = 0;
    xAxis.maxValue = (int)[[data objectForKey:@"xValues"] count]-1;
    xAxis.values = [data objectForKey:@"xValues"];
    xAxis.labels = [data objectForKey:@"xLabels"];
    
    yAxis.maxValue = [[data objectForKey:@"max"] floatValue];
    yAxis.minValue = 0;
    yAxis.values = [data objectForKey:@"yValues"];
    yAxis.labels = [data objectForKey:@"yLabels"];
    
    yAxis.otherValues = [data objectForKey:@"yOtherValues"];
    yAxis.otherLabels = [data objectForKey:@"yOtherLabels"];
    
    plot1.points = [data objectForKey:@"data"];
//    plot1.pointLabels = [data objectForKey:@"data"];
    
    plot1.keyPoints = [data objectForKey:@"keyPoints"];
    
    self.chartView.plots = @[plot1];
    
    [self.chartView setNeedsDisplay];
}

-(void)setAddrText:(NSString *)addr
{
    if (addr && addr.length > 0) {
        self.addrIcon.hidden = NO;
        self.addrLabel.hidden = NO;
        
        self.addrLabel.text = addr;
        [self.addrLabel sizeToFit];
 
        self.addrLabel.center = CGPointMake(self.frame.size.width/2.0, 55);
        self.addrIcon.center = CGPointMake(CGRectGetMinX(self.addrLabel.frame)-CGRectGetWidth(self.addrIcon.frame)/2.0, 55);
    }
}

-(void)hideAddrViews
{
    self.addrIcon.hidden = YES;
    self.addrLabel.hidden = YES;
}

-(void)show
{
    [self hideAddrViews];
    self.chartView.hidden = YES;
    self.actView.hidden = NO;
    
    if (self.hidden) {
        self.hidden = NO;
        
        CGFloat height = self.frame.size.height;
        [UIView animateWithDuration:0.3f animations:^{
            CGRect frame = self.frame;
            frame.origin.y = self.initY-height;
            self.frame = frame;
        }];
    }
}

-(void)hide
{
    if (self.hidden) {
        return;
    }
    
    [UIView animateWithDuration:0.3f animations:^{
        CGRect frame = self.frame;
        frame.origin.y = self.initY;
        self.frame = frame;
    } completion:^(BOOL finished) {
        self.hidden = YES;
        if (self.hideBlock) {
            self.hideBlock();
        }
    }];
}
@end
