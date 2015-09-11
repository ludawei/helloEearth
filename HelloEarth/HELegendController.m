//
//  HELegendController.m
//  HelloEarth
//
//  Created by 卢大维 on 15/9/10.
//  Copyright (c) 2015年 weather. All rights reserved.
//

#import "HELegendController.h"
#import "Masonry.h"
#import "Util.h"
#import "PLHttpManager.h"

@interface HELegendController ()

@property (nonatomic,strong) UIView *contentView;

@end

@implementation HELegendController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"图例";
    [self.navigationController.navigationBar setBackgroundImage:[Util createImageWithColor:[UIColor blackColor] width:1 height:64] forBarMetrics:UIBarMetricsDefault];
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"返回"] style:UIBarButtonItemStyleDone target:self action:@selector(clickBack)];
    self.navigationItem.leftBarButtonItem = left;
    
    self.view.backgroundColor = [UIColor colorWithRed:0.188 green:0.212 blue:0.263 alpha:1];
    
    NSString *url = [Util requestEncodeWithString:@"http://scapi.weather.com.cn/weather/micapslegend?fileMark=kqzl_24&" appId:@"f63d329270a44900" privateKey:@"sanx_data_99"];
    [[PLHttpManager sharedInstance].manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (responseObject) {
            [self initViewsWithData:responseObject];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

-(void)initViewsWithData:(id)data
{
    CGFloat legendHeight = 30.0f;
    NSArray *legends = (NSArray *)data;
    
    self.contentView = [UIView new];
    [self.view addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        UIView *top = (UIView *)self.topLayoutGuide;
        
        make.top.mas_equalTo(top.mas_bottom).offset(20);
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.height.mas_equalTo(legends.count * legendHeight);
    }];
    
    for (NSInteger i=0; i<legends.count; i++) {
        NSArray *colors = [[legends objectAtIndex:i] objectForKey:@"colors"];
        
        UILabel *tempLbl;
        for (NSInteger j=0; j<colors.count; j++) {
            NSDictionary *colorData = [colors objectAtIndex:j];
            UIColor *backColor = [Util colorFromRGBString:[colorData objectForKey:@"color"]];
            UIColor *textColor = [Util colorFromRGBString:[colorData objectForKey:@"color_text"]];
            
            UILabel *lbl = [self createLabelWithBackColor:backColor textColor:textColor text:[colorData objectForKey:@"text"]];
            [self.contentView addSubview:lbl];
            [lbl mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(legendHeight*i);
                if (tempLbl) {
                    make.left.mas_equalTo(tempLbl.mas_right);
                }
                else
                {
                    make.left.mas_equalTo(0);
                }
                make.height.mas_equalTo(legendHeight);
                make.width.mas_equalTo(self.contentView.mas_width).multipliedBy(1.0/colors.count);
            }];
            tempLbl = lbl;
        }
        tempLbl = nil;
    }
}

-(UILabel *)createLabelWithBackColor:(UIColor *)backColor textColor:(UIColor *)textColor text:(NSString *)text
{
    UILabel *lbl = [UILabel new];
    lbl.textAlignment = NSTextAlignmentCenter;
    lbl.text = text;
    lbl.textColor = textColor;
    lbl.backgroundColor = backColor;
    
    return lbl;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)clickBack
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
