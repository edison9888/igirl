//
//  RequestParameter.m
//  TestHttpEngine
//
//  Created by shenjianguo on 10-10-9.
//  Copyright 2010 Roosher. All rights reserved.
//

#import "RequestParameter.h"
#import "NSString+Extra.h"

@implementation RequestParameter

@synthesize name, value;

+ (id)requestParameterWithName:(NSString *)aName value:(NSString *)aValue {
	return [[RequestParameter alloc] initWithName:aName value:aValue];
}

- (id)initWithName:(NSString *)aName value:(NSString *)aValue {
    self = [super init];
    if (self ) {
		self.name = aName;
		self.value = aValue;
	}
    return self;
}


- (NSString *)URLEncodedNameValuePair {
    return [NSString stringWithFormat:@"%@=%@", [name URLEncodedString], [value URLEncodedString]];
}

@end
