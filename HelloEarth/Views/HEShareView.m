//
//  HEShareView.m
//  HelloEarth
//
//  Created by 卢大维 on 16/1/12.
//  Copyright © 2016年 weather. All rights reserved.
//

#import "HEShareView.h"

#import "Util.h"
#import "Masonry.h"
#import "WLMainItem.h"

#import <UMSocialCore/UMSocialCore.h>
#import "WXApi.h"
#import "UIImage+Extra.h"
#import "DeviceUtil.h"

@interface HEShareView ()

@end

@implementation HEShareView

-(instancetype)init
{
    if (self = [super init]) {
        UIView *bottomView = self;
        
        UILabel *shareToLbl = [self createLabelWithFont:[Util modifySystemFontWithSize:18] text:@"分享到" textColor:[UIColor colorWithRed:0.400 green:0.404 blue:0.408 alpha:1]];
        [bottomView addSubview:shareToLbl];
        [shareToLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(20);
            make.left.mas_equalTo(20);
            make.height.mas_equalTo(30);
        }];
        
        //设置微信AppId、appSecret，分享url
        [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession appKey:WX_APP_ID appSecret:WX_APP_SECRET redirectURL:@""];
        
        //设置分享到QQ互联的appKey和appSecret
        [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_QQ appKey:QQ_APP_ID  appSecret:QQ_APP_KEY redirectURL:@""];
        
        NSMutableArray *images = [NSMutableArray array];
//        if ([QQApiInterface isQQInstalled])
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
        [cancelButton addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
        
        lastView = nil;
        
        self.hidden = YES;
    }
    
    return self;
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

-(void)show
{
    self.hidden = NO;
    
    [self mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.superview.mas_bottom);
        make.left.right.mas_equalTo(self.superview);
        make.height.mas_equalTo(200);
        
    }];
}

-(void)hide
{
    [self.delegate clickShareCancel];
}

-(void)clickButton:(UIButton *)button
{
    switch (button.tag) {
        case 0:
        {
            // qq分享
            [self shareWithType:UMSocialPlatformType_QQ];
            break;
        }
        case 1:
        {
            // 微信
            [self shareWithType:UMSocialPlatformType_WechatSession];
            break;
        }
        case 2:
        {
            // 朋友圈
            [self shareWithType:UMSocialPlatformType_WechatTimeLine];
            break;
        }
        case 3:
        {
            // 新浪
            [self shareWithType:UMSocialPlatformType_Sms];
            break;
        }
        default:
            break;
    }
}

-(void)shareWithType:(UMSocialPlatformType)type
{
    NSString *imageUrl = @"https://itunes.apple.com/us/app/lanp-huan-yu/id1044915755?l=zh&ls=1&mt=8";
    UIImage *shareImage;
//    if ([type isEqualToString:UMShareToWechatTimeline]) {
//        shareImage = [self addimageWidth:MIN(375.0, self.shareImage.size.width) withImage:self.shareImage];
//    }
//    else
    {
        shareImage = [self addimageWidth:self.shareImage.size.width withImage:self.shareImage];
    }
    
    NSString *appName = [DeviceUtil getSoftVersion:true];
    
    //设置微信AppId、appSecret，分享url
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession appKey:WX_APP_ID appSecret:WX_APP_SECRET redirectURL:imageUrl];
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatTimeLine appKey:WX_APP_ID appSecret:WX_APP_SECRET redirectURL:imageUrl];
    //设置分享到QQ互联的appKey和appSecret
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_QQ appKey:QQ_APP_ID  appSecret:QQ_APP_KEY redirectURL:imageUrl];
    
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    messageObject.text = [NSString stringWithFormat:@"%@分享", appName];
    
    //创建图片内容对象
    UMShareImageObject *shareObject = [[UMShareImageObject alloc] init];
    //如果有缩略图，则设置缩略图
    shareObject.thumbImage = shareImage;
    [shareObject setShareImage:UIImageJPEGRepresentation(shareImage, 1.0)];
    
    //分享消息对象设置分享内容对象
    messageObject.shareObject = shareObject;
    
    //调用分享接口
    [[UMSocialManager defaultManager] shareToPlatform:type messageObject:messageObject currentViewController:self completion:^(id data, NSError *error) {
        if (error) {
            NSLog(@"************Share fail with error %@*********",error);
        }else{
            NSLog(@"response data is %@",data);
        }
    }];
}

-(UIImage *)addimageWidth:(CGFloat)width withImage:(UIImage *)image
{
    UIImage  *addImage = [UIImage imageNamed:@"寰宇分享.png"];
    CGFloat imgWidth = width;
    CGFloat imgHeight = (addImage.size.height/addImage.size.width + image.size.height/image.size.width) * imgWidth;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(imgWidth, imgHeight), NO, 0.0f);
    
    // Draw image1
    [image drawInRect:CGRectMake(0, 0, imgWidth, image.size.height/image.size.width * imgWidth)];
    
    // Draw image2
    [addImage drawInRect:CGRectMake(0, image.size.height/image.size.width * imgWidth, imgWidth, addImage.size.height/addImage.size.width * imgWidth)];
    
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resultingImage;
}

@end
