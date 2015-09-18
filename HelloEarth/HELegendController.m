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

@interface HELegendController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic,strong) UIView *contentView;
@property (nonatomic,copy) NSArray *datas;

@property (nonatomic,strong) UITableView *tableView;

@end

@implementation HELegendController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"图例";
    UIButton *leftNavButton = [Util leftNavButtonWithSize:CGSizeMake(self.navigationController.navigationBar.height, self.navigationController.navigationBar.height)];
    [leftNavButton addTarget:self action:@selector(clickBack) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftNavButton];
    
    self.view.backgroundColor = [UIColor colorWithRed:0.188 green:0.212 blue:0.263 alpha:1];
    
    NSString *url = [Util requestEncodeWithString:@"http://scapi.weather.com.cn/weather/micapslegend?fileMark=kqzl_24&" appId:@"f63d329270a44900" privateKey:@"sanx_data_99"];
    [[PLHttpManager sharedInstance].manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (responseObject) {
            [self initViewsWithData:responseObject];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
    
    self.tableView = [UITableView new];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.rowHeight = 50;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    self.tableView.tableFooterView = [UIView new];
}

-(void)initViewsWithData:(id)data
{
    CGFloat legendHeight = 30.0f;
    NSArray *legends = (NSArray *)data;
    
    CGFloat hMargin=15,vMargin=20;
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(hMargin, vMargin, self.view.width-hMargin*2, legendHeight*legends.count)];
    for (NSInteger i=0; i<legends.count; i++) {
        NSArray *colors = [[legends objectAtIndex:i] objectForKey:@"colors"];
        
        UILabel *tempLbl;
        for (NSInteger j=0; j<colors.count; j++) {
            NSDictionary *colorData = [colors objectAtIndex:j];
            UIColor *backColor = [Util colorFromRGBString:[colorData objectForKey:@"color"]];
            UIColor *textColor = [Util colorFromRGBString:[colorData objectForKey:@"color_text"]];
            
            UILabel *lbl = [self createLabelWithBackColor:backColor textColor:textColor text:[colorData objectForKey:@"text"]];
            lbl.font = [Util modifySystemFontWithSize:16];
            [contentView addSubview:lbl];
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
                make.width.mas_equalTo(contentView.mas_width).multipliedBy(1.0/colors.count);
            }];
            tempLbl = lbl;
        }
        tempLbl = nil;
    }
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, legendHeight*legends.count+vMargin*2)];
    headerView.backgroundColor = [UIColor colorWithRed:0.188 green:0.212 blue:0.263 alpha:1];
    [headerView addSubview:contentView];
    self.contentView = headerView;
    
    self.datas = @[@{@"level":@"一级", @"comment":@"好", @"text":@"非常有利于空气污染物稀释、扩散和清除"},
                   @{@"level":@"二级", @"comment":@"较好", @"text":@"较有利于空气污染物稀释、扩散和清除"},
                   @{@"level":@"三级", @"comment":@"一般", @"text":@"对空气污染物稀释、扩散和清除无明显影响"},
                   @{@"level":@"四级", @"comment":@"较差", @"text":@"不利于空气污染物稀释、扩散和清除"},
                   @{@"level":@"五级", @"comment":@"差", @"text":@"很不利于空气污染物稀释、扩散和清除"},
                   @{@"level":@"六级", @"comment":@"极差", @"text":@"极不利于空气污染物稀释、扩散和清除"},
                   ];
    [self.tableView reloadData];
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

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setBackgroundImage:[Util createImageWithColor:[UIColor blackColor] width:1 height:(STATUS_HEIGHT+SELF_NAV_HEIGHT)] forBarMetrics:UIBarMetricsDefault];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datas.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return self.contentView.height;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return self.contentView;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"legentCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identify];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.textColor = [UIColor whiteColor];
//        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.detailTextLabel.numberOfLines = 0;
        
        cell.textLabel.font = [Util modifySystemFontWithSize:16];
        cell.detailTextLabel.font = [Util modifySystemFontWithSize:14];
    }
    
    NSDictionary *data = [self.datas objectAtIndex:indexPath.item];
    cell.textLabel.text = [NSString stringWithFormat:@"%@   %@", [data objectForKey:@"level"], [data objectForKey:@"comment"]];
    cell.detailTextLabel.text = [data objectForKey:@"text"];
    
    return cell;
}

-(void)clickBack
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
