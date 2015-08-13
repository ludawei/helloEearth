//
//  UIView+Extra.m
//  Spendify
//
//  Created by 曹 君平 on 1/15/13.
//  Copyright (c) 2013 Tsao Chunping. All rights reserved.
//

#import "UIView+Extra.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (Extra)

- (UIImage *)viewShot
{
    CGFloat restoredAlpha = self.alpha;
    
    self.alpha = 1;
    UIImage *image;
    @autoreleasepool {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0);
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
        
        image = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
    }
    
    self.alpha = restoredAlpha;
    
    return image;
}

@end
