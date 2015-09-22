//
//  HEMapDataAnimLogic.m
//  HelloEarth
//
//  Created by 卢大维 on 15/9/11.
//  Copyright (c) 2015年 weather. All rights reserved.
//

#import "HEMapDataAnimLogic.h"
#import "CWDataManager.h"

@interface HEMapDataAnimLogic ()
{
    BOOL isClear;
}

@property (nonatomic,strong) HEMapDatas *mapDatas;

@property (nonatomic,copy) NSArray *types;
@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic) NSInteger currentPlayIndex;

@end

@implementation HEMapDataAnimLogic

-(void)dealloc
{
    [self clear];
}

-(instancetype)initWithMapDatas:(HEMapDatas *)mapDatas
{
    if (self = [super init]) {
        self.mapDatas = mapDatas;
    }
    
    return self;
}

-(void)changeType
{
    [self.delegate clearObjs];
    
    NSString *type = [self.types objectAtIndex:self.currentPlayIndex];
    id data = [[CWDataManager sharedInstance] mapdataByFileMark:type];
    if ([data objectForKey:@"time"]) {
        [self setTimeLabelText:[data objectForKey:@"time"]];
    }
    
    NSArray *comObjs = [self.mapDatas changeType:type];
    [self.delegate changeObjs:comObjs];
}

-(void)showProductWithTypes:(NSArray *)types
{
    isClear = NO;
    [self.delegate setPlayButtonSelect:NO];
    
    self.types = types;
    
    self.currentPlayIndex = 0;
    [self changeType];
//    [self startAnimationWithIndex:0];
}

-(void)startAnimationWithIndex:(NSInteger)index
{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    
    INIT_WEAK_SELF;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weakSlef.timer = [NSTimer scheduledTimerWithTimeInterval:1.5f target:weakSlef selector:@selector(timeDidFired) userInfo:nil repeats:YES];
        weakSlef.currentPlayIndex = index;
        if (index >= weakSlef.types.count-1) {
            weakSlef.currentPlayIndex = 0;
        }
        
        [weakSlef.delegate setPlayButtonSelect:YES];
        [weakSlef timeDidFired];
    });
}

-(void)timeDidFired
{
    @autoreleasepool {
        [self changeType];
        CGFloat radio = 100.0*(self.currentPlayIndex)/(self.types.count-1);
        [self.delegate setProgressValue:radio];

        self.currentPlayIndex++;
        
        if (self.currentPlayIndex > self.types.count-1) {
            [self.timer invalidate];
            [self performSelector:@selector(repeatAnimation) withObject:nil afterDelay:3.0];
        }
    }
}

-(void)repeatAnimation
{
    if (self.timer && !isClear) {
        [self startAnimationWithIndex:0];
    }
    else
    {
        
    }
}

-(void)setTimeLabelText:(NSString *)text
{
    if (!text) {
        return;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSDate* expirationDate = [NSDate dateWithTimeIntervalSince1970:[text integerValue]/1000.0];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    [self.delegate setTimeText:[dateFormatter stringFromDate:expirationDate]];
    dateFormatter = nil;
}

-(void)changeProgress:(UISlider *)progressView
{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
        [self.delegate setPlayButtonSelect:NO];
    }
    
    self.currentPlayIndex = round(progressView.value*(self.types.count-1)/progressView.maximumValue);
    [self changeType];
}

-(void)clickPlay
{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
        [self.delegate setPlayButtonSelect:NO];
    }
    else
    {
        [self startAnimationWithIndex:0];
    }
    isClear = NO;
}

-(void)clear
{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
        [self.delegate setPlayButtonSelect:NO];
    }
    
    [self.delegate setProgressValue:0];
    [self setTimeLabelText:@""];
    isClear = YES;
    [self.delegate clearObjs];
}

@end
