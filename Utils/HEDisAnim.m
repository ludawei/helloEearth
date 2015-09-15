//
//  HEDisAnim.m
//  HelloEarth
//
//  Created by 卢大维 on 15/9/15.
//  Copyright (c) 2015年 weather. All rights reserved.
//

#import "HEDisAnim.h"

@implementation HEDisAnim

-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.3;
}

-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *from = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *to = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    [[transitionContext containerView] addSubview:to.view];
    
    to.view.alpha = 0;
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        
        from.view.alpha = 0;
        to.view.alpha = 1;
        
    } completion:^(BOOL finished) {
        
        from.view.alpha = 1;
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

@end
