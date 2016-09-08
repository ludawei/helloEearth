//
//  MapImagesManager.h
//  NextRain
//
//  Created by 卢大维 on 14-10-28.
//  Copyright (c) 2014年 weather. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

typedef NS_ENUM(NSInteger, MapImageType){
    MapImageTypeRain = 1,
    MapImageTypeCloud,
};

typedef NS_ENUM(NSInteger, MapImageDownloadType){
    MapImageDownloadTypeFail = 0,
    MapImageDownloadTypeNew,
    MapImageDownloadTypeOld,
};
@interface MapImagesManager : NSObject

//+ (MapImagesManager *)sharedInstance;

@property (nonatomic,strong) UIView *hudView;

-(void)requestImageList:(enum MapImageType)type completed:(void (^)(enum MapImageDownloadType downloadType))block;
-(void)downloadAllImageWithType:(enum MapImageType)type completed:(void (^)(NSDictionary *images))block loadType:(enum MapImageDownloadType)loadType;

-(void)downloadImageWithUrl:(NSString *)url type:(enum MapImageType)type completed:(void (^)(UIImage *image))block;

-(UIImage *)imageFromDiskForUrl:(NSString *)url;

+(void)clearAllImagesFromDiskWithTime:(BOOL)withTime;
@end
