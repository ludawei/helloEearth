//
//  CWChartView.m
//  ChinaWeather
//
//  Created by ludawei on 7/16/13.
//  Copyright (c) 2013 Platomix. All rights reserved.
//

#import "CWChartView.h"

#define WIDTH_OF_LABEL      40
#define HEIGHT_OF_LABEL     20

//改动  所有的视图的宽要加20  Ｘ加8  不同情况
#define WIDTH_SPACE 20
#define SPACE 8
#define XLINE_SPACE 10
#define PLOT_SPACE 4
@interface CWChartView ()
@property (nonatomic, strong) NSMutableArray *windStatuArray;
@property (nonatomic, assign) CGRect chartFrame;
@property (nonatomic, readonly) CGFloat topMargin;
@property (nonatomic, readonly) CGFloat bottomMargin;
@property (nonatomic, readonly) CGFloat leftMargin;
@property (nonatomic, readonly) CGFloat rightMargin;
@end

@implementation CWChartView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
        self.windStatuArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutFrames];
}

- (void)layoutFrames
{
    self.chartFrame = CGRectMake(self.leftMargin, self.topMargin,
                                 self.bounds.size.width - self.leftMargin - self.rightMargin,
                                 self.bounds.size.height - self.topMargin - self.bottomMargin);
}

- (void)drawLine:(CGContextRef)ctx fromPoint:(CGPoint)from toPoint:(CGPoint)to style:(CWChartAxisLineStyle)style
{
    if(style == CWChartAxisLineStyleNone)
        return;

    UIColor *line_color = self.yAxis.lineColor;
    if (!line_color) {
        line_color = [UIColor colorWithWhite:1.0 alpha:0.5];
    }
    CGContextSetStrokeColorWithColor(ctx, line_color.CGColor);

    if(style == CWChartAxisLineStyleDash)
    {
        CGFloat dashes[] = {5,2};
        CGContextSetLineDash(ctx, 0.0, dashes, 2);
    }
    else
    {
        CGFloat normal[1] = {1};
        CGContextSetLineDash(ctx, 0, normal, 0);
    }
    CGContextSetLineWidth(ctx, 1.0);
    
    CGContextMoveToPoint(ctx, from.x + SPACE, from.y);
    CGContextAddLineToPoint(ctx, to.x + SPACE, to.y);
    CGContextStrokePath(ctx);
}

- (void)drawLine:(CGContextRef)ctx fromPoint:(CGPoint)from toPoint:(CGPoint)to width:(CGFloat)width
{
//    if(style == CWChartAxisLineStyleNone)
//        return;
    
    CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithWhite:1.0 alpha:0.5].CGColor);
    
//    if(style == CWChartAxisLineStyleDash)
//    {
//        CGFloat dashes[] = {5,2};
//        CGContextSetLineDash(ctx, 0.0, dashes, 2);
//    }
//    else
    {
        CGFloat normal[1] = {1};
        CGContextSetLineDash(ctx, 0, normal, 0);
    }
    CGContextSetLineWidth(ctx, width);
    
    CGContextMoveToPoint(ctx, from.x + SPACE, from.y);
    CGContextAddLineToPoint(ctx, to.x + SPACE, to.y);
    CGContextStrokePath(ctx);
}

- (void)drawLine:(CGContextRef)ctx fromPoint:(CGPoint)from toPoint:(CGPoint)to width:(CGFloat)width withColor:(UIColor *)color
{
    //    if(style == CWChartAxisLineStyleNone)
    //        return;
    
    if (color)
    {
        CGContextSetStrokeColorWithColor(ctx, color.CGColor);
    }
    else
    {
        CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithWhite:1.0 alpha:0.5].CGColor);
    }

    
    //    if(style == CWChartAxisLineStyleDash)
    //    {
    //        CGFloat dashes[] = {5,2};
    //        CGContextSetLineDash(ctx, 0.0, dashes, 2);
    //    }
    //    else
    {
        CGFloat normal[1] = {1};
        CGContextSetLineDash(ctx, 0, normal, 0);
    }
    CGContextSetLineWidth(ctx, width);
    
    CGContextMoveToPoint(ctx, from.x + SPACE, from.y);
    CGContextAddLineToPoint(ctx, to.x + SPACE, to.y);
    CGContextStrokePath(ctx);
}


