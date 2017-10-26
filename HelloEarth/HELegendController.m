//
//  HELegendController.m
//  HelloEarth
//
//  Created by 卢大维 on 15/9/10.
//  Copyright (c) 2015年 weather. All rights reserved.
//

#import "HELegendController.h"
#import <Masonry/Masonry.h>
#import "Util.h"
#import "PLHttpManager.h"
#import "CWDataManager.h"

@interface HELegendController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) UIPageControl *pageControl;

@property (nonatomic,strong) UIView *contentView;
@property (nonatomic,strong) NSMutableArray *contentViews;
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
    
    if ([self.fileMark isEqualToString:FILEMARK_RADAR]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self initViewWithData:nil];
        });
    }
    else
    {
        NSString *newFileMark = [[self.fileMark componentsSeparatedByString:@","] firstObject];
        NSString *url = [Util requestEncodeWithString:[NSString stringWithFormat:@"http://scapi.weather.com.cn/weather/micapslegend?fileMark=%@&", newFileMark] appId:@"f63d329270a44900" privateKey:@"sanx_data_99"];
        [[PLHttpManager sharedInstance] GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            if (responseObject) {
                [self initViewWithData:responseObject];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
    }
}

-(void)initViewWithData:(id)data
{
    CGFloat hMargin=15,vMargin=10;
    
    if (data) {
        
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.scrollView = [UIScrollView new];
        self.scrollView.pagingEnabled = YES;
        self.scrollView.delegate = self;
        [self.view addSubview:self.scrollView];
        [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.view);
        }];
        
        self.pageControl = [UIPageControl new];
        self.pageControl.hidesForSinglePage = YES;
        [self.view addSubview:self.pageControl];
        [self.pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(self.view);
            make.bottom.mas_equalTo(self.view.mas_bottom).offset(-20);
            make.height.mas_equalTo(15);
        }];
        
        self.datas = @[];//[[CWDataManager sharedInstance].indexDict objectForKey:self.fileMark];
        
        UITableView *tempTable;
        
        
        CGFloat legendHeight = 60.0f,titleLblHeight = 30;
        NSArray *legends = (NSArray *)data;
        
        UIView *sv_sub = [UIView new];
        [self.scrollView addSubview:sv_sub];
        [sv_sub mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.left.right.mas_equalTo(self.scrollView);
            make.width.mas_equalTo(self.view.width*legends.count);
            make.height.mas_equalTo(self.view.height-1);
        }];
        
        self.contentViews = [NSMutableArray arrayWithCapacity:legends.count];
        for (NSInteger i=0; i<legends.count; i++) {
            UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(hMargin, vMargin, self.view.width-hMargin*2, legendHeight)];
            
            NSDictionary *legend = [legends objectAtIndex:i];
            NSArray *colors = [legend objectForKey:@"colors"];
            colors = [colors sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
                if ([[obj1 objectForKey:@"order"] integerValue] > [[obj2 objectForKey:@"order"] integerValue]) {
                    return NSOrderedDescending;
                }
                return NSOrderedAscending;
            }];
            
