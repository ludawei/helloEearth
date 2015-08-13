//
//  ZipStr.h
//  adi
//
//  Created by LIU Zhongjie on 3/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

@interface ZipStr : NSObject 

+ (char*) Compress: (char*) str length: (int) sourceLen;
+ (char*) Uncompress: (char*) str length: (int) sourceLen;

@end