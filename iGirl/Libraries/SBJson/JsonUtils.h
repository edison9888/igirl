//
//  JsonUtils.h
//  JsonUtils
//
//  Created by 晋辉 卫 on 4/11/12.
//  Copyright (c) 2012 MobileWoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JsonUtils : NSObject

+ (id)JSONObjectWithData:(NSData *)data;
+ (id)DataWithJSONObject:(id)object;

@end
