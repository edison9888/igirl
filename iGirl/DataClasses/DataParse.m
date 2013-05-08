//
//  DataParse.m
//  Pocket flea market
//
//  Created by 兆琦 王 on 12-2-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DataParse.h"
#import "Banner.h"
#import "Category.h"
#import "Treasure.h"
#import "User.h"
#import "ShareTemplate.h"
#import "Advertise.h"
#import "Menu.h"
#import "TBSeller.h"
#import "Book.h"

#import "JsonUtils.h"
#import "Constants.h"

@interface DataParse (private)

+ (void)createSinaOauthInfo:(SinaOAuth *)oauth
                 remoteData:(NSDictionary *)remoteData;

+ (void)createMenuGroup:(MenuGroup *)menuGroup
             remoteData:(NSDictionary *)remoteData;

+ (void)createMenuItem:(MenuItem *)menuItem
            remoteData:(NSDictionary *)remoteData;

@end

@implementation DataParse

+(void)createSegmentBannerByRemoteData:(Banner *)banner
                            remoteData:(NSDictionary *)remoteData
{
    if (banner == nil) {
        return;
    }
    
    NSNumber *bannerId = [remoteData objectForKey:@"banner_id"];
    if (bannerId && [bannerId isKindOfClass:[NSNumber class]]) {
        banner.bannerId = bannerId;
    }
    NSString *title = [remoteData objectForKey:@"title"];
    if (title && [title isKindOfClass:[NSString class]] && [title length] > 0) {
        banner.title = title;
    }
    
    NSArray *tiles = [remoteData objectForKey:@"tiles"];
    if (tiles && [tiles isKindOfClass:[NSArray class]]) {
        if (banner.items) {
            [banner.items removeAllObjects];
        } else {
            banner.items = [[NSMutableArray alloc] initWithCapacity:4];
        }
        for (NSDictionary *item in tiles) {
            Tile *tile = [[Tile alloc] init];
            [self createTileByRemoteData:tile remoteData:item];
            [banner.items addObject:tile];
        }
    }
}

+(void)createDrawerBannerByRemoteData:(Banner *)banner
                           remoteData:(NSDictionary *)remoteData
{
    if (banner == nil) {
        return;
    }
    
    NSNumber *bannerId = [remoteData objectForKey:@"drawer_id"];
    if (bannerId && [bannerId isKindOfClass:[NSNumber class]]) {
        banner.bannerId = bannerId;
    }
    NSString *title = [remoteData objectForKey:@"title"];
    if (title && [title isKindOfClass:[NSString class]] && [title length] > 0) {
        banner.title = title;
    }
    
    NSArray *tiles = [remoteData objectForKey:@"tiles"];
    if (tiles && [tiles isKindOfClass:[NSArray class]]) {
        if (banner.items) {
            [banner.items removeAllObjects];
        } else {
            banner.items = [[NSMutableArray alloc] initWithCapacity:4];
        }
        for (NSDictionary *item in tiles) {
            Tile *tile = [[Tile alloc] init];
            [self createTileByRemoteData:tile remoteData:item];
            [banner.items addObject:tile];
        }
    }
}

