//
//  Treasure.m
//  Three Hundred
//
//  Created by skye on 10/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Treasure.h"

@implementation Rate

@synthesize nick               = _nick;
@synthesize result             = _result;
@synthesize content            = _content;
@synthesize created            = _created;
@synthesize deal               = _deal;

#pragma mark - NSCoding

- (id)init
{
    if (self = [super init]) {
        
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)coder
{
    self =[super init];
    if(self){
        self.nick         = [coder decodeObjectForKey:@"rate_nick"];
        self.result       = [coder decodeObjectForKey:@"rate_result"];
        self.content      = [coder decodeObjectForKey:@"rate_content"];
        self.created      = [coder decodeObjectForKey:@"rate_created"];
        self.deal         = [coder decodeObjectForKey:@"rate_deal"];
    }
    return self;
}

-(void) encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.nick forKey:@"rate_nick"];
    [coder encodeObject:self.result forKey:@"rate_result"];
    [coder encodeObject:self.content forKey:@"rate_content"];
    [coder encodeObject:self.created forKey:@"rate_created"];
    [coder encodeObject:self.deal forKey:@"rate_deal"];
}

@end

@implementation Treasure

@synthesize tid                = _tid;
@synthesize title              = _title;
@synthesize price              = _price;
@synthesize orgPrice           = _orgPrice;
@synthesize picUrl             = _picUrl;
@synthesize picUuid            = _picUuid;
@synthesize clickUrl           = _clickUrl;
@synthesize create             = _create;
@synthesize recommend          = _recommend;
@synthesize couponTime         = _couponTime;
@synthesize volume             = _volume;
@synthesize sellerCredit       = _sellerCredit;

#pragma mark - NSCoding

- (id)init
{
    if (self = [super init]) {

    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{    
    self = [super init];
    if (self) {
        self.tid                = [coder decodeObjectForKey:@"treasureId"];
        self.title              = [coder decodeObjectForKey:@"title"];        
        self.price              = [coder decodeObjectForKey:@"price"];
        self.orgPrice           = [coder decodeObjectForKey:@"orgPrice"];
        self.picUrl             = [coder decodeObjectForKey:@"picUrl"];
        self.picUuid            = [coder decodeObjectForKey:@"picUuid"];
        self.clickUrl           = [coder decodeObjectForKey:@"clickUrl"];
        self.create             = [coder decodeObjectForKey:@"create"];
        self.recommend          = [coder decodeObjectForKey:@"recommend"];
        self.couponTime         = [coder decodeObjectForKey:@"couponTime"];
        self.volume             = [coder decodeObjectForKey:@"volume"];
        self.sellerCredit       = [coder decodeObjectForKey:@"sellerCredit"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{    
    [coder encodeObject:self.tid forKey:@"treasureId"];
    [coder encodeObject:self.title forKey:@"title"];
    [coder encodeObject:self.price forKey:@"price"];
    [coder encodeObject:self.orgPrice forKey:@"orgPrice"];
    [coder encodeObject:self.picUrl forKey:@"picUrl"];
    [coder encodeObject:self.picUuid forKey:@"picUuid"];
    [coder encodeObject:self.clickUrl forKey:@"clickUrl"];
    [coder encodeObject:self.create forKey:@"create"];
    [coder encodeObject:self.recommend forKey:@"recommend"];
    [coder encodeObject:self.couponTime forKey:@"couponTime"];
    [coder encodeObject:self.volume forKey:@"volume"];
    [coder encodeObject:self.sellerCredit forKey:@"sellerCredit"];
}

@end

/////////////////////////////////////////////////////////////////

@implementation TreasureDetail

@synthesize nick        = _nick;
@synthesize desc        = _desc;
@synthesize images      = _images;
@synthesize rate        = _rate;
@synthesize location    = _location;

- (id)init
{
    if (self = [super init]) {
        
    }
    return self;
}

- (id)initWithTreasure:(Treasure *)treasure
{
    self = [super init];
    if (self) {
        if (treasure) {
            self.tid            = treasure.tid;
            self.title          = treasure.title;
            self.price          = treasure.price;
            self.picUrl         = treasure.picUrl;
            self.clickUrl       = treasure.clickUrl;
            self.create         = treasure.create;
            self.recommend      = treasure.recommend;
            self.couponTime     = treasure.couponTime;
            self.volume         = treasure.volume;
            self.sellerCredit   = treasure.sellerCredit;
        }
    }
    return self;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.nick           = [coder decodeObjectForKey:@"nick"];
        self.desc           = [coder decodeObjectForKey:@"desc"];
        self.images         = [coder decodeObjectForKey:@"images"];
        self.rate           = [coder decodeObjectForKey:@"rate"];
        self.location       = [coder decodeObjectForKey:@"location"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    [coder encodeObject:self.nick forKey:@"nick"];
    [coder encodeObject:self.desc forKey:@"desc"];
    [coder encodeObject:self.images forKey:@"images"];
    [coder encodeObject:self.rate forKey:@"rate"];
    [coder encodeObject:self.location forKey:@"location"];
}

@end