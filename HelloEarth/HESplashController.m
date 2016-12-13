//
//  HESplashController.m
//  HelloEarth
//
//  Created by 卢大维 on 15/9/15.
//  Copyright (c) 2015年 weather. All rights reserved.
//

#import "HESplashController.h"
#import "Masonry.h"
#import "HEPreAnim.h"
#import "HEDisAnim.h"
#import "CWDataManager.h"
#import "EAIntroView.h"

@interface HESplashController ()<EAIntroDelegate>

@property (nonatomic,strong) HEPreAnim *preAnim;
@property (nonatomic,strong) HEDisAnim *disAnim;
@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,strong) EAIntroView *intro;
@property (nonatomic) BOOL isAniming;

@end

@implementation HESplashController

-(BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.preAnim = [HEPreAnim new];
    self.disAnim = [HEDisAnim new];
    
    NSString *appVerison = [CWDataManager sharedInstance].appVerison;
    NSString *appRealVerison = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    if (appVerison && [appVerison isEqualToString:appRealVerison]) {
        [self showLoadingView];
    }
    else
    {
        [self showWecomeView];
    }
}

-(void)showWecomeView
{
    NSMutableArray *pages = [NSMutableArray array];
    for (NSInteger i=0; i<3; i++) {
        EAIntroPage *page = [EAIntroPage page];
        page.bgImage = [UIImage imageNamed:[NSString stringWithFormat:@"引导页-%td.jpg", i+1]];
        [pages addObject:page];
    }
    
    EAIntroView *intro = [[EAIntroView alloc] initWithFrame:self.view.bounds andPages:pages];
    intro.swipeToExit = NO;
    intro.delegate = self;
    intro.pageControl.hidden = YES;
    [intro.skipButton setTitle:nil forState:UIControlStateNormal];
    [intro.skipButton setImage:[UIImage imageNamed:@"立即体验"] forState:UIControlStateNormal];
    intro.showSkipButtonOnlyOnLastPage = YES;
    intro.skipButtonAlignment = EAViewAlignmentCenter;
    intro.skipButtonY = self.view.height * 0.35;
    [intro showInView:self.view];
    self.intro = intro;
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeDidFired) userInfo:nil repeats:YES];
}

-(void)showLoadingView
{
    UIImageView *loadingBackView = [UIImageView new];
    //    loadingBackView.frame = self.view.bounds;
    loadingBackView.contentMode = UIViewContentModeScaleAspectFill;
    loadingBackView.image = [UIImage imageNamed:@"背景.jpg"];
    [self.view addSubview:loadingBackView];
    [loadingBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    
    UIActivityIndicatorView *act = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [act startAnimating];
    [self.view addSubview:act];
    [act mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.centerY.mas_equalTo(self.view.height*0.1);
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:noti_loadanim_ok object:nil userInfo:nil];
        [self dismissViewControllerAnimated:YES completion:^{
            [CWDataManager sharedInstance].loadingAnimationFinished = YES;
            
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

#pragma mark - EAIntroDelegate
- (void)introDidFinish:(EAIntroView *)introView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:noti_loadanim_ok object:nil userInfo:nil];
    [self dismissViewControllerAnimated:YES completion:^{
        [CWDataManager sharedInstance].loadingAnimationFinished = YES;
        
        NSString *appRealVerison = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        [[CWDataManager sharedInstance] setAppVerison:appRealVerison];
        
        [self.timer invalidate];
        self.timer = nil;
    }];
}
- (void)intro:(EAIntroView *)introView pageAppeared:(EAIntroPage *)page withIndex:(NSUInteger)pageIndex
{
    CGFloat skipButtonBottomPadding = self.intro.skipButtonY - self.intro.skipButton.height/2;
    if (!CGPointEqualToPoint(self.intro.skipButton.center, CGPointMake(self.intro.width/2, self.intro.height-skipButtonBottomPadding))) {
        self.intro.skipButton.center = CGPointMake(self.intro.width/2, self.intro.height-skipButtonBottomPadding);
    }
    
    if (pageIndex == introView.pages.count-1) {
        UIImageView *loadingBackView = [UIImageView new];
        loadingBackView.contentMode = UIViewContentModeScaleAspectFill;
        loadingBackView.image = [introView viewShot];
        [self.view addSubview:loadingBackView];
        [loadingBackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.view);
        }];
        
        [self.view sendSubviewToBack:loadingBackView];
    }
}

-(void)timeDidFired
{
    if (self.isAniming) {
        return;
    }
    
    NSInteger arcRand = arc4random_uniform(10);
    if (arcRand < 5 && arcRand > 1) {
        // bounce 动画
        self.isAniming = YES;
        self.intro.skipButton.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9);
        [UIView animateWithDuration:0.3/1.5 animations:^{
            self.intro.skipButton.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3/2 animations:^{
                self.intro.skipButton.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.3/2 animations:^{
                    self.intro.skipButton.transform = CGAffineTransformIdentity;
                } completion:^(BOOL finished) {
                    self.isAniming = NO;
                }];
            }];
        }];
    }
}

@end
