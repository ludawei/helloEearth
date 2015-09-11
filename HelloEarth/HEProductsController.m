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

@end

@implementation HEProductsController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.datas = [[CWDataManager sharedInstance] productList];
    
    self.title = @"产品";
    [self.navigationController.navigationBar setBackgroundImage:[Util createImageWithColor:[UIColor blackColor] width:1 height:64] forBarMetrics:UIBarMetricsDefault];
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"返回"] style:UIBarButtonItemStyleDone target:self action:@selector(clickBack)];
    self.navigationItem.leftBarButtonItem = left;
    
    CGFloat margin = 10;
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    //    flowLayout.headerReferenceSize = CGSizeMake(self.width, 150.0f);  //设置head大小
    flowLayout.minimumLineSpacing = margin;
    flowLayout.minimumInteritemSpacing = margin;
    flowLayout.sectionInset = UIEdgeInsetsMake(15, margin, margin, margin);
    flowLayout.itemSize = CGSizeMake((self.view.width-margin*3)/2, (self.view.width-margin*3)/2);
    
    self.collView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
    self.collView.backgroundColor = [UIColor clearColor];
    self.collView.delegate = self;
    self.collView.dataSource = self;
    [self.collView registerClass:[MyCollCell class] forCellWithReuseIdentifier:@"collCell"];
    [self.collView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView"];
    [self.view addSubview:self.collView];
    
    self.collView.backgroundColor = [UIColor colorWithRed:0.188 green:0.212 blue:0.263 alpha:1];
    
    NSString *url = [Util requestEncodeWithString:@"http://scapi.weather.com.cn/weather/getmicapsproductlist?" appId:@"f63d329270a44900" privateKey:@"sanx_data_99"];
    [[PLHttpManager sharedInstance].manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (responseObject) {
            self.datas = (NSArray *)responseObject;
            [self.collView reloadData];
            
            [[CWDataManager sharedInstance] setProductList:(NSArray *)responseObject];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
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
    
    [cell setupData:self.datas[indexPath.row]];
    
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
