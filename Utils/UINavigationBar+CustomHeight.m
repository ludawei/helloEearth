//
//  UINavigationBar+CustomHeight.m
//  HelloEarth
//
//  Created by 卢大维 on 15/9/14.
//  Copyright (c) 2015年 weather. All rights reserved.
//

#import "UINavigationBar+CustomHeight.h"
#import "objc/runtime.h"

static char const *const heightKey = "Height";

@implementation UINavigationBar (CustomHeight)

- (void)setMyHeight:(CGFloat)height
{
    objc_setAssociatedObject(self, heightKey, @(height), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)myheight
{
    return objc_getAssociatedObject(self, heightKey);
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize newSize = [super sizeThatFits:size];;
    
    CGFloat h = [[self myheight] floatValue];
    if ([[self myheight] floatValue] != newSize.height) {
        newSize = CGSizeMake(self.superview.bounds.size.width, h);
    }
    
    return newSize;
}

@end
