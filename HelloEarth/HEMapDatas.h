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

-(instancetype)initWithController:(UIViewController *)theViewC;
-(NSArray *)changeType:(NSString *)type;

@end
