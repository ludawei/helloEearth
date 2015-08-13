//
//  CWWindMapBottomView.h
//  ChinaWeather
//
//  Created by 卢大维 on 15/1/23.
//  Copyright (c) 2015年 Platomix. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CWWindMapBottomView : UIView

@property (nonatomic,copy) void (^hideBlock)();

-(void)setupWithData:(NSDictionary *)data;
-(void)setAddrText:(NSString *)addr;

@property (nonatomic) CGFloat initY;

-(void)show;
-(void)hide;
@end
