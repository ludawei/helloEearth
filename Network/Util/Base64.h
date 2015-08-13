//
//  Base64.h
//  adi
//
//  Created by Zhongjie LIU on 10/12/12.
//
//

#import <Foundation/Foundation.h>

@interface Base64 : NSObject

+ (NSData*) base64Decode: (NSString *)string;
+ (NSString*) base64Encode: (NSData *)data;
+ (NSString*) base64Encode: (const unsigned char*) bytes length: (int) len;
+(NSString *)base64EncodeString:(NSString *)string;

@end
