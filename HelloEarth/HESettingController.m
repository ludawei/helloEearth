//
//  HESettingController.m
//  HelloEarth
//
//  Created by 卢大维 on 15/9/9.
//  Copyright (c) 2015年 weather. All rights reserved.
//

#import "HESettingController.h"
#import "Util.h"
#import "CWLocationManager.h"
#import "HEFeedbackController.h"

@interface HESettingController ()
{
    BOOL disableChangeMapLayer;
}

@property (nonatomic,weak) IBOutlet UISwitch *switch3D,*switchLight,*switchLocate;
@property (nonatomic,weak) IBOutlet UILabel *lbl1,*lbl2,*lbl3,*lbl4,*lbl5,*lbl6;
@property (nonatomic,weak) IBOutlet UILabel *locationLabel;
@property (nonatomic,weak) IBOutlet UIImageView *layerImageView;

@property (nonatomic,weak) IBOutlet UIView *loadingView;

@end

@implementation HESettingController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"设置";
    
    UIView *backView = [[UIView alloc] initWithFrame:self.tableView.bounds];
    backView.backgroundColor = [UIColor colorWithRed:0.188 green:0.212 blue:0.263 alpha:1];
    UIView *leftBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, MAX(self.tableView.height, self.tableView.width))];
    leftBackView.backgroundColor = [UIColor colorWithRed:0.153 green:0.184 blue:0.235 alpha:1];
    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(79, 0, 1, MAX(leftBackView.height, leftBackView.width))];
    line.backgroundColor = [UIColor darkGrayColor];
    [leftBackView addSubview:line];
    
    [backView addSubview:leftBackView];
    self.tableView.backgroundView = backView;
    self.tableView.backgroundView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundColor = [UIColor colorWithRed:0.188 green:0.212 blue:0.263 alpha:1];
    
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationed:) name:noti_update_location object:nil];
    
    self.switch3D.on = self.set3D;
    self.switchLight.on = self.setLight && self.set3D;
    self.switchLocate.on = self.setLocation;
    if (self.setLocation) {
        self.locationLabel.text = [CWLocationManager sharedInstance].plackMark.name;
    }
    
    self.lbl1.font = [Util modifyBoldSystemFontWithSize:20];
    self.lbl2.font = [Util modifyBoldSystemFontWithSize:20];
    self.lbl3.font = [Util modifyBoldSystemFontWithSize:20];
    self.lbl4.font = [Util modifyBoldSystemFontWithSize:20];
    self.lbl5.font = [Util modifyBoldSystemFontWithSize:20];
    self.lbl6.font = [Util modifyBoldSystemFontWithSize:20];
    self.locationLabel.font = [Util modifySystemFontWithSize:16];
    
    if ([self.mapDataType isEqualToString:@"卫星地图"]) {
        self.layerImageView.image = [UIImage imageNamed:@"default_layer"];
    }
    else
    {
        self.layerImageView.image = [UIImage imageNamed:@"satellite_layer"];
    }
    self.layerImageView.layer.cornerRadius = self.layerImageView.width/2;
    self.layerImageView.clipsToBounds = YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setBackgroundImage:[Util createImageWithColor:[UIColor blackColor] width:1 height:(STATUS_HEIGHT+SELF_NAV_HEIGHT)] forBarMetrics:UIBarMetricsDefault];
    UIButton *leftNavButton = [Util leftNavButtonWithSize:CGSizeMake(self.navigationController.navigationBar.height, self.navigationController.navigationBar.height)];
    [leftNavButton addTarget:self action:@selector(clickBack) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftNavButton];
    
    for (NSInteger i=0; i<[self.tableView numberOfRowsInSection:0]; i++) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        cell.backgroundColor = [UIColor clearColor];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)switchChanged:(UISwitch *)sender
{
    if (sender == self.switch3D) {
        [self.delegate show3DMap:sender.on];
        self.switchLight.on = self.setLight && sender.on;
        self.switchLight.enabled = sender.on;
        
        disableChangeMapLayer = YES;
        sender.enabled = NO;
        self.loadingView.hidden = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            sender.enabled = YES;
            disableChangeMapLayer = NO;
            self.loadingView.hidden = YES;
        });
    }
    else if (sender == self.switchLight)
    {
        [self.delegate showMapLight:sender.on];
    }
    else if (sender == self.switchLocate)
    {
        [self.delegate showLocation:sender.on];
        
        if (sender.on) {
            [[CWLocationManager sharedInstance] updateLocation];
        }
        else
        {
            [[CWLocationManager sharedInstance] stopLocation];
            self.locationLabel.text = @"";
        }
    }
}

#pragma mark - actions
-(void)clickBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)ChangeMapLayer
{
    if ([self.mapDataType isEqualToString:@"卫星地图"]) {
        [self.delegate changeMapType:@"默认地图"];
    }
    else
    {
        [self.delegate changeMapType:@"卫星地图"];
    }
    
    [self clickBack];
}

-(void)locationed:(NSNotification *)noti
{
    NSError *error = [noti.userInfo objectForKey:@"error"];
    if (error) {
        if (error.code == 1) {
            // 用户关闭定位
            [[CWLocationManager sharedInstance] stopLocation];
            return;
        }
    }
    else
    {
        self.locationLabel.text = [CWLocationManager sharedInstance].plackMark.name;
    }
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item < 3) {
        return NO;
    }
    
    if (disableChangeMapLayer && indexPath.item == 3) {
        return NO;
    }
    
    
    return YES;
}

//- (nullable NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (indexPath.item == 3) {
//        if (disableChangeMapLayer) {
//            return nil;
//        }
//        else
//        {
//            return indexPath;
//        }
//    }
//    
//    return indexPath;
//}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.item == 3) {
        [self ChangeMapLayer];
    }
    else if (indexPath.item == 4)
    {
        UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        HESettingController *next = (HESettingController *)[board instantiateViewControllerWithIdentifier:@"aboutUs"];
        [self.navigationController pushViewController:next animated:YES];
    }
    else if (indexPath.item == 5)
    {
        HEFeedbackController *next = [HEFeedbackController new];
        [self.navigationController pushViewController:next animated:YES];
    }
}
@end
