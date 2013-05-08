//
//  ShareTemplate.m
//  iAccessories
//
//  Created by 王 兆琦 on 12-12-18.
//  Copyright (c) 2012年 MobileWoo. All rights reserved.
//

#import "ShareTemplate.h"

@implementation ShareTemplate

@synthesize title               = _title;
@synthesize content             = _content;

#pragma mark - NSCoding

- (id) initWithCoder:(NSCoder *)coder
{
    self =[super init];
    if(self){
        self.title              = [coder decodeObjectForKey:@"title"];
        self.content            = [coder decodeObjectForKey:@"content"];
    }
    return self;
}

-(void) encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.title forKey:@"title"];
    [coder encodeObject:self.content forKey:@"content"];
}

@end
