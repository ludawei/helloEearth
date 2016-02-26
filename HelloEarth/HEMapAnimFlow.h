//
//  HEMapAnimFlow.h
//  HelloEarth
//
//  Created by 卢大维 on 16/2/22.
//  Copyright © 2016年 weather. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WhirlyGlobeMaplyComponent/WhirlyGlobeComponent.h>

@interface HEMapAnimFlow : NSObject

-(instancetype)initWithController:(UIViewController *)theViewC;

-(void)show;
-(void)hide;

@end