- (void)drawRect:(CGRect)rect
{
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	UIGraphicsPushContext(ctx);
    
    [self drawYAxis:ctx];
    [self drawXAxis:ctx];
    
    if (self.isColumnar)
    {
        for (CWChartPlot *plot in self.plots)
        {
            [self drawColumnar:plot withContext:ctx];
        }
    }
    else
    {
        for (CWChartPlot *plot in self.plots)
        {
            if (self.isShowQuadCurve) {
                [self drawQuadCurvedPlot:plot withContext:ctx];
            }
            else
            {
                [self drawPlot:plot withContext:ctx];
            }
        }
    }
    //画ＸＹ轴线
    if (self.isXYLine) {
        [self drawXYLineWithContex:ctx];
    }
       
    for (NSDictionary *dict in self.otherxAxis)
    {
        CWChartAxis *xAxis = (CWChartAxis *)[dict objectForKey:@"xAxis"];
        if (xAxis.images.count == 0)
        {
            [self drawXAxisLabel:ctx withY:[[dict objectForKey:@"y"] integerValue] andxAxis:[dict objectForKey:@"xAxis"]];
        }
        else
        {
            [self drawXAxisImg:ctx withY:[[dict objectForKey:@"y"] integerValue] andxAxis:[dict objectForKey:@"xAxis"]];
        }
    
    }
	UIGraphicsPopContext();
}

- (void)drawYAxis:(CGContextRef)ctx
{
    CGContextSaveGState(ctx);
    
    if(!self.yAxis ||
       self.yAxis.labels.count != self.yAxis.values.count)
    {
        return;
    }

    if(!self.yAxis.showLabels && self.yAxis.lineStyle == CWChartAxisLineStyleNone)
        return;

    [self.yAxis.labelColor set];
    for (int i = 0; i < self.yAxis.labels.count; ++i)
    {
        CGFloat value = [self.yAxis.values[i] floatValue];
        NSString *text = self.yAxis.labels[i];

        int y = self.topMargin + (self.yAxis.maxValue - value) / (self.yAxis.maxValue - self.yAxis.minValue) * self.chartFrame.size.height;
        if(self.yAxis.showLabels)
        {
            CGRect textFrame = CGRectMake(0, y - HEIGHT_OF_LABEL / 2, self.leftMargin, HEIGHT_OF_LABEL);
            
#if 1
            NSMutableParagraphStyle *parStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
            parStyle.lineBreakMode = NSLineBreakByWordWrapping;
            parStyle.alignment     = self.yAxis.labelAlignment;
            [text drawInRect:textFrame withAttributes:@{NSFontAttributeName : self.yAxis.labelFont,
                                                        NSParagraphStyleAttributeName: parStyle}];
#else
            [text drawInRect:textFrame withFont:self.yAxis.labelFont lineBreakMode:NSLineBreakByWordWrapping alignment:self.yAxis.labelAlignment];
#endif
        }

        [self drawLine:ctx
             fromPoint:CGPointMake(self.leftMargin - SPACE - 5,  y  )
               toPoint:CGPointMake(CGRectGetMaxX(self.chartFrame) - 7,  y)
                 style:self.yAxis.lineStyle];
    }
    
    for (int i = 0; i < self.yAxis.otherLabels.count; ++i)
    {
        CGFloat value = [self.yAxis.otherValues[i] floatValue];
        NSString *text = self.yAxis.otherLabels[i];
        
        int y = self.topMargin + (self.yAxis.maxValue - value) / (self.yAxis.maxValue - self.yAxis.minValue) * self.chartFrame.size.height;
        if(self.yAxis.showLabels)
        {
            CGRect textFrame = CGRectMake(0, y - HEIGHT_OF_LABEL / 2, self.leftMargin, HEIGHT_OF_LABEL);
            
#if 1
            NSMutableParagraphStyle *parStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
            parStyle.lineBreakMode = NSLineBreakByWordWrapping;
            parStyle.alignment     = self.yAxis.labelAlignment;
            [text drawInRect:textFrame withAttributes:@{NSFontAttributeName : self.yAxis.labelFont,
                                                        NSParagraphStyleAttributeName: parStyle}];
#else
            [text drawInRect:textFrame withFont:self.yAxis.labelFont lineBreakMode:NSLineBreakByWordWrapping alignment:self.yAxis.labelAlignment];
#endif
        }
    }
    
    CGContextRestoreGState(ctx);
}

