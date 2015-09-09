//
//  WebController.m
//  chinaweathernews
//
//  Created by 卢大维 on 14-10-20.
//  Copyright (c) 2014年 weather. All rights reserved.
//

#import "WebController.h"
#import "NJKWebViewProgress.h"
#import "NJKWebViewProgressView.h"

#import "UIView+Extra.h"

#define NAV_BAR_HEIGHT 44
#define TOOL_BAR_HEIGHT 44

@interface WebController ()<UIWebViewDelegate, NJKWebViewProgressDelegate>
{
    NJKWebViewProgressView *_progressView;
    NJKWebViewProgress *_progressProxy;
    UILabel *tipLabel;
    NSInteger leftNavType;
    BOOL selfHideColl;
}
@property (nonatomic,strong) UIWebView *webView;
@property (nonatomic,strong) UINavigationItem *navItem;

@end

@implementation WebController

-(void)dealloc
{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navItem = self.navigationItem;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _progressProxy = [[NJKWebViewProgress alloc] init];
    _progressProxy.webViewProxyDelegate = self;
    _progressProxy.progressDelegate = self;
    
    CGFloat progressBarHeight = 2.f;
    CGRect navigaitonBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, navigaitonBarBounds.size.height - progressBarHeight, navigaitonBarBounds.size.width, progressBarHeight);
    
    _progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
    _webView.backgroundColor = [UIColor whiteColor];
    _webView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    _webView.delegate = _progressProxy;
    [self.view addSubview:_webView];
    
    [self loadUrl];
    
    [self initLeftButtonsWityType:1];
//    [self initRightButton];
}

//-(UIWebView *)webView
//{
//    if (!_webView) {
//        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
//        _webView.delegate = _progressProxy;
//        [self.view addSubview:_webView];
//    }
//    
//    return _webView;
//}

-(void)initLeftButtonsWityType:(NSInteger)type
{
    NSString *txt = @" 返回";
    UIFont *font = [UIFont systemFontOfSize:17];
    CGFloat textWidth = [txt sizeWithAttributes:@{NSFontAttributeName:font}].width;
    
    UIImage *buttonImage = [UIImage imageNamed:@"blue_back"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:buttonImage forState:UIControlStateNormal];
    [button setTitle:txt forState:UIControlStateNormal];
    button.titleLabel.font = font;
    [button setTitleColor:[UIColor colorWithRed:0.000 green:0.478 blue:1.000 alpha:1] forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, buttonImage.size.width+textWidth, buttonImage.size.height);
    [button addTarget:self action:@selector(clickLeftButton1) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *left1 = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -10;
    
    if (type == 1 && type != leftNavType) {
        
        self.navItem.leftBarButtonItems = @[negativeSpacer, left1];
    }
    else if (type == 2 && type != leftNavType)
    {
        UIBarButtonItem *left2 = [[UIBarButtonItem alloc] initWithTitle:@"关闭"
                                                                  style:UIBarButtonItemStyleDone
                                                                 target:self
                                                                 action:@selector(clickLeftButton2)];
        negativeSpacer.width = -10;
        
        self.navItem.leftBarButtonItems = @[negativeSpacer, left1, left2];
    }
    
    leftNavType = type;
}

-(void)initRightButton
{
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:@"•••"
                                                              style:UIBarButtonItemStyleDone
                                                             target:self
                                                             action:@selector(clickRightButton)];
    self.navItem.rightBarButtonItem = right;
}

-(void)clickLeftButton1
{
    if ([self.webView canGoBack]) {
        [self.webView goBack];
    }
    else
    {
        if (self.navigationController.viewControllers.count == 1) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

-(void)clickLeftButton2
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    [self.webView stopLoading];
//    self.webView.delegate=nil;
//    [self.webView removeFromSuperview];
//    self.webView = nil;
//    [self showTipView];
    
    
//    [self.navigationController popViewControllerAnimated:YES];
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[self.info objectForKey:@"l2"]]];
//    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController.navigationBar addSubview:_progressView];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    
    // Remove progress view
    // because UINavigationBar is shared with other ViewControllers
    [_progressView removeFromSuperview];
    _webView.delegate = nil;
    _webView = nil;
}

-(void)loadUrl
{
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:self.url]];
    [self.webView loadRequest:req];
}

-(void)showTipView
{
    if (!tipLabel)
    {
        UILabel *label = [UILabel new];
        label.textColor = [UIColor lightGrayColor];
        label.text = @"出了点问题,请返回后重试";
        [label sizeToFit];
        label.center = self.view.center;
        [self.view addSubview:label];
        tipLabel = label;
    }
}

-(void)clickButton
{
    [self.navigationController popViewControllerAnimated:YES];

//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[self.info objectForKey:@"l2"]]];
//    });
}

#pragma mark - NJKWebViewProgressDelegate
-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [_progressView setProgress:progress animated:YES];
    self.navItem.title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    if ([self.webView canGoBack]) {
        [self initLeftButtonsWityType:2];
        selfHideColl = YES;
    }
    else
    {
        [self initLeftButtonsWityType:1];
        selfHideColl = NO;
    }
}

//-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
//{
//    return YES;
//}

@end
