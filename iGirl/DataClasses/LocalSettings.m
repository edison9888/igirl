//
//  LocalSettings.m
//  Three Hundred
//
//  Created by skye on 8/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Constants.h"
#import "SkipBackupUtils.h"
#import "LocalSettings.h"
#import "User.h"
#import "Menu.h"

#define kSettingPath @"setting"

#define kTreasuresStoreFileName                 @"treasures.txt"
#define kSegmentBannerIdsStoreFileName          @"segmentBannerIds.txt"
#define kBannersStoreFileName                   @"banners.txt"
#define kCategoryiesStoreFileName               @"categoryies.txt"
#define kFavoritesStoreFileName                 @"Favorites.txt"
#define kTileItemsStoreFileName                 @"TileItems.txt"
#define kBannerItemsStoreFileName               @"BannerItems.txt"
#define kCatItemsStoreFileName                  @"CatItems.txt"
#define kMeStoreFileName                        @"MyInfo.txt"
#define kShareTemplateStoreFileName             @"shareTemplate.txt"
#define kAdvertiseStoreFileName                 @"advertise.txt"
#define kMenuStoreFileName                      @"menu.txt"
#define kSearchHistoryStoreFileName             @"searchHistory.txt"
#define kHasNewStoreFileName                    @"hasNew.txt"

#define kDownloadDirectory                      @"downloads"


static NSString *settingPath = nil;
static NSString *downloadPdfPath = nil;

@interface LocalSettings (Private)

+ (void)createDirectory;
+ (NSString *)settingPath;

@end

@implementation LocalSettings

+ (void)createDirectory {
	if (![[NSFileManager defaultManager] fileExistsAtPath:settingPath]) {
		[[NSFileManager defaultManager] createDirectoryAtPath:settingPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:downloadPdfPath]) {
		[[NSFileManager defaultManager] createDirectoryAtPath:downloadPdfPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

+ (NSString *)settingPath
{
    if(!settingPath) {        
        if (SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(@"5.0")) {
            NSArray *cachesPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            settingPath = [[[cachesPaths objectAtIndex:0] stringByAppendingString:@"/"] stringByAppendingPathComponent:kSettingPath];
        } else {
            NSArray *supportPaths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
            settingPath = [[[supportPaths objectAtIndex:0] stringByAppendingString:@"/"] stringByAppendingPathComponent:kSettingPath];       
        }
        NSLog(@"settingPath:%@", settingPath);
        
        [self createDirectory];
        
        [SkipBackupUtils addSkipBackupAttributeToItemAtPath:settingPath];
    }
    return settingPath;
}

+ (void)copyResourceFileToSettingPath
{
    NSError *error;
    //默认模版
    NSString *defaultCategorys = [[self settingPath] stringByAppendingPathComponent:kCategoryiesStoreFileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:defaultCategorys]) {
        [[NSFileManager defaultManager] copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"categoryies" ofType:@"txt"] toPath:defaultCategorys error:&error];
    }
    NSString *defaultShareTemplate = [[self settingPath] stringByAppendingPathComponent:kShareTemplateStoreFileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:defaultShareTemplate]) {
        [[NSFileManager defaultManager] copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"shareTemplate" ofType:@"txt"] toPath:defaultShareTemplate error:&error];
    }
    NSString *defaultMenuTemplate = [[self settingPath] stringByAppendingPathComponent:kMenuStoreFileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:defaultMenuTemplate]) {
        [[NSFileManager defaultManager] copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"menu" ofType:@"txt"] toPath:defaultMenuTemplate error:&error];
    }
}

