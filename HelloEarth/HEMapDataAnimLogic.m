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

@property (nonatomic,strong) HEMapDatas *mapDatas;

@property (nonatomic,copy) NSArray *types;
@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic) NSInteger currentPlayIndex;

@end

@implementation HEMapDataAnimLogic

-(instancetype)initWithMapDatas:(HEMapDatas *)mapDatas
{
    if (self = [super init]) {
        self.mapDatas = mapDatas;
    }
    
    return self;
}

-(void)changeType
{
    [self.delegate willChangeObjs];
    NSArray *comObjs = [self.mapDatas changeType:[self.types objectAtIndex:self.currentPlayIndex]];
    [self.delegate changeObjs:comObjs];
}

-(void)showProductWithTypes:(NSArray *)types
{
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
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.5f target:self selector:@selector(timeDidFired) userInfo:nil repeats:YES];
        self.currentPlayIndex = index;
        if (index >= self.types.count-1) {
            self.currentPlayIndex = 0;
        }
        [self.delegate setPlayButtonSelect:YES];
        
        [self timeDidFired];
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
            [self repeatAnimation];
        }
    }
}

-(void)repeatAnimation
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.timer) {
            [self startAnimationWithIndex:0];
        }
    });
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
}

-(void)clear
{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
        [self.delegate setPlayButtonSelect:NO];
    }
}

@end
