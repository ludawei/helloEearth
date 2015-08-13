//
//  NewMapCoverView.m
//  windMap
//
//  Created by 卢大维 on 14/12/26.
//  Copyright (c) 2014年 weather. All rights reserved.
//

#import "NewMapCoverView.h"
#import "MyVector.h"
#import "WindParticle.h"
#import "UIView+Extra.h"
#import <CoreFoundation/CoreFoundation.h>

#import "MKMapView+ZoomLevel.h"

#define S_HEIGHT_RADIO 0.5
#define S_WIDTH_RADIO 0.6

#define PARTICLE_WIDTH 7
#define PARTICLE_HEIGHT 4

#define ARC4RANDOM_MAX      0x100000000
//#define PARTICLE_LIMIT      500
#define PARTICLE_SHOW_LIMIT 3000

//#define REFRESH_TIMEVAL_1   0.04f
//#define REFRESH_TIMEVAL_2   0.065f

//#define USE_TIMER 1

@interface NewMapCoverView ()
{
    CGFloat mapRadio;
}

#ifdef USE_TIMER
@property (nonatomic,strong) NSTimer *timer;            // cpu 60%~70%
#else
@property (nonatomic,strong) CADisplayLink *timer;      // cpu 70%~80%
#endif

@property (nonatomic) CGFloat x0,y0,x1,y1;
@property (nonatomic) NSInteger gridWidth,gridHeight;
@property (nonatomic) CGFloat maxLength;
@property (nonatomic,strong) NSArray *fields;

@property (nonatomic,strong) NSMutableArray *particles;

@property (nonatomic,strong) UIBezierPath *arrowPath;

//@property (nonatomic,strong) UIImageView *imgView;

@end

@implementation NewMapCoverView

-(void)setNeedsDisplay
{
    [super setNeedsDisplay];
    
    if (self.particleType == 2)
    {
        [self.motionView addLayer:self.layer];
    }
}

-(void)removeFromSuperview
{
    [self.motionView removeFromSuperview];
    self.motionView = nil;
    self.particles = nil;
    [self.timer invalidate];
    self.timer = nil;
    
    [super removeFromSuperview];
}

-(id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        self.particles = [NSMutableArray arrayWithCapacity:PARTICLE_SHOW_LIMIT];
        
        // 用来显示拖尾巴效果
//        self.imgView = [[UIImageView alloc] initWithFrame:self.bounds];
////        self.imgView.alpha = 0.8;
//        [self addSubview:self.imgView];
        
        self.partLimit = PARTICLE_SHOW_LIMIT;
    }
    
    return self;
}

-(void)setupWithData:(NSDictionary *)data
{
    NSArray *fields = [data objectForKey:@"field"];
    self.x0 = [[data objectForKey:@"x0"] floatValue];
    self.y0 = [[data objectForKey:@"y0"] floatValue];
    self.x1 = [[data objectForKey:@"x1"] floatValue];
    self.y1 = [[data objectForKey:@"y1"] floatValue];
    self.gridWidth = [[data objectForKey:@"gridWidth"] intValue];
    self.gridHeight = [[data objectForKey:@"gridHeight"] intValue];
    
    [self setupFields:fields];
    
    if (!self.partNum) {
        self.partNum = PARTICLE_SHOW_LIMIT;
    }
    
    for (int i = 0; i<self.partNum; i++) {
        WindParticle *particle = [[WindParticle alloc] init];
        particle.maxLength = self.maxLength;
        
        [self.particles addObject:particle];
    }
}

-(void)setParticleType:(int)particleType
{
    _particleType = particleType;
    if (particleType == 1) {
        self.motionView.hidden = YES;
    }
    else
    {
        self.motionView.hidden = NO;
    }
    
    [self stop];
    [self setNeedsDisplay];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self restart];
    });
    
