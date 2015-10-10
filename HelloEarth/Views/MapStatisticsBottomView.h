//
//  MapStatisticsBottomView.h
//  chinaweathernews
//
//  Created by 卢大维 on 15/5/20.
//  Copyright (c) 2015年 weather. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapStatisticsBottomView : UIView

@property (nonatomic,copy) NSString *addr;
-(void)showWithStationId:(NSString *)stationid;
-(void)hide;

@end
