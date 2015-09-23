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
{
    UIImageView *loadingIV;
}

@property (nonatomic,strong) UIImageView *loadingBackView;
@property (nonatomic,strong) UIViewController *cont;

@end

@implementation HENavController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [UIView setAnimationsEnabled:NO];
    
    // Stackoverflow #26357162 to force orientation
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
    [self.navigationBar setMyHeight:50];
    [self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont systemFontOfSize:20]}];
    [self.navigationBar setTintColor:[UIColor whiteColor]];
    
    [self.navigationBar setTitleVerticalPositionAdjustment:-5 forBarMetrics:UIBarMetricsDefault];
    [self.navigationBar setTitleVerticalPositionAdjustment:-8 forBarMetrics:UIBarMetricsCompact];
//    [self.navigationBar setBackgroundImage:[Util createImageWithColor:[UIColor blackColor] width:1 height:(STATUS_HEIGHT+SELF_NAV_HEIGHT)] forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.translucent = YES;
    
    self.interactivePopGestureRecognizer.enabled = YES;
    self.interactivePopGestureRecognizer.delegate = self;
    
    UIImageView *loadingBackView = [UIImageView new];
    loadingBackView.contentMode = UIViewContentModeScaleAspectFill;
    loadingBackView.image = [UIImage imageNamed:@"APP启动图－3.jpg"];
    [self.view addSubview:loadingBackView];
    [loadingBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    loadingIV = loadingBackView;
    
    INIT_WEAK_SELF;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSlef showLoadingView];
    });
}

-(void)showLoadingView
{
    HESplashController *next = [HESplashController new];
    next.transitioningDelegate = next;
    [self presentViewController:next animated:YES completion:^{
        [loadingIV removeFromSuperview];
        loadingIV = nil;
        
    }];
    
    ViewController *next1 = [ViewController new];
    [self pushViewController:next1 animated:NO];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [UIView setAnimationsEnabled:YES];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (self.viewControllers.count == 2)
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
    if ([self.topViewController isKindOfClass:[ViewController class]]){
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
    
    return UIInterfaceOrientationMaskPortrait;
}

//-(BOOL)shouldAutorotate
//{
//    return YES;
//}

//-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
//{
//    return UIInterfaceOrientationPortrait;
//}

@end
