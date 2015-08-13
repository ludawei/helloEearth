//
//  WindParticle.m
//  windMap
//
//  Created by 卢大维 on 14/12/25.
//  Copyright (c) 2014年 weather. All rights reserved.
//

#import "WindParticle.h"

@interface WindParticle ()

//@property (nonatomic) CGFloat vScale;       // 速度比例
@property (nonatomic) CGFloat initAge;

@end

@implementation WindParticle

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

-(instancetype)init
{
    if (self = [super init]) {
        
        self.oldCenter = CGPointMake(-1, -1);
    }
    
    return self;
}

-(void)setVelocityWithX:(CGFloat)x y:(CGFloat)y
{
    self.xv = x;
    self.yv = y;
    
    CGFloat s = sqrt(x*x + y*y)/self.maxLength;
    CGFloat t = floor(290*(1 - s)) - 45;
    
    self.colorHue = t;
}

-(void)resetWithCenter:(CGPoint)center age:(NSInteger)age xv:(CGFloat)xv yv:(CGFloat)yv
{
    self.age = age;
    self.initAge = age;
    [self updateWithCenter:center xv:xv yv:yv];
    
    self.oldCenter = CGPointMake(-1, -1);
    
    
}

-(CGFloat)initAge
{
    return _initAge;
}

-(CGFloat)length
{
    return sqrt(self.xv*self.xv + self.yv*self.yv);
}

-(BOOL)isShow
{
//    if (self.length <= 1.0) {
//        return NO;
//    }
    
    return YES;
}

-(CGFloat)angleWithXY
{
    CGFloat angle = atan2(self.yv, self.xv);
    if (self.oldCenter.x != -1) {
        if (self.center.x == self.oldCenter.x) {
            angle = ((self.center.y > self.oldCenter.y)?1:-1)*M_PI_2;
        }
        else if (self.center.y == self.oldCenter.y)
        {
            angle = (self.center.x > self.oldCenter.x)?0:M_PI;
        }
        else
        {
            angle = atan2(self.center.y - self.oldCenter.y, self.center.x - self.oldCenter.x);
        }
    }
    
    return angle;
}

-(void)updateWithCenter:(CGPoint)center xv:(CGFloat)xv yv:(CGFloat)yv
{
    self.oldCenter = self.center;
    self.center = center;
    [self setVelocityWithX:xv y:yv];
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"center: %@, xv: %.2f, yv: %.2f, colorHue:%f", [NSValue valueWithCGPoint:self.center], self.xv, self.yv, self.colorHue];
}
@end