+(void)createTileByRemoteData:(Tile *)tile
                   remoteData:(NSDictionary *)remoteData
{
    if (tile == nil) {
        return;
    }
    
    NSNumber *tileId = [remoteData objectForKey:@"tile_id"];
    if (tileId && [tileId isKindOfClass:[NSNumber class]]) {
        tile.tileId = tileId;
    }
    NSString *tileTitle = [remoteData objectForKey:@"title"];
    if (tileTitle && [tileTitle isKindOfClass:[NSString class]] && [tileTitle length] > 0) {
        tile.tileTitle = tileTitle;
    }
    NSString *uuid = [remoteData objectForKey:@"photo"];
    if (uuid && [uuid isKindOfClass:[NSString class]] && [uuid length] > 0) {
        tile.tileUUID = uuid;
    }
    NSString *picUrl = [remoteData objectForKey:@"pic_url"];
    if (picUrl && [picUrl isKindOfClass:[NSString class]] && [picUrl length] > 0) {
        tile.picUrl = picUrl;
    }
    NSNumber *type = [remoteData objectForKey:@"type"];
    if (type && [type isKindOfClass:[NSNumber class]]) {
        tile.type = type;
    }
    NSString *link = [remoteData objectForKey:@"link"];
    if (link && [link isKindOfClass:[NSString class]] && [link length] > 0) {
        tile.link = link;
    }
    NSNumber *itemId = [remoteData objectForKey:@"item_id"];
    if (itemId && [itemId isKindOfClass:[NSNumber class]]) {
        tile.itemId = itemId;
    }
    id treasureListType = [remoteData objectForKey:@"show_list"];
    if (treasureListType && [treasureListType isKindOfClass:[NSNumber class]]) {
        tile.treasureShowType = [treasureListType intValue];
    }
    id treasurePrice = [remoteData objectForKey:@"price"];
    if (treasurePrice && [treasurePrice isKindOfClass:[NSNumber class]]) {
        tile.treasurePrice = treasurePrice;
    }
    id recommend = [remoteData objectForKey:@"recommend"];
    if (recommend && [recommend isKindOfClass:[NSString class]] && [recommend length] > 0) {
        tile.recommand = recommend;
    }
    id volumn = [remoteData objectForKey:@"volumn"];
    if (volumn && [volumn isKindOfClass:[NSNumber class]]) {
        tile.volumn = volumn;
    }
    id coupon = [remoteData objectForKey:@"coupon_end_time"];
    if (coupon && [coupon isKindOfClass:[NSNumber class]]) {
        tile.couponTime = [NSDate dateWithTimeIntervalSince1970:[coupon doubleValue]];
    }
}

+(void)createCategoryByRemoteData:(Category *)category
                       remoteData:(NSDictionary *)remoteData
{
    if (category == nil) {
        return;
    }
    
    NSNumber *cid = [remoteData objectForKey:@"cid"];
    if (cid && [cid isKindOfClass:[NSNumber class]]) {
        category.cid = cid;
    }
    NSString *name = [remoteData objectForKey:@"name"];
    if (name && [name isKindOfClass:[NSString class]] && [name length] > 0) {
        category.name = name;
    }
    NSString *uuid = [remoteData objectForKey:@"uuid"];
    if (uuid && [uuid isKindOfClass:[NSString class]] && [uuid length] > 0) {
        category.uuid = uuid;
    }
    
    NSArray *subCategories = [remoteData objectForKey:@"sub_category"];
    if (subCategories && [subCategories isKindOfClass:[NSArray class]]) {
        NSMutableArray *subArray = [[NSMutableArray alloc] init];
        for (NSDictionary *subItem in subCategories) {
            Category *subCategory = [[Category alloc] init];
            [self createCategoryByRemoteData:subCategory remoteData:subItem];
            [subArray addObject:subCategory ];
        }
        category.subCategory = [[NSArray alloc] initWithArray:subArray];
    }
}

