//
//  DownloadObject.m
//  iAccessories
//
//  Created by zhang on 12-11-26.
//  Copyright (c) 2012年 MobileWoo. All rights reserved.
//

#import "DownloadObject.h"

@implementation DownloadObject
@synthesize bookId, nowRange, allRange, downloadUrl, status;


- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if(self){
        self.bookId             = [coder decodeObjectForKey:@"bookId"];
        self.nowRange           = [coder decodeObjectForKey:@"nowRange"];
        self.allRange           = [coder decodeObjectForKey:@"allRange"];
        self.downloadUrl        = [coder decodeObjectForKey:@"downloadUrl"];
        self.status             = [coder decodeIntForKey:@"status"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.bookId forKey:@"bookId"];
    [coder encodeObject:self.nowRange forKey:@"nowRange"];
    [coder encodeObject:self.allRange forKey:@"allRange"];
    [coder encodeObject:self.downloadUrl forKey:@"downloadUrl"];
    [coder encodeInt:self.status forKey:@"status"];
}

- (BOOL)isEqual:(id)object
{
    BOOL result = NO;
    if ([object isKindOfClass:[DownloadObject class]]) {
        result = [self.bookId isEqualToNumber:((DownloadObject *)object).bookId];
    }
    return result;
}


@end
