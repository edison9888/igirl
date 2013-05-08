//
//  LocalSettings.h
//  Three Hundred
//
//  Created by skye on 8/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Me;
@class Menu;

@interface LocalSettings : NSObject {    
}

+ (void)clearLocalData;
+ (void)clearOldData;
+ (void)copyResourceFileToSettingPath;
+ (NSString *)downloadPdfPath;

+ (NSDictionary *)loadTreasures;
+ (void)saveTreasures:(NSDictionary *)treasures;

+ (NSArray *)loadCategories;
+ (void)saveCategories:(NSArray *)categories;

+ (NSArray *)loadSegmentBannerIds;
+ (void)saveSegmentBannerIds:(NSArray *)segmentBanners;

+ (NSDictionary *)loadBanners;
+ (void)saveBanners:(NSDictionary *)banners;

+ (NSArray *)loadFavorites;
+ (void)saveFavorites:(NSArray *)favorites;

+ (NSDictionary *)loadTileItems;
+ (void)saveTileItems:(NSDictionary *)tileItems;

+ (NSDictionary *)loadBannerItems;
+ (void)saveBannerItems:(NSDictionary *)bannerItems;

+ (NSDictionary *)loadCatItems;
+ (void)saveCatItems:(NSDictionary *)catItems;

+ (Me *)loadMe;
+ (void)saveMe:(Me *)me;

+ (void)saveShareTemplates:(NSArray *)shareTemplates;
+ (NSArray *)loadShareTemplates;

+ (void)saveAdvertise:(NSArray *)advertise;
+ (NSArray *)loadAdvertise;

+ (void)saveMenu:(Menu *)menu;
+ (Menu *)loadMenu;

+ (void)saveSearchHistory:(NSArray *)searchHistory;
+ (NSArray *)loadSearchHistory;

+ (void)saveHasNew:(NSArray *)hasNew;
+ (NSArray *)loadHasNew;

+ (NSMutableArray *)loadDownloading;
+ (void)saveDownloading:(NSMutableArray *) downloading;
@end
