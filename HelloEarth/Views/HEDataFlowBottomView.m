//
//  HEDataFlowBottomView.m
//  HelloEarth
//
//  Created by 卢大维 on 16/3/4.
//  Copyright © 2016年 weather. All rights reserved.
//

#import "HEDataFlowBottomView.h"
#import "Util.h"

@interface HEDataFlowBottomView ()

@property (nonatomic,strong) UIImageView *backView;
@property (nonatomic,strong) UILabel *addrLabel;
@property (nonatomic,strong) UIButton *timeButton;
@property (nonatomic,strong) NSMutableArray *buttons;
@property (nonatomic,assign) CGRect initFrame;

@property (nonatomic,assign) CGFloat leftMargin;

@end

@implementation HEDataFlowBottomView

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.initFrame = frame;
        
        self.leftMargin = 8.0f;
        
        self.backView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.backView.image = [[UIImage imageNamed:@"kuangzi"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10) resizingMode:UIImageResizingModeStretch];
        [self addSubview:self.backView];
        
        UIFont *tempFont = [Util modifyBoldSystemFontWithSize:18];
        CGFloat lblHeight = 40.0 * SCREEN_SIZE.width/414.0;
        
        UIColor *color = UIColorFromRGB(0x02bcff);
        
        UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(self.leftMargin, 3 + (lblHeight-tempFont.lineHeight)/2, 4, tempFont.lineHeight)];
        line.backgroundColor = color;
        [self.backView addSubview:line];
        
        UILabel *tipLabel = [self createLabelWithFrame:CGRectMake(CGRectGetMaxX(line.frame) + 5, 3 + 2, 80, lblHeight - 4) color:color font:tempFont];
        tipLabel.text = @"气象观测";
        tipLabel.width = [tipLabel.text sizeWithAttributes:@{NSFontAttributeName:tempFont}].width;
        [self.backView addSubview:tipLabel];
        
        self.addrLabel = [self createLabelWithFrame:CGRectMake(CGRectGetMaxX(tipLabel.frame) + 10, 3, 200, lblHeight) color:color font:[Util modifyBoldSystemFontWithSize:15]];
//        self.addrLabel.text = @"-";
        [self.backView addSubview:self.addrLabel];
        
        self.timeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 5, 0, 0)];
        self.timeButton.userInteractionEnabled = NO;
        [self.timeButton setImage:[UIImage imageNamed:@"clock"] forState:UIControlStateNormal];
        [self.timeButton setTitleColor:UIColorFromRGB(0x667989) forState:UIControlStateNormal];
        self.timeButton.titleLabel.font = [Util modifySystemFontWithSize:13];
        [self.backView addSubview:self.timeButton];
        
        CGSize btnSize = CGSizeMake((self.width - self.leftMargin * 2)/3.0, 40.0 * SCREEN_SIZE.width/414.0);
        
        NSArray *imageNames = @[@"wendu", @"qiya", @"jiangshuiliang", @"xiangduishidu", @"fengsu", @"nengjiandu"];
        self.buttons = [NSMutableArray array];
        
        for (NSInteger i=0; i<6; i++) {
            NSInteger row = i / 3;
            NSInteger col = i % 3;
            
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(8 + btnSize.width * col, CGRectGetMaxY(tipLabel.frame) + btnSize.height * row , btnSize.width, btnSize.height)];
            view.layer.borderColor = [color colorWithAlphaComponent:0.2].CGColor;
            view.layer.borderWidth = 0.5;
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, view.width/2, view.height)];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            imageView.image = [UIImage imageNamed:[imageNames objectAtIndex:i]];
            [view addSubview:imageView];
            
            UILabel *lbl = [self createLabelWithFrame:CGRectMake(view.width/2 - view.width * 0.05, 0, view.width/2, view.height) color:[UIColor colorWithWhite:1 alpha:0.6] font:[Util modifySystemFontWithSize:15]];
