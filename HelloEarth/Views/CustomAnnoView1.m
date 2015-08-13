//
//  CustomAnnoView1.m
//  TestMapCover-Pad
//
//  Created by 卢大维 on 15/6/15.
//  Copyright (c) 2015年 weather. All rights reserved.
//

#import "CustomAnnoView1.h"

@interface CustomAnnoView1 ()

@property (nonatomic) UILabel *countLabel;

@end

@implementation CustomAnnoView1

- (instancetype)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self setUpLabel];
    }
    return self;
}

- (void)setUpLabel
{
    _countLabel = [[UILabel alloc] initWithFrame:self.bounds];
//    _countLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _countLabel.textAlignment = NSTextAlignmentCenter;
    _countLabel.backgroundColor = [UIColor clearColor];
    _countLabel.textColor = [UIColor grayColor];
//    _countLabel.adjustsFontSizeToFitWidth = YES;
//    _countLabel.minimumScaleFactor = 2;
//    _countLabel.numberOfLines = 0;
//    _countLabel.font = [UIFont boldSystemFontOfSize:10];
//    _countLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    
    [self addSubview:_countLabel];
}

-(void)setLabelText:(NSString *)text withTextSize:(CGFloat)size
{
    self.countLabel.font = [UIFont boldSystemFontOfSize:size];
    self.countLabel.text = text;
    [self.countLabel sizeToFit];
    
    self.frame = self.countLabel.frame;
}

@end
