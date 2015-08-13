//
//  TJPieView.h
//  LongForTianjie
//
//  Created by PLATOMIX  on 14-8-15.
//  Copyright (c) 2014年 platomix. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TJPieView : UIView

- (instancetype)initRadiuses:(NSArray *)radiuses total:(CGFloat)total;

-(void)startAnim;
@end