//    if (self.timer) {
//        [self.timer invalidate];
//        self.timer = nil;
//    }
//    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.timeval target:self selector:@selector(timeFired) userInfo:nil repeats:YES];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    if (self.particles.count <= 0) {
        return;
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);
    
    CGContextClearRect(context, self.bounds);
    
    NSInteger showCount = 0;
    for (int i=0; i<self.partNum; i++) {
        
        if (showCount >= self.partLimit) {
            break;
        }
        
        if ([self drawPathInContext:context particle:[self.particles objectAtIndex:i]]) {
            showCount++;
        }
    }

    UIGraphicsPopContext();
}

-(BOOL)drawPathInContext:(CGContextRef)context particle:(WindParticle *)particle
{
    if (particle.age <= 0 || !particle.isShow) {
        return NO;
    }
    
    CGSize size = CGSizeMake(PARTICLE_WIDTH, PARTICLE_HEIGHT);
    CGPoint center = particle.center;
    CGPoint point = CGPointMake(center.x - size.width/2.0, center.y - size.height/2.0);

    CGContextSaveGState(context);
    
    CGFloat temp_alpha = 10.0f;
    CGFloat alpha = particle.age/temp_alpha;
    if (particle.initAge-particle.age <= temp_alpha) {
        alpha = (particle.initAge-particle.age)/temp_alpha;
    }
    CGContextSetAlpha(context, alpha);
    
//    [self colorWithLength:particle.length];//
    UIColor *partcicleColor = [self colorWithLength:particle.length];//[UIColor colorWithHue:1.0-(float)particle.colorHue/255.0f saturation:0.7f brightness:0.7f alpha:0.8f];
    
    if (self.particleType == 1) {
        CGContextTranslateCTM(context, point.x, point.y);       // 移动原点
        CGContextRotateCTM(context, particle.angleWithXY);      // 旋转画布
        
        CGContextSetFillColorWithColor(context, [partcicleColor CGColor]);
        
        [self.arrowPath fill];
        
    }
    else if (self.particleType == 2)
    {
        /**********************************   画一条线段  *****************************************/
        if (particle.oldCenter.x != -1) {
            CGContextSetStrokeColorWithColor(context, [partcicleColor CGColor]);
            
            CGContextSetLineWidth(context, 1.2);
            
            CGPoint newPoint = CGPointMake(particle.center.x, particle.center.y);
            CGContextMoveToPoint(context, newPoint.x, newPoint.y);
            
            newPoint = CGPointMake(particle.oldCenter.x, particle.oldCenter.y);
            CGContextAddLineToPoint(context, newPoint.x, newPoint.y);
            
            CGContextStrokePath(context);
            
//            if ([self.particles indexOfObject:particle] >= self.particles.count-1) {
//                CGContextStrokePath(context);
//            }
        }
        
        /**********************************   画一条线段  *****************************************/
    }
    
    CGContextRestoreGState(context);
    
    return YES;
}

-(UIBezierPath *)arrowPath
{
    if (!_arrowPath) {
        /**********************************   画一个箭头  *****************************************/
        
        _arrowPath = [UIBezierPath bezierPath];
        
        CGSize size = CGSizeMake(PARTICLE_WIDTH, PARTICLE_HEIGHT);
        
        CGPoint point = CGPointZero;
        
        CGPoint newPoint = CGPointMake((0 + point.x), (size.height*((1-S_HEIGHT_RADIO)/2.0) + point.y));
        [_arrowPath moveToPoint:newPoint];
        
        newPoint = CGPointMake((size.width*S_WIDTH_RADIO + point.x), (size.height*((1-S_HEIGHT_RADIO)/2.0) + point.y));
        [_arrowPath addLineToPoint:newPoint];
        
        newPoint = CGPointMake((size.width*S_WIDTH_RADIO + point.x), (0 + point.y));
        [_arrowPath addLineToPoint:newPoint];
        
        newPoint = CGPointMake((size.width + point.x), (size.height*0.5 + point.y));
        [_arrowPath addLineToPoint:newPoint];
        
        newPoint = CGPointMake((size.width*S_WIDTH_RADIO + point.x), (size.height + point.y));
        [_arrowPath addLineToPoint:newPoint];
        
        newPoint = CGPointMake((size.width*S_WIDTH_RADIO + point.x), (size.height*((1+S_HEIGHT_RADIO)/2.0) + point.y));
        [_arrowPath addLineToPoint:newPoint];
        
        newPoint = CGPointMake((0 + point.x), (size.height*((1+S_HEIGHT_RADIO)/2.0) + point.y));
        [_arrowPath addLineToPoint:newPoint];
         /**********************************   画一个箭头  *****************************************/
    }
    return _arrowPath;
}

