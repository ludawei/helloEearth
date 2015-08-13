//
//  MapStatistTempView.h
//  TestMapCover-Pad
//
//  Created by 卢大维 on 15/5/25.
//  Copyright (c) 2015年 weather. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapStatistTempView : UIView

@property (nonatomic,copy) NSString *addr;
-(void)showWithStationId:(NSString *)stationid;

@end