//            lbl.text = @"-";
            lbl.tag = 100 + i;
            [view addSubview:lbl];
            
            [self.buttons addObject:view];
            
            [self.backView addSubview:view];
        }
    }
    
    return self;
}

-(UILabel *)createLabelWithFrame:(CGRect)frame color:(UIColor *)color font:(UIFont *)font
{
    UILabel *lbl = [[UILabel alloc] initWithFrame:frame];
    lbl.textColor = color;
    lbl.font = font;
    
    return lbl;
}

-(void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
}

-(void)setupWithData:(NSDictionary *)dict
{
    NSDictionary *data = [[dict objectForKey:@"observe"] objectForKey:@"l"];
    NSArray *temp = @[@[@"l1", @"°C"],
                      @[@"l10", @"hPa"],
                      @[@"l6", @"mm"],
                      @[@"l2", @"%"],
                      @[@"l11", @"m/s"],
                      @[@"l9", @"m"],
                      ];
    NSString *time = [[data objectForKey:@"l13"] substringToIndex:16];
    
    self.addrLabel.text = [[dict objectForKey:@"from"] objectForKey:@"name"];
    
    [self.timeButton setTitle:[@" " stringByAppendingString:time] forState:UIControlStateNormal];
    [self.timeButton sizeToFit];
    self.timeButton.x = self.width - self.timeButton.width - 5;
    
    for (NSInteger i=0; i<self.buttons.count; i++) {
        
        UIView *view = [self.buttons objectAtIndex:i];
        UILabel *lbl = [view viewWithTag:100+i];
        
        NSArray *tempArr = [temp objectAtIndex:i];
        NSString *text = [[[data objectForKey:tempArr.firstObject] componentsSeparatedByString:@"|"] lastObject];
        if ([tempArr.firstObject isEqualToString:@"l9"]) {
            NSInteger tempPa = [text integerValue];
            
            if (tempPa > 1000) {
                NSNumberFormatter *nFormat = [[NSNumberFormatter alloc] init];
                [nFormat setNumberStyle:NSNumberFormatterDecimalStyle];
                [nFormat setMaximumFractionDigits:3];
                
                lbl.text = [NSString stringWithFormat:@"%@km", [nFormat stringFromNumber:@(tempPa/1000.0)]];
            }
            else
            {
                lbl.text = [text stringByAppendingString:tempArr.lastObject];
            }
        }
        else
        {
            lbl.text = [text stringByAppendingString:tempArr.lastObject];
        }
    }
}

-(void)changeRotationToSize:(CGSize)toSize
{
    if (toSize.height > toSize.width) {
        self.frame = self.initFrame;
        self.backView.frame = self.bounds;
        self.timeButton.x = self.width - self.timeButton.width - 5;
        
        CGSize btnSize = CGSizeMake((self.width - self.leftMargin * 2)/3.0, 40.0 * toSize.width/414.0);
        
        for (NSInteger i=0; i<self.buttons.count; i++) {
            NSInteger row = i / 3;
            NSInteger col = i % 3;
            
            UIView *view = [self.buttons objectAtIndex:i];
            view.frame = CGRectMake(8 + btnSize.width * col, CGRectGetMaxY(self.addrLabel.frame) + btnSize.height * row , btnSize.width, btnSize.height);
        }
    }
    else
    {
        CGFloat ht = 80 * SCREEN_SIZE.width/414.0 + 13.0;
        self.frame = CGRectMake(5, toSize.height - ht, toSize.width - 10, ht);
        
        self.backView.frame = self.bounds;
        self.timeButton.x = self.width - self.timeButton.width - 5;
        
        CGSize btnSize = CGSizeMake((self.width - self.leftMargin * 2)/6.0, 40.0 * SCREEN_SIZE.width/414.0);
        
        for (NSInteger i=0; i<self.buttons.count; i++) {
            
            UIView *view = [self.buttons objectAtIndex:i];
            view.frame = CGRectMake(8 + btnSize.width * i, CGRectGetMaxY(self.addrLabel.frame) , btnSize.width, btnSize.height);
        }
    }
}
@end
