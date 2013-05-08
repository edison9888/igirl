//
//  DataParse.h
//  Pocket flea market
//
//  Created by 兆琦 王 on 12-2-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Banner;
@class Tile;
@class Category;
@class Treasure;
@class TreasureDetail;
@class UserBase;
@class Me;
@class OAuth;
@class ShareTemplate;
@class Advertise;
@class Menu;
@class TBSeller;
@class Book;

@interface DataParse : NSObject

+(void)createSegmentBannerByRemoteData:(Banner *)banner
                            remoteData:(NSDictionary *)remoteData;

+(void)createDrawerBannerByRemoteData:(Banner *)banner
                           remoteData:(NSDictionary *)remoteData;

+(void)createTileByRemoteData:(Tile *)tile
                   remoteData:(NSDictionary *)remoteData;

+(void)createCategoryByRemoteData:(Category *)category
                       remoteData:(NSDictionary *)remoteData;

+(void)createItemDataByRemoteData:(Treasure *)treasure
                       remoteData:(NSDictionary *)remoteData;

+(void)createTreasureDetailByRemoteData:(TreasureDetail *)treasure
                             remoteData:(NSDictionary *)remoteData;

+(void)createMeByRemoteData:(Me *)me
                 remoteData:(NSDictionary *)remoteData;

+(void)createUserBaseByRemoteData:(UserBase *)userBase
                       remoteData:(NSDictionary *)remoteData;

+(void)createOAuthByRemoteData:(OAuth *)oauth
                    remoteData:(NSDictionary *)remoteData;

+ (void)createShareTemplate:(ShareTemplate *)shareTemplate
                 remoteData:(NSDictionary *)remoteData;

+ (void)createAdvertise:(Advertise *)advertise
             remoteData:(NSDictionary *)remoteData;

+ (void)createMenu:(Menu *)menu
        remoteData:(NSDictionary *)remoteData;

+ (void)createTBSeller:(TBSeller *)seller
            remoteData:(NSDictionary *)remoteData;

+ (void)createOtherItem:(Treasure *)otherItem
             remoteData:(NSDictionary *)remoteData;

+ (void)createBook:(Book *)book
        remoteData:(NSDictionary *)remoteData;

@end
