//
//  Menu.m
//  iAccessories
//
//  Created by 王 兆琦 on 12-12-18.
//  Copyright (c) 2012年 MobileWoo. All rights reserved.
//

#import "Menu.h"
#import "Constants.h"

@implementation Menu

@synthesize groups          = _groups;

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if(self){
        self.groups         = [coder decodeObjectForKey:@"groups"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.groups forKey:@"groups"];
}

@end

@implementation MenuGroup

@synthesize menuItems       = _menuItems;

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if(self){
        self.groupName          = [coder decodeObjectForKey:@"groupName"];
        self.menuItems          = [coder decodeObjectForKey:@"menuItems"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.groupName forKey:@"groupName"];
    [coder encodeObject:self.menuItems forKey:@"menuItems"];
}

@end

@implementation MenuItemFactory

+ (id)createMenuItemByType:(int)type
{
    MenuItem *item = nil;
    switch (type) {
        case kMenuActionTypeList:
            item = [[MenuItemTreasureList alloc] init];
            item.menuType = [NSNumber numberWithInt:kMenuActionTypeList];
            break;
        case kMenuActionTypeListAuto:
            item = [[MenuItemTreasureListAuto alloc] init];
            item.menuType = [NSNumber numberWithInt:kMenuActionTypeListAuto];
            break;
        case kMenuActionTypeListDiscount:
            item = [[MenuItemTreasureListDiscount alloc] init];
            item.menuType = [NSNumber numberWithInt:kMenuActionTypeListDiscount];
            break;
        case kMenuActionTypeTreasure:
            item = [[MenuItemTreasureDetail alloc] init];
            item.menuType = [NSNumber numberWithInt:kMenuActionTypeTreasure];
            break;
        case kMenuActionTypeLink:
            item = [[MenuItemLink alloc] init];
            item.menuType = [NSNumber numberWithInt:kMenuActionTypeLink];
            break;
        case kMenuActionTypeSence:
        case kMenuActionTypeDiscount:
        case kMenuActionTypeEditorRecommand:
            item = [[MenuItemSence alloc] init];
            item.menuType = [NSNumber numberWithInt:kMenuActionTypeSence];
            break;
        case kMenuActionTypeCategory:
            item = [[MenuItemCategory alloc] init];
            item.menuType = [NSNumber numberWithInt:kMenuActionTypeCategory];
            break;
        case kMenuActionTypeFavorite:
            item = [[MenuItemFavorite alloc] init];
            item.menuType = [NSNumber numberWithInt:kMenuActionTypeFavorite];
            break;
        case kMenuActionTypeSettings:
            item = [[MenuItemSettings alloc] init];
            item.menuType = [NSNumber numberWithInt:kMenuActionTypeSettings];
            break;
        case kMenuActionTypeBackHomePage:
            item = [[MenuItemBackHomePage alloc] init];
            item.menuType = [NSNumber numberWithInt:kMenuActionTypeBackHomePage];
            break;
        case kMenuActionTypePin:
            item = [[MenuItemPin alloc] init];
            item.menuType = [NSNumber numberWithInt:kMenuActionTypePin];
            break;
        default:
            break;
    }
    return item;
}

@end

@implementation MenuItem

@synthesize menuType        = _menuType;
@synthesize menuName        = _menuName;
@synthesize bannerId        = _bannerId;
@synthesize hasNew          = _hasNew;

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if(self){
        self.menuType           = [coder decodeObjectForKey:@"menuType"];
        self.menuName           = [coder decodeObjectForKey:@"menuName"];
        self.bannerId           = [coder decodeObjectForKey:@"bannerId"];
        self.hasNew             = [[coder decodeObjectForKey:@"hasNew"] boolValue];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.menuType forKey:@"menuType"];
    [coder encodeObject:self.menuName forKey:@"menuName"];
    [coder encodeObject:self.bannerId forKey:@"bannerId"];
    [coder encodeObject:[NSNumber numberWithBool:self.hasNew] forKey:@"hasNew"];
}

@end


@implementation MenuItemTreasureList

@synthesize treasureShowType    = _treasureShowType;
@synthesize advertisingUUID     = _advertisingUUID;
@synthesize advertisingUrl      = _advertisingUrl;
@synthesize dataSwitch          = _dataSwitch;

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if(self){
        self.treasureShowType   = [coder decodeIntForKey:@"treasureShowType"];
        self.advertisingUUID    = [coder decodeObjectForKey:@"advertisingUUID"];
        self.advertisingUrl     = [coder decodeObjectForKey:@"advertisingUrl"];
        self.dataSwitch         = [coder decodeIntForKey:@"dataSwitch"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    [coder encodeInt:self.treasureShowType forKey:@"treasureShowType"];
    [coder encodeObject:self.advertisingUUID forKey:@"advertisingUUID"];
    [coder encodeObject:self.advertisingUrl forKey:@"advertisingUrl"];
    [coder encodeInt:self.dataSwitch forKey:@"dataSwitch"];
}

@end

@implementation MenuItemTreasureListAuto

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if(self){
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
}

@end

@implementation MenuItemTreasureListDiscount

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if(self){
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
}

@end

@implementation MenuItemTreasureDetail

@synthesize tid             = _tid;

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if(self){
        self.tid            = [coder decodeObjectForKey:@"tid"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    [coder encodeObject:self.tid forKey:@"tid"];
}

@end

@implementation MenuItemLink

@synthesize url             = _url;

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if(self){
        self.url            = [coder decodeObjectForKey:@"url"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    [coder encodeObject:self.url forKey:@"url"];
}

@end

@implementation MenuItemSence

@synthesize tileShowType     = _tileShowType;

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if(self){
        self.tileShowType    = [coder decodeIntForKey:@"tileShowType"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    [coder encodeInt:self.tileShowType forKey:@"tileShowType"];
}

@end

@implementation MenuItemCategory

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if(self){

    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
}

@end

@implementation MenuItemFavorite

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if(self){
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
}

@end

@implementation MenuItemSettings

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if(self){
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
}

@end

@implementation MenuItemBackHomePage

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if(self){
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
}

@end

@implementation MenuItemPin

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if(self){
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
}

@end