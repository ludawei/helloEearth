//
//  HCBaseObject.h
//  HighCourt
//
//  Created by ludawei on 13-9-24.
//  Copyright (c) 2013年 ludawei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PLBaseObject : NSObject

-(id)initWithDict:(NSDictionary *)dict;

- (void)dictionaryForObject:(NSDictionary*) dict;
- (NSDictionary *)dictionaryFromObject;
@end
