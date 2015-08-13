//
//  UIView+ModifyFrame.m
//  babyshow_ios
//
//  Created by ludawei on 14-2-14.
//  Copyright (c) 2014年 platomix.dw. All rights reserved.
//

#import "UIView+ModifyFrame.h"

@implementation UIView (ModifyFrame)

-(float) x {
    return self.frame.origin.x;
}

-(void) setX:(float) newX {
    CGRect frame = self.frame;
    frame.origin.x = newX;
    self.frame = frame;
}

-(float) y {
    return self.frame.origin.y;
}

-(void) setY:(float) newY {
    CGRect frame = self.frame;
    frame.origin.y = newY;
    self.frame = frame;
}

-(float) width {
    return self.frame.size.width;
}

-(void) setWidth:(float) newWidth {
    CGRect frame = self.frame;
    frame.size.width = newWidth;
    self.frame = frame;
}

-(float) height {
    return self.frame.size.height;
}

-(void) setHeight:(float) newHeight {
    CGRect frame = self.frame;
    frame.size.height = newHeight;
    self.frame = frame;
}

@end
