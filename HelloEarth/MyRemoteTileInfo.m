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
    if (tileID.level < MAP_LAYER_OFFLINE_LEVEL)
    {
        return nil;
    }
    
    NSURLRequest *oldRequest = [super requestForTile:tileID];
    NSString *urlString = oldRequest.URL.absoluteString;
    NSURLRequest *newRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[urlString stringByAppendingString:@"?access_token=pk.eyJ1IjoiZGl2ZGl2IiwiYSI6ImNpZXpoN3ZhbjE5cjdyem0zdDduNzB5YmsifQ.yammbn9qObvstid_12Gq9A"]]];
    
    
    return newRequest;
}

-(bool)tileIsLocal:(MaplyTileID)tileID frame:(int)frame
{
    if (tileID.level < MAP_LAYER_OFFLINE_LEVEL)
    {
        return true;
    }
    
    bool bl = [super tileIsLocal:tileID frame:frame];
    
    return bl;
}

- (NSString *)fileNameForTile:(MaplyTileID)tileID
{
    if (tileID.level < MAP_LAYER_OFFLINE_LEVEL) {
        NSString *fileName = [self.imageInfo objectForKey:@"type"];
        NSString *ext = [self.imageInfo objectForKey:@"ext"];
        
        fileName = [NSString stringWithFormat:@"%@_%d_%d_%d", fileName, tileID.level, tileID.x, tileID.y];
        
        NSString *s = [[NSBundle mainBundle] pathForResource:fileName ofType:ext];
        
//        NSLog(@"%d,%d,%d\n%@\n%@", tileID.level, tileID.x, tileID.y, s_r, s);
        return s;
    }
    else
    {
        NSString *s = [super fileNameForTile:tileID];
        return s;
    }
}
@end
