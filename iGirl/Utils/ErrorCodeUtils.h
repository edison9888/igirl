//
//  ErrorCodeUtils.h
//  Three Hundred
//
//  Created by 郭雪 on 11-8-26.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ErrorCodeUtils : NSObject {
    
}

+ (NSString *)errorDetailFromErrorCode:(int)errorCode;

+ (NSString *)errorDetailFromSinaErrorCode:(int)errorCode;

@end
