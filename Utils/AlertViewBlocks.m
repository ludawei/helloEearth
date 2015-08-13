//
//  AlertViewBlocks.m
//  multipleAlertViews
//
//  Created by abdus on 2/14/13.
//  Copyright (c) 2013 abdus. All rights reserved.
//

#import "AlertViewBlocks.h"
#import <objc/runtime.h>

@implementation UIAlertView (AddBlockCallBacks)
//Runtime association key.
static NSString *handlerRunTimeAccosiationKey = @"alertViewBlocksDelegate";

- (void)showAlerViewFromButtonAction:(UIButton *)clickedButton animated:(BOOL)animated handler:(UIActionAlertViewCallBackHandler)handler {
    
    //set runtime accosiation of object
    //param -  sourse object for association, association key, association value, policy of association
    objc_setAssociatedObject(self, ( const void *)CFBridgingRetain(handlerRunTimeAccosiationKey), handler, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self setDelegate:self];
    [self show];  //call UIAlertView show method
}
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIActionAlertViewCallBackHandler completionHandler = objc_getAssociatedObject(self, ( const void *)CFBridgingRetain(handlerRunTimeAccosiationKey));
    
    if (completionHandler != nil) {
        
        completionHandler(alertView, buttonIndex);
    }
}

@end
