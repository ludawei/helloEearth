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
    NSURLRequest *newRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[urlString stringByAppendingString:@"?access_token=pk.eyJ1IjoibHVkYXdlaSIsImEiOiJldzV1SVIwIn0.-gaUYss5MkQMyem_IOskdA"]]];
    
    
    return newRequest;
}

@end