- (void)drawXAxis:(CGContextRef)ctx
{
    CGContextSaveGState(ctx);
    
    if(!self.xAxis ||
       self.xAxis.labels.count != self.xAxis.values.count)
    {
        return;
    }
    
    if(!self.xAxis.showLabels && self.xAxis.lineStyle == CWChartAxisLineStyleNone)
        return;

    int y = CGRectGetMaxY(self.chartFrame) + 5;
    [self.xAxis.labelColor set];

    for (int i = 0; i < self.xAxis.labels.count; ++i)
    {
        CGFloat value = [self.xAxis.values[i] floatValue];
        NSString *text = self.xAxis.labels[i];
        
        int x = self.leftMargin + (value - self.xAxis.minValue) / (self.xAxis.maxValue - self.xAxis.minValue) * (self.chartFrame.size.width - WIDTH_SPACE);

        if(self.xAxis.showLabels)
        {
            CGRect textFrame = CGRectMake(x + SPACE - WIDTH_OF_LABEL / 2, y, WIDTH_OF_LABEL, HEIGHT_OF_LABEL*[[text componentsSeparatedByString:@"\n"] count]);
#if 1
            NSMutableParagraphStyle *parStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
            parStyle.lineBreakMode = NSLineBreakByWordWrapping;
            parStyle.alignment     = self.xAxis.labelAlignment;
            [text drawInRect:textFrame withAttributes:@{NSFontAttributeName : self.xAxis.labelFont,
                                                        NSParagraphStyleAttributeName: parStyle}];
#else
            [text drawInRect:textFrame withFont:self.xAxis.labelFont lineBreakMode:NSLineBreakByWordWrapping alignment:self.xAxis.labelAlignment];
#endif
        }

        [self drawLine:ctx
             fromPoint:CGPointMake(x , self.topMargin - XLINE_SPACE)
               toPoint:CGPointMake(x , CGRectGetMaxY(self.chartFrame))
                 style:self.xAxis.lineStyle];
    }
    
    CGContextRestoreGState(ctx);
}

// ludawei,add
- (void)drawXAxisLabel:(CGContextRef)ctx withY:(CGFloat)y andxAxis:(CWChartAxis *)xAxis
{
    if (y < 0)
    {
        y = CGRectGetMaxY(self.chartFrame) + y;
    }
    
    [xAxis.labelColor set];
    
    for (int i = 0; i < xAxis.labels.count; ++i)
    {
        CGFloat value = [xAxis.values[i] floatValue];
        NSString *text = xAxis.labels[i];
        
        int x = self.leftMargin + (value - xAxis.minValue) / (xAxis.maxValue - xAxis.minValue) * (self.chartFrame.size.width - WIDTH_SPACE);
    
        CGRect textFrame = CGRectMake(x - WIDTH_OF_LABEL / 2, y, WIDTH_OF_LABEL, HEIGHT_OF_LABEL);
#if 1
        NSMutableParagraphStyle *parStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
        parStyle.lineBreakMode = NSLineBreakByWordWrapping;
        parStyle.alignment     = self.xAxis.labelAlignment;
        [text drawInRect:textFrame withAttributes:@{NSFontAttributeName : xAxis.labelFont,
                                                    NSParagraphStyleAttributeName: parStyle}];
#else
        [text drawInRect:textFrame withFont:xAxis.labelFont lineBreakMode:NSLineBreakByWordWrapping alignment:self.xAxis.labelAlignment];
#endif
    }
}

- (void)drawXAxisImg:(CGContextRef)ctx withY:(CGFloat)y andxAxis:(CWChartAxis *)xAxis
{
    if (y < 0)
    {
        y = CGRectGetMaxY(self.chartFrame) + y;
    }
    
    for (int i = 0; i < xAxis.images.count; ++i)
    {
        CGFloat value = [xAxis.values[i] floatValue];
        UIImage *img = xAxis.images[i];
        
        int x = self.leftMargin + (value - xAxis.minValue) / (xAxis.maxValue - xAxis.minValue) * (self.chartFrame.size.width - WIDTH_SPACE);
        
        CGRect textFrame = CGRectMake(x - WIDTH_OF_LABEL / 2, y, MAX(HEIGHT_OF_LABEL, WIDTH_OF_LABEL), MAX(HEIGHT_OF_LABEL, WIDTH_OF_LABEL));
        [img drawInRect:textFrame];
    }
}

