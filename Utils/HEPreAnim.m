//
//  HEPreAnim.m
//  HelloEarth
//
//  Created by 卢大维 on 15/9/15.
//  Copyright (c) 2015年 weather. All rights reserved.
//

#import "HEPreAnim.h"

@implementation HEPreAnim

-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.25;
}

-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    //    UIViewController *from = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *to = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    [[transitionContext containerView] addSubview:to.view];
    
    CGRect finalFrame = [transitionContext finalFrameForViewController:to];
//    to.view.frame = CGRectOffset(finalFrame, -finalFrame.size.width, 0);
    to.view.frame = finalFrame;
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        
//        to.view.frame = finalFrame;
        
    } completion:^(BOOL finished) {
        
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

@end
