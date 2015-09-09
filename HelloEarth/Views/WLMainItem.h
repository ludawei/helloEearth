//
//  WLMainItem.h
//  weatherLive
//
//  Created by 卢大维 on 15/4/23.
//  Copyright (c) 2015年 weather. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WLMainItem : UIControl

-(NSString *)title;
-(void)setTitle:(NSString *)title;
-(void)setTitleFont:(CGFloat)fontSize;
-(void)setTitleColor:(UIColor *)color;
-(void)setImage:(UIImage *)image;

@end
