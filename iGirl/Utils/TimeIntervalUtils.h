//
//  TimeIntervalUtils.h
//  Three Hundred
//
//  Created by 郭雪 on 11-8-16.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TimeIntervalUtils : NSObject

@property (nonatomic, strong, readonly) NSDateFormatter *dateFormatter;

+ (TimeIntervalUtils *)sharedInstance;
+ (NSString*)shortTextFromTimeIntervalSince1970:(int)timeInterval;
+ (NSString*)fullTextFromTimeIntervalSince1970:(int)timeInterval;


+ (NSString *)getNowDateString;
+ (NSString *)getNowTimeString_Second;
+ (NSString *)getNowTimeString_Minutes;

+ (NSString *)getDateStringFromTimeIntervalSince1970:(int)timeInterval;
+ (NSString *)getTimeString_SecondFromTimeIntervalSince1970:(int)timeInterval;
+ (NSString *)getTimeString_MinutesFromTimeIntervalSince1970:(int)timeInterval;

+ (NSString *)getStringFromDate:(NSDate *)sdate;
+ (NSDate *)getDateFromString:(NSString *)string;

@end
