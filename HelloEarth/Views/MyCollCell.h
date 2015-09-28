//
//  MyCollCell.h
//  chinaweathernews
//
//  Created by 卢大维 on 14-10-20.
//  Copyright (c) 2014年 weather. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyCollCell : UICollectionViewCell

-(void)setupData:(NSDictionary *)data selectFileMark:(NSString *)fileMark imageVersion:(NSString *)imgVersion;

@end
