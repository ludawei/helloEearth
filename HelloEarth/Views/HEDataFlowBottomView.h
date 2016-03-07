//
//  HEDataFlowBottomView.h
//  HelloEarth
//
//  Created by 卢大维 on 16/3/4.
//  Copyright © 2016年 weather. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HEDataFlowBottomView : UIView

-(void)setupWithData:(NSDictionary *)data;
-(void)changeRotationToSize:(CGSize)toSize;

@end
