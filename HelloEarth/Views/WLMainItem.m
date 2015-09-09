//
//  WLMainItem.m
//  weatherLive
//
//  Created by 卢大维 on 15/4/23.
//  Copyright (c) 2015年 weather. All rights reserved.
//

#import "WLMainItem.h"
#import "Masonry.h"

@interface WLMainItem ()

@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,strong) UILabel *titleLabel;

@end

@implementation WLMainItem

-(instancetype)init
{
    if (self = [super init]) {
        
        self.layer.cornerRadius = 40;
        
        self.imageView = [UIImageView new];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.imageView];
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
//            UIEdgeInsets padding = UIEdgeInsetsMake(10, 10, 30, 10);
            make.edges.mas_equalTo(self);
        }];
        
        self.titleLabel = [UILabel new];
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = [UIFont systemFontOfSize:16];
        [self addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.mas_equalTo(10);
            make.right.mas_equalTo(-10);
            make.top.mas_equalTo(self.mas_bottom).offset(5);
        }];
    }
    
    return self;
}

-(NSString *)title
{
    return self.titleLabel.text;
}

-(void)setTitle:(NSString *)title
{
    self.titleLabel.text = title;
    [self.titleLabel sizeToFit];
}

-(void)setTitleFont:(CGFloat)fontSize
{
    self.titleLabel.font = [UIFont systemFontOfSize:fontSize];
}

-(void)setTitleColor:(UIColor *)color
{
    self.titleLabel.textColor = color;
}

-(void)setImage:(UIImage *)image
{
    self.imageView.image = image;
}
@end
