//
//  CWHttpCmdFeedback.h
//  ChinaWeather
//
//  Created by 曹 君平 on 7/19/13.
//  Copyright (c) 2013 Platomix. All rights reserved.
//

#import "PLHttpCmd.h"

@interface CWHttpCmdFeedback : PLHttpCmd

@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *tel;

@end
