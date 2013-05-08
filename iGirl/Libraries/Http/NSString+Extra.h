//
//  NSString+Extra.h
//  Roosher
//
//  Created by shenjianguo on 10-9-27.
//  Copyright 2010 Roosher inc. All rights reserved.
//

@interface NSString (Extra)

+ (NSString*)stringWithNewUUID;
- (NSString *)URLEncodedString;
- (NSString *)URLDecodedString;

//字符串转换为:距离目前时间的间隔
- (NSString *)stringToTimeInterval;

//字符串转换为TimeInterval
- (NSString *)stringToDateTimeInterval;

@end
