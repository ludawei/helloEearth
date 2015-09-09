//
//  HEMapDatas.h
//  HelloEarth
//
//  Created by 卢大维 on 15/8/14.
//  Copyright (c) 2015年 weather. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ViewController.h"

@interface HEMapDatas : NSObject

@property (nonatomic,assign) id<ViewConDelegate> delegate;

-(instancetype)initWithController:(UIViewController *)theViewC;
-(NSArray *)changetitle:(NSString *)title;

@end