-(void)didMoveToSuperview
{
    [super didMoveToSuperview];
    
    mapRadio = self.mapView.zoomLevel/self.mapView.maxZoomLevel;
    
#ifdef USE_TIMER
//    self.timer = [NSTimer scheduledTimerWithTimeInterval:REFRESH_TIMEVAL target:self selector:@selector(timeFired) userInfo:nil repeats:YES];
//    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:UITrackingRunLoopMode];
#else
    self.timer = [CADisplayLink displayLinkWithTarget:self selector:@selector(timeFired)];
//    self.timer.frameInterval = 4;
    [self.timer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [self.timer addToRunLoop:[NSRunLoop mainRunLoop] forMode:UITrackingRunLoopMode];
#endif
}

-(void)setupFields:(NSArray *)fields
{
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:fields.count/2];
    for (NSInteger i=0; i<fields.count/2; i++) {
        CGVector v = CGVectorMake([[fields objectAtIndex:i*2] floatValue], [[fields objectAtIndex:i*2+1] floatValue]);
        [arr addObject:[NSValue valueWithCGVector:v]];
        
        self.maxLength = MAX(self.maxLength, [MyVector length:v]);
    }
    
    self.fields = arr;
}


// 在界面上随机产生一个点
-(CGPoint)randomParticleCenter
{
    CGFloat x,y;
    double a = ((double)arc4random() / ARC4RANDOM_MAX);
    double b = ((double)arc4random() / ARC4RANDOM_MAX);
#if 0
    x = a*self.x0 + (1-a)*self.x1;
    y = b*self.y0 + (1-b)*self.y1;
#else
    x = (1-a)*self.bounds.size.width;
    y = (1-b)*self.bounds.size.height;
#endif
    CGPoint p = CGPointMake(x, y);
    
    CGVector vp = [self vecorWithPoint:[self mapPointFromViewPoint:p]];
    CGFloat temp = sqrt(vp.dx*vp.dx + vp.dy*vp.dy);
//    NSLog(@"%f", temp);
    
    CGFloat vRadio = 5.0;
    if (self.particleType == 2) {
        vRadio = 2.0;
    }
    
    if (temp < vRadio) {
        p = [self randomParticleCenter];
    }
    
    return p;
}

// 产生一个随机的生命周期
-(NSInteger)randomAge
{
    return 50+arc4random_uniform(150);
}



/**
 *  根据周围点的速度，得到该点的速度
 *
 *  @param isX 是X，还是Y
 *  @param a   x方向上的值
 *  @param b   y方向上的值
 *
 *  @return 得到该点的速度（x或y）
 */
-(CGFloat)bilinearWithIsX:(BOOL)isX a:(CGFloat)a b:(CGFloat)b
{
    NSInteger na = MIN((int)floor(a), self.gridWidth-1);
    NSInteger nb = MIN((int)floor(b), self.gridHeight-1);
    NSInteger ma = MIN((int)ceil(a), self.gridWidth-1);
    NSInteger mb = MIN((int)ceil(b), self.gridHeight-1);
    CGFloat fa = a - na;
    CGFloat fb = b - nb;
    
    NSInteger index = self.gridHeight;
//    [MyVector ValueWithIsX:isX v:[[self.fields objectAtIndex:MIN((na*index+nb), self.fields.count-1)] CGVectorValue]]
//    [(Vector *)[self.fields objectAtIndex:MIN((na*index+nb), self.fields.count-1)] ValueWithIsX:isX]
    return [MyVector ValueWithIsX:isX v:[[self.fields objectAtIndex:MIN((na*index+nb), self.fields.count-1)] CGVectorValue]] * (1 - fa) * (1 - fb) +
    [MyVector ValueWithIsX:isX v:[[self.fields objectAtIndex:MIN((ma*index+nb), self.fields.count-1)] CGVectorValue]] * fa * (1 - fb) +
    [MyVector ValueWithIsX:isX v:[[self.fields objectAtIndex:MIN((na*index+mb), self.fields.count-1)] CGVectorValue]] * (1 - fa) * fb +
    [MyVector ValueWithIsX:isX v:[[self.fields objectAtIndex:MIN((ma*index+mb), self.fields.count-1)] CGVectorValue]] * fa * fb;
}