+ (NSString *)downloadPdfPath
{
    if(!downloadPdfPath) {
//        if (SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(@"5.0")) {
//            NSArray *cachesPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
//            downloadPdfPath = [[[cachesPaths objectAtIndex:0] stringByAppendingString:@"/"] stringByAppendingPathComponent:kDownloadDirectory];
//        } else {
//            NSArray *supportPaths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
//            downloadPdfPath = [[[supportPaths objectAtIndex:0] stringByAppendingString:@"/"] stringByAppendingPathComponent:kDownloadDirectory];
//        }
        // 下载路径保存在 Caches 目录内
        NSArray *cachesPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        downloadPdfPath = [[[cachesPaths objectAtIndex:0] stringByAppendingString:@"/"] stringByAppendingPathComponent:kDownloadDirectory];

        NSLog(@"downloadPdfPath:%@", downloadPdfPath);
        
        [self createDirectory];
        
        [SkipBackupUtils addSkipBackupAttributeToItemAtPath:downloadPdfPath];
    }
    return downloadPdfPath;
}

+ (void)clearOldData
{

}

+ (void)clearLocalData
{
    [[NSFileManager defaultManager] removeItemAtPath:settingPath error:nil];
    settingPath = nil;
}

+ (NSDictionary *)loadTreasures
{
    NSDictionary *treasures = nil;
	NSString *appFile = [[self settingPath] stringByAppendingPathComponent:kTreasuresStoreFileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:appFile]) {
        NSData *data = [NSData dataWithContentsOfFile:appFile];
        treasures = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return treasures;    
}

+ (void)saveTreasures:(NSDictionary *)treasures
{
    if (!treasures) {
        return;
    }
	NSString *appFile = [[self settingPath] stringByAppendingPathComponent:kTreasuresStoreFileName];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:treasures];
    [data writeToFile:appFile atomically:YES];    
}

+ (NSArray *)loadCategories
{
    NSMutableArray *items = nil;
	NSString *appFile = [[self settingPath] stringByAppendingPathComponent:kCategoryiesStoreFileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:appFile]) {
        NSData *data = [NSData dataWithContentsOfFile:appFile];
        NSArray *temp = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        items = [NSMutableArray arrayWithArray:temp];
    }
    return items;
}

+ (void)saveCategories:(NSArray *)categories
{
    if (!categories) {
        return;
    }
	NSString *appFile = [[self settingPath] stringByAppendingPathComponent:kCategoryiesStoreFileName];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:categories];
    [data writeToFile:appFile atomically:YES];
}

+ (NSArray *)loadSegmentBannerIds
{
    NSArray *banners = nil;
	NSString *appFile = [[self settingPath] stringByAppendingPathComponent:kSegmentBannerIdsStoreFileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:appFile]) {
        NSData *data = [NSData dataWithContentsOfFile:appFile];
        banners = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return banners;
}

+ (void)saveSegmentBannerIds:(NSArray *)segmentBanners
{
    if (!segmentBanners) {
        return;
    }
	NSString *appFile = [[self settingPath] stringByAppendingPathComponent:kSegmentBannerIdsStoreFileName];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:segmentBanners];
    [data writeToFile:appFile atomically:YES];
}

+ (NSDictionary *)loadBanners
{
    NSDictionary *banners = nil;
	NSString *appFile = [[self settingPath] stringByAppendingPathComponent:kBannersStoreFileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:appFile]) {
        NSData *data = [NSData dataWithContentsOfFile:appFile];
        banners = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return banners;
}

+ (void)saveBanners:(NSDictionary *)banners
{
    if (!banners) {
        return;
    }
	NSString *appFile = [[self settingPath] stringByAppendingPathComponent:kBannersStoreFileName];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:banners];
    [data writeToFile:appFile atomically:YES];
}

+ (NSDictionary *)loadCatItems
{
    NSDictionary *items = nil;
	NSString *appFile = [[self settingPath] stringByAppendingPathComponent:kCatItemsStoreFileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:appFile]) {
        NSData *data = [NSData dataWithContentsOfFile:appFile];
        items = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return items;
}

