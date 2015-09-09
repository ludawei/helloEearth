//
//  ViewController.h
//  HelloEarth
//
//  Created by 卢大维 on 15/7/28.
//  Copyright (c) 2015年 weather. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ViewConDelegate <NSObject>

-(void)setPlayButtonSelect:(BOOL)select;
-(void)setTimeText:(NSString *)text;
-(void)setProgressValue:(CGFloat)radio;

@end

@interface ViewController : UIViewController

@property (nonatomic,assign) BOOL isBottomFull;
@property (nonatomic,copy) NSString *dataType;
@property (nonatomic,copy) NSString *dataUrl;

@end

