//
//  HEBaseController.m
//  HelloEarth
//
//  Created by 卢大维 on 15/9/23.
//  Copyright © 2015年 weather. All rights reserved.
//

#import "HEBaseController.h"

@interface HEBaseController ()

@end

@implementation HEBaseController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if (!UIDeviceOrientationIsPortrait(orientation)) {
        [UIView setAnimationsEnabled:NO];
        
        // Stackoverflow #26357162 to force orientation
        NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
        [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [UIView setAnimationsEnabled:YES];
}

@end

@implementation HEBaseTableController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if (!UIDeviceOrientationIsPortrait(orientation)) {
        [UIView setAnimationsEnabled:NO];
        
        // Stackoverflow #26357162 to force orientation
        NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
        [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [UIView setAnimationsEnabled:YES];
}

@end
