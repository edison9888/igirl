//
//  NSStringExtra.m
//  ThreeHundred
//
//  Created by 郭雪 on 11-11-25.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "NSStringExtra.h"

@implementation NSString (NSStringExtra)

- (NSString*)stringByTrimmingBoth {
    NSString *trimmed = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return trimmed;
}

- (NSString*)stringByTrimmingLeadingWhitespace {
    NSInteger i = 0;
    
    while (i < self.length && [[NSCharacterSet whitespaceCharacterSet] characterIsMember:[self characterAtIndex:i]]) {
        i++;
    }
    if (i < self.length) {
        return [self substringFromIndex:i];
    } else {
        return @"";
    }
}

- (NSString*)stringToMoneyFormat:(NSString *)str
{
    NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];

    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSString *numberString = [numberFormatter stringFromNumber:[NSNumber numberWithInteger:[str intValue]]];

    return numberString;
}

@end
