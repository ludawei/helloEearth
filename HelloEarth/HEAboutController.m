//
//  HEAboutController.m
//  HelloEarth
//
//  Created by 卢大维 on 15/9/21.
//  Copyright © 2015年 weather. All rights reserved.
//

#import "HEAboutController.h"
#import "DeviceUtil.h"
#import "Util.h"
#import "WebController.h"

@interface HEAboutController ()

@property (nonatomic,weak) IBOutlet UILabel *vesionLabel;

@end

@implementation HEAboutController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"设置";
    UIButton *leftNavButton = [Util leftNavButtonWithSize:CGSizeMake(self.navigationController.navigationBar.height, self.navigationController.navigationBar.height)];
    [leftNavButton addTarget:self action:@selector(clickBack) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftNavButton];
    
    self.vesionLabel.text = [NSString stringWithFormat:@"版本号：V%@", [DeviceUtil getSoftVersion:false]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)clickBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)clickLink:(UIButton *)button
{
    WebController *next = [WebController new];
    next.url = @"http://www.cma.gov.cn/2011xwzx/2011xgzdt/201508/t20150821_291102.html";
    [self.navigationController pushViewController:next animated:YES];
}

-(IBAction)clickCall:(UIButton *)button
{
    NSString *callString = [button titleForState:UIControlStateNormal];
    NSString *UrlStr = [NSString stringWithFormat:@"telprompt://%@", callString];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UrlStr]];
}

@end
