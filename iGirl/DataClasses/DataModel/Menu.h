//
//  Menu.h
//  iAccessories
//
//  Created by 王 兆琦 on 12-12-18.
//  Copyright (c) 2012年 MobileWoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@interface Menu : NSObject <NSCoding>
{
    NSArray         *_groups;
}
@property (nonatomic, retain) NSArray *groups;

@end

@interface MenuGroup : NSObject <NSCoding>
{
    NSString        *_groupName;
    NSArray         *_menuItems;
}
@property (nonatomic, copy) NSString *groupName;
@property (nonatomic, retain) NSArray *menuItems;

@end


@interface MenuItemFactory : NSObject

+ (id)createMenuItemByType:(int)type;

@end

@interface MenuItem : NSObject <NSCoding>
{
    NSNumber        *_menuType;
    NSString        *_menuName;
    NSNumber        *_bannerId;
    BOOL            _hasNew;
}
@property (nonatomic, retain) NSNumber *menuType;
@property (nonatomic, copy) NSString *menuName;
@property (nonatomic, retain) NSNumber *bannerId;
@property (assign) BOOL hasNew;
@end

@interface MenuItemTreasureList : MenuItem
{
    TreasureShowType    _treasureShowType;
    NSString            *_advertisingUUID;
    NSString            *_advertisingUrl;
    int                 _dataSwitch;
}

@property (nonatomic, assign) TreasureShowType treasureShowType;
@property (nonatomic, copy) NSString *advertisingUUID;
@property (nonatomic, copy) NSString *advertisingUrl;
@property (nonatomic, assign) int dataSwitch;

@end

@interface MenuItemTreasureListAuto : MenuItemTreasureList
@end

@interface MenuItemTreasureListDiscount : MenuItemTreasureList
@end

@interface MenuItemTreasureDetail : MenuItem
{
    NSNumber        *_tid;
}
@property (nonatomic, retain) NSNumber *tid;
@end

@interface MenuItemLink : MenuItem
{
    NSString        *_url;
}
@property (nonatomic, copy) NSString *url;
@end

@interface MenuItemSence : MenuItem
{
    TileShowType    _tileShowType;
}
@property (nonatomic, assign) TileShowType tileShowType;
@end

@interface MenuItemCategory : MenuItem
@end

@interface MenuItemFavorite : MenuItem
@end

@interface MenuItemSettings : MenuItem
@end

@interface MenuItemBackHomePage : MenuItem
@end

@interface MenuItemPin : MenuItem
@end