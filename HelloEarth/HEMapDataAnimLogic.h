//
//  HEMapDataAnimLogic.h
//  HelloEarth
//
//  Created by 卢大维 on 15/9/11.
//  Copyright (c) 2015年 weather. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HEMapAnimLogic.h"
#import "HEMapDatas.h"

@protocol HEMapDataAnimDelegate <HEMapAnimLogicDelegate>

-(void)willChangeObjs;
-(void)changeObjs:(NSArray *)objs;

@end

@interface HEMapDataAnimLogic : NSObject

@property (nonatomic,assign) id<HEMapDataAnimDelegate> delegate;

-(instancetype)initWithMapDatas:(HEMapDatas *)mapDatas;

-(void)showProductWithTypes:(NSArray *)types;
-(void)changeProgress:(UISlider *)progressView;
-(void)clickPlay;
-(void)clear;

@end
