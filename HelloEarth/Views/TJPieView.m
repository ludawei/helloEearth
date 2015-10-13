//
//  TJPieView.m
//  LongForTianjie
//
//  Created by PLATOMIX  on 14-8-15.
//  Copyright (c) 2014年 platomix. All rights reserved.
//

#import "TJPieView.h"

@interface TJPieView ()

//@property (nonatomic) CGFloat currentPer;
@property (nonatomic,strong) NSArray *datas;
@property (nonatomic) int currentIndex;
@property (nonatomic) CGFloat start,end;

@property (nonatomic) CGFloat totalNum;

@end

@implementation TJPieView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (instancetype)initRadiuses:(NSArray *)radiuses total:(CGFloat)total
{
    if (self = [super init]) {
        
        self.datas = radiuses;
        self.totalNum = total;
    }
    
    return self;
}

-(void)startAnim
{
    self.currentIndex = 0;
    [self startAnimWithIndex:self.currentIndex];
}

-(void)startAnimWithIndex:(NSInteger)index
{
    if (index >= self.datas.count) {
        return;
    }
    
    CGFloat radio = self.frame.size.width/2;
    NSDictionary *dict = [self.datas objectAtIndex:index];
    CGFloat value = [[dict objectForKey:@"value"] floatValue];
    
    self.start = self.end;
    self.end += value/self.totalNum;
    UIColor *color = [self colorWithName:[dict objectForKey:@"name"]];
    
//    NSLog(@"start : %f, end : %f", self.start, self.end);
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path addArcWithCenter:CGPointMake(radio,radio) radius:radio startAngle:M_PI*3/2 endAngle:-M_PI/2 clockwise:NO];
    [path closePath];
    
    CAShapeLayer *arcLayer = [CAShapeLayer layer];
    arcLayer.path = path.CGPath;
    arcLayer.fillColor = [UIColor clearColor].CGColor;
    arcLayer.strokeColor = color.CGColor;
    arcLayer.lineWidth = radio*2/5;
    arcLayer.cornerRadius = radio;
    arcLayer.strokeStart = self.start;
    arcLayer.strokeEnd = self.end;
    arcLayer.masksToBounds = YES;
    arcLayer.frame = self.bounds;//CGRectMake(10, 10, self.bounds.size.width-20, self.bounds.size.height-20);
    [self.layer addSublayer:arcLayer];
    
    [self drawLineAnimation:arcLayer start:self.start end:self.end];
}


//定义动画过程
-(void)drawLineAnimation:(CALayer*)layer start:(CGFloat)start end:(CGFloat)end
{
    CABasicAnimation *bas=[CABasicAnimation animationWithKeyPath:NSStringFromSelector(@selector(strokeEnd))];
    bas.duration = (end-start);
    bas.delegate=self;
    bas.fromValue=[NSNumber numberWithFloat:start];
    bas.toValue=[NSNumber numberWithFloat:end];

    if (start == 0) {
        bas.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    }
    else if (end == 1)
    {
        bas.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    }
    [layer addAnimation:bas forKey:nil];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (flag) {
        if (self.currentIndex == 0) {
            UILabel *descriptionLabel =  [self descriptionLabel];
            [self addSubview:descriptionLabel];
            
            // bounce 动画
            descriptionLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);
            [UIView animateWithDuration:0.3/1.5 animations:^{
                descriptionLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.3/2 animations:^{
                    descriptionLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9);
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:0.3/2 animations:^{
                        descriptionLabel.transform = CGAffineTransformIdentity;
                    }];
                }];
            }];
        }
        
        self.currentIndex++;
        
        [self startAnimWithIndex:self.currentIndex];
    }
}

- (UILabel *)descriptionLabel
{
    UILabel *descriptionLabel = [[UILabel alloc] init];
    NSInteger days_int = [[[self.datas firstObject] objectForKey:@"value"] integerValue];
    NSString *days = [NSString stringWithFormat:@"%td天", days_int];
    
    if (days_int == -1) {
        days = @"--";
    }
    
    NSString *titleText = [NSString stringWithFormat:@"%@\n%@", [[self.datas firstObject] objectForKey:@"name"], days];
    
    descriptionLabel.text = titleText;
    
    descriptionLabel.font = [UIFont systemFontOfSize:self.width/5];
//    CGSize labelSize = [descriptionLabel.text sizeWithAttributes:@{NSFontAttributeName:descriptionLabel.font}];
//    descriptionLabel.frame = CGRectMake(descriptionLabel.frame.origin.x, descriptionLabel.frame.origin.y,
//                                        descriptionLabel.frame.size.width, labelSize.height);
    descriptionLabel.numberOfLines   = 0;
    descriptionLabel.textColor       = [UIColor whiteColor];
    descriptionLabel.textAlignment   = NSTextAlignmentCenter;
    descriptionLabel.alpha           = 1;
    descriptionLabel.backgroundColor = [UIColor clearColor];
    [descriptionLabel sizeToFit];
    
    descriptionLabel.center          = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    return descriptionLabel;
}

-(UIColor *)colorWithName:(NSString *)name
{
    if ([name isEqualToString:@"雨"]) {
        return [UIColor colorWithRed:0.161 green:0.639 blue:0.031 alpha:1];
    }
    else if ([name isEqualToString:@"雪"]) {
        return [UIColor colorWithRed:0.553 green:0.596 blue:0.702 alpha:1];
    }
    else if ([name isEqualToString:@"沙尘"]) {
        return [UIColor colorWithRed:0.992 green:0.408 blue:0.004 alpha:1];
    }
    else if ([name isEqualToString:@"雾"]) {
        return [UIColor colorWithRed:0.349 green:1.000 blue:1.000 alpha:1];
    }
    else if ([name isEqualToString:@"霾"]) {
        return [UIColor colorWithRed:0.788 green:0.608 blue:0.078 alpha:1];
    }
    else if ([name isEqualToString:@"其它"]) {
        return [UIColor colorWithRed:0.800 green:0.800 blue:0.800 alpha:1];
    }
    
    return [UIColor colorWithRed:0.592 green:0.710 blue:0.322 alpha:1];
}
@end