/**
 *  根据任一经纬度，得到一个速度Vector
 *
 *  @param point 经纬度(x为long, y为lat)
 *
 *  @return 得到一个速度Vector
 */
-(CGVector)vecorWithPoint:(CGPoint)point
{
//    point = CGPointMake(-178.875,-90);
    CGFloat a = (self.gridWidth - 1 - 1e-6)*(point.x - self.x0)/(self.x1 - self.x0);
    CGFloat b = (self.gridHeight - 1 - 1e-6)*(point.y - self.y0)/(self.y1 - self.y0);
    CGFloat vx = [self bilinearWithIsX:YES a:a b:b];
    CGFloat vy = [self bilinearWithIsX:NO a:a b:b];
    
//    NSLog(@"vx: %f, vy: %f", vx, vy);
    
    return CGVectorMake(vx, vy);
}

-(void)timeFired
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //        __weak typeof(self) weakSelf = self;
        if (self.fields.count > 0) {
            [self.particles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                WindParticle *particle = (WindParticle *)obj;
                [self updateCenter:particle];
                
                if (idx == self.particles.count-1) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self setNeedsDisplay];
                    });
                }
            }];
        }
    });
}

-(void)updateCenter:(WindParticle *)particle
{
    particle.age--;
    if (particle.age <= 0) {
        CGPoint center = [self randomParticleCenter];
        CGVector vect = [self vecorWithPoint:[self mapPointFromViewPoint:center]];
        [particle resetWithCenter:center age:[self randomAge] xv:vect.dx yv:vect.dy];
    }
    else
    {
        if (!particle.isShow) {
            return;
        }
        
        CGFloat vRadio = 1.5;
        if (self.particleType == 2) {
            vRadio = 2.5;
        }
        
        // 经度自下向上，画布自上向下，故取反
        CGPoint center = CGPointMake(particle.center.x+particle.xv*mapRadio* vRadio, particle.center.y+(-particle.yv)*mapRadio * vRadio);
        CGRect disRect = self.bounds;
        
        // 卫星地图，只显示有卫星的区域
        CGFloat minDisMapY = -66;
        CGFloat maxDisMapY = 80;
        
        CGPoint mapPoint = [self mapPointFromViewPoint:center];

        if (mapPoint.x <= self.x0) {
            mapPoint.x = self.x1-self.x0 + mapPoint.x;
        }
        if (!CGRectContainsPoint(disRect, center) || mapPoint.y < minDisMapY || mapPoint.y > maxDisMapY) {
            center = [self randomParticleCenter];
            CGVector vect = [self vecorWithPoint:[self mapPointFromViewPoint:center]];
            [particle resetWithCenter:center age:[self randomAge] xv:vect.dx yv:vect.dy];
        }
        
        CGVector vect = [self vecorWithPoint:mapPoint];
        [particle updateWithCenter:center xv:vect.dx yv:vect.dy];
    }
}

-(void)stop
{
#ifdef USE_TIMER
    [self.timer setFireDate:[NSDate distantFuture]];
#else
    self.timer.paused = YES;
#endif
    self.hidden = YES;
    self.motionView.hidden = YES;
}

-(void)restart
{
    self.hidden = NO;
    if (self.particleType == 1) {
        self.motionView.hidden = YES;
        self.timer.frameInterval = 3;
    }
    else
    {
        [self setNeedsDisplay];
        self.motionView.hidden = NO;
        self.timer.frameInterval = 5;
    }
    
#ifdef USE_TIMER
    [self.timer setFireDate:[NSDate distantPast]];
#else
    self.timer.paused = NO;
#endif
    
//    self.imgView.image = nil;
    
    mapRadio = self.mapView.zoomLevel/self.mapView.maxZoomLevel;
    
    self.partLimit = PARTICLE_SHOW_LIMIT - 100 * (1 - self.mapView.zoomLevel/self.mapView.maxZoomLevel);
//    self.imgView.alpha = 0.85+((self.mapView.maxZoomLevel-self.mapView.zoomLevel)/self.mapView.maxZoomLevel)*0.13;
}

