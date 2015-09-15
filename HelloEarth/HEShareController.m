//
//  HEShareController.m
//  HelloEarth
//
//  Created by 卢大维 on 15/9/8.
//  Copyright (c) 2015年 weather. All rights reserved.
//

#import "HEShareController.h"
#import "Util.h"
#import "Masonry.h"
#import "WLMainItem.h"
#import "UIView+Extra.h"

#import "UMSocial.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialQQHandler.h"

@interface HEShareController ()
//@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) UIView *contentView,*shareView;
@property (nonatomic,strong) UIControl *dimView;

@end

@implementation HEShareController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"分享";
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"返回"] style:UIBarButtonItemStyleDone target:self action:@selector(clickBack)];
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:@"•••"
                                                              style:UIBarButtonItemStyleDone
                                                             target:self
                                                             action:@selector(clickRightButton)];
    
    self.navigationItem.leftBarButtonItem = left;
    self.navigationItem.rightBarButtonItem = right;
    
    [self initViews];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setBackgroundImage:[Util createImageWithColor:[UIColor blackColor] width:1 height:(STATUS_HEIGHT+SELF_NAV_HEIGHT)] forBarMetrics:UIBarMetricsDefault];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initViews
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    // top views
    UIView *topView = [UIView new];
    topView.backgroundColor = [UIColor colorWithRed:0.192 green:0.196 blue:0.200 alpha:1];
    [self.view addSubview:topView];
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(STATUS_HEIGHT+SELF_NAV_HEIGHT);
        make.bottom.left.right.mas_equalTo(self.view);
    }];
    self.contentView = topView;
    
    UIImageView *logo = [UIImageView new];
    logo.image = [UIImage imageNamed:@"logo"];
    logo.contentMode = UIViewContentModeScaleAspectFit;
    [topView addSubview:logo];
    [logo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(10);
        make.right.mas_equalTo(-10);
        make.height.mas_equalTo(60);
        make.width.mas_equalTo(logo.image.size.width/logo.image.size.height * 60);
    }];
    
    UIImageView *shareImageView = [UIImageView new];
    shareImageView.image = [UIImage imageNamed:@"手机"];
    shareImageView.contentMode = UIViewContentModeScaleAspectFit;
    [topView addSubview:shareImageView];
    
    CGSize imgSize = CGSizeMake(self.view.width*0.55, self.view.width*0.55*shareImageView.image.size.height/shareImageView.image.size.width);
    [shareImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(topView.mas_centerX);
        make.top.mas_greaterThanOrEqualTo(self.view.height*0.02).with.priorityHigh();
//        make.bottom.mas_lessThanOrEqualTo(titleLabel.mas_top).offset(-20).with.priorityHigh();
        make.width.mas_lessThanOrEqualTo(imgSize.width);
        make.height.mas_lessThanOrEqualTo(imgSize.height);
    }];
    
    UIImageView *inImageView = [UIImageView new];
    inImageView.image = self.image;
    [shareImageView addSubview:inImageView];
    [inImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(shareImageView.mas_centerX);
        make.centerY.mas_equalTo(shareImageView.mas_centerY);
        make.width.mas_equalTo(shareImageView.mas_width).multipliedBy(0.9);
        make.height.mas_equalTo(shareImageView.mas_height).multipliedBy(0.8);
    }];
    
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:10];
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:@"      “蓝π蚂蚁” 邀您体验酷炫的3D地图展示立体化的气象数据，动态的效果、直观的方式，让您能够与之互动，更全面、更直观地感觉产品。"];
    [text addAttributes:@{NSParagraphStyleAttributeName:paragraphStyle } range:NSMakeRange(0, text.length)];
    CGFloat textHeight = ceil([text size].width/(self.view.width*0.9));
    
    UILabel *titleLabel = [self createLabelWithFont:[UIFont boldSystemFontOfSize:16] text:text textColor:[UIColor colorWithRed:0.698 green:0.698 blue:0.702 alpha:1]];
    [topView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(shareImageView.mas_bottom).offset(20);
//        make.bottom.mas_equalTo(topView).offset(-10).with.priorityLow();
        make.centerX.mas_equalTo(topView.mas_centerX);
        make.width.mas_equalTo(topView.mas_width).multipliedBy(0.9);
        make.height.mas_greaterThanOrEqualTo(textHeight*([text size].height+10));
    }];
    
    self.dimView = [UIControl new];
    self.dimView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    [self.view addSubview:self.dimView];
    [self.dimView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    self.dimView.hidden = YES;
    [self.dimView addTarget:self action:@selector(topDim) forControlEvents:UIControlEventTouchDown];
    
    // bottom views
    UIView *bottomView = [UIView new];
    bottomView.backgroundColor = [UIColor colorWithRed:0.165 green:0.169 blue:0.173 alpha:1];
    [self.view addSubview:bottomView];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_bottom);
        make.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(200);
    }];
    self.shareView = bottomView;
    
    UILabel *shareToLbl = [self createLabelWithFont:[UIFont systemFontOfSize:18] text:@"分享到" textColor:[UIColor colorWithRed:0.400 green:0.404 blue:0.408 alpha:1]];
    [bottomView addSubview:shareToLbl];
    [shareToLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(20);
    }];
    [shareToLbl sizeToFit];
    
    NSArray *images = @[@[@"QQ", @"qq"],
                        @[@"微信", @"微信"],
                        @[@"朋友圈", @"朋友圈"],
                        @[@"新浪微博", @"微博"]];
    WLMainItem *lastButton;
    for (NSInteger i=0; i<images.count; i++) {
        
        NSString *text = [[images objectAtIndex:i] firstObject];
        NSString *imgName = [[images objectAtIndex:i] lastObject];
        WLMainItem *button = [self createButtonWithImage:[UIImage imageNamed:imgName] text:text];
        button.tag = i;
        [bottomView addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            if (lastButton) {
                make.left.mas_equalTo(lastButton.mas_right);
            }
            else
            {
                make.left.mas_equalTo(0);
            }
            
            make.top.mas_equalTo(shareToLbl.mas_bottom).offset(10);
            //            make.bottom.mas_equalTo(bottomView).offset(10);
            make.width.mas_equalTo(bottomView.mas_width).multipliedBy(0.25);
            make.height.mas_equalTo(bottomView.mas_height).multipliedBy(0.25);
        }];
        
        [button addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
        lastButton = button;
    }
    
    UIButton *cancelButton = [UIButton new];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    cancelButton.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    [bottomView addSubview:cancelButton];
    [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(lastButton.mas_bottom).offset(35);
        make.bottom.mas_equalTo(bottomView.mas_bottom).offset(-15);
        make.centerX.mas_equalTo(bottomView.mas_centerX);
        make.width.mas_equalTo(bottomView.mas_width).multipliedBy(0.85);
    }];
    [cancelButton addTarget:self action:@selector(clickCancelButton) forControlEvents:UIControlEventTouchUpInside];
    
    lastButton = nil;
    
    self.shareView.hidden = YES;
}

