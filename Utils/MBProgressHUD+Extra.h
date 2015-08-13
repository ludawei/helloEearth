//
//  MBProgressHUD+Extra.h
//  Ituji
//
//  Created by 曹 君平 on 9/16/12.
//
//

#import "MBProgressHUD.h"

@interface MBProgressHUD (Extra)

+(MBProgressHUD *)showLoadingHUDAddedTo:(UIView *)view;
+(void)hideLoadingHUDForView:(UIView *)view;

+ (MBProgressHUD *)showHUDInView:(UIView *)view andText:(NSString *)text;
+ (void)showHUDInView:(UIView *)view withImage:(NSString *)imageName andText:(NSString *)text;
+ (void)showHUDInView:(UIView *)view withImage:(NSString *)imageName;
+ (void)showHUDInView:(UIView *)view withText:(NSString *)text;
+ (void)showHUDNoteInView:(UIView *)view withText:(NSString *)text;
+ (void)showHUDNoteWithText:(NSString *)text;
+ (void)showHUDNoteWithText:(NSString *)text delay:(float)delay;
+ (void)hideHUDInView:(UIView *)view;
+ (void)showHUDInView:(UIView *)view withText:(NSString *)text delay:(float)delay;
@end