// 返回view上的点对应在地图上的位置
-(CGPoint)mapPointFromViewPoint:(CGPoint)point
{
    if (self.mapView) {
        CLLocationCoordinate2D coor = [self.mapView convertPoint:point toCoordinateFromView:self.mapView];
        
        return CGPointMake(coor.longitude, coor.latitude);
    }
    
    return point;
}

-(UIColor *)colorWithLength:(CGFloat)length
{
    if (length < 8.49) {
        UIColor *color1 = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.0f];
        UIColor *color2 = [UIColor colorWithRed:152/255.0 green:219/255.0 blue:248/255.0 alpha:1.0f];
        
        return [self colorWithLength:length color1:color1 color2:color2 len1:0 len2:8.49];
    }
    else if (length < 15.79)
    {
        UIColor *color1 = [UIColor colorWithRed:152/255.0 green:219/255.0 blue:248/255.0 alpha:1.0f];
        UIColor *color2 = [UIColor colorWithRed:0 green:137/255.0 blue:209/255.0 alpha:1.0f];
        
        return [self colorWithLength:length color1:color1 color2:color2 len1:8.49 len2:15.79];
    }
    else if (length < 30)
    {
        UIColor *color1 = [UIColor colorWithRed:0 green:137/255.0 blue:209/255.0 alpha:1.0f];
        UIColor *color2 = [UIColor colorWithRed:254/255.0 green:0 blue:3/255.0 alpha:1.0f];
        
        return [self colorWithLength:length color1:color1 color2:color2 len1:15.79 len2:30];
    }
    else if (length < 70)
    {
        UIColor *color1 = [UIColor colorWithRed:254/255.0 green:0 blue:3/255.0 alpha:1.0f];
        UIColor *color2 = [UIColor colorWithRed:209/255.0 green:103/255.0 blue:211/255.0 alpha:1.0f];
        
        return [self colorWithLength:length color1:color1 color2:color2 len1:30 len2:70];
    }
    else if (length < 90)
    {
        UIColor *color1 = [UIColor colorWithRed:209/255.0 green:103/255.0 blue:211/255.0 alpha:1.0f];
        UIColor *color2 = [UIColor colorWithRed:238/255.0 green:200/255.0 blue:239/255.0 alpha:1.0f];
        
        return [self colorWithLength:length color1:color1 color2:color2 len1:70 len2:90];
    }
    else if (length < 100)
    {
        UIColor *color1 = [UIColor colorWithRed:238/255.0 green:200/255.0 blue:239/255.0 alpha:1.0f];
        UIColor *color2 = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0f];
        
        return [self colorWithLength:length color1:color1 color2:color2 len1:90 len2:100];
    }
    
    return nil;
}

-(UIColor *)colorWithLength:(CGFloat)length color1:(UIColor *)color1 color2:(UIColor *)color2 len1:(CGFloat)len1 len2:(CGFloat)len2
{
    CGFloat r1,g1,b1,a1, r2,g2,b2,a2;
    [color1 getRed:&r1 green:&g1 blue:&b1 alpha:&a1];
    [color2 getRed:&r2 green:&g2 blue:&b2 alpha:&a2];
    
    CGFloat r = r1 + ((r2 - r1)*(length - len1)/(len2 - len1));
    CGFloat g = g1 + ((g2 - g1)*(length - len1)/(len2 - len1));
    CGFloat b = b1 + ((b2 - b1)*(length - len1)/(len2 - len1));
    CGFloat a = a1 + ((a2 - a1)*(length - len1)/(len2 - len1));
    
    return [UIColor colorWithRed:r green:g blue:b alpha:a];
}
@end