+(void)createItemDataByRemoteData:(Treasure *)treasure
                       remoteData:(NSDictionary *)remoteData
{
    if (treasure == nil) {
        return;
    }
    
    NSNumber *tid = [remoteData objectForKey:@"item_id"];
    if (tid && [tid isKindOfClass:[NSNumber class]]) {
        treasure.tid = tid;
    }
    NSString *title = [remoteData objectForKey:@"title"];
    if (title && [title isKindOfClass:[NSString class]] && [title length] > 0) {
        treasure.title = title;
    }
    NSNumber *price = [remoteData objectForKey:@"price"];
    if (price && [price isKindOfClass:[NSNumber class]]) {
        treasure.price = price;
    }
    NSNumber *orgPrice = [remoteData objectForKey:@"org_price"];
    if (orgPrice && [orgPrice isKindOfClass:[NSNumber class]]) {
        treasure.orgPrice = orgPrice;
    }
    NSNumber *sellerCredit = [remoteData objectForKey:@"seller_credit_score"];
    if (sellerCredit && [sellerCredit isKindOfClass:[NSNumber class]]) {
        treasure.sellerCredit = sellerCredit;
    }
    NSString *picUrl = [remoteData objectForKey:@"pic_url"];
    if (picUrl && [picUrl isKindOfClass:[NSString class]] && [picUrl length] > 0) {
        treasure.picUrl = picUrl;
    }
    NSString *picUuid = [remoteData objectForKey:@"choice_uuid"];
    if (picUuid && [picUuid isKindOfClass:[NSString class]] && [picUuid length] > 0) {
        treasure.picUuid = picUuid;
    }
    NSNumber *created = [remoteData objectForKey:@"created"];
    if (created && [created isKindOfClass:[NSNumber class]]) {
        treasure.create = [NSDate dateWithTimeIntervalSince1970:[created doubleValue]];
    }
    NSString *clickUrl = [remoteData objectForKey:@"click_url"];
    if (clickUrl && [clickUrl isKindOfClass:[NSString class]] && [clickUrl length] > 0) {
        treasure.clickUrl = clickUrl;
    }
    NSNumber *couponTime = [remoteData objectForKey:@"coupon_end_time"];
    if (couponTime && [couponTime isKindOfClass:[NSNumber class]]) {
        treasure.couponTime = [NSDate dateWithTimeIntervalSince1970:[couponTime doubleValue]];
    }
    NSString *recommend = [remoteData objectForKey:@"recommend"];
    if (recommend && [recommend isKindOfClass:[NSString class]] && [recommend length] > 0) {
        treasure.recommend = recommend;
    }
    NSNumber *volume = [remoteData objectForKey:@"volume"];
    if (volume && [volume isKindOfClass:[NSNumber class]]) {
        treasure.volume = volume;
    }
}

+(void)createTreasureDetailByRemoteData:(TreasureDetail *)treasure
                             remoteData:(NSDictionary *)remoteData
{
    if (treasure == nil) {
        return;
    }
    
    NSNumber *tid = [remoteData objectForKey:@"item_id"];
    if (tid && [tid isKindOfClass:[NSNumber class]]) {
        treasure.tid = tid;
    }
    NSString *title = [remoteData objectForKey:@"title"];
    if (title && [title isKindOfClass:[NSString class]] && [title length] > 0) {
        treasure.title = title;
    }
    NSNumber *price = [remoteData objectForKey:@"price"];
    if (price && [price isKindOfClass:[NSNumber class]]) {
        treasure.price = price;
    }
    NSString *nick = [remoteData objectForKey:@"nick"];
    if (nick && [nick isKindOfClass:[NSString class]] && [nick length] > 0) {
        treasure.nick = nick;
    }
    NSString *desc = [remoteData objectForKey:@"desc"];
    if (desc && [desc isKindOfClass:[NSString class]] && [desc length] > 0) {
        treasure.desc = desc;
    }
    NSString *picUrl = [remoteData objectForKey:@"pic_url"];
    if (picUrl && [picUrl isKindOfClass:[NSString class]] && [picUrl length] > 0) {
        treasure.picUrl = picUrl;
    }
    NSString *clickUrl = [remoteData objectForKey:@"click_url"];
    if (clickUrl && [clickUrl isKindOfClass:[NSString class]] && [clickUrl length] > 0) {
        treasure.clickUrl = clickUrl;
    }
    NSString *location = [remoteData objectForKey:@"location"];
    if (location && [location isKindOfClass:[NSString class]] && [location length] > 0) {
        treasure.location = location;
    }
    NSNumber *sellerCredit = [remoteData objectForKey:@"seller_credit_score"];
    if (sellerCredit && [sellerCredit isKindOfClass:[NSNumber class]]) {
        treasure.sellerCredit = sellerCredit;
    }
    NSArray *images = [remoteData objectForKey:@"item_imgs"];
    if (images && [images isKindOfClass:[NSArray class]]) {
        NSMutableArray *newImages = [[NSMutableArray alloc] initWithCapacity:4];
        for (NSDictionary *image in images) {
            NSString *url = [image objectForKey:@"url"];
            [newImages addObject:url];
        }
        treasure.images = [NSArray arrayWithArray:newImages];
    }
    // 评论
    NSMutableArray *rates = [[NSMutableArray alloc] init];
    NSArray *trade_rate = [remoteData objectForKey:@"trade_rate"];
    if (trade_rate && (![trade_rate isEqual:[NSNull null]])) {
        if ([trade_rate isKindOfClass:[NSArray class]]) {
            for (NSDictionary *item in trade_rate) {
                Rate *rate = [[Rate alloc] init];
                NSString *nick = [item objectForKey:@"nick"];
                if (nick && (![nick isEqual:[NSNull null]])) {
                    rate.nick = nick;
                }
                NSNumber *result = [item objectForKey:@"result"];
                if (result && (![result isEqual:[NSNull null]])) {
                    switch ([result intValue]) {
                        case -1:
                            rate.result = @"bad";
                            break;
                        case 0:
                            rate.result = @"neutral";
                            break;
                        case 1:
                            rate.result = @"good";
                            break;
                        default:
                            break;
                    }
                }
                NSString *content = [item objectForKey:@"content"];
                if (content && (![content isEqual:[NSNull null]])) {
                    rate.content = content;
                }
                NSString *created = [item objectForKey:@"created"];
                if (created && (![created isEqual:[NSNull null]])) {
                    rate.created = created;
                }
                NSString *deal = [item objectForKey:@"deal"];
                if (deal && (![deal isEqual:[NSNull null]])) {
                    rate.deal = deal;
                }
                [rates addObject:rate];
            }
        }
        treasure.rate = [[NSArray alloc] initWithArray:rates];
    }
}