+ (void)saveCatItems:(NSDictionary *)catItems
{
    if (!catItems) {
        return;
    }
    NSString *appFile = [[self settingPath] stringByAppendingPathComponent:kCatItemsStoreFileName];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:catItems];
    [data writeToFile:appFile atomically:YES];    
}

+ (NSArray *)loadFavorites
{
    NSMutableArray *favorites = nil;
	NSString *appFile = [[self settingPath] stringByAppendingPathComponent:kFavoritesStoreFileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:appFile]) {
        NSData *data = [NSData dataWithContentsOfFile:appFile];
        NSArray *temp = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        favorites = [NSMutableArray arrayWithArray:temp];
    }
    return favorites;
}

+ (void)saveFavorites:(NSArray *)favorites
{
    if (!favorites) {
        return;
    }
	NSString *appFile = [[self settingPath] stringByAppendingPathComponent:kFavoritesStoreFileName];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:favorites];
    [data writeToFile:appFile atomically:YES]; 
}

+ (NSDictionary *)loadTileItems
{
    NSDictionary *items = nil;
	NSString *appFile = [[self settingPath] stringByAppendingPathComponent:kTileItemsStoreFileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:appFile]) {
        NSData *data = [NSData dataWithContentsOfFile:appFile];
        items = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return items;
}

+ (void)saveTileItems:(NSDictionary *)tileItems
{
    if (!tileItems) {
        return;
    }
	NSString *appFile = [[self settingPath] stringByAppendingPathComponent:kTileItemsStoreFileName];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:tileItems];
    [data writeToFile:appFile atomically:YES];
}

+ (NSDictionary *)loadBannerItems
{
    NSDictionary *items = nil;
	NSString *appFile = [[self settingPath] stringByAppendingPathComponent:kBannerItemsStoreFileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:appFile]) {
        NSData *data = [NSData dataWithContentsOfFile:appFile];
        items = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return items;
}

+ (void)saveBannerItems:(NSDictionary *)bannerItems
{
    if (!bannerItems) {
        return;
    }
	NSString *appFile = [[self settingPath] stringByAppendingPathComponent:kBannerItemsStoreFileName];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:bannerItems];
    [data writeToFile:appFile atomically:YES];
}

+ (NSString *)getSettingPath
{
    NSArray *doumenetPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *settingPath = [[[doumenetPaths objectAtIndex:0] stringByAppendingString:@"/"] stringByAppendingPathComponent:kSettingPath];
    if (![[NSFileManager defaultManager] fileExistsAtPath:settingPath])
		[[NSFileManager defaultManager] createDirectoryAtPath:settingPath withIntermediateDirectories:NO attributes:nil error:nil];
    return settingPath;
}

+ (Me *)loadMe
{
    Me *me = nil;
	NSString *appFile = [[self settingPath] stringByAppendingPathComponent:kMeStoreFileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:appFile]) {
        NSData *data = [NSData dataWithContentsOfFile:appFile];
        me = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return me;
}

+ (void)saveMe:(Me *)me
{
    if (me) {
        NSString *appFile = [[self settingPath] stringByAppendingPathComponent:kMeStoreFileName];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:me];
        [data writeToFile:appFile atomically:YES];
    } else {
        NSString *appFile = [[self settingPath] stringByAppendingPathComponent:kMeStoreFileName];
        [[NSFileManager defaultManager] removeItemAtPath:appFile error:nil];
    }
}

+ (void)saveShareTemplates:(NSArray *)shareTemplates
{
    if (!shareTemplates) {
        return;
    }
    NSString *appFile = [[self settingPath] stringByAppendingPathComponent:kShareTemplateStoreFileName];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:shareTemplates];
    [data writeToFile:appFile atomically:YES];
    return;
}

+ (NSArray *)loadShareTemplates
{
    NSMutableArray *shareTemplates = [[NSMutableArray alloc] init];
	NSString *appFile = [[self settingPath] stringByAppendingPathComponent:kShareTemplateStoreFileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:appFile]) {
        NSData *data = [NSData dataWithContentsOfFile:appFile];
        NSMutableArray *temp = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        [shareTemplates addObjectsFromArray:temp];
    }
    return shareTemplates;
}

