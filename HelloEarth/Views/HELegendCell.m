//
//  HELegendCell.m
//  HelloEarth
//
//  Created by 卢大维 on 15/11/12.
//  Copyright © 2015年 weather. All rights reserved.
//

#import "HELegendCell.h"
#import "Masonry.h"

@implementation HELegendCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initViews];
    }
    
    return self;
}

-(void)initViews
{
    [self.contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(0);
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
    }];
    
    self.textLabel.numberOfLines = 0;
    [self.textLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(0);
        make.left.mas_equalTo(20);
    }];
    
    [self.detailTextLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(0);
        make.right.mas_equalTo(-20);
    }];
    
    UILabel *line = [UILabel new];
    line.backgroundColor = [UIColor colorWithWhite:1 alpha:0.7];
    [self.contentView addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.height.mas_equalTo(0.8);
        make.bottom.mas_equalTo(0);
    }];
}

@end
