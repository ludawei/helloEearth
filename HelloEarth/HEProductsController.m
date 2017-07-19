//
//  HEProductsController.m
//  HelloEarth
//
//  Created by 卢大维 on 15/9/10.
//  Copyright (c) 2015年 weather. All rights reserved.
//

#import "HEProductsController.h"
#import "MyCollCell.h"
#import "PLHttpManager.h"
#import "Util.h"
#import "CWDataManager.h"

@interface HEProductsController ()<UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic,strong) UICollectionView *collView;
@property (nonatomic,copy) NSArray *datas;
@property (nonatomic,copy) NSString *imageVersion;

@end

@implementation HEProductsController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.datas = [[CWDataManager sharedInstance] productList];
    self.imageVersion = [CWDataManager sharedInstance].imageVersion;
    
    self.title = @"产品";
    UIButton *leftNavButton = [Util leftNavButtonWithSize:CGSizeMake(self.navigationController.navigationBar.height, self.navigationController.navigationBar.height)];
    [leftNavButton addTarget:self action:@selector(clickBack) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftNavButton];
    
    CGFloat margin = 15;
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    //    flowLayout.headerReferenceSize = CGSizeMake(self.width, 150.0f);  //设置head大小
    flowLayout.minimumLineSpacing = margin;
    flowLayout.minimumInteritemSpacing = margin;
    flowLayout.sectionInset = UIEdgeInsetsMake(15, margin, margin, margin);
    
    CGFloat itemWidth = (MIN(self.view.width, self.view.height)-margin*3)/2;
    flowLayout.itemSize = CGSizeMake(itemWidth, itemWidth*3/4);
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    CGFloat topHeight = STATUS_HEIGHT+SELF_NAV_HEIGHT;
    self.collView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, topHeight, self.view.width, self.view.height-topHeight) collectionViewLayout:flowLayout];
    self.collView.backgroundColor = [UIColor colorWithRed:0.188 green:0.212 blue:0.263 alpha:1];
    self.collView.delegate = self;
    self.collView.dataSource = self;
    [self.collView registerClass:[MyCollCell class] forCellWithReuseIdentifier:@"collCell"];
    [self.collView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView"];
    [self.view addSubview:self.collView];
    
//    NSString *url = [Util requestEncodeWithString:@"http://scapi.weather.com.cn/weather/getmicapsproductlist?" appId:@"f63d329270a44900" privateKey:@"sanx_data_99"];
    NSString *url = @"http://decision-admin.tianqi.cn/Home/extra/getHuanyuProducts";
    [[PLHttpManager sharedInstance] GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
            self.datas = [responseObject objectForKey:@"array"];
            self.imageVersion = [responseObject objectForKey:@"version"];
            [self.collView reloadData];
            
            [[CWDataManager sharedInstance] setProductList:(NSArray *)self.datas];
            [[CWDataManager sharedInstance] setImageVersion:self.imageVersion];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGFloat topHeight = STATUS_HEIGHT+SELF_NAV_HEIGHT;
    self.collView.frame = CGRectMake(0, topHeight, self.view.width, self.view.height-topHeight);
}

-(void)scrollToLocation
{
    if (self.fileMark) {
        NSInteger index = 0;
        for (NSInteger i=0; i<self.datas.count; i++) {
            NSDictionary *data = [self.datas objectAtIndex:i];
            if ([[data objectForKey:@"fileMark"] isEqualToString:self.fileMark]) {
                index = i;
                break;
            }
        }
        [self.collView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setBackgroundImage:[Util createImageWithColor:[UIColor blackColor] width:1 height:(STATUS_HEIGHT+SELF_NAV_HEIGHT)] forBarMetrics:UIBarMetricsDefault];
    
    [self.collView setContentOffset:[CWDataManager sharedInstance].productOffset animated:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [CWDataManager sharedInstance].productOffset = self.collView.contentOffset;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.datas count];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    MyCollCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"collCell" forIndexPath:indexPath];
    
    NSDictionary *data = [self.datas objectAtIndex:indexPath.item];
    [cell setupData:data selectFileMark:self.fileMark imageVersion:self.imageVersion];
    
    return cell;
}

#pragma mark --UICollectionViewDelegateFlowLayout

//定义每个UICollectionView 的大小
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ([self.type isEqualToString:@"product"]) {
//        return CGSizeMake(self.width/2, self.width/2);
//    }
//    
//    return CGSizeMake(self.width, 75);
//}
//
////定义每个UICollectionView 的 margin
//-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
//{
//    return UIEdgeInsetsMake(0, 0, 0, 0);
//}

#pragma mark --UICollectionViewDelegate

//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *data = [self.datas objectAtIndex:indexPath.row];
    [self.delegate setData:data];
    [self.navigationController popViewControllerAnimated:YES];
}

//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

#pragma mark - actions
-(void)clickBack
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
