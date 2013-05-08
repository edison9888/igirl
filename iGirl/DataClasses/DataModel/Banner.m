//
//  Banner.m
//  iAccessories
//
//  Created by 王 兆琦 on 12-10-17.
//  Copyright (c) 2012年 MobileWoo. All rights reserved.
//

#import "Banner.h"

@implementation Banner

@synthesize bannerId            = _bannerId;
@synthesize title               = _title;
@synthesize items               = _items;

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if(self){
        self.bannerId           = [coder decodeObjectForKey:@"bannerId"];
        self.title              = [coder decodeObjectForKey:@"title"];
        
        NSArray *items = [coder decodeObjectForKey:@"items"];
        self.items = [NSMutableArray arrayWithArray:items];
        
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.bannerId forKey:@"bannerId"];
    [coder encodeObject:self.title forKey:@"title"];
    [coder encodeObject:self.items forKey:@"items"];
}

- (BOOL)isEqual:(id)object
{
    BOOL result = NO;
    if ([object isKindOfClass:[Banner class]]) {
        result = [self.bannerId isEqualToNumber:((Banner *)object).bannerId];
    }
    return result;
}

@end


////////////////////////////////////////////////////////////


@implementation Tile

@synthesize tileId              = _tileId;
@synthesize tileTitle           = _tileTitle;
@synthesize tileUUID            = _tileUUID;
@synthesize picUrl              = _picUrl;
@synthesize type                = _type;
@synthesize link                = _link;
@synthesize itemId              = _itemId;
@synthesize treasurePrice       = _treasurePrice;
@synthesize recommand           = _recommand;
@synthesize volumn              = _volumn;
@synthesize couponTime          = _couponTime;
@synthesize subTiles            = _subTiles;
@synthesize treasureShowType    = _treasureShowType;

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if(self){
        self.tileId             = [coder decodeObjectForKey:@"tileId"];
        self.tileTitle          = [coder decodeObjectForKey:@"tileTitle"];
        self.tileUUID           = [coder decodeObjectForKey:@"tileUUID"];
        self.picUrl             = [coder decodeObjectForKey:@"picUrl"];
        self.type               = [coder decodeObjectForKey:@"type"];
        self.link               = [coder decodeObjectForKey:@"link"];
        self.itemId             = [coder decodeObjectForKey:@"itemId"];
        self.treasurePrice      = [coder decodeObjectForKey:@"treasurePrice"];
        self.recommand          = [coder decodeObjectForKey:@"recommand"];
        self.volumn             = [coder decodeObjectForKey:@"volumn"];
        self.couponTime         = [coder decodeObjectForKey:@"couponTime"];
        self.treasureShowType   = [coder decodeIntForKey:@"treasureShowType"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.tileId forKey:@"tileId"];
    [coder encodeObject:self.tileTitle forKey:@"tileTitle"];
    [coder encodeObject:self.tileUUID forKey:@"tileUUID"];
    [coder encodeObject:self.picUrl forKey:@"picUrl"];
    [coder encodeObject:self.type forKey:@"type"];
    [coder encodeObject:self.link forKey:@"link"];
    [coder encodeObject:self.itemId forKey:@"itemId"];
    [coder encodeObject:self.treasurePrice forKey:@"treasurePrice"];
    [coder encodeObject:self.recommand forKey:@"recommand"];
    [coder encodeObject:self.volumn forKey:@"volumn"];
    [coder encodeObject:self.couponTime forKey:@"couponTime"];
    [coder encodeInt:self.treasureShowType forKey:@"treasureShowType"];
}

- (BOOL)isEqual:(id)object
{
    BOOL result = NO;
    if ([object isKindOfClass:[Tile class]]) {
        result = [self.tileId isEqualToNumber:((Tile *)object).tileId];
    }
    return result;
}


@end
