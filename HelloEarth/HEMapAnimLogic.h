//
//  HEMapAnimLogic.h
//  HelloEarth
//
//  Created by 卢大维 on 15/8/14.
//  Copyright (c) 2015年 weather. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WhirlyGlobeComponent.h"

@interface HEMapAnimLogic : NSObject

@property (nonatomic,strong) MaplyComponentObject *stickersObj;

-(instancetype)initWithController:(UIViewController *)theViewC;

-(void)showImagesAnimation:(enum MapImageType)type;

@end
