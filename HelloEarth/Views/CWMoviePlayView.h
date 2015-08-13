//
//  CWMoviePlayView.h
//  TestMapCover-Pad
//
//  Created by 卢大维 on 15/7/11.
//  Copyright (c) 2015年 weather. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayerView.h"

@interface CWMoviePlayView : UIView

@property (nonatomic,assign) BOOL fullStatus;

@property (nonatomic ,strong) PlayerView *playerView;

-(instancetype)initWithFrame:(CGRect)frame withUrl:(NSURL *)url;
- (void)stateButtonTouched;

@end