+(void)createMeByRemoteData:(Me *)me
                 remoteData:(NSDictionary *)remoteData
{
    if (me == nil) {
        return;
    }
    
    [DataParse createUserBaseByRemoteData:me remoteData:remoteData];
    NSString *session = [remoteData objectForKey:@"session"];
    if (session && [session isKindOfClass:[NSString class]] && [session length] > 0) {
        me.session = session;
    }
}

+(void)createUserBaseByRemoteData:(UserBase *)userBase
                       remoteData:(NSDictionary *)remoteData
{
    if (userBase == nil) {
        return;
    }
    
    NSNumber *userId = [remoteData objectForKey:@"user_id"];
    if (userId && [userId isKindOfClass:[NSNumber class]]) {
        userBase.userId = userId;
    }
    
    NSString *userName = [remoteData objectForKey:@"username"];
    if (userName && [userName isKindOfClass:[NSString class]] && [userName length] > 0) {
        userBase.userName = userName;
    }
    NSString *avatar = [remoteData objectForKey:@"avatar"];
    if (avatar && [avatar isKindOfClass:[NSString class]] && [avatar length] > 0) {
        userBase.avatar = avatar;
    }
}

+(void)createOAuthByRemoteData:(OAuth *)oauth
                    remoteData:(NSDictionary *)remoteData
{
    if (!oauth) {
        return;
    }
    
    NSString *token = [remoteData objectForKey:@"oauth_token"];
    if (token && [token isKindOfClass:[NSString class]] && [token length] > 0) {
        oauth.token = token;
    }
    NSString *secret = [remoteData objectForKey:@"oauth_token_secret"];
    if (secret && [secret isKindOfClass:[NSString class]] && [secret length] > 0) {
        oauth.tokenSecret = secret;
    }
    NSString *authId = [remoteData objectForKey:@"oauth_uid"];
    if (authId && [authId isKindOfClass:[NSString class]] && [authId length] > 0) {
        oauth.authId = authId;
    }
    NSString *screenName = [remoteData objectForKey:@"screenname"];
    if (screenName && [screenName isKindOfClass:[NSString class]] && [screenName length] > 0) {
        oauth.screenName = screenName;
    }
    NSString *refreshToken = [remoteData objectForKey:@"refresh_token"];
    if (refreshToken && [refreshToken isKindOfClass:[NSString class]] && [refreshToken length] > 0) {
        oauth.refreshToken = refreshToken;
    }
    NSString *oauthInfo = [remoteData objectForKey:@"info"];
    if (oauthInfo && [oauthInfo isKindOfClass:[NSString class]] && [oauthInfo length] > 0) {
        switch (oauth.type) {
            case kOAuthTypeSinaWeibo:
                [self createSinaOauthInfo:((SinaOAuth *)oauth) remoteData:[JsonUtils JSONObjectWithData:[oauthInfo dataUsingEncoding:NSUTF8StringEncoding]]];
                break;
            default:
                break;
        }
    }
}

