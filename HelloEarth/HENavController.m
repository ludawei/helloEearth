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
    
//    [self.navigationBar setBackgroundImage:[Util createImageWithColor:[UIColor blackColor] width:1 height:(STATUS_HEIGHT+SELF_NAV_HEIGHT)] forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.translucent = YES;
    
    self.interactivePopGestureRecognizer.enabled = YES;
    self.interactivePopGestureRecognizer.delegate = self;
    
//    [self showLoadingView];
}

-(void)showLoadingView
{
    HESplashController *next = [HESplashController new];
    [self presentViewController:next animated:NO completion:^{

    }];
    
//    [[[UIApplication sharedApplication].delegate window] addSubview:next.view];

#if 0
    NSMutableArray *imgs = [NSMutableArray array];
    for (NSInteger i=1; i<=25; i++) {
        [imgs addObject:[UIImage imageNamed:[NSString stringWithFormat:@"loading_%ld", i]]];
    }
    [imgs insertObject:[UIImage imageNamed:@"loading_11"] atIndex:10];
    [imgs insertObject:[UIImage imageNamed:@"loading_11"] atIndex:10];
    [imgs insertObject:[UIImage imageNamed:@"loading_11"] atIndex:10];
    [imgs insertObject:[UIImage imageNamed:@"loading_11"] atIndex:10];
    
    [imgs addObject:[imgs lastObject]];
    [imgs addObject:[imgs lastObject]];
    [imgs addObject:[imgs lastObject]];
    [imgs addObject:[imgs lastObject]];
    
    UIImageView *loadingBackView = [UIImageView new];
//    loadingBackView.frame = self.view.bounds;
    loadingBackView.contentMode = UIViewContentModeScaleAspectFill;
    loadingBackView.image = [UIImage imageNamed:@"APP启动图－3.jpg"];
    [[[UIApplication sharedApplication].delegate window] addSubview:loadingBackView];
    [loadingBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo([[UIApplication sharedApplication].delegate window]);
    }];
    
    self.loadingBackView = loadingBackView;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        loadingBackView.image = [UIImage imageNamed:@"背景.jpg"];
        
        UIImageView *loadingView = [UIImageView new];
        [loadingBackView addSubview:loadingView];
        [loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(loadingBackView.mas_centerX);
            make.centerY.mas_equalTo(loadingBackView.mas_centerY).offset(-self.view.height/7);
        }];
        [loadingView sizeToFit];
        
        loadingView.animationImages = imgs;
        loadingView.animationRepeatCount = 1;
        loadingView.animationDuration = 14.8;//5.8;
        [loadingView startAnimatingWithCompletionBlock:^(BOOL success) {
            if (success) {
                [UIView animateWithDuration:0.3 animations:^{
                    loadingBackView.alpha = 0;
                } completion:^(BOOL finished) {
                    [loadingBackView removeFromSuperview];
//                    [[NSNotificationCenter defaultCenter] removeObserver:self];
                }];
            }
        }];
    });
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceRotated:) name:UIDeviceOrientationDidChangeNotification object:nil];
#endif
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

- (NSUInteger)supportedInterfaceOrientations
{
//    if ([self.topViewController isKindOfClass:[ViewController class]]){
//        return UIInterfaceOrientationMaskAllButUpsideDown;
//    }
    
    return UIInterfaceOrientationMaskPortrait;
}

@end
