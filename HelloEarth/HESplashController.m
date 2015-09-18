//
//  HESplashController.m
//  HelloEarth
//
//  Created by 卢大维 on 15/9/15.
//  Copyright (c) 2015年 weather. All rights reserved.
//

#import "HESplashController.h"
#import "UIImageView+AnimationCompletion.h"
#import "Masonry.h"
#import "HEPreAnim.h"
#import "HEDisAnim.h"

@interface HESplashController ()

@property (nonatomic,strong) HEPreAnim *preAnim;
@property (nonatomic,strong) HEDisAnim *disAnim;

@end

@implementation HESplashController

-(BOOL)shouldAutorotate
{
    return NO;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.preAnim = [HEPreAnim new];
    self.disAnim = [HEDisAnim new];
    
    [self showLoadingView];
}

-(void)showLoadingView
{
    NSMutableArray *imgs = [NSMutableArray array];
    for (NSInteger i=1; i<=25; i++) {
        [imgs addObject:[UIImage imageNamed:[NSString stringWithFormat:@"loading_%td", i]]];
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
    [self.view addSubview:loadingBackView];
    [loadingBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        loadingBackView.image = [UIImage imageNamed:@"背景.jpg"];
        
        UIImageView *loadingView = [UIImageView new];
        [loadingBackView addSubview:loadingView];
        [loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(loadingBackView.mas_centerX);
            make.centerY.mas_equalTo(loadingBackView.mas_centerY).offset(-self.view.height/7);
        }];
        [loadingView sizeToFit];
        
        loadingView.image = [imgs lastObject];
        loadingView.animationImages = imgs;
        loadingView.animationRepeatCount = 1;
        loadingView.animationDuration = 4.8;//5.8;
        [loadingView startAnimatingWithCompletionBlock:^(BOOL success) {
            if (success) {
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self dismissViewControllerAnimated:YES completion:^{
                        
                    }];
                });
            }
        }];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIViewControllerAnimatedTransitioning
-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    return self.preAnim;
}

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return self.disAnim;
}

@end