+ (void)saveAdvertise:(NSArray *)advertise
{
    NSString *appFile = [[self settingPath] stringByAppendingPathComponent:kAdvertiseStoreFileName];
    if (advertise) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:advertise];
        [data writeToFile:appFile atomically:YES];
    } else {
        [[NSFileManager defaultManager] removeItemAtPath:appFile error:nil];
    }
    return;
}

+ (NSArray *)loadAdvertise
{
    NSMutableArray *advertise = [[NSMutableArray alloc] init];
	NSString *appFile = [[self settingPath] stringByAppendingPathComponent:kAdvertiseStoreFileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:appFile]) {
        NSData *data = [NSData dataWithContentsOfFile:appFile];
        NSMutableArray *temp = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        [advertise addObjectsFromArray:temp];
    }
    return advertise;
}

+ (void)saveMenu:(Menu *)menu
{
    if (menu) {
        NSString *appFile = [[self settingPath] stringByAppendingPathComponent:kMenuStoreFileName];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:menu];
        [data writeToFile:appFile atomically:YES];
    } 
}

+ (Menu *)loadMenu
{
    Menu *menu = nil;
	NSString *appFile = [[self settingPath] stringByAppendingPathComponent:kMenuStoreFileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:appFile]) {
        NSData *data = [NSData dataWithContentsOfFile:appFile];
        menu = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return menu;
}

+ (void)saveSearchHistory:(NSArray *)searchHistory
{
    NSString *appFile = [[self settingPath] stringByAppendingPathComponent:kSearchHistoryStoreFileName];
    if (searchHistory) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:searchHistory];
        [data writeToFile:appFile atomically:YES];
    } else {
        [[NSFileManager defaultManager] removeItemAtPath:appFile error:nil];
    }
}

+ (NSArray *)loadSearchHistory
{
    NSMutableArray *searchHistory = [[NSMutableArray alloc] init];
	NSString *appFile = [[self settingPath] stringByAppendingPathComponent:kSearchHistoryStoreFileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:appFile]) {
        NSData *data = [NSData dataWithContentsOfFile:appFile];
        NSMutableArray *temp = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        [searchHistory addObjectsFromArray:temp];
    }
    return searchHistory;
}

+ (void)saveHasNew:(NSArray *)hasNew
{
    NSString *appFile = [[self settingPath] stringByAppendingPathComponent:kHasNewStoreFileName];
    if (hasNew) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:hasNew];
        [data writeToFile:appFile atomically:YES];
    } else {
        [[NSFileManager defaultManager] removeItemAtPath:appFile error:nil];
    }
}

+ (NSArray *)loadHasNew
{
    NSMutableArray *hasNew = [[NSMutableArray alloc] init];
	NSString *appFile = [[self settingPath] stringByAppendingPathComponent:kHasNewStoreFileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:appFile]) {
        NSData *data = [NSData dataWithContentsOfFile:appFile];
        NSMutableArray *temp = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        [hasNew addObjectsFromArray:temp];
    }
    return hasNew;
}


+ (NSMutableArray *)loadDownloading
{
    NSMutableArray *downloading = nil;
	NSString *appFile = [[self settingPath] stringByAppendingPathComponent:kDownloadDirectory];
    if ([[NSFileManager defaultManager] fileExistsAtPath:appFile]) {
        NSData *data = [NSData dataWithContentsOfFile:appFile];
        downloading = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return downloading;
}

+ (void)saveDownloading:(NSMutableArray *) downloading
{
    if (!downloading) {
        return;
    }
    // 不保存状态,没有断点续传需求
    return;
	NSString *appFile = [[self settingPath] stringByAppendingPathComponent:kDownloadDirectory];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:downloading];
    [data writeToFile:appFile atomically:YES];
}
@end
