//
//  RequestParameter.h
//  TestHttpEngine
//
//  Created by shenjianguo on 10-10-9.
//  Copyright 2010 Roosher. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RequestParameter : NSObject {
@protected
    NSString *name;
    NSString *value;
}
@property(copy) NSString *name;
@property(copy) NSString *value;

+ (id)requestParameterWithName:(NSString *)aName value:(NSString *)aValue;
- (id)initWithName:(NSString *)aName value:(NSString *)aValue;
- (NSString *)URLEncodedNameValuePair;

@end
