//
//  HEProductsController.h
//  HelloEarth
//
//  Created by 卢大维 on 15/9/10.
//  Copyright (c) 2015年 weather. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HEProductDelegate <NSObject>

-(void)setData:(NSDictionary *)data;

@end

@interface HEProductsController : UIViewController

@property (nonatomic,assign) id<HEProductDelegate> delegate;

@end
