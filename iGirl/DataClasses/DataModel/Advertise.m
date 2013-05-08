//
//  Advertise.m
//  iAccessories
//
//  Created by 王 兆琦 on 12-12-18.
//  Copyright (c) 2012年 MobileWoo. All rights reserved.
//

#import "Advertise.h"

@implementation Advertise

@synthesize name                = _name;
@synthesize uuid                = _uuid;
@synthesize url                 = _url;

#pragma mark - NSCoding

- (id) initWithCoder:(NSCoder *)coder
{
    self =[super init];
    if(self){
        self.name               = [coder decodeObjectForKey:@"name"];
        self.uuid               = [coder decodeObjectForKey:@"uuid"];
        self.url                = [coder decodeObjectForKey:@"url"];
    }
    return self;
}

-(void) encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.uuid forKey:@"uuid"];
    [coder encodeObject:self.url forKey:@"url"];
}

@end