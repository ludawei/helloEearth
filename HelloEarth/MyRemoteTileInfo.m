//
//  MyRemoteTileInfo.m
//  HelloEarth
//
//  Created by 卢大维 on 15/7/30.
//  Copyright (c) 2015年 weather. All rights reserved.
//

#import "MyRemoteTileInfo.h"

@implementation MyRemoteTileInfo

- (NSURLRequest *)requestForTile:(MaplyTileID)tileID
{
    NSURLRequest *oldRequest = [super requestForTile:tileID];
    NSString *urlString = oldRequest.URL.absoluteString;
    NSURLRequest *newRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[urlString stringByAppendingString:@"?access_token=pk.eyJ1IjoiZGl2ZGl2IiwiYSI6ImNpZXpoN3ZhbjE5cjdyem0zdDduNzB5YmsifQ.yammbn9qObvstid_12Gq9A"]]];
    
    
    return newRequest;
}

-(bool)tileIsLocal:(MaplyTileID)tileID frame:(int)frame
{
    bool bl = [super tileIsLocal:tileID frame:frame];
    
    return bl;
}
@end
