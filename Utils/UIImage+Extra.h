//
//  UIImage+Extra.h
//  ChinaWeather
//
//  Created by ludawei on 7/22/13.
//  Copyright (c) 2013 Platomix. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Extra)

- (UIImage *)cropInRect:(CGRect)rect;
- (UIImage *)croppedImage:(CGRect)bounds;
- (UIImage *)scaleToSize:(CGSize)size;
+(UIImage *)autoReleasedImageWithName:(NSString *)name;
- (UIImage *)resizedImageWithContentMode:(UIViewContentMode)contentMode
                                  bounds:(CGSize)bounds
                    interpolationQuality:(CGInterpolationQuality)quality;

- (UIImage *)rotatedByDegrees:(CGFloat)degrees;
@end