+ (void)createSinaOauthInfo:(SinaOAuth *)oauth
                 remoteData:(NSDictionary *)remoteData
{
    if (!oauth) {
        return;
    }
    id expiredIn = [remoteData objectForKey:@"expired_in"];
    if (expiredIn && [expiredIn isKindOfClass:[NSNumber class]]) {
        oauth.expiredIn = [NSDate dateWithTimeIntervalSince1970:[expiredIn doubleValue]];
    }
}

+ (void)createShareTemplate:(ShareTemplate *)shareTemplate
                 remoteData:(NSDictionary *)remoteData
{
    if (!shareTemplate) {
        return;
    }
    id title = [remoteData objectForKey:@"title"];
    if (title && [title isKindOfClass:[NSString class]] && [title length] > 0) {
        shareTemplate.title = title;
    }
    id content = [remoteData objectForKey:@"content"];
    if (content && [content isKindOfClass:[NSString class]] && [content length] > 0) {
        shareTemplate.content = content;
    }
}

+ (void)createAdvertise:(Advertise *)advertise
             remoteData:(NSDictionary *)remoteData
{
    if (!advertise) {
        return;
    }
    id name = [remoteData objectForKey:@"name"];
    if (name && [name isKindOfClass:[NSString class]] && [name length] > 0) {
        advertise.name = name;
    }
    id uuid = [remoteData objectForKey:@"uuid"];
    if (uuid && [uuid isKindOfClass:[NSString class]] && [uuid length] > 0) {
        advertise.uuid = uuid;
    }
    id url = [remoteData objectForKey:@"url"];
    if (url && [url isKindOfClass:[NSString class]] && [url length] > 0) {
        advertise.url = url;
    }
}

+ (void)createMenu:(Menu *)menu
        remoteData:(NSDictionary *)remoteData
{
    if (!menu) {
        return;
    }
    id menus = [remoteData objectForKey:@"menus"];
    if (menus && [menus isKindOfClass:[NSArray class]] && [menus count] > 0) {
        NSMutableArray *tempGroups = [[NSMutableArray alloc] initWithCapacity:4];
        for (NSDictionary *dict in menus) {
            MenuGroup *group = [[MenuGroup alloc] init];
            [self createMenuGroup:group remoteData:dict];
            [tempGroups addObject:group];
        }
        menu.groups = [NSArray arrayWithArray:tempGroups];
    }
}

+ (void)createMenuGroup:(MenuGroup *)menuGroup
             remoteData:(NSDictionary *)remoteData
{
    if (!menuGroup) {
        return;
    }
    
    id groupName = [remoteData objectForKey:@"menu_title"];
    id menuItems = [remoteData objectForKey:@"drawers"];
    if (groupName && [groupName isKindOfClass:[NSString class]] && [groupName length] > 0) {
        menuGroup.groupName = groupName;
    }
    
    NSMutableArray *tempItems = [[NSMutableArray alloc] initWithCapacity:4];
    if (menuItems && [menuItems isKindOfClass:[NSArray class]] && [menuItems count] > 0) {
        for (NSDictionary *itemData in menuItems) {
            NSNumber *type = [itemData objectForKey:@"drawer_type"];
            if (type && [type isKindOfClass:[NSNumber class]]) {
                if ([[itemData objectForKey:@"data_type"] intValue] == 1) {
                    // 到付
                    NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] init];
                    [tmpDict setObject:[itemData objectForKey:@"banner_id"] forKey:@"orderBannerId"];
                    [tmpDict setObject:type forKey:@"orderShowType"];
                    [tmpDict setObject:[itemData objectForKey:@"show_list"] forKey:@"orderListShowType"];
                    [tmpDict setObject:[itemData objectForKey:@"show_menu"] forKey:@"orderSceneShowType"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ORDER_SHOW_TYPE object:nil userInfo:tmpDict];
                    continue;
                }
                if ([[itemData objectForKey:@"data_type"] intValue] == 2) {
                    // 评测
                    NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] init];
                    [tmpDict setObject:[itemData objectForKey:@"banner_id"] forKey:@"pingceBannerId"];
                    [tmpDict setObject:type forKey:@"pingceShowType"];
                    [tmpDict setObject:[itemData objectForKey:@"show_list"] forKey:@"pingceListShowType"];
                    [tmpDict setObject:[itemData objectForKey:@"show_menu"] forKey:@"pingceSceneShowType"];
                    [tmpDict setObject:[itemData objectForKey:@"has_new"] forKey:@"pingceHasNew"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PINGCE_SHOW_TYPE object:nil userInfo:tmpDict];
                    continue;
                }
                MenuItem *item = [MenuItemFactory createMenuItemByType:[type intValue]];
                [self createMenuItem:item remoteData:itemData];
                // menu type有可能是未知类型，所以item有可能是空
                if (item) {
                    [tempItems addObject:item];
                }
            }
        }
    }
    menuGroup.menuItems = [NSArray arrayWithArray:tempItems];
}

