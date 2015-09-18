//
//  HENavController.m
//  HelloEarth
//
//  Created by 卢大维 on 15/9/8.
//  Copyright (c) 2015年 weather. All rights reserved.
//

#import "HENavController.h"
#import "ViewController.h"
#import "Util.h"
#import "UINavigationBar+CustomHeight.h"
#import "Masonry.h"
#import "UIImageView+AnimationCompletion.h"
#import "HESplashController.h"

@interface HENavController ()<UIGestureRecognizerDelegate>

@property (nonatomic,strong) UIImageView *loadingBackView;

@end

@implementation HENavController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationBar setMyHeight:50];
    [self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont systemFontOfSize:20]}];
    [self.navigationBar setTintColor:[UIColor whiteColor]];
    
    [self.navigationBar setTitleVerticalPositionAdjustment:-5 forBarMetrics:UIBarMetricsDefault];
//    [self.navigationBar setBackgroundImage:[Util createImageWithColor:[UIColor blackColor] width:1 height:(STATUS_HEIGHT+SELF_NAV_HEIGHT)] forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.translucent = YES;
    
    self.interactivePopGestureRecognizer.enabled = YES;
    self.interactivePopGestureRecognizer.delegate = self;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (self.viewControllers.count == 1)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 状态栏样式
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
//    if ([self.topViewController isKindOfClass:[ViewController class]]){
//        return UIInterfaceOrientationMaskAllButUpsideDown;
//    }
    
    return UIInterfaceOrientationMaskPortrait;
}

@end
