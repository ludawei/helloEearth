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
    
}

@property (nonatomic,strong) CLGeocoder *geocoder;
@property (nonatomic,weak) IBOutlet UISwitch *switch3D,*switchLight,*switchLocate;
@property (nonatomic,weak) IBOutlet UILabel *locationLabel;

@end

@implementation HESettingController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"设置";
    [self.navigationController.navigationBar setBackgroundImage:[Util createImageWithColor:[UIColor blackColor] width:1 height:64] forBarMetrics:UIBarMetricsDefault];
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"返回"] style:UIBarButtonItemStyleDone target:self action:@selector(clickBack)];
    self.navigationItem.leftBarButtonItem = left;
    
    
    UIView *backView = [[UIView alloc] initWithFrame:self.tableView.bounds];
    backView.backgroundColor = [UIColor colorWithRed:0.188 green:0.212 blue:0.263 alpha:1];
    UIView *leftBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, self.tableView.height)];
    leftBackView.backgroundColor = [UIColor colorWithRed:0.153 green:0.184 blue:0.235 alpha:1];
    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(79, 0, 1, leftBackView.height)];
    line.backgroundColor = [UIColor darkGrayColor];
    [leftBackView addSubview:line];
    
    [backView addSubview:leftBackView];
    self.tableView.backgroundView = backView;
    
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationed:) name:noti_update_location object:nil];
    
    self.geocoder = [[CLGeocoder alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)switchChanged:(id)sender
{
    if (sender == self.switch3D) {
        
    }
    else if (sender == self.switchLight)
    {
        
    }
    else if (sender == self.switchLocate)
    {
        
    }
}

#pragma mark - actions
-(void)clickBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)locationed:(NSNotification *)noti
{
//    NSDictionary *
    NSError *error = [noti.userInfo objectForKey:@"error"];
    if (error) {
        if (error.code == 1) {
            // 用户关闭定位
            return;
        }
    }
    else
    {
        if (self.geocoder.isGeocoding) {
            [self.geocoder cancelGeocode];
        }
        
        [self.geocoder reverseGeocodeLocation:[[CLLocation alloc] initWithLatitude:[[noti.userInfo objectForKey:LATITUDE_KEY] floatValue] longitude:[[noti.userInfo objectForKey:LONGITUDE_KEY] floatValue]] completionHandler:^(NSArray* placemarks,NSError *error)
         {
             NSString *mapName;
             if (placemarks.count > 0   )
             {
                 CLPlacemark * plmark = [placemarks objectAtIndex:0];
                 
                 mapName = plmark.name;
                 
                 LOG(@"1:%@2:%@3:%@4:%@",  plmark.locality, plmark.subLocality,plmark.thoroughfare,plmark.subThoroughfare);
             }
             
             self.locationLabel.text = mapName;
         }];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.item == 3) {
        NSString *UrlStr = [NSString stringWithFormat:@"telprompt://%@", @"010-68408068"];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UrlStr]];
    }
    else if (indexPath.item == 4)
    {
        HEFeedbackController *next = [HEFeedbackController new];
        [self.navigationController pushViewController:next animated:YES];
    }
}
@end
