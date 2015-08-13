//
//  AuthorizeUtil.h
//  adi
//
//  Created by Zhongjie LIU on 10/12/12.
//
//

#import <Foundation/Foundation.h>

@interface AuthorizeUtil : NSObject

+ (NSString*) getAppKey;
+ (NSString*) getBaseUpload;
+ (void) saveOauthData: (NSString*) expiration string: (NSString*) upload;

@end
