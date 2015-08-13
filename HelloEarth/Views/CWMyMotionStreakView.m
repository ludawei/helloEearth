//
//  CWMyMotionStreakView.m
//  ChinaWeather
//
//  Created by 卢大维 on 15/1/27.
//  Copyright (c) 2015年 Platomix. All rights reserved.
//

#import "CWMyMotionStreakView.h"

#define LIMIT 20

@interface CWMyMotionStreakView ()

@property (nonatomic,strong) NSMutableArray *imgLayers;

@end

@implementation CWMyMotionStreakView

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = NO;
        self.imgLayers = [NSMutableArray arrayWithCapacity:LIMIT];
    }
    
    return self;
}

-(void)addLayer:(CALayer *)layer1
{
    if (self.imgLayers.count == LIMIT) {
        CALayer *layer = self.imgLayers.lastObject;
        [layer removeFromSuperlayer];
        [self.imgLayers removeLastObject];
    }
    
    CALayer *layer = [CALayer layer];
    layer.frame = self.bounds;
//    layer.contents = (id)image.CGImage;
    layer.contents = layer1.contents;
    layer.actions = @{@"opacity": [NSNull null]};              // 取消动画
    [self.layer addSublayer:layer];
    
    [self.imgLayers insertObject:layer atIndex:0];
    
    for (NSInteger i=self.imgLayers.count-1; i>=0; i--) {
        CALayer *layer = [self.imgLayers objectAtIndex:i];
        layer.opacity = MAX(layer.opacity - 1.0/LIMIT, 0);
    }
}

-(void)setHidden:(BOOL)hidden
{
    if (hidden) {
        [self.imgLayers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            CALayer *layer = (CALayer *)obj;
            [layer removeFromSuperlayer];
            [self.imgLayers removeObjectAtIndex:idx];
        }];
        
        [self setNeedsDisplay];
    }
    
    [super setHidden:hidden];
}

@end