- (void)drawCircleAndLabelWithPlot:(CWChartPlot *)plot withContext:(CGContextRef)ctx
{
    [plot.color set];
    CGContextSetLineWidth(ctx, plot.width);

    CGFloat x = self.leftMargin + SPACE;
    CGFloat step = (self.chartFrame.size.width - WIDTH_SPACE) / (plot.points.count - 1);
    CGFloat lastX, lastY;
    for (int i = 0; i < plot.points.count; ++i)
    {
        CGFloat value = [plot.points[i] floatValue];
        
        //改动  减5
        CGFloat y = self.topMargin + (self.yAxis.maxValue - value) / (self.yAxis.maxValue - self.yAxis.minValue) * self.chartFrame.size.height - PLOT_SPACE;
        if (i == 0)
        {
            if (value == 0 && plot.points.count <= 7)
            {
                //  UI(@"I: %d  Value:%f",i,value);
                lastX = x + step;
                value = [plot.points[i += 1] floatValue];
                lastY = self.topMargin + (self.yAxis.maxValue - value) / (self.yAxis.maxValue - self.yAxis.minValue) * self.chartFrame.size.height;
                x = lastX;
                y = lastY;
            }
        }
        
        //添加画线的阴影
        BOOL isKeyPoint = NO;
        if(plot.keyPoints && i < plot.keyPoints.count)
        {
            isKeyPoint = [plot.keyPoints[i] boolValue];
        }
        
        CGRect circleRect;
        if(isKeyPoint)
        {
            CGContextSetShadowWithColor(ctx, CGSizeMake(1, 1), 0.0, [UIColor blackColor].CGColor);
            circleRect = CGRectMake(x - plot.keyDiameter / 2, y - plot.keyDiameter / 2, plot.keyDiameter, plot.keyDiameter);
        }
        else
        {
            CGContextSetShadowWithColor(ctx, CGSizeMake(1, 1), 0.0, nil);
            circleRect = CGRectMake(x - plot.width / 2, y - plot.width / 2, plot.width, plot.width);
        }

        CGContextFillEllipseInRect(ctx, circleRect);
           // CGContextFillRect(ctx, circleRect);
        
        if(plot.pointLabels && i < plot.pointLabels.count)
        {
            NSString *pointLabel = plot.pointLabels[i];
            CGRect labelFrame = CGRectMake(x - 50 / 2, y - 20, 50, 20); // CWChartPlotPointLabelPositionUp
            if(plot.pointLabelPosition == CWChartPlotPointLabelPositionDown)
            {
                labelFrame.origin.y = y + 5;
            }
            
#if 1
            NSMutableParagraphStyle *parStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
            parStyle.lineBreakMode = NSLineBreakByWordWrapping;
            parStyle.alignment     = NSTextAlignmentCenter;
            [pointLabel drawInRect:labelFrame withAttributes:@{NSFontAttributeName : plot.labelFont,
                                                        NSParagraphStyleAttributeName: parStyle}];
#else
            [pointLabel drawInRect:labelFrame withFont:plot.labelFont lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];
#endif
        }
        
        lastX = x;
        lastY = y;
        
        x += step;
    }
}


/********************************为了将点连成曲线*************************************/
+ (UIBezierPath *)quadCurvedPathWithPoints:(NSArray *)points
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    NSValue *value = points[0];
    CGPoint p1 = [value CGPointValue];
    [path moveToPoint:p1];
    
    if (points.count == 2) {
        value = points[1];
        CGPoint p2 = [value CGPointValue];
        [path addLineToPoint:p2];
        return path;
    }
    
    for (NSUInteger i = 1; i < points.count; i++) {
        value = points[i];
        CGPoint p2 = [value CGPointValue];
        
        CGPoint midPoint = midPointForPoints(p1, p2);
        [path addQuadCurveToPoint:midPoint controlPoint:controlPointForPoints(midPoint, p1)];
        [path addQuadCurveToPoint:p2 controlPoint:controlPointForPoints(midPoint, p2)];
        
        p1 = p2;
    }
    return path;
}

static CGPoint midPointForPoints(CGPoint p1, CGPoint p2) {
    return CGPointMake((p1.x + p2.x) / 2, (p1.y + p2.y) / 2);
}