//            BOOL isStripe = [[legend objectForKey:@"is_stripe"] integerValue] == 1;
            
            NSString *title = [[legend objectForKey:@"val"] objectForKey:@"n"];
            UILabel *titleLbl;
            if (![Util isEmpty:title]) {
                titleLbl = [self createLabelWithBackColor:[UIColor clearColor] textColor:[UIColor whiteColor] text:title];
                titleLbl.font = [Util modifySystemFontWithSize:16];
                titleLbl.textAlignment = NSTextAlignmentLeft;
                [contentView addSubview:titleLbl];
                [titleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.left.right.mas_equalTo(0);
                    make.height.mas_equalTo(titleLblHeight);
                }];
            }
            
            NSInteger minFontSize = 16;
            for (NSInteger j=0; j<colors.count; j++) {
                NSDictionary *colorData = [colors objectAtIndex:j];
                NSInteger fontSize = [self binarySearchForFontSizeForText:[colorData objectForKey:@"text"] minFontSize:8 maxFontSize:minFontSize size:CGSizeMake(contentView.width/colors.count-10, legendHeight-titleLblHeight)];
                minFontSize = MIN(minFontSize, fontSize);
            }
            
            UILabel *tempLbl;
            for (NSInteger j=0; j<colors.count; j++) {
                NSDictionary *colorData = [colors objectAtIndex:j];
                UIColor *backColor = [Util colorFromRGBString:[colorData objectForKey:@"color"] alpha:1.0];
                UIColor *textColor = [Util colorFromRGBString:[colorData objectForKey:@"color_text"] alpha:1.0];
                
                UILabel *lbl = [self createLabelWithBackColor:backColor textColor:textColor text:[[[colorData objectForKey:@"text"] componentsSeparatedByString:@"-"] lastObject]];
                lbl.font = [UIFont systemFontOfSize:minFontSize];//[Util modifySystemFontWithSize:16];
                [contentView addSubview:lbl];
                [lbl mas_makeConstraints:^(MASConstraintMaker *make) {
                    if (titleLbl) {
                        make.top.mas_equalTo(titleLbl.mas_bottom);
                    }
                    else
                    {
                        make.top.mas_equalTo((legendHeight-titleLblHeight)/2);
                    }
                    
                    if (tempLbl) {
                        make.left.mas_equalTo(tempLbl.mas_right);
                    }
                    else
                    {
                        make.left.mas_equalTo(0);
                    }
                    make.height.mas_equalTo(legendHeight-titleLblHeight);
                    make.width.mas_equalTo(contentView.mas_width).multipliedBy(1.0/colors.count);
                }];
                
                
//                if (isStripe) {
//                    UIImage *image = [[UIImage imageNamed:@"图例_stripe.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//                    UIImageView *imgView = [UIImageView new];
//                    imgView.clipsToBounds = YES;
//                    imgView.backgroundColor = [UIColor whiteColor];
//                    imgView.image = image;
//                    imgView.tintColor = backColor;
//                    imgView.contentMode = UIViewContentModeScaleAspectFill;
//                    [contentView addSubview:imgView];
//                    [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
//                        make.edges.mas_equalTo(lbl);
//                    }];
//                    
//                    lbl.backgroundColor = [UIColor clearColor];
//                    [contentView sendSubviewToBack:imgView];
//                }
//                else
                {
                    lbl.backgroundColor = backColor;
                }
                
                tempLbl = lbl;
            }
            tempLbl = nil;
            
            UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, legendHeight+vMargin*2)];
            headerView.backgroundColor = [UIColor colorWithRed:0.188 green:0.212 blue:0.263 alpha:1];
            [headerView addSubview:contentView];
            [self.contentViews addObject:headerView];
            
            UITableView *tableView = [UITableView new];
            tableView.delegate = self;
            tableView.dataSource = self;
            tableView.backgroundColor = [UIColor clearColor];
            tableView.estimatedRowHeight = 50;
            tableView.tag = 100+i;
            [sv_sub addSubview:tableView];
            [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.mas_topLayoutGuide);
                make.bottom.mas_equalTo(sv_sub);
                make.width.mas_equalTo(self.view);
                if (tempTable) {
                    make.left.mas_equalTo(tempTable.mas_right);
                }
                else
                {
                    make.left.mas_equalTo(0);
                }
            }];
            tableView.tableFooterView = [UIView new];
            tempTable = tableView;
        }
        
        self.pageControl.numberOfPages = legends.count;
    }
    else
    {
        self.datas = @[];//[[CWDataManager sharedInstance].indexDict objectForKey:self.fileMark];
        
        UIImage *legendImage = [UIImage imageNamed:@"Legend_radar.png"];
        
        UIImageView *contentView = [[UIImageView alloc] initWithFrame:CGRectMake(hMargin, vMargin, self.view.width-hMargin*2, legendImage.size.height*(self.view.width-hMargin*2)/legendImage.size.width)];
        contentView.image = legendImage;
        
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, contentView.height+vMargin*2)];
        headerView.backgroundColor = [UIColor colorWithRed:0.188 green:0.212 blue:0.263 alpha:1];
        [headerView addSubview:contentView];
        self.contentView = headerView;
        
        UITableView *tableView = [UITableView new];
        self.tableView = tableView;
        
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.backgroundColor = [UIColor clearColor];
        tableView.estimatedRowHeight = 50;
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.view);
        }];
        tableView.tableFooterView = [UIView new];
    }
}

-(NSInteger)binarySearchForFontSizeForText:(NSString *)text minFontSize:(NSInteger)minFontSize maxFontSize:(NSInteger)maxFontSize size:(CGSize)size
{
    if (maxFontSize < minFontSize)
        return minFontSize;
    
    NSInteger fontSize = (minFontSize + maxFontSize) / 2;
    UIFont *font = [UIFont systemFontOfSize:fontSize];
    
    CGSize constraintSize = CGSizeMake(size.width, MAXFLOAT);
    CGRect rect = [text boundingRectWithSize:constraintSize
                                           options:NSStringDrawingUsesLineFragmentOrigin
                                        attributes:@{NSFontAttributeName : font}
                                           context:nil];
    CGSize labelSize = rect.size;
    
    if (labelSize.height >= size.height + 10 && labelSize.width >= size.width + 10 && labelSize.height <= size.height && labelSize.height <= size.width)
        return fontSize;
    else if (labelSize.height > size.height || labelSize.width > size.width)
        return [self binarySearchForFontSizeForText:text minFontSize:minFontSize maxFontSize:fontSize-1 size:size];
    else
        return [self binarySearchForFontSizeForText:text minFontSize:fontSize+1 maxFontSize:maxFontSize size:size];
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
    if (tableView == self.tableView) {
        return self.datas.count;
    }
    
    NSArray *data = [self.datas objectAtIndex:tableView.tag - 100];
    return data.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        return self.contentView.height;
    }
    UIView *view = [self.contentViews objectAtIndex:tableView.tag-100];
    return [view height];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (self.tableView == tableView) {
        return self.contentView;
    }
    return [self.contentViews objectAtIndex:tableView.tag-100];
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
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
    
    NSArray *data;
    if (tableView == self.tableView) {
        data = [self.datas objectAtIndex:indexPath.item];
    }
    else
    {
        NSArray *datas = [self.datas objectAtIndex:tableView.tag - 100];
        data = [datas objectAtIndex:indexPath.item];
    }
    if (data.count == 1)
    {
        cell.textLabel.text = [NSString stringWithFormat:@"%@", [data firstObject]];
    }
    else
    {
        if (data.count == 3)
        {
            cell.textLabel.text = [NSString stringWithFormat:@"%@   %@", [data firstObject], [data objectAtIndex:1]];
        }
        else if (data.count == 2)
        {
            cell.textLabel.text = [NSString stringWithFormat:@"%@", [data firstObject]];
        }
        
        
        cell.detailTextLabel.text = [data lastObject];
    }
    
    return cell;
}

-(void)clickBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.scrollView == scrollView) {
        NSInteger page = ceil(scrollView.contentOffset.x/scrollView.width);
        self.pageControl.currentPage = page;
    }
}
@end
