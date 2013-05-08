//
//  Book.m
//  iGirl
//
//  Created by zhang on 13-5-2.
//  Copyright (c) 2013年 MobileWoo. All rights reserved.
//

#import "Book.h"

@implementation Book
@synthesize bookId, picUrl, link;

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if(self){
        self.bookId             = [coder decodeObjectForKey:@"bookId"];
        self.picUrl             = [coder decodeObjectForKey:@"picUrl"];
        self.link               = [coder decodeObjectForKey:@"link"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.bookId forKey:@"bookId"];
    [coder encodeObject:self.picUrl forKey:@"picUrl"];
    [coder encodeObject:self.link forKey:@"link"];
}

- (BOOL)isEqual:(id)object
{
    BOOL result = NO;
    if ([object isKindOfClass:[Book class]]) {
        result = [self.bookId isEqualToNumber:((Book *)object).bookId];
    }
    return result;
}

@end