static CGPoint controlPointForPoints(CGPoint p1, CGPoint p2) {
    CGPoint controlPoint = midPointForPoints(p1, p2);
    CGFloat diffY = fabs(p2.y - controlPoint.y);
    
    if (p1.y < p2.y)
        controlPoint.y += diffY;
    else if (p1.y > p2.y)
        controlPoint.y -= diffY;
    
    return controlPoint;
}
/********************************为了将点连成曲线*************************************/


- (void)drawQuadCurvedPlot:(CWChartPlot *)plot withContext:(CGContextRef)ctx
{
    if(!plot.points ||
       plot.points.count == 0)
    {
        return;
    }
    
    [plot.color set];
    CGContextSetLineWidth(ctx, plot.width);
    CGFloat x = self.leftMargin + SPACE;
    CGFloat step = (self.chartFrame.size.width - WIDTH_SPACE) / (plot.points.count - 1);
    CGFloat lastX, lastY;
    
    
    NSMutableArray *showPoints = [NSMutableArray array];
    
    for (int i = 0; i < plot.points.count; ++i)
    {
        CGFloat value = [plot.points[i] floatValue];
        
        //改动  减5
        CGFloat y = self.topMargin + (self.yAxis.maxValue - value) / (self.yAxis.maxValue - self.yAxis.minValue) * self.chartFrame.size.height - PLOT_SPACE;
        if (i == 0)
        {
            if (value == 0 && plot.points.count <= 7 && [plot.pointLabels[i] isKindOfClass:[NSString class]] && [plot.pointLabels[i] length]==0)
            {
                //  UI(@"I: %d  Value:%f",i,value);
                lastX = x + step;
                value = [plot.points[i += 1] floatValue];
                lastY = self.topMargin + (self.yAxis.maxValue - value) / (self.yAxis.maxValue - self.yAxis.minValue) * self.chartFrame.size.height;
                x = lastX;
                y = lastY;
            }
        }
        
        [showPoints addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
        
        lastX = x;
        lastY = y;
        
        x += step;
    }
    
    // 将点连成曲线
    CGContextAddPath(ctx, [CWChartView quadCurvedPathWithPoints:showPoints].CGPath);
    CGContextStrokePath(ctx);
    
    [self drawCircleAndLabelWithPlot:plot withContext:ctx];
}

///*
- (void)drawPlot:(CWChartPlot *)plot withContext:(CGContextRef)ctx
{
    if(!plot.points ||
       plot.points.count == 0)
    {
        return;
    }
    
    [plot.color set];
    CGContextSetLineWidth(ctx, plot.width);
    CGFloat x = self.leftMargin + SPACE;
    CGFloat step = (self.chartFrame.size.width - WIDTH_SPACE) / (plot.points.count - 1);
    CGFloat lastX = 0.0, lastY = 0.0;
    
    
    for (int i = 0; i < plot.points.count; ++i)
    {
        CGFloat value = [plot.points[i] floatValue];
        
        //改动  减5
        CGFloat y = self.topMargin + (self.yAxis.maxValue - value) / (self.yAxis.maxValue - self.yAxis.minValue) * self.chartFrame.size.height - PLOT_SPACE;
        if (i == 0)
        {
            if (value == 0 && plot.points.count <= 7 && [plot.pointLabels[i] isKindOfClass:[NSString class]] && [plot.pointLabels[i] length]==0)
            {
                //  UI(@"I: %d  Value:%f",i,value);
                lastX = x + step;
                value = [plot.points[i += 1] floatValue];
                lastY = self.topMargin + (self.yAxis.maxValue - value) / (self.yAxis.maxValue - self.yAxis.minValue) * self.chartFrame.size.height;
                x = lastX;
                y = lastY;
            }
        }
        
        
        if (i == 1) {
            CGContextMoveToPoint(ctx, lastX, lastY);
        }
        
        if(i != 0)
        {
            CGContextAddLineToPoint(ctx, x, y);
        }
        
        if(i == plot.points.count-1)
        {
            //添加画线的阴影
//            CGContextSetShadowWithColor(ctx, CGSizeMake(1, 1), 0.4, [UIColor blackColor].CGColor);
            CGContextSetLineJoin(ctx, kCGLineJoinRound);
            CGContextSetLineCap(ctx, kCGLineCapRound);
            
            CGContextStrokePath(ctx);
        }
        
        if(plot.pointLabels && i < plot.pointLabels.count)
        {
            NSString *pointLabel = plot.pointLabels[i];
            CGRect labelFrame = CGRectMake(x - 50 / 2, y - 20, 50, 20); // CWChartPlotPointLabelPositionUp
            if(plot.pointLabelPosition == CWChartPlotPointLabelPositionDown)
            {
                labelFrame.origin.y = y + 5;
            }
            
#if 1
            NSMutableParagraphStyle *parStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
            parStyle.lineBreakMode = NSLineBreakByWordWrapping;
            parStyle.alignment     = NSTextAlignmentCenter;
            [pointLabel drawInRect:labelFrame withAttributes:@{NSFontAttributeName : plot.labelFont,
                                                               NSParagraphStyleAttributeName: parStyle}];
#else
            [pointLabel drawInRect:labelFrame withFont:plot.labelFont lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];
#endif
        }
        
        lastX = x;
        lastY = y;
        
        x += step;
    }
    [self drawCircleAndLabelWithPlot:plot withContext:ctx];
}

//*/
- (void)drawColumnar:(CWChartPlot *)plot withContext:(CGContextRef)ctx
{
    if(!plot.points ||
       plot.points.count == 0)
    {
        return;
    }
    [plot.color set];
    CGContextSetLineWidth(ctx, plot.width);
    CGFloat x = self.leftMargin;
    CGFloat step = (self.chartFrame.size.width - WIDTH_SPACE) / (plot.points.count - 1);
    CGFloat lastX, lastY;
    for (int i = 0; i < plot.points.count; ++i)
    {
        CGFloat value = [plot.points[i] floatValue];
        CGFloat y = self.topMargin + (self.yAxis.maxValue - value) / (self.yAxis.maxValue - self.yAxis.minValue) * self.chartFrame.size.height;
    
        [self drawLine:ctx
             fromPoint:CGPointMake(x, CGRectGetMaxY(self.chartFrame))
               toPoint:CGPointMake(x, y)
                 width:self.columnarWidth
             withColor:self.columnarColor];
        
        if(plot.pointLabels && i < plot.pointLabels.count)
        {
            NSString *pointLabel = plot.pointLabels[i];
            CGRect labelFrame = CGRectMake(x - 50 / 2 + SPACE, y - 20, 50, 20); // CWChartPlotPointLabelPositionUp
            if(plot.pointLabelPosition == CWChartPlotPointLabelPositionDown)
            {
                labelFrame.origin.y = y + 5;
            }
#if 1
            NSMutableParagraphStyle *parStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
            parStyle.lineBreakMode = NSLineBreakByWordWrapping;
            parStyle.alignment     = NSTextAlignmentCenter;
            [pointLabel drawInRect:labelFrame withAttributes:@{NSFontAttributeName : plot.labelFont,
                                                               NSParagraphStyleAttributeName: parStyle}];
#else
            [pointLabel drawInRect:labelFrame withFont:plot.labelFont lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];
#endif
        }
        
        lastX = x;
        lastY = y;
        
        x += step;
    }
}

-(void) drawXYLineWithContex:(CGContextRef)ctx
{
    int x = self.leftMargin + ([[self.xAxis.values lastObject] floatValue] - self.xAxis.minValue) / (self.xAxis.maxValue - self.xAxis.minValue) * (self.chartFrame.size.width - WIDTH_SPACE);
    
    int y = self.topMargin + (self.yAxis.maxValue - [[self.yAxis.values lastObject] floatValue]) / (self.yAxis.maxValue - self.yAxis.minValue) * self.chartFrame.size.height;
    CGContextSetLineWidth(ctx, 2);
    CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextMoveToPoint(ctx, self.leftMargin - 5, y - SPACE);
    CGContextAddLineToPoint(ctx, self.leftMargin - 5, CGRectGetMaxY(self.chartFrame));
    CGContextAddLineToPoint(ctx,x + 5 + SPACE*2 , CGRectGetMaxY(self.chartFrame));
    CGContextStrokePath(ctx);
}

#pragma mark - Properties

- (CGFloat)topMargin
{
    return 15;
}

- (CGFloat)bottomMargin
{
    if(self.xAxis && self.xAxis.showLabels)
        return self.xAxis.labelFont.lineHeight*(self.xAxis.showLines?2:1) + 10;
    else
        return 15;
}

- (CGFloat)leftMargin
{
    if(self.yAxis && self.yAxis.showLabels)
        return 35+self.leftMarginModify;
    else
        return 15;
}

- (CGFloat)rightMargin
{
    return 15;
}

@end
