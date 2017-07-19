//
//  MBProgressHUD+Extra.m
//  Ituji
//
//  Created by ludawei on 9/16/12.
//
//

#import "MBProgressHUD+Extra.h"

@implementation MBProgressHUD (Extra)

+(MBProgressHUD *)showLoadingHUDAddedTo:(UIView *)view
{
    return [MBProgressHUD showHUDAddedTo:view animated:YES];
}

+(void)hideLoadingHUDForView:(UIView *)view
{
    [MBProgressHUD hideAllHUDsForView:view animated:YES];
}

+ (MBProgressHUD *)showHUDInView:(UIView *)view andText:(NSString *)text
{
    if(!view)
        return nil;
    
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:view];
    [view addSubview:HUD];
    if(text)
    {
        HUD.labelText = text;
    }
    [HUD show:YES];
    return HUD;
}

+ (void)showHUDInView:(UIView *)view withImage:(NSString *)imageName andText:(NSString *)text
{
    if(!view || (!imageName && !text))
        return;
    
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:view];
    [view addSubview:HUD];
    if(imageName)
    {
        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
        HUD.mode = MBProgressHUDModeCustomView;
    }
    if(text)
    {
        HUD.labelText = text;
    }
    [HUD show:YES];
    [HUD hide:YES afterDelay:0.8];
}

+ (void)showHUDInView:(UIView *)view withImage:(NSString *)imageName
{
    [self showHUDInView:view withImage:imageName andText:nil];
}

+ (void)showHUDInView:(UIView *)view withText:(NSString *)text
{
    [self showHUDInView:view withImage:nil andText:text];
}

+ (void)showHUDNoteInView:(UIView *)view withText:(NSString *)text
{
    if(!view)
        return;

    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:view];
    hud.mode = MBProgressHUDModeText;
    [view addSubview:hud];
    hud.labelText = text;
    [hud show:YES];
    [hud hide:YES afterDelay:1.5];
}

+ (void)showHUDNoteWithText:(NSString *)text
{
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:[UIApplication sharedApplication].keyWindow];
    hud.mode = MBProgressHUDModeText;
    [[UIApplication sharedApplication].keyWindow addSubview:hud];
    hud.labelText = text;
    [hud show:YES];
    [hud hide:YES afterDelay:1.5];
}

+ (void)showHUDNoteWithText:(NSString *)text delay:(float)delay
{
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:[UIApplication sharedApplication].keyWindow];
    hud.mode = MBProgressHUDModeText;
    hud.removeFromSuperViewOnHide = YES;
    [[UIApplication sharedApplication].keyWindow addSubview:hud];
    hud.labelText = text;
    [hud show:YES];
    [hud hide:YES afterDelay:delay];
}

+ (void)hideHUDInView:(UIView *)view 
{
    [self hideAllHUDsForView:view animated:YES];
}
+ (void)showHUDInView:(UIView *)view withText:(NSString *)text delay:(float)delay
{
    if(!view)
        return;
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:view];
    [view addSubview:hud];
    hud.labelText = text;
    [hud show:YES];
    [hud hide:YES afterDelay:delay];
}
@end
