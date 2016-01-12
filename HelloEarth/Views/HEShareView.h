//
//  HEShareView.h
//  HelloEarth
//
//  Created by 卢大维 on 16/1/12.
//  Copyright © 2016年 weather. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HEShareDelegate;

@interface HEShareView : UIView

@property (nonatomic,weak) id<HEShareDelegate> delegate;
@property (nonatomic,strong) UIImage *shareImage;

-(void)show;
-(void)hide;

@end

@protocol HEShareDelegate <NSObject>

-(void)clickShareCancel;

@end
