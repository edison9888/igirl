//
//  TimeIntervalUtils.m
//  Three Hundred
//
//  Created by 郭雪 on 11-8-16.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "TimeIntervalUtils.h"

static TimeIntervalUtils *singleton = nil;
@implementation TimeIntervalUtils
@synthesize dateFormatter = _dateFormatter;

+ (TimeIntervalUtils *)sharedInstance
{
    if (singleton == nil) {
        singleton = [[TimeIntervalUtils alloc] init];
    }
    return singleton;
}

- (id)init
{
    if (self == [super init]) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setLocale:[NSLocale currentLocale]];
        [_dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    }
    return self;
}


+ (NSString*)shortTextFromTimeIntervalSince1970:(int)timeInterval
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSTimeInterval theSeconds = [date timeIntervalSinceNow];
    int seconds = 0 - theSeconds;
    
    if (seconds < 60) {//just now
        return NSLocalizedString(@"刚刚", @"");
    }
    else if (seconds >= 60 && seconds < 60 * 60) {//min
        return [NSString stringWithFormat:NSLocalizedString(@"%d分钟", @""), seconds / 60];
    }
    else if (seconds >= 60 * 60 && seconds < 60 * 60 * 24) {//hour
        return [NSString stringWithFormat:NSLocalizedString(@"%d小时", @""), seconds / (60 * 60)];
    }
    else if (seconds >= 60 * 60 * 24 && seconds < 60 * 60 * 24 * 30) {//day
        return [NSString stringWithFormat:NSLocalizedString(@"%d天", @""), seconds / (60 * 60 * 24)];
    }
    else {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        
        NSString *formattedDateString = [dateFormatter stringFromDate:date];
        return formattedDateString;        
    }
}

+ (NSString*)fullTextFromTimeIntervalSince1970:(int)timeInterval
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSTimeInterval theSeconds = [date timeIntervalSinceNow];
    int seconds = 0 - theSeconds;
    
    if (seconds < 60) {//just now
        return NSLocalizedString(@"刚刚", @"");
    } else if (seconds >= 60 && seconds < 60 * 60) {//min
        return [NSString stringWithFormat:NSLocalizedString(@"%d分钟前", @""), seconds / 60];
    } else if (seconds >= 60 * 60 && seconds < 60 * 60 * 24) {//hour
        return [NSString stringWithFormat:NSLocalizedString(@"%d小时前", @""), seconds / (60 * 60)];
    } else if (seconds >= 60 * 60 * 24 && seconds < 60 * 60 * 24 * 30) {//day
        return [NSString stringWithFormat:NSLocalizedString(@"%d天前", @""), seconds / (60 * 60 * 24)];
    } else {
        TimeIntervalUtils *timeutils = [TimeIntervalUtils sharedInstance];
        [timeutils.dateFormatter setDateFormat:NSLocalizedString(@"YYYY.MM.dd", @"")];
        return [timeutils.dateFormatter stringFromDate:date];    
    }
}



+ (NSString *)getNowDateString 
{
    TimeIntervalUtils *timeutils = [TimeIntervalUtils sharedInstance];
    [timeutils.dateFormatter setDateFormat:NSLocalizedString(@"YYYY-MM-dd", @"")];
    return [timeutils.dateFormatter stringFromDate:[NSDate date]];
}

+ (NSString *)getNowTimeString_Second
{
    TimeIntervalUtils *timeutils = [TimeIntervalUtils sharedInstance];
    [timeutils.dateFormatter setDateFormat:@"HH:mm:ss"];
    return [timeutils.dateFormatter stringFromDate:[NSDate date]];
}


+ (NSString *)getNowTimeString_Minutes
{
    TimeIntervalUtils *timeutils = [TimeIntervalUtils sharedInstance];
    [timeutils.dateFormatter setDateFormat:@"HH:mm a"];
    return [timeutils.dateFormatter stringFromDate:[NSDate date]];
}

+ (NSString *)getDateStringFromTimeIntervalSince1970:(int)timeInterval
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    TimeIntervalUtils *timeutils = [TimeIntervalUtils sharedInstance];
    [timeutils.dateFormatter setDateFormat:NSLocalizedString(@"YYYY-MM-dd", @"")];
    return [timeutils.dateFormatter stringFromDate:date];
}

+ (NSString *)getTimeString_SecondFromTimeIntervalSince1970:(int)timeInterval
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    TimeIntervalUtils *timeutils = [TimeIntervalUtils sharedInstance];
    [timeutils.dateFormatter setDateFormat:@"HH:mm:ss a"];
    return [timeutils.dateFormatter stringFromDate:date];
}

+ (NSString *)getTimeString_MinutesFromTimeIntervalSince1970:(int)timeInterval
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    TimeIntervalUtils *timeutils = [TimeIntervalUtils sharedInstance];
    [timeutils.dateFormatter setDateFormat:@"a hh:mm"];
    return [timeutils.dateFormatter stringFromDate:date];
}


+ (NSString *)getStringFromDate:(NSDate *)sdate {
    TimeIntervalUtils *timeutils = [TimeIntervalUtils sharedInstance];
    [timeutils.dateFormatter setDateFormat:NSLocalizedString(@"YYYY-MM-dd", @"")];
    return [timeutils.dateFormatter stringFromDate:sdate];
}


+ (NSDate *)getDateFromString:(NSString *)string {
    TimeIntervalUtils *timeutils = [TimeIntervalUtils sharedInstance];
    return [timeutils.dateFormatter dateFromString:string];
}


@end
