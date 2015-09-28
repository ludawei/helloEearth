//
//  MyCollCell.m
//  chinaweathernews
//
//  Created by 卢大维 on 14-10-20.
//  Copyright (c) 2014年 weather. All rights reserved.
//

#import "MyCollCell.h"
#import "UIImageView+AFNetworking.h"
#import "Util.h"

@interface MyCollCell ()

@property (nonatomic,strong) UIView *imgBackView;
@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,strong) UILabel *lbl;

@end

@implementation MyCollCell

-(id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        CGFloat lblHeight = self.frame.size.height*0.24;
        
        UIView *imgBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        imgBackView.layer.cornerRadius = 5;
        imgBackView.layer.borderWidth = 2;
        imgBackView.layer.borderColor = [UIColor whiteColor].CGColor;
        imgBackView.clipsToBounds = YES;
        [self.contentView addSubview:imgBackView];
        self.imgBackView = imgBackView;

        self.imageView = [[UIImageView alloc] initWithFrame:self.imgBackView.bounds];
//        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(imgBackView.x+5, imgBackView.y+5, imgBackView.width-10, imgBackView.height-10)];
        self.imageView.clipsToBounds = YES;
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        //        self.imageView.clipsToBounds = YES;
        [self.imgBackView addSubview:self.imageView];
        
        self.lbl = [[UILabel alloc] init];
        self.lbl.font = [Util modifySystemFontWithSize:16];
        self.lbl.frame = CGRectMake(0, self.imgBackView.height-lblHeight, self.imgBackView.width, lblHeight);
        self.lbl.textAlignment = NSTextAlignmentCenter;
        self.lbl.textColor = [UIColor whiteColor];
        self.lbl.backgroundColor = [UIColor colorWithRed:0.188 green:0.212 blue:0.263 alpha:0.9];
        [self.imgBackView addSubview:self.lbl];
        
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

-(void)setupData:(NSDictionary *)data selectFileMark:(NSString *)fileMark
{
#if 1
    NSString *imageUrl = [NSString stringWithFormat:@"http://7xn1l2.com1.z0.glb.clouddn.com/3d_earth_%@.jpg", data[@"fileMark"]];
#else
    NSString *imageUrl = [NSString stringWithFormat:@"http://scapi.weather.com.cn/weather/img/%@", data[@"fileMark"]];
#endif
    [self.imageView setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"test.png"]];
   
    self.lbl.text = data[@"name"];
    
    [self setSelected:[fileMark isEqualToString:data[@"fileMark"]]];
}

-(void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    if (highlighted) {
        self.imgBackView.layer.borderColor = UIColorFromRGB(0x2da7e0).CGColor;
//        self.imgBackView.layer.borderWidth = 2;
        self.lbl.textColor = UIColorFromRGB(0x2da7e0);
    }
    else
    {
        self.imgBackView.layer.borderColor = [UIColor whiteColor].CGColor;
        self.imgBackView.layer.borderWidth = 2;
        self.lbl.textColor = [UIColor whiteColor];
    }
}

-(void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    if (selected) {
        self.imgBackView.layer.borderColor = UIColorFromRGB(0x2da7e0).CGColor;
//        self.imgBackView.layer.borderWidth = 2;
        self.lbl.textColor = UIColorFromRGB(0x2da7e0);
    }
    else
    {
        self.imgBackView.layer.borderColor = [UIColor whiteColor].CGColor;
//        self.imgBackView.layer.borderWidth = 2;
        self.lbl.textColor = [UIColor whiteColor];
    }
}

@end
