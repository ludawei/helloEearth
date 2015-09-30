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

-(void)changeObjs:(NSArray *)objs;
-(void)clearObjs;

@end

@interface HEMapDataAnimLogic : NSObject

@property (nonatomic,weak) id<HEMapDataAnimDelegate> delegate;

-(instancetype)initWithMapDatas:(HEMapDatas *)mapDatas;

-(void)showProductWithTypes:(NSArray *)types withAge:(NSString *)age;
-(void)changeProgress:(UISlider *)progressView;
-(void)clickPlay;
-(void)clear;

@end