+ (void)createMenuItem:(MenuItem *)menuItem
            remoteData:(NSDictionary *)remoteData
{
    if (!menuItem) {
        return;
    }
    id itemName = [remoteData objectForKey:@"drawer_title"];
    if (itemName && [itemName isKindOfClass:[NSString class]] && [itemName length] > 0) {
        menuItem.menuName = itemName;
    }
    id bannerId = [remoteData objectForKey:@"banner_id"];
    if (bannerId && [bannerId isKindOfClass:[NSNumber class]]) {
        ((MenuItemTreasureList *)menuItem).bannerId = bannerId;
    }
    BOOL hasNew = [[remoteData objectForKey:@"has_new"] boolValue];
    ((MenuItemTreasureList *)menuItem).hasNew = hasNew;
    switch ([menuItem.menuType intValue]) {
        case kMenuActionTypeList:
        case kMenuActionTypeListAuto:
        case kMenuActionTypeListDiscount:
        {
            id showTreasure = [remoteData objectForKey:@"show_list"];
            if (showTreasure && [showTreasure isKindOfClass:[NSNumber class]]) {
                ((MenuItemTreasureList *)menuItem).treasureShowType = [showTreasure intValue];
            }
            id advertisingUUID = [remoteData objectForKey:@"ad_uuid"];
            if (advertisingUUID && [advertisingUUID isKindOfClass:[NSString class]] && [advertisingUUID length] > 0) {
                ((MenuItemTreasureList *)menuItem).advertisingUUID = advertisingUUID;
            }
            id advertisingUrl = [remoteData objectForKey:@"ad_url"];
            if (advertisingUrl && [advertisingUrl isKindOfClass:[NSString class]] && [advertisingUrl length] > 0) {
                ((MenuItemTreasureList *)menuItem).advertisingUrl = advertisingUrl;
            }
            id dataSwitch = [remoteData objectForKey:@"data_switch"];
            if (dataSwitch && [dataSwitch isKindOfClass:[NSNumber class]]) {
                ((MenuItemTreasureList *)menuItem).dataSwitch = [dataSwitch intValue];
            }
        }
            break;
        case kMenuActionTypeTreasure:
        {
            id tid = [remoteData objectForKey:@"item_id"];
            if (tid && [tid isKindOfClass:[NSNumber class]]) {
                ((MenuItemTreasureDetail *)menuItem).tid = tid;
            }
        }
            break;
        case kMenuActionTypeLink:
        {
            id url = [remoteData objectForKey:@"link_url"];
            if (url && [url isKindOfClass:[NSString class]] && [url length] > 0) {
                ((MenuItemLink *)menuItem).url = url;
            }
        }
            break;
        case kMenuActionTypeSence:
        {
            id showMenu = [remoteData objectForKey:@"show_menu"];
            if (showMenu && [showMenu isKindOfClass:[NSNumber class]]) {
                ((MenuItemSence *)menuItem).tileShowType = [showMenu intValue];
            }
        }
            break;
        default:
            break;
    }
}

