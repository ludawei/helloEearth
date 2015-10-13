//
//  MyMaplyRemoteTileSource.m
//  HelloEarth
//
//  Created by 卢大维 on 15/10/12.
//  Copyright © 2015年 weather. All rights reserved.
//

#import "MyMaplyRemoteTileSource.h"

@interface MyMaplyRemoteTileSource ()

@property (nonatomic,assign) NSInteger z,x,y;

@end

@implementation MyMaplyRemoteTileSource



-(id)imageForTile:(MaplyTileID)tileID
{
    if (tileID.level < MAP_LAYER_OFFLINE_LEVEL) {
        NSString *fileName = [self.imageInfo objectForKey:@"type"];
        NSString *ext = [self.imageInfo objectForKey:@"ext"];
        
        fileName = [NSString stringWithFormat:@"%@_%d_%d_%d", fileName, tileID.level, tileID.x, tileID.y];
        
        NSString *s = [[NSBundle mainBundle] pathForResource:fileName ofType:ext];
        
        NSData *img = [NSData dataWithContentsOfFile:s];
        
//        NSLog(@"%d,%d,%d", tileID.level, tileID.x, tileID.y);
//        NSData *r = [super imageForTile:tileID];
//        UIImage *im1 = [UIImage imageWithData:img];
//        UIImage *im2 = [UIImage imageWithData:r];
        
        return img;
    }
//    NSLog(@"%d,%d,%d", tileID.level, tileID.x, tileID.y);
    
    return [super imageForTile:tileID];
}
@end
