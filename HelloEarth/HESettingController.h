//
//  HESettingController.h
//  HelloEarth
//
//  Created by 卢大维 on 15/9/9.
//  Copyright (c) 2015年 weather. All rights reserved.
//

#import "HEBaseController.h"

@protocol HESettingDelegate <NSObject>

-(void)show3DMap:(BOOL)flag;
-(void)showMapLight:(BOOL)flag;
-(void)showLocation:(BOOL)flag;

@end

@interface HESettingController : HEBaseTableController

@property (nonatomic,assign) id<HESettingDelegate> delegate;
@property (nonatomic,assign) BOOL set3D,setLight,setLocation;

@end
