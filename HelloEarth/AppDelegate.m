//
//  AppDelegate.m
//  HelloEarth
//
//  Created by 卢大维 on 15/7/28.
//  Copyright (c) 2015年 weather. All rights reserved.
//

#import "AppDelegate.h"
#import "MapImagesManager.h"
#import <UMSocialCore/UMSocialCore.h>
#import <Bugly/Bugly.h>
#import "Contants.h"
#import "CWDataManager.h"
#import "UIAlertController+Blocks.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url];
    if (!result) {
        // 其他如支付等SDK的回调
    }
    return result;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [Bugly startWithAppId:@"900010224"];
    [[UMSocialManager defaultManager] setUmSocialAppkey:UM_APP_KEY];

    // 使用日期20161230
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([[NSDate date] timeIntervalSince1970] >= 1483027200) {
            [UIAlertController showAlertInViewController:self.window.rootViewController withTitle:@"提示" message:@"试用期已过，请安装正式版本！" cancelButtonTitle:@"确定" destructiveButtonTitle:nil otherButtonTitles:nil tapBlock:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
                exit(0);
            }];
        }
    });
    
//    NSString *dictPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    NSArray *files = [fileManager subpathsAtPath:dictPath];
//    NSString *filesSizeStr = [NSString stringWithFormat:@"%.1fM", [self fileSizeAtDirectory:dictPath]/(1024.0*1024.0)];
    
    return YES;
}

//-(long long)fileSizeAtDirectory:(NSString *)directoryPath
//{
//    //    NSString *filePath = [[WLDataManager sharedInstance] localFilesPath];
//    long long directorySize = 0.0f;
//    
//    NSFileManager* manager = [NSFileManager defaultManager];
//    NSArray *files = [manager subpathsAtPath:directoryPath];
//    for (NSString *fileName in files) {
//        NSString *filePath = [directoryPath stringByAppendingPathComponent:fileName];
//        if ([manager fileExistsAtPath:filePath]){
//            
//            directorySize += [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
//        }
//    }
//    
//    return directorySize;
//    
//}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [MapImagesManager clearAllImagesFromDiskWithTime:YES];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [MapImagesManager clearAllImagesFromDiskWithTime:NO];
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

@end
