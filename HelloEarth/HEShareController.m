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

#import "UMSocial.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialQQHandler.h"
#import "WXApi.h"
#import "UIImage+Extra.h"
#import "DeviceUtil.h"

#define SHARE_TEXT @"“蓝PI·寰宇”邀您体验酷炫的气象数据3D展示，三维的地图、动态的效果、便捷的交互，让您能够与数据互动，更全面、更直观地感受气象服务产品。"

@interface HEShareController ()
{
    BOOL finishLoad;
}
//@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) UIImageView *shareImageView;
@property (nonatomic,strong) UIView *contentView,*shareView;
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UIControl *dimView;

@end

@implementation HEShareController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"分享";
    UIButton *leftNavButton = [Util leftNavButtonWithSize:CGSizeMake(self.navigationController.navigationBar.height, self.navigationController.navigationBar.height)];
    [leftNavButton addTarget:self action:@selector(clickBack) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftNavButton];
    
    UIButton *rightNavButton = [Util rightNavButtonWithTitle:@"•••"];
    [rightNavButton addTarget:self action:@selector(clickRightButton) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightNavButton];
    
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
    
    finishLoad = YES;
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if (finishLoad) {
        return;
    }
    
    [self.contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.centerY.mas_equalTo(self.view.mas_centerY).offset((STATUS_HEIGHT+SELF_NAV_HEIGHT)/2);
        make.size.mas_equalTo(self.contentView.bounds.size);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initViews
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor colorWithRed:0.188 green:0.212 blue:0.263 alpha:1];
    
    // top views
    UIView *topView = [UIView new];
    [self.view addSubview:topView];
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(STATUS_HEIGHT+SELF_NAV_HEIGHT);
        make.left.right.mas_equalTo(self.view);
    }];
    self.contentView = topView;
    
    UIImageView *logo = [UIImageView new];
    logo.image = [UIImage imageNamed:@"logo"];
    logo.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:logo];
    [logo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo((STATUS_HEIGHT+SELF_NAV_HEIGHT)+10);
        make.right.mas_equalTo(-10);
        make.height.mas_equalTo(60);
        make.width.mas_equalTo(logo.image.size.width/logo.image.size.height * 60);
    }];
    
    UIImage *disImage = [UIImage imageNamed:@"ipad"];
    UIImageView *shareImageView = [UIImageView new];
    shareImageView.image = self.imageRotationAngle!=0?[disImage rotatedByDegrees:-90]:disImage;
    shareImageView.contentMode = UIViewContentModeScaleAspectFit;
    [topView addSubview:shareImageView];
    
    CGFloat imgWidth = self.view.width * 0.5;
    if (self.imageRotationAngle != 0) {
        imgWidth = self.view.width * 0.7;
    }
    CGSize imgSize = CGSizeMake(imgWidth, imgWidth*shareImageView.image.size.height/shareImageView.image.size.width);
    [shareImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(topView.mas_centerX);
        make.top.mas_greaterThanOrEqualTo(self.view.height*0.02).with.priorityHigh();
//        make.bottom.mas_lessThanOrEqualTo(titleLabel.mas_top).offset(-20).with.priorityHigh();
        make.width.mas_lessThanOrEqualTo(imgSize.width);
        make.height.mas_lessThanOrEqualTo(imgSize.height);
    }];
    self.shareImageView = shareImageView;
    
    UIImageView *inImageView = [UIImageView new];
    inImageView.image = self.image;//self.imageRotationAngle!=0?[self.image rotatedByDegrees:self.imageRotationAngle]:self.image;
    [shareImageView addSubview:inImageView];
    [inImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(shareImageView.mas_centerX);
        make.centerY.mas_equalTo(shareImageView.mas_centerY);
        
        if (self.imageRotationAngle!=0) {
            make.width.mas_equalTo(shareImageView.mas_width).multipliedBy(0.81);
            make.height.mas_equalTo(shareImageView.mas_height).multipliedBy(0.9);
        }
        else
        {
            make.width.mas_equalTo(shareImageView.mas_width).multipliedBy(0.9);
            make.height.mas_equalTo(shareImageView.mas_height).multipliedBy(0.81);
        }
    }];
    
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:10];
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[@"      " stringByAppendingString:SHARE_TEXT]];
    [text addAttributes:@{NSParagraphStyleAttributeName:paragraphStyle } range:NSMakeRange(0, text.length)];
    CGFloat textHeight = ceil([text size].width/(self.view.width*0.9));
    
    UILabel *titleLabel = [self createLabelWithFont:[Util modifyBoldSystemFontWithSize:16] text:text textColor:[UIColor colorWithRed:0.698 green:0.698 blue:0.702 alpha:1]];
    [topView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(shareImageView.mas_bottom).offset(20);
//        make.bottom.mas_equalTo(topView).offset(-10).with.priorityLow();
        make.centerX.mas_equalTo(topView.mas_centerX);
        make.width.mas_equalTo(topView.mas_width).multipliedBy(0.9);
        make.height.mas_greaterThanOrEqualTo(textHeight*([text size].height+10));
    }];
    self.titleLabel = titleLabel;
    
    [topView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(titleLabel.mas_bottom).offset(10);
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
    
    UILabel *shareToLbl = [self createLabelWithFont:[Util modifySystemFontWithSize:18] text:@"分享到" textColor:[UIColor colorWithRed:0.400 green:0.404 blue:0.408 alpha:1]];
    [bottomView addSubview:shareToLbl];
    [shareToLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(20);
    }];
    [shareToLbl sizeToFit];
    
    //设置微信AppId、appSecret，分享url
    [UMSocialWechatHandler setWXAppId:WX_APP_ID appSecret:WX_APP_SECRET url:@""];

    //设置分享到QQ/Qzone的应用Id，和分享url 链接
    [UMSocialQQHandler setQQWithAppId:QQ_APP_ID appKey:QQ_APP_KEY url:@""];
    
    NSMutableArray *images = [NSMutableArray array];
    if ([QQApiInterface isQQInstalled])
    {
        [images addObject:@[@"QQ", @"qq"]];
    }
    if ([WXApi isWXAppInstalled])
    {
        [images addObject:@[@"微信", @"微信"]];
        [images addObject:@[@"朋友圈", @"朋友圈"]];
    }
    
    UIView *lastView;
    if (images.count == 0) {
        UILabel *tipLabel = [self createLabelWithFont:[Util modifySystemFontWithSize:18] text:@"没有可分享的平台😔" textColor:[UIColor lightGrayColor]];
        tipLabel.textAlignment = NSTextAlignmentCenter;
        [bottomView addSubview:tipLabel];
        [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(bottomView);
            make.top.mas_equalTo(shareToLbl.mas_bottom).offset(10);
            make.height.mas_equalTo(bottomView.mas_height).multipliedBy(0.25);
        }];
        
        lastView = tipLabel;
    }
    else
    {
        for (NSInteger i=0; i<images.count; i++) {
            
            NSString *text = [[images objectAtIndex:i] firstObject];
            NSString *imgName = [[images objectAtIndex:i] lastObject];
            WLMainItem *button = [self createButtonWithImage:[UIImage imageNamed:imgName] text:text];
            button.tag = i;
            [bottomView addSubview:button];
            [button mas_makeConstraints:^(MASConstraintMaker *make) {
                if (lastView) {
                    make.left.mas_equalTo(lastView.mas_right);
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
            lastView = button;
        }
    }
    
    UIButton *cancelButton = [UIButton new];
    cancelButton.layer.cornerRadius = 10;
    cancelButton.clipsToBounds = YES;
    [cancelButton setBackgroundImage:[Util createImageWithColor:[UIColor colorWithWhite:0 alpha:0.2] width:1 height:1] forState:UIControlStateNormal];
    [cancelButton setBackgroundImage:[Util createImageWithColor:[UIColor colorWithWhite:0 alpha:0.7] width:1 height:1] forState:UIControlStateHighlighted];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [bottomView addSubview:cancelButton];
    [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(lastView.mas_bottom).offset(35);
        make.bottom.mas_equalTo(bottomView.mas_bottom).offset(-15);
        make.centerX.mas_equalTo(bottomView.mas_centerX);
        make.width.mas_equalTo(bottomView.mas_width).multipliedBy(0.85);
    }];
    [cancelButton addTarget:self action:@selector(clickCancelButton) forControlEvents:UIControlEventTouchUpInside];
    
    lastView = nil;
    
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
    NSString *imageUrl = @"https://itunes.apple.com/us/app/lanp-huan-yu/id1044915755?l=zh&ls=1&mt=8";
    UIImage *shareImage = [self.contentView viewShot];
    NSString *appName = [DeviceUtil getSoftVersion:true];
    
    [UMSocialData defaultData].extConfig.qqData.title = [appName stringByAppendingString:@" 分享"];
    [UMSocialData defaultData].extConfig.qzoneData.title = [appName stringByAppendingString:@" 分享"];
    [UMSocialData defaultData].extConfig.wechatSessionData.title = [appName stringByAppendingString:@" 分享"];
    [UMSocialData defaultData].extConfig.wechatTimelineData.title = [[SHARE_TEXT componentsSeparatedByString:@"，"] firstObject];
    
    //设置微信AppId、appSecret，分享url
    [UMSocialWechatHandler setWXAppId:WX_APP_ID appSecret:WX_APP_SECRET url:imageUrl];
    
    //设置分享到QQ/Qzone的应用Id，和分享url 链接
    [UMSocialQQHandler setQQWithAppId:QQ_APP_ID appKey:QQ_APP_KEY url:imageUrl];
    
    [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[type]
                                                        content:[[SHARE_TEXT componentsSeparatedByString:@"，"] firstObject]//self.info.title
                                                          image:shareImage
                                                       location:nil
                                                    urlResource:[[UMSocialUrlResource alloc] initWithSnsResourceType:UMSocialUrlResourceTypeDefault url:imageUrl]
                                            presentedController:self
                                                     completion:^(UMSocialResponseEntity *response){
                                                         if (response.responseCode == UMSResponseCodeSuccess) {
                                                             LOG(@"分享成功！");
                                                         }
                                                     }];
}

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    if (self.titleLabel) {
        [self.titleLabel removeFromSuperview];
        self.titleLabel = nil;
    }
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:10];
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[@"      " stringByAppendingString:SHARE_TEXT]];
    [text addAttributes:@{NSParagraphStyleAttributeName:paragraphStyle } range:NSMakeRange(0, text.length)];
    CGFloat textHeight = ceil([text size].width/(size.width*0.9));
    
    UILabel *titleLabel = [self createLabelWithFont:[Util modifyBoldSystemFontWithSize:16] text:text textColor:[UIColor colorWithRed:0.698 green:0.698 blue:0.702 alpha:1]];
    [self.contentView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.shareImageView.mas_bottom).offset(20);
        make.centerX.mas_equalTo(self.contentView.mas_centerX);
        make.width.mas_equalTo(size.width * 0.9);
        make.height.mas_greaterThanOrEqualTo(textHeight*([text size].height+10));
    }];
    [self.view layoutIfNeeded];
    
    titleLabel.width = 0.9 * size.width;
    [titleLabel sizeToFit];
    self.titleLabel = titleLabel;
    
    
}
@end
