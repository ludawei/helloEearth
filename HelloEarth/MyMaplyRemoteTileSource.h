//
//  MyMaplyRemoteTileSource.h
//  HelloEarth
//
//  Created by 卢大维 on 15/10/12.
//  Copyright © 2015年 weather. All rights reserved.
//

#import "MaplyRemoteTileSource.h"
#import "MaplyQuadImageTilesLayer.h"

@interface MyMaplyRemoteTileSource : MaplyRemoteTileSource

@property (nonatomic,copy) NSDictionary *imageInfo;

@end