-(UILabel *)createLabelWithFont:(UIFont *)font text:(id)text textColor:(UIColor *)color
{
    UILabel *titleView = [UILabel new];
    titleView.textColor = color;
    titleView.font = font;
    titleView.numberOfLines = 0;
    if ([text isKindOfClass:[NSAttributedString class]]) {
        titleView.attributedText = text;
    }
    else
    {
        titleView.text = text;
    }
    
    return titleView;
}

-(WLMainItem *)createButtonWithImage:(UIImage *)image text:(NSString *)text
{
    WLMainItem *button = [WLMainItem new];
    [button setImage:image];
    [button setTitle:text];
    [button setTitleColor:[UIColor colorWithRed:0.400 green:0.404 blue:0.408 alpha:1]];
    [button setTitleFont:15];

    return button;
}

#pragma mark - actions 
-(void)clickBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)clickRightButton
{
    if (self.shareView.hidden) {
        self.shareView.hidden = NO;
        self.dimView.hidden = NO;
        self.dimView.alpha = 0.0f;
        
        [self.shareView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.view.mas_bottom);
            make.left.right.mas_equalTo(self.view);
            make.height.mas_equalTo(200);

        }];
        [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self.view layoutIfNeeded];
            self.dimView.alpha = 1.0f;
        } completion:^(BOOL finished) {
            
        }];
    }
    else
    {
        [self.shareView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.view.mas_bottom);
            make.left.right.mas_equalTo(self.view);
            make.height.mas_equalTo(200);
        }];
        
        [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self.view layoutIfNeeded];
            self.dimView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            self.shareView.hidden = YES;
            self.dimView.hidden = YES;
        }];
    }
}

-(void)clickCancelButton
{
    [self clickRightButton];
}

-(void)topDim
{
    [self clickCancelButton];
}

-(void)clickButton:(UIButton *)button
{
    switch (button.tag) {
        case 0:
        {
            // qq分享
            [self shareWithType:UMShareToQQ];
            break;
        }
        case 1:
        {
            // 微信
            [self shareWithType:UMShareToWechatSession];
            break;
        }
        case 2:
        {
            // 朋友圈
            [self shareWithType:UMShareToWechatTimeline];
            break;
        }
        case 3:
        {
            // 新浪
            [self shareWithType:UMShareToSina];
            break;
        }
        default:
            break;
    }
}


-(void)shareWithType:(NSString *)type
{
    NSString *imageUrl = @"www.weather.com.cn";
    UIImage *shareImage = [self.contentView viewShot];//[[UIImageView sharedImageCache] cachedImageForRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]]];
    
    [UMSocialData defaultData].extConfig.qqData.title = @"蓝π蚂蚁 分享";
    [UMSocialData defaultData].extConfig.qzoneData.title = @"蓝π蚂蚁 分享";
    [UMSocialData defaultData].extConfig.wechatSessionData.title = @"蓝π蚂蚁 分享";
    [UMSocialData defaultData].extConfig.wechatTimelineData.title = @"蓝π蚂蚁 分享";//title;
    
    //设置微信AppId、appSecret，分享url
    [UMSocialWechatHandler setWXAppId:WX_APP_ID appSecret:WX_APP_SECRET url:imageUrl];
    
    //设置分享到QQ/Qzone的应用Id，和分享url 链接
    [UMSocialQQHandler setQQWithAppId:QQ_APP_ID appKey:QQ_APP_KEY url:imageUrl];
    
    //    [UMSocialSnsService presentSnsIconSheetView:self
    //                                         appKey:UM_APP_KEY
    //                                      shareText:@""//self.info.title
    //                                     shareImage:shareImage
    //                                shareToSnsNames:[NSArray arrayWithObjects:UMShareToWechatSession, UMShareToWechatTimeline, UMShareToQQ, UMShareToQzone,nil]
    //                                       delegate:nil];
    
    [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[type]
                                                        content:@"蓝π蚂蚁 分享"//self.info.title
                                                          image:shareImage
                                                       location:nil
                                                    urlResource:[[UMSocialUrlResource alloc] initWithSnsResourceType:UMSocialUrlResourceTypeDefault url:imageUrl]
                                            presentedController:self
                                                     completion:^(UMSocialResponseEntity *response){
                                                         if (response.responseCode == UMSResponseCodeSuccess) {
                                                             NSLog(@"分享成功！");
                                                         }
                                                     }];
}
@end
