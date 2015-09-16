//
//  MyCollCell.m
//  chinaweathernews
//
//  Created by 卢大维 on 14-10-20.
//  Copyright (c) 2014年 weather. All rights reserved.
//

#import "MyCollCell.h"
#import "UIImageView+AFNetworking.h"

@interface MyCollCell ()

@property (nonatomic,strong) UIView *imgBackView;
@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,strong) UILabel *lbl;

@end

@implementation MyCollCell

-(id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        CGFloat lblHeight = 30;
        
        self.lbl = [[UILabel alloc] init];
        self.lbl.font = [UIFont systemFontOfSize:16];
        self.lbl.frame = CGRectMake(0, self.height-lblHeight, self.width, lblHeight);
        self.lbl.textAlignment = NSTextAlignmentCenter;
        self.lbl.textColor = [UIColor whiteColor];
        [self.contentView addSubview:self.lbl];
        
        UIView *imgBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, CGRectGetMinY(self.lbl.frame))];
        imgBackView.layer.cornerRadius = 5;
        imgBackView.layer.borderWidth = 1;
        imgBackView.layer.borderColor = [UIColor whiteColor].CGColor;
        [self.contentView addSubview:imgBackView];
        self.imgBackView = imgBackView;
        
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(imgBackView.x+5, imgBackView.y+5, imgBackView.width-10, imgBackView.height-10)];
        //        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        //        self.imageView.clipsToBounds = YES;
        [self.contentView addSubview:self.imageView];
        
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

-(void)setupData:(NSDictionary *)data
{
    [self.imageView setImageWithURL:[NSURL URLWithString:data[@"l4"]] placeholderImage:[UIImage imageNamed:@"qrcode_for_gh_9eb43db17ffb_430.jpg"]];
   
    self.lbl.text = data[@"name"];
}

-(void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    if (highlighted) {
        self.imgBackView.layer.borderColor = UIColorFromRGB(0x2da7e0).CGColor;
        self.imgBackView.layer.borderWidth = 3;
    }
    else
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.imgBackView.layer.borderColor = [UIColor whiteColor].CGColor;
            self.imgBackView.layer.borderWidth = 1;
        });
    }
}

//-(void)setSelected:(BOOL)selected
//{
//    [super setSelected:selected];
//    
//    if (selected) {
//        self.imgBackView.layer.borderColor = UIColorFromRGB(0x2da7e0).CGColor;
//        self.imgBackView.layer.borderWidth = 3;
//    }
//    else
//    {
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            self.imgBackView.layer.borderColor = [UIColor whiteColor].CGColor;
//            self.imgBackView.layer.borderWidth = 1;
//        });
//    }
//}

@end
