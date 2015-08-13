//
//  DecStr.h
//  adi
//
//  Created by LIU Zhongjie on 3/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

@interface DecStr : NSObject

+ (void) encrypt: (char*) buffer length: (unsigned int) len;
+ (void) decrypt: (char*) buffer length: (int) len;

@end