+ (void)createTBSeller:(TBSeller *)seller
            remoteData:(NSDictionary *)remoteData
{
    if (!seller) {
        return ;
    }
    id nick = [remoteData objectForKey:@"nick"];
    if (nick && [nick isKindOfClass:[NSString class]] && [nick length] > 0) {
        seller.nick = nick;
    }
    else {
        seller.nick = @"";
    }
    id avatar = [remoteData objectForKey:@"avatar"];
    if (avatar && [avatar isKindOfClass:[NSString class]] && [avatar length] > 0) {
        seller.avatar = avatar;
    }
    else {
        seller.avatar = @"";
    }
    id location = [remoteData objectForKey:@"location"];
    if (location && [location isKindOfClass:[NSString class]] && [location length] > 0) {
        seller.location = location;
    }
    else {
        seller.location = @"";
    }
    id sellerCredit = [remoteData objectForKey:@"seller_credit"];
    if (sellerCredit && [sellerCredit isKindOfClass:[NSNumber class]]) {
        seller.sellerCredit = sellerCredit;
    }
    id isConsumerProtection = [remoteData objectForKey:@"consumer_protection"];
    if (isConsumerProtection && [isConsumerProtection isKindOfClass:[NSNumber class]]) {
        seller.isConsumerProtection = [isConsumerProtection boolValue];
    }
    id isGoldenSeller = [remoteData objectForKey:@"is_golden_seller"];
    if (isGoldenSeller && [isGoldenSeller isKindOfClass:[NSNumber class]]) {
        seller.isGoldenSeller = [isGoldenSeller boolValue];
    }
    id goodRate = [remoteData objectForKey:@"good_rate"];
    if (goodRate && [goodRate isKindOfClass:[NSString class]] && [goodRate length] > 0) {
        seller.goodRate = goodRate;
    }
    else {
        seller.goodRate = @"";
    }
}

+ (void)createOtherItem:(Treasure *)otherItem
            remoteData:(NSDictionary *)remoteData
{
    if (!otherItem) {
        return ;
    }
    id itemId = [remoteData objectForKey:@"num_iid"];
    if (itemId && [itemId isKindOfClass:[NSNumber class]]) {
        otherItem.tid = itemId;
    }
    id price = [remoteData objectForKey:@"price"];
    if (price && [price isKindOfClass:[NSNumber class]]) {
        otherItem.price = price;
    }
    id creditScore = [remoteData objectForKey:@"seller_credit_score"];
    if (creditScore && [creditScore isKindOfClass:[NSNumber class]]) {
        otherItem.sellerCredit = creditScore;
    }
    id clickUrl = [remoteData objectForKey:@"click_url"];
    if (clickUrl && [clickUrl isKindOfClass:[NSString class]] && [clickUrl length] > 0) {
        otherItem.clickUrl = clickUrl;
    }
    id picUrl = [remoteData objectForKey:@"pic_url"];
    if (picUrl && [picUrl isKindOfClass:[NSString class]] && [picUrl length] > 0) {
        otherItem.picUrl = picUrl;
    }
}

+ (void)createBook:(Book *)book
        remoteData:(NSDictionary *)remoteData
{
    if (!book) {
        return ;
    }
    id itemId = [remoteData objectForKey:@"book_id"];
    if (itemId && [itemId isKindOfClass:[NSNumber class]]) {
        book.bookId = itemId;
    }
    id picUrl = [remoteData objectForKey:@"pic_url"];
    if (picUrl && [picUrl isKindOfClass:[NSString class]] && [picUrl length] > 0) {
        book.picUrl = picUrl;
    }
    id link = [remoteData objectForKey:@"link"];
    if (link && [link isKindOfClass:[NSString class]] && [link length] > 0) {
        book.link = link;
    }
//    id needWeiboLogin = [remoteData objectForKey:@"needWeiboLogin"];
//    if (needWeiboLogin && [needWeiboLogin isKindOfClass:[NSNumber class]]) {
//        book.needWeiboLogin = [needWeiboLogin boolValue];
//    }
}

@end
