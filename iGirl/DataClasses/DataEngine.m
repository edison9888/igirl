//
//  DataEngine.m
//  Three Hundred
//
//  Created by skye on 8/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DataEngine.h"
#import "HttpEngine.h"
#import "DeviceHardware.h"
#import "JsonUtils.h"
#import "NSString+MD5.h"
#import "ErrorCodeUtils.h"
#import "DataCompose.h"
#import "DataParse.h"
#import "Constants.h"
#import "Treasure.h"
#import "Banner.h"
#import "OAuth.h"
#import "User.h"
#import "ShareTemplate.h"
#import "Menu.h"
#import "Advertise.h"
#import "ImageCacheEngine.h"
#import "LocalSettings.h"
#import "AppDelegate.h"
#import "RIButtonItem.h"
#import <UIKit/UIKit.h>
#import "UIAlertView+Blocks.h"
#import "CLog.h"
#import "Category.h"
#import "NSString+HTML.h"
#import "ImageCacheEngine.h"
#import "TBSeller.h"
#import "Book.h"

#define NOTIFICATION_ID     @"NotificationId"


static DataEngine *dataEngine = nil;
static DownloadManager *downloadManager = nil;

@interface DataEngine (Notification)

- (void)networkReachable:(NSNotification *)notification;

@end

@interface DataEngine (Private)

- (void)initDataEngineProperty;

- (void)doSomeThingAfterLogin:(BOOL)isAutoLogin;

- (void)doSomeThingAfterLogout;

//读取本地数据
- (void)getLocalData;

//清除本地所有数据（仅限在读取本地失败crash的时候清理所有本地数据）
- (void)clearLocalDataAll;

@end

@implementation DataEngine

@synthesize uuid                = _uuid;
@synthesize sid                 = _sid;
@synthesize treasures           = _treasures;
@synthesize segmentBannerIds    = _segmentBannerIds;
@synthesize banners             = _banners;
@synthesize tileItems           = _tileItems;
@synthesize bannerItems         = _bannerItems;
@synthesize categories          = _categories;
@synthesize catItems            = _catItems;
@synthesize favories            = _favories;
@synthesize me                  = _me;
@synthesize buyButtonText       = _buyButtonText;
@synthesize shareButtonText     = _shareButtonText;
@synthesize shareViewAdvertise  = _shareViewAdvertise;
@synthesize menu                = _menu;
@synthesize weiboEngine         = _weiboEngine;
@synthesize appInReview         = _appInReview;
@synthesize catSellers          = _catSellers;
@synthesize recommendItems      = _recommendItems;
@synthesize adIsHide            = _adIsHide;
@synthesize searchResultItems   = _searchResultItems;
@synthesize searchHistory       = _searchHistory;
@synthesize hasNew              = _hasNew;

@synthesize orderBannerId, orderListShowType, orderShowType, orderSceneShowType, pingceBannerId, pingceShowType, pingceSceneShowType, pingceListShowType;
@synthesize pingceHasNew;
@synthesize isInShareViewController;
@synthesize downloadings;
@synthesize books;

+ (DownloadManager *)downloadManager {
    if (downloadManager == nil) {
        downloadManager = [[DownloadManager alloc] init];
    }
    return downloadManager;
}

+ (DataEngine *)sharedDataEngine
{
	@synchronized(dataEngine) {
		if (!dataEngine) {
			dataEngine = [[self alloc] init];
		}
	}
	return dataEngine;
}

- (BOOL)isLogin
{
    BOOL result = NO;
    if (_me) {
        result = YES;
    } else {
        result = NO;
    }
    return result;
}

- (DataEngine *)init
{
	self = [super init];
    if (self) {    
        [self initDataEngineProperty];
        orderListShowType = kTreasureListShowTypeList;
        orderShowType = kMenuActionTypeSence;
        orderSceneShowType = kTileShowType123;
        _adIsHide = NO;
        isInShareWebViewController = NO;
        _searchResultItems = [[NSMutableArray alloc] init];
        downloadings = [[NSMutableArray alloc] init];
        books = [[NSMutableArray alloc] init];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(networkReachable:) 
                                                     name:@"NetworkReachable"
                                                   object:nil];        
        [self doSomeThingAfterDataEngineCreate];
    }
	return self;
}

- (void)initDataEngineProperty
{
    UIDevice *device = [UIDevice currentDevice];
    _uuid = [[NSMutableString alloc] initWithFormat:@"%@", [device uniqueGlobalDeviceIdentifier]];
    [_uuid replaceOccurrencesOfString:@"-" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [_uuid length])];
    
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:4];
    [result addObject:[NSString stringWithFormat:@"%02d", (unsigned int)[[_uuid substringWithRange:NSMakeRange(0, 4)] UTF8String] % 100]];
    [result addObject:[NSString stringWithFormat:@"%02d", (unsigned int)[[_uuid substringWithRange:NSMakeRange(4, 4)] UTF8String] % 100]];
    [result addObject:[NSString stringWithFormat:@"%02d", (unsigned int)[[_uuid substringWithRange:NSMakeRange(8, 4)] UTF8String] % 100]];
    [result addObject:[NSString stringWithFormat:@"%02d", (unsigned int)[[_uuid substringWithRange:NSMakeRange(12, 4)] UTF8String] % 100]];
    [result addObject:[NSString stringWithFormat:@"%02d", (unsigned int)[[_uuid substringWithRange:NSMakeRange(16, 4)] UTF8String] % 100]];
    [result addObject:[NSString stringWithFormat:@"%02d", (unsigned int)[[_uuid substringWithRange:NSMakeRange(20, 4)] UTF8String] % 100]];
    [result addObject:[NSString stringWithFormat:@"%02d", (unsigned int)[[_uuid substringWithRange:NSMakeRange(24, 4)] UTF8String] % 100]];
    [result addObject:[NSString stringWithFormat:@"%02d", (unsigned int)[[_uuid substringWithRange:NSMakeRange(28, 4)] UTF8String] % 100]];
    NSMutableString *imei = [NSMutableString stringWithString:[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@", [result objectAtIndex:0], [result objectAtIndex:1], [result objectAtIndex:2], [result objectAtIndex:3], [result objectAtIndex:4], [result objectAtIndex:5], [result objectAtIndex:6], [result objectAtIndex:7]]];
    _sid = [NSString stringWithFormat:@"t%@", [imei substringWithRange:NSMakeRange(0, 15)]];
    _hasRetinaDisplay = [device hasRetinaDisplay];
    
    _sourceDict = [[NSMutableDictionary alloc] initWithCapacity:4];
    if([[NSUserDefaults standardUserDefaults] valueForKey:APPINREVIEW]) {
        _appInReview = [[[NSUserDefaults standardUserDefaults] valueForKey:APPINREVIEW] boolValue];
    } else {
        _appInReview = YES;
    }
    [self getLocalData];
}

- (void)getLocalData
{
    @try {
        [self loadData];
    }
    @catch (NSException *exception) {
        [self clearLocalDataAll];
    }
}

- (void)clearLocalDataAll
{
    [LocalSettings clearLocalData];
    _segmentBannerIds = nil;
    _tileItems = nil;
    _categories = nil;
    _catItems = nil;
    _favories = nil;
    _searchHistory = nil;
    _searchResultItems = nil;
    _hasNew = nil;
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:CATEGORYVERSION];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:BANNERVERSION];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)doSomeThingAfterDataEngineCreate
{
    [self checkVersion:nil];
    
    //自动登录
    if (_me && [_me oauthes]) {
        OAuth *oauth = [[_me oauthes] objectForKey:[NSNumber numberWithInt:kOAuthTypeSinaWeibo]];
        if (oauth) {
            [self oauthLogin:oauth followZb:0 isAutoLogin:YES from:nil];
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setDouble:[[NSDate date] timeIntervalSince1970] forKey:LASTINTOFOREGROUND];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)doSomeThingAfterLogin:(BOOL)isAutoLogin
{
    if (!isAutoLogin) {
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [self apns:delegate.token from:nil];
    }
   
    [LocalSettings saveMe:_me];
    _weiboEngine = [[SinaWeibo alloc] initWithAppKey:SINA_APPKEY appSecret:SINA_SECRET appRedirectURI:SINA_CALLBACK andDelegate:self];
    SinaOAuth *oauth = [[_me oauthes] objectForKey:[NSNumber numberWithInt:kOAuthTypeSinaWeibo]];
    
    _weiboEngine.accessToken = oauth.token;
    _weiboEngine.expirationDate = oauth.expiredIn;
    _weiboEngine.userID = oauth.authId;
}

- (void)doSomeThingAfterLogout
{
    _me = nil;
    [LocalSettings saveMe:_me];
    [_weiboEngine logOut];
}

- (void)saveData
{
    [LocalSettings saveTreasures:_treasures];
    [LocalSettings saveCategories:_categories];
    [LocalSettings saveSegmentBannerIds:_segmentBannerIds];
    [LocalSettings saveBanners:_banners];
    [LocalSettings saveFavorites:_favories];
    [LocalSettings saveSearchHistory:_searchHistory];
    [LocalSettings saveHasNew:_hasNew];
}

- (void)loadData
{
    NSDictionary *dicts = nil;
    dicts = [LocalSettings loadTreasures];
    if(dicts) {
        _treasures = [[NSMutableDictionary alloc] initWithDictionary:dicts];
    } else {
        _treasures = [[NSMutableDictionary alloc] initWithCapacity:4];
    }
    dicts = [LocalSettings loadCatItems];
    if(dicts) {
        _catItems = [[NSMutableDictionary alloc] initWithDictionary:dicts];
    } else {
        _catItems = [[NSMutableDictionary alloc] initWithCapacity:4];
    }
    dicts = [LocalSettings loadTileItems];
    if(dicts) {
        _tileItems = [[NSMutableDictionary alloc] initWithDictionary:dicts];
    } else {
        _tileItems = [[NSMutableDictionary alloc] initWithCapacity:4];
    }

    dicts = [LocalSettings loadBannerItems];
    if(dicts) {
        _bannerItems = [[NSMutableDictionary alloc] initWithDictionary:dicts];
    } else {
        _bannerItems = [[NSMutableDictionary alloc] initWithCapacity:4];
    }
    dicts = [LocalSettings loadBanners];
    if(dicts) {
        _banners = [[NSMutableDictionary alloc] initWithDictionary:dicts];
    } else {
        _banners = [[NSMutableDictionary alloc] initWithCapacity:4];
    }
    
    _menu = [LocalSettings loadMenu];
    _segmentBannerIds = [LocalSettings loadSegmentBannerIds];
    
    NSArray *arrays = nil;
    arrays = [LocalSettings loadFavorites];
    if(arrays) {
        _favories = [[NSMutableArray alloc] initWithArray:arrays];
    } else {
        _favories = [[NSMutableArray alloc] initWithCapacity:4];
    }
    arrays = [LocalSettings loadCategories];
    if(arrays) {
        _categories = [[NSMutableArray alloc] initWithArray:arrays];
    } else {
        _categories = [[NSMutableArray alloc] initWithCapacity:1];
    }
    
    _me = [LocalSettings loadMe];
    
    arrays = [LocalSettings loadSearchHistory];
    if(arrays) {
        _searchHistory = [[NSMutableArray alloc] initWithArray:arrays];
    } else {
        _searchHistory = [[NSMutableArray alloc] initWithCapacity:1];
    }
    arrays = [LocalSettings loadHasNew];
    if(arrays) {
        _hasNew = [[NSMutableArray alloc] initWithArray:arrays];
    } else {
        _hasNew = [[NSMutableArray alloc] initWithCapacity:1];
    }
    self.orderBannerId = [[[NSUserDefaults standardUserDefaults] valueForKey:@"orderBannerId"] intValue];
    self.orderShowType = [[[NSUserDefaults standardUserDefaults] valueForKey:@"orderShowType"] intValue];
    self.orderSceneShowType = [[[NSUserDefaults standardUserDefaults] valueForKey:@"orderSceneShowType"] intValue];
    self.orderListShowType = [[[NSUserDefaults standardUserDefaults] valueForKey:@"orderListShowType"] intValue];
    self.pingceBannerId = [[[NSUserDefaults standardUserDefaults] valueForKey:@"pingceBannerId"] intValue];
    self.pingceShowType = [[[NSUserDefaults standardUserDefaults] valueForKey:@"pingceShowType"] intValue];
    self.pingceListShowType = [[[NSUserDefaults standardUserDefaults] valueForKey:@"pingceListShowType"] intValue];
    self.pingceSceneShowType = [[[NSUserDefaults standardUserDefaults] valueForKey:@"pingceSceneShowType"] intValue];
    self.pingceHasNew = [[[NSUserDefaults standardUserDefaults] valueForKey:@"pingceHasNew"] boolValue];

}

- (void)removeAllImageCaches
{
    NSString *allFileSize = @"0";
    allFileSize = [self removeAllImageByPath:[ImageCacheEngine sharedInstance].imageRootDir];

    NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] init];
    [tmpDict setObject:allFileSize forKey:@"allFileSize"];
    [[NSNotificationCenter defaultCenter] postNotificationName:REMOVE_ALL_IMAGE_CACHES object:tmpDict];
}

- (NSString*)removeAllImageByPath:(NSString*) path
{
    NSString *allFileSize = @"0";
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *fileList = [fileManager contentsOfDirectoryAtPath:path error:nil];
    for (int i=0; i<[fileList count]; i++) {
        NSNumber *fileSize;
        NSString *filePath = [NSString stringWithFormat:@"%@/%@", path, [fileList objectAtIndex:i]];
        NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:filePath error:nil];
        if ((fileSize = [fileAttributes objectForKey:NSFileSize])) {
            allFileSize = [NSString stringWithFormat:@"%lld", ([allFileSize longLongValue] + [fileSize longLongValue])];
        }
        [fileManager removeItemAtPath:filePath error:nil];
    }
    return allFileSize;
}


#pragma mark - Notification

- (void)networkReachable:(NSNotification *)notification 
{
    
}

#pragma mark - API 公共函数

- (NSString *)getAPIRequestString
{
    NSString *request = nil;
    if (_me && _me.session) {
        request = _me.session;
    } else {
        request = _uuid;
    }
    return request;
}

- (void)addTarget:(NSString *)_notification from:(NSString *)_source identifier:(NSString *)_identifier
{
	if ((_notification != nil) && (_identifier != nil)) {
		@synchronized(_sourceDict) {
			NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
								  _notification, NOTIFICATION_NAME,
								  _source,       REQUEST_SOURCE_KEY,
								  nil];
			[_sourceDict setObject:dict forKey:_identifier];
		}
	}
}

- (void)callBack:(NSDictionary *)dict forRequest:(NSString *)identifier
{
    NSDictionary *targetDict = [_sourceDict objectForKey:identifier];
    if (targetDict != nil) {
        NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] initWithDictionary:dict];
        [tmpDict addEntriesFromDictionary:targetDict];    
        
        NSString *source = [targetDict objectForKey:REQUEST_SOURCE_KEY];
        if (source && [source isKindOfClass:[NSString class]] && [source length] > 0) {
			[tmpDict setObject:source forKey:REQUEST_SOURCE_KEY];
		} 		
		NSString *name = [targetDict objectForKey:NOTIFICATION_NAME];
        if (name != nil) {
            [[NSNotificationCenter defaultCenter] postNotificationName:name object:self userInfo:tmpDict];
		} 
    }    
    [_sourceDict removeObjectForKey:identifier];
}

- (void)requestFaild:(NSError *)error with:(NSString *)identifier
{
    NSDictionary *targetDict = [_sourceDict objectForKey:identifier];
    if (targetDict != nil) {
		NSString *name = [targetDict objectForKey:NOTIFICATION_NAME];
		NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] initWithDictionary:targetDict];
        [tmpDict setObject:[NSNumber numberWithInt:[error code]] forKey:RETURN_CODE];
        [tmpDict setObject:[ErrorCodeUtils errorDetailFromErrorCode:[error code]] forKey:TOUI_REQUEST_ERROR_MESSAGE];
        if (name != nil) {
            [[NSNotificationCenter defaultCenter] postNotificationName:name object:self userInfo:tmpDict];				
		}
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"network_error" object:error];
    }
    [_sourceDict removeObjectForKey:identifier];
}

#pragma mark - 获取图片大小和后缀

- (NSString *)getImageSize:(ImageSizeType)type
{
    NSString *result = @"";
    if (type == kImageSizeDetail) {
        if (_hasRetinaDisplay) {
            result = @"600x600";
        } else {
            result = @"300x300";
        }
    } else if (type == kImageSizeThumb) {
        if (_hasRetinaDisplay) {
            result = @"220x220";
        } else {
            result = @"110x110";
        }
    } else if (type == kImageSize22) {
        if (_hasRetinaDisplay) {
            result = @"310x310";
        } else {
            result = @"160x160";
        }
    } else {
        result = @"";
    }
    return result;
}

- (NSString *)getImageUrlByUUID:(NSString *)uuid
{
    NSString *retina = @"";
    if (_hasRetinaDisplay) {
        retina = @"_2x";
    }
    NSString *path = [NSString stringWithFormat:@"%@media/%@/icon%@.jpg", HTTP_REQUEST_RUL, uuid, retina];
    return path;
}

- (NSString *)getPNGImageUrlByUUID:(NSString *)uuid
{
    NSString *retina = @"";
    if (_hasRetinaDisplay) {
        retina = @"_2x";
    }
    NSString *path = [NSString stringWithFormat:@"%@media/%@/icon%@.png", HTTP_REQUEST_RUL, uuid, retina];
    return path;
}

#pragma mark - 获取本地商品数据

- (Treasure *)getTreasureByItemId:(NSNumber *)itemId
{    
    Treasure *result = [_treasures objectForKey:itemId];
    return result;
}

- (void)addFavorieTreasure:(NSNumber *)itemId
{
    if (![_favories containsObject:itemId]) {
        NSMutableArray *favArray = [[NSMutableArray alloc] initWithObjects:itemId, nil];
        [favArray addObjectsFromArray:_favories];
        [LocalSettings saveTreasures:_treasures];
        [LocalSettings saveFavorites:favArray];
        [_favories removeAllObjects];
        [_favories addObjectsFromArray:favArray];
        [favArray removeAllObjects];
        favArray = nil;
    }
}

- (void)removeFavorieTreasure:(NSNumber *)itemId
{
    [_favories removeObject:itemId];
    [LocalSettings saveFavorites:_favories];
}

- (TBSeller *)getTBSellerByNick:(NSString *)nick
{
    TBSeller *seller = nil;
    if (_catSellers) {
        seller = [_catSellers objectForKey:nick];
    }
    return seller;
}

- (MenuItem *)getMenuItemByBarnnerId:(NSNumber *)barnnerId
{
    MenuItem *menuItem = nil;
    if (barnnerId && [barnnerId isKindOfClass:[NSNumber class]]) {
        for (MenuGroup *group in _menu.groups) {
            for (MenuItem *item in group.menuItems) {
                if ([item.bannerId isEqualToNumber:barnnerId]) {
                    menuItem = item;
                    break ;
                }
            }
            if (menuItem) {
                break ;
            }
        }
    }
    return menuItem;
}

#pragma mark - 新浪微博相关方法实现

- (void)sinaWeiboLogin
{
    if (_weiboEngine == nil) {
        _weiboEngine = [[SinaWeibo alloc] initWithAppKey:SINA_APPKEY appSecret:SINA_SECRET appRedirectURI:SINA_CALLBACK andDelegate:self];
    }
    [_weiboEngine logIn];
}

- (void)sinaweiboDidLogIn:(SinaWeibo *)sinaweibo
{
    if (_weiboEngine == sinaweibo) {
        NSLog(@"sinaweiboDidLogIn");
        [_weiboEngine requestWithURL:@"users/show.json"
                              params:[NSMutableDictionary dictionaryWithObject:_weiboEngine.userID forKey:@"uid"]
                          httpMethod:@"GET"
                            delegate:self];
    }
}

- (void)sinaweiboDidLogOut:(SinaWeibo *)sinaweibo
{
    if (_weiboEngine == sinaweibo) {
        NSLog(@"sinaweiboDidLogOut");
    }
}

- (void)sinaweiboLogInDidCancel:(SinaWeibo *)sinaweibo
{
    if (_weiboEngine == sinaweibo) {
        NSLog(@"sinaweiboLogInDidCancel");
        [[NSNotificationCenter defaultCenter] postNotificationName:REQUEST_SINAWEIBOCANCEL object:self];
    }
}

- (void)sinaweibo:(SinaWeibo *)sinaweibo logInDidFailWithError:(NSError *)error
{
    if (_weiboEngine == sinaweibo) {
        NSLog(@"sinaweibo logInDidFailWithError %@", error);
    }
}

- (void)sinaweibo:(SinaWeibo *)sinaweibo accessTokenInvalidOrExpired:(NSError *)error
{
    if (_weiboEngine == sinaweibo) {
        NSLog(@"sinaweiboAccessTokenInvalidOrExpired %@", error);
        [self userLogout:nil];
    }
}

//微博请求成功
- (void)request:(SinaWeiboRequest *)request didFinishLoadingWithResult:(id)result
{
    // 当一个 delegate 需要处理多个请求回调时,可以通过 url 来判断当前的 request
    if ([request.url hasSuffix:@"users/show.json"]) {        
        SinaOAuth *oauth = [OAuthFactory createOAuthByType:kOAuthTypeSinaWeibo];
        oauth.token = _weiboEngine.accessToken;
        oauth.authId = _weiboEngine.userID;
        oauth.tokenSecret = nil;
        oauth.screenName = [result objectForKey:@"screen_name"];
        oauth.avatar = [result objectForKey:@"avatar_large"];
        oauth.weiboAuthDetail = [result objectForKey:@"verified_reason"];
        oauth.expiredIn = _weiboEngine.expirationDate;
        NSString *gender = [result objectForKey:@"gender"];
        if ([gender isEqualToString:@"m"]) {
            oauth.weiboUserSex = @"男";
        } else if ([gender isEqualToString:@"f"]) {
            oauth.weiboUserSex = @"女";
        } else {
            oauth.weiboUserSex = @"未知";
        }
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithCapacity:4];
        [userInfo setObject:[NSNumber numberWithInt:NO_ERROR] forKey:RETURN_CODE];
        [userInfo setObject:oauth forKey:TOUI_PARAM_SINA_USERINFO_OAUTHINFO];
        [[NSNotificationCenter defaultCenter] postNotificationName:REQUEST_SINAWEIBOUSERINFO object:self userInfo:userInfo];
    }
}

//微博请求失败
- (void)request:(SinaWeiboRequest *)request didFailWithError:(NSError *)error
{
    // 当一个 delegate 需要处理多个请求回调时,可以通过 url 来判断当前的 request
    if ([request.url hasSuffix:@"users/show.json"]) {
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithCapacity:4];
        NSString *errorMessage = [ErrorCodeUtils errorDetailFromSinaErrorCode:TSB_ERROR_CODE_SINA_USER_INFO_FAILED];
        [userInfo setObject:[NSNumber numberWithInt:TSB_ERROR_CODE_SINA_USER_INFO_FAILED] forKey:RETURN_CODE];
        [userInfo setObject:errorMessage forKey:TOUI_REQUEST_ERROR_MESSAGE];
        [[NSNotificationCenter defaultCenter] postNotificationName:REQUEST_SINAWEIBOUSERINFO object:self userInfo:userInfo];
        [_weiboEngine logOut];
    }
}

#pragma mark - API 下载图片

- (void)downloadFileReceived:(NSDictionary *)dictionary
                     fileUrl:(NSString *)fileUrl
                        type:(DownloadFileType)type
                        with:(NSString *)identifier
{
//    NSLog(@"download file finished: %@", fileUrl);
    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:4];
    NSData *fileData = [dictionary objectForKey:@"data"]; 
    NSDictionary *targetDict = [_sourceDict objectForKey:identifier];
    if (targetDict != nil) {
        NSString *filePath = [[ImageCacheEngine sharedInstance] setImagePath:fileData forUrl:fileUrl];
        if (filePath) {
            [result setObject:filePath forKey:TOUI_PARAM_DOWNLOADFILE_FILEPATH];
        }
        [result setObject:fileUrl forKey:TOUI_PARAM_DOWNLOADFILE_FILEURL];
        [result setObject:[NSNumber numberWithInt:type] forKey:TOUI_PARAM_DOWNLOADFILE_FILETYPE];
    }    
    [self callBack:result forRequest:identifier];
}

- (void)downloadFileByUrl:(NSString *)url
                     type:(DownloadFileType)type 
                     from:(NSString *)source
{
    @synchronized(_sourceDict) {
        for(NSString *key in _sourceDict){
            NSDictionary *dict = [_sourceDict objectForKey:key];
            NSString *imageIdInProcess = [dict objectForKey:REQUEST_DOWNLOADFILE_URL];
            if (imageIdInProcess != nil && [url isEqualToString:imageIdInProcess]) {
                return;
            }
        }          
    }
    NSLog(@"%@", url);
    NSString *identifier = [HttpEngine doHttpGet:url
                                         timeOut:URL_REQUEST_TIMEOUT
                                          header:nil
                                           error:^(NSError *error, NSString *identifier) {
                                               [self requestFaild:error with:identifier];
                                           }
                                        complete:^(NSDictionary *dictionary, NSString *identifier) {
                                            [self downloadFileReceived:dictionary
                                                               fileUrl:url 
                                                                  type:type
                                                                  with:identifier];
                                        }];
    
    //为了滤重
    if ((REQUEST_DOWNLOADFILE_NOTIFICATION_NAME != nil) && (identifier != nil)) {
		@synchronized(_sourceDict) {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:4];
            if (REQUEST_DOWNLOADFILE_NOTIFICATION_NAME) {
                [dict setObject:REQUEST_DOWNLOADFILE_NOTIFICATION_NAME forKey:NOTIFICATION_NAME];
            }
            if (url) {
                [dict setObject:url forKey:REQUEST_DOWNLOADFILE_URL];
            }
            if (source) {
                [dict setObject:source forKey:REQUEST_SOURCE_KEY];
            }
			[_sourceDict setObject:dict forKey:identifier];
		}
	}
}

#pragma mark - 接口API

- (void)getBannerReceived:(NSDictionary *)dictionary
                     with:(NSString *)identifier
{
    NSData *response = [dictionary objectForKey:@"data"];
    NSDictionary *dict = [JsonUtils JSONObjectWithData:response];
    
    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:4];
    
    NSNumber *returnCode = [dict objectForKey:RETURN_CODE];
    if (returnCode && [returnCode isKindOfClass:[NSNumber class]]) {
        [result setObject:returnCode forKey:RETURN_CODE];
        if ([returnCode intValue] == NO_ERROR) {
            self.segmentBannerIds = nil;
            
            //解析数据
            NSArray *banners = [dict objectForKey:@"banners"];
            NSMutableArray *tempSegmentBanners = [[NSMutableArray alloc] initWithCapacity:4];
            for (NSDictionary *item in banners) {
                Banner *banner = [[Banner alloc] init];
                [DataParse createSegmentBannerByRemoteData:banner remoteData:item];
                if ([item objectForKey:@"banner_id"] && [item objectForKey:@"title"]) {
                    [_banners setObject:banner forKey:banner.bannerId];
                    [tempSegmentBanners addObject:banner.bannerId];
                }
            }
            _segmentBannerIds = [NSArray arrayWithArray:tempSegmentBanners];
            [LocalSettings saveSegmentBannerIds:_segmentBannerIds];
            [LocalSettings saveBanners:_banners];
            id version = [dict objectForKey:@"banner_version"];
            if (version && [version isKindOfClass:[NSNumber class]]) {
                [[NSUserDefaults standardUserDefaults] setValue:version forKey:BANNERVERSION];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        } else {
            [result setObject:[ErrorCodeUtils errorDetailFromErrorCode:[returnCode intValue]] forKey:TOUI_REQUEST_ERROR_MESSAGE];
        }
    } else {
		[result setObject:[NSNumber numberWithInt:TSB_ERROR_CODE_SERVER_ERROR] forKey:RETURN_CODE];
        [result setObject:[ErrorCodeUtils errorDetailFromErrorCode:TSB_ERROR_CODE_SERVER_ERROR] forKey:TOUI_REQUEST_ERROR_MESSAGE];
    }
    [self callBack:result forRequest:identifier];

}

- (void)getBanner:(NSString *)source
{
    NSString *request = [self getAPIRequestString];
    NSString *param = [DataCompose getBanners:[APP_ID intValue]
                                   appVersion:APP_VERSION
                                     inReview:_appInReview];
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:request, @"request", @"banners", @"action", param, @"param", nil];
    NSString *identifier = [HttpEngine doHttpPost:HTTP_REQUEST_RUL
                                          timeOut:URL_REQUEST_TIMEOUT
                                           header:nil
                                             body:params
                                            error:^(NSError *error, NSString *identifier) {
                                                [self requestFaild:error with:identifier];
                                            }
                                         complete:^(NSDictionary *dictionary, NSString *identifier) {
                                             [self getBannerReceived:dictionary with:identifier];
                                         }];
    [self addTarget:REQUEST_GETBANNER from:source identifier:identifier];
}

- (void)getCategoryReceived:(NSDictionary *)dictionary
                       with:(NSString *)identifier
{
    NSData *response = [dictionary objectForKey:@"data"];
    NSDictionary *dict = [JsonUtils JSONObjectWithData:response];
    
    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:4];
    
    NSNumber *returnCode = [dict objectForKey:RETURN_CODE];
    if (returnCode && [returnCode isKindOfClass:[NSNumber class]]) {
        [result setObject:returnCode forKey:RETURN_CODE];
        if ([returnCode intValue] == NO_ERROR) {
            //解析数据
            NSArray *categories = [dict objectForKey:@"category"];
            if (categories && [categories isKindOfClass:[NSArray class]] && [categories count] > 0) {
                NSMutableArray *tempCategories = [[NSMutableArray alloc] initWithCapacity:4];
                for (NSDictionary *item in categories) {
                    Category *category = [[Category alloc] init];
                    [DataParse createCategoryByRemoteData:category remoteData:item];
                    [tempCategories addObject:category];
                }
                _categories = [NSArray arrayWithArray:tempCategories];
                [LocalSettings saveCategories:_categories];
                NSNumber *version = [dict objectForKey:@"version"];
                if(version && [version isKindOfClass:[NSNumber class]]) {
                    [[NSUserDefaults standardUserDefaults] setObject:version forKey:CATEGORYVERSION];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
            }
        } else {
            [result setObject:[ErrorCodeUtils errorDetailFromErrorCode:[returnCode intValue]] forKey:TOUI_REQUEST_ERROR_MESSAGE];
        }
    } else {
		[result setObject:[NSNumber numberWithInt:TSB_ERROR_CODE_SERVER_ERROR] forKey:RETURN_CODE];
        [result setObject:[ErrorCodeUtils errorDetailFromErrorCode:TSB_ERROR_CODE_SERVER_ERROR] forKey:TOUI_REQUEST_ERROR_MESSAGE];
    }
    [self callBack:result forRequest:identifier];
}

- (void)getCategory:(NSString *)source
{
    NSString *request = [self getAPIRequestString];
    NSString *param = [DataCompose getCategory:[APP_ID intValue]
                                    appVersion:APP_VERSION];
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:request, @"request", @"category", @"action", param, @"param", nil];
    NSString *identifier = [HttpEngine doHttpPost:HTTP_REQUEST_RUL
                                          timeOut:URL_REQUEST_TIMEOUT
                                           header:nil
                                             body:params
                                            error:^(NSError *error, NSString *identifier) {
                                                [self requestFaild:error with:identifier];
                                            }
                                         complete:^(NSDictionary *dictionary, NSString *identifier) {
                                             [self getCategoryReceived:dictionary with:identifier];
                                         }];
    [self addTarget:REQUEST_GETCATEGORY from:source identifier:identifier];
}

- (void)getCatItemsReceived:(NSDictionary *)dictionary
                       with:(NSString *)identifier
{
    NSData *response = [dictionary objectForKey:@"data"];
    NSDictionary *dict = [JsonUtils JSONObjectWithData:response];
    
    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:4];
    
    NSNumber *returnCode = [dict objectForKey:RETURN_CODE];
    if (returnCode && [returnCode isKindOfClass:[NSNumber class]]) {
        [result setObject:returnCode forKey:RETURN_CODE];
        if ([returnCode intValue] == NO_ERROR) {
            //解析数据
            NSNumber *cid = [dict objectForKey:@"cid"];
            if (cid && [cid isKindOfClass:[NSNumber class]]) {
                [result setObject:cid forKey:@"cid"];
            }
            NSNumber *current = [dict objectForKey:@"current"];
            if (current && [current isKindOfClass:[NSNumber class]]) {
                [result setObject:current forKey:@"current"];
            }
            
            NSDictionary *data = [dict objectForKey:@"data"];
            if (data && [data isKindOfClass:[NSDictionary class]]) {
                NSMutableArray *array = [_catItems objectForKey:cid];
                if(!array) {
                    array = [[NSMutableArray alloc] initWithCapacity:1];
                }
                NSArray *items = [data objectForKey:@"items"];
                if (items && [items isKindOfClass:[NSArray class]]) {
                    int count = [items count];
                    for (NSDictionary *item in items) {
                        Treasure *treasure = [[Treasure alloc] init];
                        [DataParse createItemDataByRemoteData:treasure remoteData:item];
                        [self.treasures setObject:treasure forKey:treasure.tid];
                        [array addObject:treasure.tid];
                    }
                    [result setObject:[NSNumber numberWithInt:count] forKey:@"count"];
                    if (_catItems == nil) {
                        _catItems = [[NSMutableDictionary alloc] initWithCapacity:4];
                    }
                    [_catItems setObject:array forKey:cid];
                }
            }
        } else {
            [result setObject:[ErrorCodeUtils errorDetailFromErrorCode:[returnCode intValue]] forKey:TOUI_REQUEST_ERROR_MESSAGE];
        }
    } else {
		[result setObject:[NSNumber numberWithInt:TSB_ERROR_CODE_SERVER_ERROR] forKey:RETURN_CODE];
        [result setObject:[ErrorCodeUtils errorDetailFromErrorCode:TSB_ERROR_CODE_SERVER_ERROR] forKey:TOUI_REQUEST_ERROR_MESSAGE];
    }
    [self callBack:result forRequest:identifier];    
}

- (void)getCatItems:(int)size
            current:(int)current
               sort:(TreasureListSort)sort
                cid:(NSNumber *)cid
               from:(NSString *)source
{
    if (current == 0) {
        NSMutableArray *items = [_catItems objectForKey:cid];
        if(items) {
            [items removeAllObjects];
        }
    }
    NSString *request = [self getAPIRequestString];
    NSString *param = [DataCompose getCatItemList:cid
                                             sort:sort
                                             size:size
                                          current:current
                                            appId:[APP_ID intValue]
                                       appVersion:APP_VERSION];
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:request, @"request", @"get_cate_items", @"action", param, @"param", nil];
    NSString *identifier = [HttpEngine doHttpPost:HTTP_REQUEST_RUL
                                          timeOut:URL_REQUEST_TIMEOUT
                                           header:nil
                                             body:params
                                            error:^(NSError *error, NSString *identifier) {
                                                [self requestFaild:error with:identifier];
                                            }
                                         complete:^(NSDictionary *dictionary, NSString *identifier) {
                                             [self getCatItemsReceived:dictionary with:identifier];
                                         }];
    [self addTarget:REQUEST_GETCATITEMS from:source identifier:identifier];
}

- (void)getItemDetailReceived:(NSDictionary *)dictionary 
                        tid:(NSNumber *)tid
                         with:(NSString *)identifier
{
    NSData *response = [dictionary objectForKey:@"data"]; 
    NSDictionary *dict = [JsonUtils JSONObjectWithData:response];
    
    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:4];
    
    NSNumber *returnCode = [dict objectForKey:RETURN_CODE];
    if (returnCode && [returnCode isKindOfClass:[NSNumber class]]) {
        [result setObject:returnCode forKey:RETURN_CODE];
        if ([returnCode intValue] == NO_ERROR) {
            //解析数据
            Treasure *treasure = [_treasures objectForKey:tid];
            TreasureDetail *treasureDetail = [[TreasureDetail alloc] initWithTreasure:treasure];
            [DataParse createTreasureDetailByRemoteData:treasureDetail remoteData:dict];
            [_treasures setObject:treasureDetail forKey:treasureDetail.tid];            
            [result setObject:treasureDetail.tid forKey:TOUI_PARAM_TREASURE_DETAIL_ITEMID];
        } else {
            [result setObject:[ErrorCodeUtils errorDetailFromErrorCode:[returnCode intValue]] forKey:TOUI_REQUEST_ERROR_MESSAGE];
        }
    } else {
		[result setObject:[NSNumber numberWithInt:TSB_ERROR_CODE_SERVER_ERROR] forKey:RETURN_CODE];
        [result setObject:[ErrorCodeUtils errorDetailFromErrorCode:TSB_ERROR_CODE_SERVER_ERROR] forKey:TOUI_REQUEST_ERROR_MESSAGE];
    }
    [self callBack:result forRequest:identifier];
}

- (void)getItemDetail:(NSNumber *)tid
                 from:(NSString *)source
{
    NSString *request = [self getAPIRequestString];
    NSString *param = [DataCompose getItemDetail:tid
                                           appId:[APP_ID intValue]
                                      appVersion:APP_VERSION];
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:request, @"request", @"get_item", @"action", param, @"param", nil];
    NSString *identifier = [HttpEngine doHttpPost:HTTP_REQUEST_RUL
                                          timeOut:URL_REQUEST_TIMEOUT 
                                           header:nil 
                                             body:params
                                            error:^(NSError *error, NSString *identifier) {
                                                [self requestFaild:error with:identifier];
                                            }
                                         complete:^(NSDictionary *dictionary, NSString *identifier) {
                                             [self getItemDetailReceived:dictionary tid:tid with:identifier];
                                         }];
    [self addTarget:REQUEST_GETITEMDETAIL from:source identifier:identifier]; 
}

- (void)getTileItemsReceived:(NSDictionary *)dictionary
                        with:(NSString *)identifier
                      tileId:(NSNumber *)tileId
{
    NSData *response = [dictionary objectForKey:@"data"];
    NSDictionary *dict = [JsonUtils JSONObjectWithData:response];
    
    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:4];
    
    NSNumber *returnCode = [dict objectForKey:RETURN_CODE];
    if (returnCode && [returnCode isKindOfClass:[NSNumber class]]) {
        [result setObject:returnCode forKey:RETURN_CODE];
        if ([returnCode intValue] == NO_ERROR) {
            //解析数据
            NSNumber *current = [dict objectForKey:@"current"];
            if (current && [current isKindOfClass:[NSNumber class]]) {
                [result setObject:current forKey:@"current"];
            }
            NSDictionary *data = [dict objectForKey:@"data"];
            if (data && [data isKindOfClass:[NSDictionary class]]) {
                NSArray *items = [data objectForKey:@"items"];
                if (items && [items isKindOfClass:[NSArray class]]) {
                    NSMutableArray *tileItems = [_tileItems objectForKey:tileId];
                    if (tileItems == nil) {
                        tileItems = [[NSMutableArray alloc] initWithCapacity:4];
                    }
                    for (NSDictionary *item in items) {
                        Treasure *treasure = [[Treasure alloc] init];
                        [DataParse createItemDataByRemoteData:treasure remoteData:item];
                        [self.treasures setObject:treasure forKey:treasure.tid];
                        [tileItems addObject:treasure.tid];
                    }
                    if (_tileItems == nil) {
                        _tileItems = [[NSMutableDictionary alloc] initWithCapacity:4];
                    }
                    [_tileItems setObject:tileItems forKey:tileId];
                    int count = [items count];
                    [result setObject:[NSNumber numberWithInt:count] forKey:@"count"];
                }
            }
            
            NSDictionary *advers = [dict objectForKey:@"advers"];
            if (advers && [advers isKindOfClass:[NSDictionary class]]) {
                Advertise *advertise = [[Advertise alloc] init];
                [DataParse createAdvertise:advertise remoteData:advers];
                [result setObject:advertise forKey:TOUI_PARAM_TILEITEMS_AD];
            }
            
            id dataSwitch = [dict objectForKey:@"data_switch"];
            if (dataSwitch && [dataSwitch isKindOfClass:[NSNumber class]]) {
                [result setObject:dataSwitch forKey:TOUI_PARAM_TILEITEMS_DATASWITCH];
            }
        } else {
            [result setObject:[ErrorCodeUtils errorDetailFromErrorCode:[returnCode intValue]] forKey:TOUI_REQUEST_ERROR_MESSAGE];
        }
    } else {
		[result setObject:[NSNumber numberWithInt:TSB_ERROR_CODE_SERVER_ERROR] forKey:RETURN_CODE];
        [result setObject:[ErrorCodeUtils errorDetailFromErrorCode:TSB_ERROR_CODE_SERVER_ERROR] forKey:TOUI_REQUEST_ERROR_MESSAGE];
    }
    [self callBack:result forRequest:identifier];
}

- (void)getTileItems:(int)size
             current:(int)current
                type:(int)type
                sort:(TreasureListSort)sort
                 cid:(NSNumber *)tileId
                from:(NSString *)source
{
    if (current == 0) {
        [_tileItems removeObjectForKey:tileId];
    }
    NSString *request = [self getAPIRequestString];
    NSString *param = [DataCompose getTileItems:tileId
                                           sort:sort
                                           type:type
                                           size:size
                                        current:current
                                          appId:[APP_ID intValue]
                                     appVersion:APP_VERSION];
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:request, @"request", @"get_tile_items", @"action", param, @"param", nil];
    NSString *identifier = [HttpEngine doHttpPost:HTTP_REQUEST_RUL
                                          timeOut:URL_REQUEST_TIMEOUT
                                           header:nil
                                             body:params
                                            error:^(NSError *error, NSString *identifier) {
                                                [self requestFaild:error with:identifier];
                                            }
                                         complete:^(NSDictionary *dictionary, NSString *identifier) {
                                             [self getTileItemsReceived:dictionary with:identifier tileId:tileId];
                                         }];
    [self addTarget:REQUEST_GETTILEITEMS from:source identifier:identifier];
}

- (void)getBannerItemsReceived:(NSDictionary *)dictionary
                          with:(NSString *)identifier
                      bannerId:(NSNumber *)bannerId
{
    NSData *response = [dictionary objectForKey:@"data"];
    NSDictionary *dict = [JsonUtils JSONObjectWithData:response];
    
    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:4];
    
    NSNumber *returnCode = [dict objectForKey:RETURN_CODE];
    if (returnCode && [returnCode isKindOfClass:[NSNumber class]]) {
        [result setObject:returnCode forKey:RETURN_CODE];
        if ([returnCode intValue] == NO_ERROR) {
            //解析数据
            NSNumber *current = [dict objectForKey:@"current"];
            if (current && [current isKindOfClass:[NSNumber class]]) {
                [result setObject:current forKey:@"current"];
            }
            NSDictionary *data = [dict objectForKey:@"data"];
            if (data && [data isKindOfClass:[NSDictionary class]]) {
                NSArray *items = [data objectForKey:@"items"];
                if (items && [items isKindOfClass:[NSArray class]]) {
                    NSMutableArray *tileItems = [_bannerItems objectForKey:bannerId];
                    if (tileItems == nil) {
                        tileItems = [[NSMutableArray alloc] initWithCapacity:4];
                    }
                    for (NSDictionary *item in items) {
                        Treasure *treasure = [[Treasure alloc] init];
                        [DataParse createItemDataByRemoteData:treasure remoteData:item];
                        [self.treasures setObject:treasure forKey:treasure.tid];
                        [tileItems addObject:treasure.tid];
                    }
                    if (_tileItems == nil) {
                        _tileItems = [[NSMutableDictionary alloc] initWithCapacity:4];
                    }
                    [_bannerItems setObject:tileItems forKey:bannerId];
                    int count = [items count];
                    [result setObject:[NSNumber numberWithInt:count] forKey:@"count"];
                }
            }
            
            NSDictionary *advers = [dict objectForKey:@"advers"];
            if (advers && [advers isKindOfClass:[NSDictionary class]]) {
                Advertise *advertise = [[Advertise alloc] init];
                [DataParse createAdvertise:advertise remoteData:advers];
                [result setObject:advertise forKey:TOUI_PARAM_TILEITEMS_AD];
            }

            id dataSwitch = [dict objectForKey:@"data_switch"];
            if (dataSwitch && [dataSwitch isKindOfClass:[NSNumber class]]) {
                [result setObject:dataSwitch forKey:TOUI_PARAM_TILEITEMS_DATASWITCH];
            }
        } else {
            [result setObject:[ErrorCodeUtils errorDetailFromErrorCode:[returnCode intValue]] forKey:TOUI_REQUEST_ERROR_MESSAGE];
        }
    } else {
		[result setObject:[NSNumber numberWithInt:TSB_ERROR_CODE_SERVER_ERROR] forKey:RETURN_CODE];
        [result setObject:[ErrorCodeUtils errorDetailFromErrorCode:TSB_ERROR_CODE_SERVER_ERROR] forKey:TOUI_REQUEST_ERROR_MESSAGE];
    }
    [self callBack:result forRequest:identifier];
}

- (void)getBannerItems:(int)size
               current:(int)current
                  type:(int)type
                  sort:(TreasureListSort)sort
              bannerId:(NSNumber *)bannerId
                  from:(NSString *)source
{
    if (current == 0) {
        [_bannerItems removeObjectForKey:bannerId];
    }
    NSString *request = [self getAPIRequestString];
    NSString *param = [DataCompose getBannerItems:bannerId
                                             sort:sort
                                             type:type
                                             size:size
                                          current:current
                                            appId:[APP_ID intValue]
                                       appVersion:APP_VERSION];
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:request, @"request", @"get_tile_items", @"action", param, @"param", nil];
    NSString *identifier = [HttpEngine doHttpPost:HTTP_REQUEST_RUL
                                          timeOut:URL_REQUEST_TIMEOUT
                                           header:nil
                                             body:params
                                            error:^(NSError *error, NSString *identifier) {
                                                [self requestFaild:error with:identifier];
                                            }
                                         complete:^(NSDictionary *dictionary, NSString *identifier) {
                                             [self getBannerItemsReceived:dictionary with:identifier bannerId:bannerId];
                                         }];
    [self addTarget:REQUEST_GETBANNERITEMS from:source identifier:identifier];
}

- (void)userLogoutReceived:(NSDictionary *)dictionary with:(NSString *)identifier
{
    NSData *response = [dictionary objectForKey:@"data"];
    NSDictionary *dict = [JsonUtils JSONObjectWithData:response];
    
    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:4];
    
    NSNumber *returnCode = [dict objectForKey:RETURN_CODE];
    if (returnCode && [returnCode isKindOfClass:[NSNumber class]]) {
        [result setObject:returnCode forKey:RETURN_CODE];
        if ([returnCode intValue] == NO_ERROR) {
            [self doSomeThingAfterLogout];
        } else {
            [result setObject:[ErrorCodeUtils errorDetailFromErrorCode:[returnCode intValue]] forKey:TOUI_REQUEST_ERROR_MESSAGE];
        }
    } else {
        [result setObject:[ErrorCodeUtils errorDetailFromErrorCode:TSB_ERROR_CODE_SERVER_ERROR] forKey:TOUI_REQUEST_ERROR_MESSAGE];
    }
    [self callBack:result forRequest:identifier];
}

- (void)userLogout:(NSString *)source
{
    NSString *request = [self getAPIRequestString];
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:request, @"request", @"logout", @"action", nil];
    
    NSString *identifier = [HttpEngine doHttpPost:HTTP_REQUEST_RUL
                                          timeOut:URL_REQUEST_TIMEOUT
                                           header:nil
                                             body:params
                                            error:^(NSError *error, NSString *identifier) {
                                                [self requestFaild:error with:identifier];
                                            }
                                         complete:^(NSDictionary *dictionary, NSString *identifier) {
                                             [self userLogoutReceived:dictionary with:identifier];
                                         }];
    
	[self addTarget:REQUEST_USERLOGOUT from:source identifier:identifier];
}

- (void)oauthLoginReceived:(NSDictionary *)dictionary
                      with:(NSString *)identifier
               isAutoLogin:(BOOL)isAutoLogin
{
    NSData *response = [dictionary objectForKey:@"data"];
    NSDictionary *dict = [JsonUtils JSONObjectWithData:response];
    
    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:4];
    
    NSNumber *returnCode = [dict objectForKey:RETURN_CODE];
    if (returnCode && [returnCode isKindOfClass:[NSNumber class]]) {
        [result setObject:returnCode forKey:RETURN_CODE];
        if ([returnCode intValue] == NO_ERROR) {
            //解析数据
            _me = [[Me alloc] init];
            [DataParse createMeByRemoteData:_me remoteData:dict];
            if ([_me oauthes]) {
                [[_me oauthes] removeAllObjects];
            } else {
                [_me setOauthes:[[NSMutableDictionary alloc] initWithCapacity:4]];
            }
            NSArray *auth = [dict objectForKey:@"oauth"];
            if (auth && [auth isKindOfClass:[NSArray class]] && [auth count] > 0) {
                for (NSDictionary *dictionary in auth) {
                    int type = [[dictionary objectForKey:@"oauth_type"] intValue];
                    OAuth *oauth = [[_me oauthes] objectForKey:[NSNumber numberWithInt:type]];
                    if (!oauth) {
                        oauth = [OAuthFactory createOAuthByType:type];
                    }
                    [DataParse createOAuthByRemoteData:oauth remoteData:dictionary];
                    if (oauth) {
                        [[_me oauthes] setObject:oauth forKey:[NSNumber numberWithInt:oauth.type]];
                    }
                }
            }
            [self doSomeThingAfterLogin:isAutoLogin];
        } else {
            [result setObject:[ErrorCodeUtils errorDetailFromErrorCode:[returnCode intValue]] forKey:TOUI_REQUEST_ERROR_MESSAGE];
        }
    } else {
		[result setObject:[NSNumber numberWithInt:TSB_ERROR_CODE_SERVER_ERROR] forKey:RETURN_CODE];
        [result setObject:[ErrorCodeUtils errorDetailFromErrorCode:TSB_ERROR_CODE_SERVER_ERROR] forKey:TOUI_REQUEST_ERROR_MESSAGE];
    }
    [self callBack:result forRequest:identifier];
}

- (void)oauthLogin:(OAuth *)oauth
          followZb:(int)followZb
       isAutoLogin:(BOOL)isAutoLogin
              from:(NSString *)source
{    
    NSString *param = [DataCompose oauthLogin:[APP_ID intValue]
                                   appVersion:APP_VERSION
                                         type:oauth.type
                                        token:oauth.token
                                  tokenSecret:oauth.tokenSecret
                                       userId:oauth.authId
                                         name:oauth.screenName
                                 refreshToken:oauth.refreshToken
                                       avatar:oauth.avatar
                                     followZb:followZb
                                    expiredIn:[oauth isMemberOfClass:[SinaOAuth class]] ? ((SinaOAuth *)oauth).expiredIn : nil];
    NSString *timeStamp = [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970]];
    NSString *beforeSig = [[NSString alloc] initWithFormat:@"%@%@%@", APP_TOKEN, timeStamp, param];
    NSString *sig = [[beforeSig md5] lowercaseString];
    
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:timeStamp, @"request", @"oauth_login", @"action", sig, @"sig", param, @"param", nil];
    
    NSString *identifier = [HttpEngine doHttpPost:HTTP_REQUEST_RUL
                                          timeOut:URL_REQUEST_TIMEOUT
                                           header:nil
                                             body:params
                                            error:^(NSError *error, NSString *identifier) {
                                                [self requestFaild:error with:identifier];
                                             }
                                         complete:^(NSDictionary *dictionary, NSString *identifier) {
                                             [self oauthLoginReceived:dictionary with:identifier isAutoLogin:isAutoLogin];
                                         }];
    [self addTarget:REQUEST_OAUTHLOGIN from:source identifier:identifier];  
}

- (void)shareReceived:(NSDictionary *)dictionary with:(NSString *)identifier
{
    NSData *response = [dictionary objectForKey:@"data"];
    NSDictionary *dict = [JsonUtils JSONObjectWithData:response];
    
    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:4];
    
    NSNumber *returnCode = [dict objectForKey:RETURN_CODE];
    if (returnCode && [returnCode isKindOfClass:[NSNumber class]]) {
        [result setObject:returnCode forKey:RETURN_CODE];
        if ([returnCode intValue] == NO_ERROR) {
            
        } else {
            [result setObject:[ErrorCodeUtils errorDetailFromErrorCode:[returnCode intValue]] forKey:TOUI_REQUEST_ERROR_MESSAGE];
        }
    } else {
		[result setObject:[NSNumber numberWithInt:TSB_ERROR_CODE_SERVER_ERROR] forKey:RETURN_CODE];
        [result setObject:[ErrorCodeUtils errorDetailFromErrorCode:TSB_ERROR_CODE_SERVER_ERROR] forKey:TOUI_REQUEST_ERROR_MESSAGE];
    }
    [self callBack:result forRequest:identifier];
}

- (void)share:(int)shareType
   treasureId:(NSNumber *)treasureId
  description:(NSString *)desc
         link:(NSString *)link 
         from:(NSString *)source
{
    NSString *param = [DataCompose share:shareType
                              treasureId:treasureId
                             description:desc
                                   appId:[APP_ID intValue]
                              appVersion:APP_VERSION
                                    link:link];
    NSString *request = [self getAPIRequestString];
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:request, @"request", @"share_web", @"action", param, @"param", nil];
    NSString *identifier = [HttpEngine doHttpPost:HTTP_REQUEST_RUL
                                          timeOut:URL_REQUEST_TIMEOUT
                                           header:nil
                                             body:params
                                            error:^(NSError *error, NSString *identifier) {
                                                [self requestFaild:error with:identifier];
                                            }
                                         complete:^(NSDictionary *dictionary, NSString *identifier) {
                                             [self shareReceived:dictionary with:identifier];
                                         }];
    [self addTarget:REQUEST_SHARETOWEB from:source identifier:identifier];
}

- (void)getTilesReceived:(NSDictionary *)dictionary
                    with:(NSString *)identifier
                bannerId:(NSNumber *)bannerId
{
    NSData *response = [dictionary objectForKey:@"data"];
    NSDictionary *dict = [JsonUtils JSONObjectWithData:response];
    
    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:4];
    
    NSNumber *returnCode = [dict objectForKey:RETURN_CODE];
    if (returnCode && [returnCode isKindOfClass:[NSNumber class]]) {
        [result setObject:returnCode forKey:RETURN_CODE];
        if ([returnCode intValue] == NO_ERROR) {
            //解析数据
            Banner *existBanner = [self getBannerById:bannerId];
            NSString *bannerTitle = [dict objectForKey:@"banner_title"];
            NSArray *tiles = [dict objectForKey:@"tiles"];
            if (tiles && [tiles isKindOfClass:[NSArray class]]) {
                if (existBanner == nil) {
                    existBanner = [[Banner alloc] init];
                    if (bannerTitle && [bannerTitle isKindOfClass:[NSString class]] && ![bannerTitle isEqualToString:@""]) {
                        existBanner.title = bannerTitle;
                    }
                    existBanner.bannerId = bannerId;
                    [_banners setObject:existBanner forKey:existBanner.bannerId];

//                    if (bannerId) {
//                        [_banners setObject:existBanner forKey:existBanner.bannerId];
//                    } else {
//                        if (dataType && [dataType intValue] == kTileDataTypePingCe) {
//                            [_banners setObject:existBanner forKey:BARNNER_PINGCE];
//                        }
//                        if (dataType && [dataType intValue] == kTileDataTypeDaofu) {
//                            [_banners setObject:existBanner forKey:BARNNER_DAOFU];
//                        }
//                    }
                    
                } 
                if (existBanner.items == nil) {
                    existBanner.items = [[NSMutableArray alloc] initWithCapacity:4];
                }
                int count = [tiles count];
                for (NSDictionary *item in tiles) {
                    Tile *tile = [[Tile alloc] init];
                    [DataParse createTileByRemoteData:tile remoteData:item];
                    if ([existBanner.items containsObject:tile]) {
                        NSInteger index = [existBanner.items indexOfObject:tile];
                        [existBanner.items replaceObjectAtIndex:index withObject:tile];
                    } else {
                        [existBanner.items addObject:tile];
                    }
                }
                [result setObject:[NSNumber numberWithInt:count] forKey:@"count"];
            }
        } else {
            [result setObject:[ErrorCodeUtils errorDetailFromErrorCode:[returnCode intValue]] forKey:TOUI_REQUEST_ERROR_MESSAGE];
        }
    } else {
		[result setObject:[NSNumber numberWithInt:TSB_ERROR_CODE_SERVER_ERROR] forKey:RETURN_CODE];
        [result setObject:[ErrorCodeUtils errorDetailFromErrorCode:TSB_ERROR_CODE_SERVER_ERROR] forKey:TOUI_REQUEST_ERROR_MESSAGE];
    }
    [self callBack:result forRequest:identifier];
}

- (void)getTile:(int)size
        current:(int)current
       bannerId:(NSNumber *)bannerId
       dataType:(NSNumber *)dataType
           from:(NSString *)source
{
    if (current == 0) {
        Banner *existBanner = [self getBannerById:bannerId];
        if (existBanner && existBanner.items) {
            [existBanner.items removeAllObjects];
        }
    }
    NSString *request = [self getAPIRequestString];
    NSString *param = [DataCompose getTiles:bannerId
                                   dataType:dataType
                                       size:size
                                    current:current
                                      appId:[APP_ID intValue]
                                 appVersion:APP_VERSION
                                   inReview:_appInReview];
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:request, @"request", @"tiles", @"action", param, @"param", nil];
    NSString *identifier = [HttpEngine doHttpPost:HTTP_REQUEST_RUL
                                          timeOut:URL_REQUEST_TIMEOUT
                                           header:nil
                                             body:params
                                            error:^(NSError *error, NSString *identifier) {
                                                [self requestFaild:error with:identifier];
                                            }
                                         complete:^(NSDictionary *dictionary, NSString *identifier) {
                                             [self getTilesReceived:dictionary
                                                               with:identifier
                                                           bannerId:bannerId];
                                         }];
    [self addTarget:REQUEST_GETTILE from:source identifier:identifier];
}

- (Banner *)getBannerById:(NSNumber *)bannerId
{
    Banner *result = nil;
    if (bannerId) {
        result = [_banners objectForKey:bannerId];
    }
    return result;
}

- (void)addbanner:(Banner *)banner
{
    if (banner && banner.bannerId) {
        [_banners setObject:banner forKey:banner.bannerId];
        [LocalSettings saveBanners:_banners];
    }
}

- (void)getBooksReceived:(NSDictionary *)dictionary
                    with:(NSString *)identifier
{
    NSData *response = [dictionary objectForKey:@"data"];
    NSDictionary *dict = [JsonUtils JSONObjectWithData:response];
    
    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:4];
    
    NSNumber *returnCode = [dict objectForKey:RETURN_CODE];
    if (returnCode && [returnCode isKindOfClass:[NSNumber class]]) {
        [result setObject:returnCode forKey:RETURN_CODE];
        if ([returnCode intValue] == NO_ERROR) {
            if (!books) {
                books = [[NSMutableArray alloc] init];
            }
            [books removeAllObjects];
            //解析数据
            NSArray *booksArray = [dict objectForKey:@"data"];
            for (int i=0; i<[booksArray count]; i++) {
                Book *bookItem = [[Book alloc] init];
                NSDictionary *bookItemDict = [booksArray objectAtIndex:i];
                [DataParse createBook:bookItem remoteData:bookItemDict];
                [books addObject:bookItem];
            }
            NSLog(@"books:%@", books);
        } else {
            [result setObject:[ErrorCodeUtils errorDetailFromErrorCode:[returnCode intValue]] forKey:TOUI_REQUEST_ERROR_MESSAGE];
        }
    } else {
		[result setObject:[NSNumber numberWithInt:TSB_ERROR_CODE_SERVER_ERROR] forKey:RETURN_CODE];
        [result setObject:[ErrorCodeUtils errorDetailFromErrorCode:TSB_ERROR_CODE_SERVER_ERROR] forKey:TOUI_REQUEST_ERROR_MESSAGE];
    }
    [self callBack:result forRequest:identifier];

}

- (void)getBooks:(int)current
            size:(int)size
            from:(NSString *) source
{
    NSString *request = [self getAPIRequestString];
    NSString *param = [DataCompose getBooks:[APP_ID intValue]
                                 appVersion:APP_VERSION
                                    current:[NSNumber numberWithInt:current]
                                       size:[NSNumber numberWithInt:size]];
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:request, @"request", @"get_books", @"action", param, @"param", nil];
    NSString *identifier = [HttpEngine doHttpPost:HTTP_REQUEST_RUL
                                          timeOut:URL_REQUEST_TIMEOUT
                                           header:nil
                                             body:params
                                            error:^(NSError *error, NSString *identifier) {
                                                [self requestFaild:error with:identifier];
                                            }
                                         complete:^(NSDictionary *dictionary, NSString *identifier) {
                                             [self getBooksReceived:dictionary
                                                               with:identifier];
                                         }];
    [self addTarget:REQUEST_GETBOOKS from:source identifier:identifier];
}

#pragma mark - 系统 API

// 设定apns数据
- (void)apnsRecieved:(NSDictionary *)dictionary with:(NSString *)identifier
{
    NSData *response = [dictionary objectForKey:@"data"]; 
    NSDictionary *dict = [JsonUtils JSONObjectWithData:response];
    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:4];
    NSNumber *returnCode = [dict objectForKey:RETURN_CODE];
    if (returnCode && [returnCode isKindOfClass:[NSNumber class]]) {
        [result setObject:returnCode forKey:RETURN_CODE];
        if ([returnCode intValue] == NO_ERROR) {
            //do nothing
        } else {
            [result setObject:[ErrorCodeUtils errorDetailFromErrorCode:[returnCode intValue]] forKey:TOUI_REQUEST_ERROR_MESSAGE];
        }
    } else {
        [result setObject:[NSNumber numberWithInt:TSB_ERROR_CODE_SERVER_ERROR] forKey:RETURN_CODE];
        [result setObject:[ErrorCodeUtils errorDetailFromErrorCode:TSB_ERROR_CODE_SERVER_ERROR] forKey:TOUI_REQUEST_ERROR_MESSAGE];
    }
    [self callBack:result forRequest:identifier];
}

- (void)apns:(NSString *)token from:(NSString *)source
{    
    NSString *request = [self getAPIRequestString];
    NSString *param = [DataCompose apns:token
                             appVersion:APP_VERSION
                                  appId:[APP_ID intValue]
                                   imei:_uuid];
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:request, @"request", @"apns", @"action", param, @"param", nil];
    NSString *identifier = [HttpEngine doHttpPost:HTTP_REQUEST_RUL
                                          timeOut:URL_REQUEST_TIMEOUT 
                                           header:nil 
                                             body:params
                                            error:^(NSError *error, NSString *identifier) {
                                                [self requestFaild:error with:identifier];
                                            }
                                         complete:^(NSDictionary *dictionary, NSString *identifier) {
                                             [self apnsRecieved:dictionary with:identifier];
                                         }];
    
	[self addTarget:REQUEST_APNS from:source identifier:identifier];  
}

//版本
- (void)checkVersionReceived:(NSDictionary *)dictionary
                        with:(NSString *)identifier
{
    NSData *response = [dictionary objectForKey:@"data"];
    NSDictionary *dict = [JsonUtils JSONObjectWithData:response];
    
    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:4];
    
    NSNumber *returnCode = [dict objectForKey:RETURN_CODE];
    if (returnCode && [returnCode isKindOfClass:[NSNumber class]]) {
        [result setObject:returnCode forKey:RETURN_CODE];
        if ([returnCode intValue] == NO_ERROR) {
            NSNumber *umeng = [dict objectForKey:@"umeng"];
            BOOL shutDownUmeng = ![umeng boolValue];
            [[NSUserDefaults standardUserDefaults] setBool:shutDownUmeng forKey:ShutDownUmeng];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            NSNumber *isInReview = [dict objectForKey:@"in_review"];
            if (isInReview && [isInReview isKindOfClass:[NSNumber class]]) {
                _appInReview = [isInReview boolValue];
                [[NSUserDefaults standardUserDefaults] setBool:_appInReview forKey:APPINREVIEW];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
            NSString *version = [dict objectForKey:@"version"];
            if (version && [version compare:APP_VERSION] == NSOrderedDescending) {
                NSString *upgradeUrl = [dict objectForKey:@"url"];
                NSString *upgradeLog = [dict objectForKey:@"log"];
                RIButtonItem *cancelItem = [RIButtonItem item];
                cancelItem.label = NSLocalizedString(@"不升级，使用旧版", @"");
                cancelItem.action = ^{
                };
                
                RIButtonItem *okItem = [RIButtonItem item];
                okItem.label = NSLocalizedString(@"立即升级", @"");
                okItem.action = ^{
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:upgradeUrl]];
                };
                
                if (!(upgradeLog && [upgradeLog isKindOfClass:[NSString class]] && [upgradeLog length] > 0)) {
                    upgradeLog = NSLocalizedString(@"发现新版本，是否更新？", @"");
                }
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"系统通知", @"")
                                                                message:upgradeLog
                                                       cancelButtonItem:cancelItem
                                                       otherButtonItems:okItem, nil];
                [alert show];
            }
            [[NSUserDefaults standardUserDefaults] setObject:APP_VERSION forKey:LASTAPPLAUNCHVERSION];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            //tile版本
            NSNumber *tileVersion = [dict objectForKey:@"banner_version"];
            if (tileVersion && [tileVersion isKindOfClass:[NSNumber class]]) {
                NSNumber *current = [[NSUserDefaults standardUserDefaults] objectForKey:BANNERVERSION];
                if (current && [current isKindOfClass:[NSNumber class]]) {
                    if (![tileVersion isEqualToNumber:current]) {
                        [self getBanner:@""];
                    }
                } else {
                    [self getBanner:@""];
                }
            }
            
            //分类版本
            NSNumber *categoryVersion = [dict objectForKey:@"category_version"];
            if (categoryVersion && [categoryVersion isKindOfClass:[NSNumber class]]) {
                NSNumber *current = [[NSUserDefaults standardUserDefaults] objectForKey:CATEGORYVERSION];
                if (current && [current isKindOfClass:[NSNumber class]]) {
                    if (![categoryVersion isEqualToNumber:current]) {
                        [self getCategory:@""];
                    }
                } else {
                    [self getCategory:@""];
                }
            }
            
            //首页广告版本
            NSNumber *adverVersion = [dict objectForKey:@"adver_version"];
            if (adverVersion && [adverVersion isKindOfClass:[NSNumber class]]) {
                NSNumber *current = [[NSUserDefaults standardUserDefaults] objectForKey:ADVERSION];
                if (current && [current isKindOfClass:[NSNumber class]]) {
                    if (![adverVersion isEqualToNumber:current]) {
                        [self getAdvertise:nil];
                    }
                } else {
                    [self getAdvertise:nil];
                }
            }
            
            //菜单版本
            NSNumber *menuVersion = [dict objectForKey:@"menu_version"];
            if (menuVersion && [menuVersion isKindOfClass:[NSNumber class]]) {
                NSNumber *current = [[NSUserDefaults standardUserDefaults] objectForKey:MENUVERSION];
                if (current && [current isKindOfClass:[NSNumber class]]) {
                    if (![menuVersion isEqualToNumber:current]) {
                        [self getMenu:nil];
                    }
                } else {
                    [self getMenu:nil];
                }
            }

            //分享摸版版本
            NSNumber *shareTemplateVersion = [dict objectForKey:@"share_template_version"];
            if (shareTemplateVersion && [shareTemplateVersion isKindOfClass:[NSNumber class]]) {
                NSNumber *current = [[NSUserDefaults standardUserDefaults] objectForKey:SHARETEMPLATEVERSION];
                if (current && [current isKindOfClass:[NSNumber class]]) {
                    if (![shareTemplateVersion isEqualToNumber:current]) {
                        [self getShareTemplate:nil];
                    }
                } else {
                    [self getShareTemplate:nil];
                }
            }
            
            _buyButtonText = [dict objectForKey:@"buy_txt"];
            _shareButtonText = [dict objectForKey:@"share_txt"];
            
            // 可配的首页
            NSNumber *menuBannerIdVersion = [dict objectForKey:@"menu_banner_id"];
            if (menuBannerIdVersion && [menuBannerIdVersion isKindOfClass:[NSNumber class]]) {
                NSNumber *currentId = [[NSUserDefaults standardUserDefaults] objectForKey:MENUBANNERIDVERSION];
                
                [[NSUserDefaults standardUserDefaults] setValue:menuBannerIdVersion forKey:MENUBANNERIDVERSION];
                [[NSUserDefaults standardUserDefaults] synchronize];
                if (currentId && [currentId isKindOfClass:[NSNumber class]]) {
                    if (![menuBannerIdVersion isEqualToNumber:currentId]) {
                        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                        [delegate variableHomePage:menuBannerIdVersion];
                    }
                }
            } else {
                [[NSUserDefaults standardUserDefaults] setValue:nil forKey:MENUBANNERIDVERSION];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            [self clickMenu:[[NSUserDefaults standardUserDefaults] objectForKey:MENUBANNERIDVERSION]];
            
            // 书籍密码
            NSString *bookSecret = [dict objectForKey:@"book_secret"];
            if (bookSecret && [bookSecret length] > 0) {
                [[NSUserDefaults standardUserDefaults] setValue:bookSecret forKey:BOOK_SECRET];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
            // 下载书籍是否需要的登录
            NSNumber *needLogin = [dict objectForKey:@"need_login"];
            if (needLogin && [needLogin isKindOfClass:[NSNumber class]]) {
                [[NSUserDefaults standardUserDefaults] setBool:[needLogin boolValue] forKey:DOWNLOAD_BOOK_NEED_LOGIN];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        } else {
            [result setObject:[ErrorCodeUtils errorDetailFromErrorCode:[returnCode intValue]] forKey:TOUI_REQUEST_ERROR_MESSAGE];
        }
    } else {
        [result setObject:[NSNumber numberWithInt:TSB_ERROR_CODE_SERVER_ERROR] forKey:RETURN_CODE];
        [result setObject:[ErrorCodeUtils errorDetailFromErrorCode:TSB_ERROR_CODE_SERVER_ERROR] forKey:TOUI_REQUEST_ERROR_MESSAGE];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:APPLICATIONCANCONFIGFINISHED object:nil];
    }

    [self callBack:result forRequest:identifier];
}

- (void)checkVersion:(NSString *)source
{
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    NSString *request = [self getAPIRequestString];
    NSString *param = [DataCompose checkNewVersion:[APP_ID intValue]
                                        appVersion:APP_VERSION
                                         userAgent:APP_USER_AGENT
                                              imei:_uuid
                                            device:[[UIDevice currentDevice] model]
                                                OS:[[UIDevice currentDevice] systemVersion]
                                           network:[delegate networkStatus]];
    
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:request, @"request", @"version", @"action", param, @"param", nil];
    NSString *identifier = [HttpEngine doHttpPost:HTTP_REQUEST_RUL
                                          timeOut:URL_REQUEST_TIMEOUT
                                           header:nil
                                             body:params
                                            error:^(NSError *error, NSString *identifier) {
                                                [self requestFaild:error with:identifier];
                                            }
                                         complete:^(NSDictionary *dictionary, NSString *identifier) {
                                             [self checkVersionReceived:dictionary with:identifier];
                                         }];
    
	[self addTarget:REQUEST_CHECKVERSION from:source identifier:identifier];
}

// 反馈
- (void)feedbackReceived:(NSDictionary *)dictionary
                      with:(NSString *)identifier
{
    NSData *response = [dictionary objectForKey:@"data"];
    NSDictionary *dict = [JsonUtils JSONObjectWithData:response];
    
    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:4];
    
    NSNumber *returnCode = [dict objectForKey:RETURN_CODE];
    if (returnCode && [returnCode isKindOfClass:[NSNumber class]]) {
        [result setObject:returnCode forKey:RETURN_CODE];
        if ([returnCode intValue] == NO_ERROR) {
            //do nothing
        } else {
            [result setObject:[ErrorCodeUtils errorDetailFromErrorCode:[returnCode intValue]] forKey:TOUI_REQUEST_ERROR_MESSAGE];
        }
    } else {
        [result setObject:[NSNumber numberWithInt:TSB_ERROR_CODE_SERVER_ERROR] forKey:RETURN_CODE];
        [result setObject:[ErrorCodeUtils errorDetailFromErrorCode:TSB_ERROR_CODE_SERVER_ERROR] forKey:TOUI_REQUEST_ERROR_MESSAGE];
    }
    [self callBack:result forRequest:identifier];
}

- (void)feedback:(NSString *)content email:(NSString *)email from:(NSString *)source
{    
    NSString *request = [self getAPIRequestString];
    NSString *param = [DataCompose feedback:[APP_ID intValue]
                                 appVersion:APP_VERSION
                                       imei:_uuid
                                      email:email
                                   feedback:content];
    
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:request, @"request", @"feedback", @"action", param, @"param", nil];
    NSString *identifier = [HttpEngine doHttpPost:HTTP_REQUEST_RUL
                                          timeOut:URL_REQUEST_TIMEOUT
                                           header:nil
                                             body:params
                                            error:^(NSError *error, NSString *identifier) {
                                                [self requestFaild:error with:identifier];
                                            }
                                         complete:^(NSDictionary *dictionary, NSString *identifier) {
                                             [self feedbackReceived:dictionary with:identifier];
                                         }];
    
	[self addTarget:REQUEST_FEEDBACK from:source identifier:identifier];    
}

- (void)advertisReceived:(NSDictionary *)dictionary
                    with:(NSString *)identifier
{
    NSData *response = [dictionary objectForKey:@"data"];
    NSDictionary *dict = [JsonUtils JSONObjectWithData:response];
    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:4];
    NSNumber *returnCode = [dict objectForKey:RETURN_CODE];
    if (returnCode && [returnCode isKindOfClass:[NSNumber class]]) {
        [result setObject:returnCode forKey:RETURN_CODE];
        if ([returnCode intValue] == NO_ERROR) {
            //解析广告
            id ads = [dict objectForKey:@"advers"];
            if (ads && [ads isKindOfClass:[NSArray class]] && [ads count] > 0) {
                if ([ads count] <= 1) {
                    // 如果返回的广告数量<1,代表没有广告,清空
                    // 如果返回的广告数量=1,代表只有分享时显示的广告,也清空
                    [LocalSettings saveAdvertise:nil];
                }
                NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:4];
                for (NSDictionary *advertiseData in ads) {
                    if (advertiseData && [advertiseData isKindOfClass:[NSDictionary class]]) {
                        NSNumber *type = [advertiseData objectForKey:@"type"];
                        switch ([type intValue]) {
                            case kAdvertiseBanner:
                            {
                                Advertise *advertise = [[Advertise alloc] init];
                                [DataParse createAdvertise:advertise remoteData:advertiseData];
                                [tempArray addObject:advertise];
                                [LocalSettings saveAdvertise:tempArray];
                            }
                                break;
                            case kAdvertiseShare:
                                _shareViewAdvertise = [advertiseData objectForKey:@"uuid"];
                                break;
                            default:
                                break;
                        }
                    }
                }
                id version = [dict objectForKey:@"adver_version"];
                if (version && [version isKindOfClass:[NSNumber class]]) {
                    [[NSUserDefaults standardUserDefaults] setValue:version forKey:ADVERSION];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
            } else {
                [LocalSettings saveAdvertise:nil];
            }
        } else {
            [result setObject:[ErrorCodeUtils errorDetailFromErrorCode:[returnCode intValue]] forKey:TOUI_REQUEST_ERROR_MESSAGE];
        }
    } else {
        [result setObject:[NSNumber numberWithInt:TSB_ERROR_CODE_SERVER_ERROR] forKey:RETURN_CODE];
        [result setObject:[ErrorCodeUtils errorDetailFromErrorCode:TSB_ERROR_CODE_SERVER_ERROR] forKey:TOUI_REQUEST_ERROR_MESSAGE];
    }
    [self callBack:result forRequest:identifier];
}

- (void)getAdvertise:(NSString *)source
{
    NSString *request = [self getAPIRequestString];
    NSString *param = [DataCompose advertising:[APP_ID intValue]
                                    appVersion:APP_VERSION
                                      inReview:_appInReview];
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:request, @"request", @"advertising", @"action", param, @"param", nil];
    NSString *identifier = [HttpEngine doHttpPost:HTTP_REQUEST_RUL
                                          timeOut:URL_REQUEST_TIMEOUT
                                           header:nil
                                             body:params
                                            error:^(NSError *error, NSString *identifier) {
                                                [self requestFaild:error with:identifier];
                                            }
                                         complete:^(NSDictionary *dictionary, NSString *identifier) {
                                             [self advertisReceived:dictionary with:identifier];
                                         }];
    
	[self addTarget:REQUEST_ADVERTISE from:source identifier:identifier];
}

- (void)menusReceived:(NSDictionary *)dictionary
                 with:(NSString *)identifier
{
    NSData *response = [dictionary objectForKey:@"data"];
    NSDictionary *dict = [JsonUtils JSONObjectWithData:response];
    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:4];
    NSNumber *returnCode = [dict objectForKey:RETURN_CODE];
    if (returnCode && [returnCode isKindOfClass:[NSNumber class]]) {
        [result setObject:returnCode forKey:RETURN_CODE];
        if ([returnCode intValue] == NO_ERROR) {
            // 是否第一次装载应用
            BOOL isFirstApp = NO;
            if (_menu == nil) {
                isFirstApp = YES;
            }
            
            //解析menus
            id menus = [dict objectForKey:@"menus"];
            if (menus && [menus isKindOfClass:[NSArray class]] && [menus count] > 0) {
                Menu *menu = [[Menu alloc] init];
                [DataParse createMenu:menu remoteData:dict];
                // 删掉所有new提示
                [self.hasNew removeAllObjects];
                [self saveData];
                NSMutableArray *hasNewArray = [[NSMutableArray alloc] init];
                for (int i=0; i<[menu.groups count]; i++) {
                    MenuGroup *menuGroup = [menu.groups objectAtIndex:i];
                    for (int j=0; j<[menuGroup.menuItems count]; j++) {
                        MenuItem *menuItem = [menuGroup.menuItems objectAtIndex:j];
                        if (menuItem.hasNew && ([[NSUserDefaults standardUserDefaults] objectForKey:MENUBANNERIDVERSION] && ![menuItem.bannerId isEqualToNumber:[[NSUserDefaults standardUserDefaults] objectForKey:MENUBANNERIDVERSION]])) {
                            [hasNewArray addObject:menuItem.bannerId];
                        }
                    }
                }
                _hasNew = hasNewArray;
                [LocalSettings saveHasNew:hasNewArray];
                // 发出一个通知，有更新
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_HAS_NEW object:nil];
                _menu = menu;
                if (isFirstApp) {
                    NSNumber *menuBannerIdVersion = [[NSUserDefaults standardUserDefaults] objectForKey:MENUBANNERIDVERSION];
                    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                    [delegate variableHomePage:menuBannerIdVersion];
                }
                [LocalSettings saveMenu:menu];
                id version = [dict objectForKey:@"menu_version"];
                if (version && [version isKindOfClass:[NSNumber class]]) {
                    [[NSUserDefaults standardUserDefaults] setValue:version forKey:MENUVERSION];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
            }
        } else {
            [result setObject:[ErrorCodeUtils errorDetailFromErrorCode:[returnCode intValue]] forKey:TOUI_REQUEST_ERROR_MESSAGE];
        }
    } else {
        [result setObject:[NSNumber numberWithInt:TSB_ERROR_CODE_SERVER_ERROR] forKey:RETURN_CODE];
        [result setObject:[ErrorCodeUtils errorDetailFromErrorCode:TSB_ERROR_CODE_SERVER_ERROR] forKey:TOUI_REQUEST_ERROR_MESSAGE];
    }
    [self callBack:result forRequest:identifier];
}

- (void)getMenu:(NSString *)source
{
    NSString *request = [self getAPIRequestString];
    NSString *param = [DataCompose getMenus:[APP_ID intValue]
                                 appVersion:APP_VERSION
                                   inReview:_appInReview];
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:request, @"request", @"menus", @"action", param, @"param", nil];
    NSString *identifier = [HttpEngine doHttpPost:HTTP_REQUEST_RUL
                                          timeOut:URL_REQUEST_TIMEOUT
                                           header:nil
                                             body:params
                                            error:^(NSError *error, NSString *identifier) {
                                                [self requestFaild:error with:identifier];
                                            }
                                         complete:^(NSDictionary *dictionary, NSString *identifier) {
                                             [self menusReceived:dictionary with:identifier];
                                         }];
    
	[self addTarget:REQUEST_MENUS from:source identifier:identifier];
}

- (void)shareTemplateReceived:(NSDictionary *)dictionary
                         with:(NSString *)identifier
{
    NSData *response = [dictionary objectForKey:@"data"];
    NSDictionary *dict = [JsonUtils JSONObjectWithData:response];
    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:4];
    NSNumber *returnCode = [dict objectForKey:RETURN_CODE];
    if (returnCode && [returnCode isKindOfClass:[NSNumber class]]) {
        [result setObject:returnCode forKey:RETURN_CODE];
        if ([returnCode intValue] == NO_ERROR) {
            id templates = [dict objectForKey:@"templates"];
            if (templates && [templates isKindOfClass:[NSArray class]] && [templates count] > 0) {
                NSMutableArray *shareTemplates = [[NSMutableArray alloc] initWithCapacity:4];
                for (NSDictionary *shareTemplateData in templates) {
                    ShareTemplate *template = [[ShareTemplate alloc] init];
                    [DataParse createShareTemplate:template remoteData:shareTemplateData];
                    [shareTemplates addObject:template];
                }
                [LocalSettings saveShareTemplates:shareTemplates];
                id version = [dict objectForKey:@"version"];
                if (version && [version isKindOfClass:[NSNumber class]]) {
                    [[NSUserDefaults standardUserDefaults] setValue:version forKey:SHARETEMPLATEVERSION];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
            }
        } else {
            [result setObject:[ErrorCodeUtils errorDetailFromErrorCode:[returnCode intValue]] forKey:TOUI_REQUEST_ERROR_MESSAGE];
        }
    } else {
        [result setObject:[NSNumber numberWithInt:TSB_ERROR_CODE_SERVER_ERROR] forKey:RETURN_CODE];
        [result setObject:[ErrorCodeUtils errorDetailFromErrorCode:TSB_ERROR_CODE_SERVER_ERROR] forKey:TOUI_REQUEST_ERROR_MESSAGE];
    }
    [self callBack:result forRequest:identifier];
}

- (void)getShareTemplate:(NSString *)source
{
    NSString *request = [self getAPIRequestString];
    NSString *param = [DataCompose shareTemplate:[APP_ID intValue]
                                      appVersion:APP_VERSION
                                        inReview:_appInReview];
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:request, @"request", @"share_template", @"action", param, @"param", nil];
    NSString *identifier = [HttpEngine doHttpPost:HTTP_REQUEST_RUL
                                          timeOut:URL_REQUEST_TIMEOUT
                                           header:nil
                                             body:params
                                            error:^(NSError *error, NSString *identifier) {
                                                [self requestFaild:error with:identifier];
                                            }
                                         complete:^(NSDictionary *dictionary, NSString *identifier) {
                                             [self shareTemplateReceived:dictionary with:identifier];
                                         }];
    
	[self addTarget:REQUEST_SHARETEMPLATE from:source identifier:identifier];
}

//- (void)discountReceived:(NSDictionary *)dictionary
//                    with:(NSString *)identifier
//{
//    NSData *response = [dictionary objectForKey:@"data"];
//    NSDictionary *dict = [JsonUtils JSONObjectWithData:response];
//    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:4];
//    NSNumber *returnCode = [dict objectForKey:RETURN_CODE];
//    if (returnCode && [returnCode isKindOfClass:[NSNumber class]]) {
//        [result setObject:returnCode forKey:RETURN_CODE];
//        if ([returnCode intValue] == NO_ERROR) {
//            NSDictionary *data = [dict objectForKey:@"data"];
//            if (data && [data isKindOfClass:[NSDictionary class]]) {
//                NSArray *items = [data objectForKey:@"items"];
//                if (items && [items isKindOfClass:[NSArray class]]) {
//                    NSMutableArray *tileItems = [[NSMutableArray alloc] initWithCapacity:4];
//                    for (NSDictionary *item in items) {
//                        Treasure *treasure = [[Treasure alloc] init];
//                        [DataParse createItemDataByRemoteData:treasure remoteData:item];
//                        [self.treasures setObject:treasure forKey:treasure.tid];
//                        [tileItems addObject:treasure.tid];
//                    }
//                    [result setObject:tileItems forKey:@"discountList"];
//                    int count = [items count];
//                    [result setObject:[NSNumber numberWithInt:count] forKey:@"count"];
//                }
//            }
//        } else {
//            [result setObject:[ErrorCodeUtils errorDetailFromErrorCode:[returnCode intValue]] forKey:TOUI_REQUEST_ERROR_MESSAGE];
//        }
//    } else {
//        [result setObject:[NSNumber numberWithInt:TSB_ERROR_CODE_SERVER_ERROR] forKey:RETURN_CODE];
//        [result setObject:[ErrorCodeUtils errorDetailFromErrorCode:TSB_ERROR_CODE_SERVER_ERROR] forKey:TOUI_REQUEST_ERROR_MESSAGE];
//    }
//    [self callBack:result forRequest:identifier];
//}
//
//- (void)getDiscountItems:(NSString *)source
//{
//    NSString *request = [self getAPIRequestString];
//    NSString *param = [DataCompose getDiscountItems:[APP_ID intValue]
//                                         appVersion:APP_VERSION];
//    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:request, @"request", @"coupon", @"action", param, @"param", nil];
//    NSString *identifier = [HttpEngine doHttpPost:HTTP_REQUEST_RUL
//                                          timeOut:URL_REQUEST_TIMEOUT
//                                           header:nil
//                                             body:params
//                                            error:^(NSError *error, NSString *identifier) {
//                                                [self requestFaild:error with:identifier];
//                                            }
//                                         complete:^(NSDictionary *dictionary, NSString *identifier) {
//                                             [self discountReceived:dictionary with:identifier];
//                                         }];
//	[self addTarget:REQUEST_DISCOUNT from:source identifier:identifier];
//}

- (void)getTBSellerInfoReceived:(NSDictionary *)dictionary
                           nick:(NSString *)nick
                           with:(NSString *)identifier
{
    NSData *response = [dictionary objectForKey:@"data"];
    NSDictionary *dict = [JsonUtils JSONObjectWithData:response];
    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:4];
    NSNumber *returnCode = [dict objectForKey:RETURN_CODE];
    if (returnCode && [returnCode isKindOfClass:[NSNumber class]]) {
        [result setObject:returnCode forKey:RETURN_CODE];
        if ([returnCode intValue] == NO_ERROR) {
            TBSeller *seller = [[TBSeller alloc] init];
            [DataParse createTBSeller:seller remoteData:[dict objectForKey:@"data"]];
            seller.nick = nick;
            if (_catSellers == nil) {
                _catSellers = [[NSMutableDictionary alloc] init];
            }
            if (seller.nick && [seller.nick length] > 0) {
                [_catSellers setObject:seller forKey:seller.nick];
            }
            // [result setObject:seller forKey:TOUI_PARAM_TB_SELLER_INFO];
        } else {
            [result setObject:[ErrorCodeUtils errorDetailFromErrorCode:[returnCode intValue]] forKey:TOUI_REQUEST_ERROR_MESSAGE];
        }
    } else {
        [result setObject:[NSNumber numberWithInt:TSB_ERROR_CODE_SERVER_ERROR] forKey:RETURN_CODE];
        [result setObject:[ErrorCodeUtils errorDetailFromErrorCode:TSB_ERROR_CODE_SERVER_ERROR] forKey:TOUI_REQUEST_ERROR_MESSAGE];
    }
    [self callBack:result forRequest:identifier];
}

- (void)getTBSellerInfo:(NSString *)sellerName
                   from:(NSString *)source
{
    NSString *request = [self getAPIRequestString];
    NSString *param = [DataCompose getTBSellerInfo:sellerName
                                             appId:[APP_ID intValue]
                                        appVersion:APP_VERSION];
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:request, @"request", @"get_user_info", @"action", param, @"param", nil];
    NSString *identifier = [HttpEngine doHttpPost:HTTP_REQUEST_RUL
                                          timeOut:URL_REQUEST_TIMEOUT
                                           header:nil
                                             body:params
                                            error:^(NSError *error, NSString *identifier) {
                                                [self requestFaild:error with:identifier];
                                            }
                                         complete:^(NSDictionary *dictionary, NSString *identifier) {
                                             [self getTBSellerInfoReceived:dictionary nick:sellerName with:identifier];
                                         }];
    
    [self addTarget:REQUEST_TBSELLERINFO from:source identifier:identifier];
}

- (void)getOtherItemsReceived:(NSDictionary *)dictionary
                         with:(NSString *)identifier
{
    NSData *response = [dictionary objectForKey:@"data"];
    NSDictionary *dict = [JsonUtils JSONObjectWithData:response];
    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:4];
    NSNumber *returnCode = [dict objectForKey:RETURN_CODE];
    if (returnCode && [returnCode isKindOfClass:[NSNumber class]]) {
        [result setObject:returnCode forKey:RETURN_CODE];
        if ([returnCode intValue] == NO_ERROR) {
            // otherItems
            NSArray *items = [dict objectForKey:@"items"];
            int count = [items count];
            if (items && [items isKindOfClass:[NSArray class]] && count > 0) {
                NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:count];
                for (NSDictionary *dic in items) {
                    Treasure *otherItem = [[Treasure alloc] init];
                    [DataParse createOtherItem:otherItem remoteData:dic];
                    [array addObject:otherItem];
                }
                [result setObject:array forKey:TOUI_PARAM_OTHER_ITEMS];
            }
        } else {
            [result setObject:[ErrorCodeUtils errorDetailFromErrorCode:[returnCode intValue]] forKey:TOUI_REQUEST_ERROR_MESSAGE];
        }
    } else {
        [result setObject:[NSNumber numberWithInt:TSB_ERROR_CODE_SERVER_ERROR] forKey:RETURN_CODE];
        [result setObject:[ErrorCodeUtils errorDetailFromErrorCode:TSB_ERROR_CODE_SERVER_ERROR] forKey:TOUI_REQUEST_ERROR_MESSAGE];
    }
    [self callBack:result forRequest:identifier];
}

- (void)getOtherItems:(NSNumber *)treasureId
                 from:(NSString *)source
{
    NSString *request = [self getAPIRequestString];
    NSString *param = [DataCompose getOtherItems:treasureId
                                           appId:[APP_ID intValue]
                                      appVersion:APP_VERSION];
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:request, @"request", @"get_other_items", @"action", param, @"param", nil];
    NSString *identifier = [HttpEngine doHttpPost:HTTP_REQUEST_RUL
                                          timeOut:URL_REQUEST_TIMEOUT
                                           header:nil
                                             body:params
                                            error:^(NSError *error, NSString *identifier) {
                                                [self requestFaild:error with:identifier];
                                            }
                                         complete:^(NSDictionary *dictionary, NSString *identifier) {
                                             [self getOtherItemsReceived:dictionary with:identifier];
                                         }];
    
    [self addTarget:REQUEST_OTHERITEMS from:source identifier:identifier];
}

- (void)replyDiscuss:(NSNumber *)discussId
                nick:(NSString *)nick
             content:(NSString *)content
                from:(NSString *)source
{
    NSString *request = [self getAPIRequestString];
    NSString *param = [DataCompose getReplyDiscuss:[APP_ID intValue]
                                        appVersion:APP_VERSION
                                         discussID:discussId
                                              nick:nick
                                              imei:_uuid
                                           content:content];
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:request, @"request", @"reply_discuss", @"action", param, @"param", nil];
    NSString *identifier = [HttpEngine doHttpPost:HTTP_REQUEST_RUL
                                          timeOut:URL_REQUEST_TIMEOUT
                                           header:nil
                                             body:params
                                            error:^(NSError *error, NSString *identifier) {
                                                [self requestFaild:error with:identifier];
                                            }
                                         complete:^(NSDictionary *dictionary, NSString *identifier) {
                                             [self getReplyDiscuss:dictionary with:identifier];
                                         }];
    
    [self addTarget:REQUEST_REPLYDISCUSS from:source identifier:identifier];
}

- (void)getReplyDiscuss:(NSDictionary *)dictionary
                   with:(NSString *)identifier
{
    NSData *response = [dictionary objectForKey:@"data"];
    NSDictionary *dict = [JsonUtils JSONObjectWithData:response];
    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:4];
    NSNumber *returnCode = [dict objectForKey:RETURN_CODE];
    if (returnCode && [returnCode isKindOfClass:[NSNumber class]]) {
        [result setObject:returnCode forKey:RETURN_CODE];
        if ([returnCode intValue] != NO_ERROR) {
            [result setObject:[ErrorCodeUtils errorDetailFromErrorCode:[returnCode intValue]] forKey:TOUI_REQUEST_ERROR_MESSAGE];
        }
    } else {
        [result setObject:[NSNumber numberWithInt:TSB_ERROR_CODE_SERVER_ERROR] forKey:RETURN_CODE];
        [result setObject:[ErrorCodeUtils errorDetailFromErrorCode:TSB_ERROR_CODE_SERVER_ERROR] forKey:TOUI_REQUEST_ERROR_MESSAGE];
    }
    [self callBack:result forRequest:identifier];
}

- (void)addOrderReceived:(NSDictionary *)dictionary
                   with:(NSString *)identifier
{
    NSData *response = [dictionary objectForKey:@"data"];
    NSDictionary *dict = [JsonUtils JSONObjectWithData:response];
    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:4];
    NSNumber *returnCode = [dict objectForKey:RETURN_CODE];
    if (returnCode && [returnCode isKindOfClass:[NSNumber class]]) {
        [result setObject:returnCode forKey:RETURN_CODE];
        if ([returnCode intValue] != NO_ERROR) {
            [result setObject:[ErrorCodeUtils errorDetailFromErrorCode:[returnCode intValue]] forKey:TOUI_REQUEST_ERROR_MESSAGE];
        }
    } else {
        [result setObject:[NSNumber numberWithInt:TSB_ERROR_CODE_SERVER_ERROR] forKey:RETURN_CODE];
        [result setObject:[ErrorCodeUtils errorDetailFromErrorCode:TSB_ERROR_CODE_SERVER_ERROR] forKey:TOUI_REQUEST_ERROR_MESSAGE];
    }
    [self callBack:result forRequest:identifier];
}

- (void)addOrder:(NSNumber *)itemId
            name:(NSString *)name
          remark:(NSString *)remark
        buyCount:(NSNumber *)buyCount
           phone:(NSString *)phone
         address:(NSString *)address
            from:(NSString *)source
{
    NSString *request = [self getAPIRequestString];
    NSString *param = [DataCompose getAddOrder:[APP_ID intValue]
                                    appVersion:APP_VERSION
                                        itemId:itemId
                                          name:name
                                          imei:_uuid
                                        remark:(!remark || [remark isEqualToString:@""] ? @"" : remark)
                                      buyCount:buyCount
                                         phone:phone
                                       address:address];
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:request, @"request", @"orders", @"action", param, @"param", nil];
    NSString *identifier = [HttpEngine doHttpPost:HTTP_REQUEST_RUL
                                          timeOut:URL_REQUEST_TIMEOUT
                                           header:nil
                                             body:params
                                            error:^(NSError *error, NSString *identifier) {
                                                [self requestFaild:error with:identifier];
                                            }
                                         complete:^(NSDictionary *dictionary, NSString *identifier) {
                                             [self addOrderReceived:dictionary with:identifier];
                                         }];
    
    [self addTarget:REQUEST_ADDORDER from:source identifier:identifier];
}

- (void)searchReceived:(NSDictionary *)dictionary
                    with:(NSString *)identifier
{
    NSData *response = [dictionary objectForKey:@"data"];
    NSDictionary *dict = [JsonUtils JSONObjectWithData:response];
    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:4];
    NSNumber *returnCode = [dict objectForKey:RETURN_CODE];
    if (returnCode && [returnCode isKindOfClass:[NSNumber class]]) {
        [result setObject:returnCode forKey:RETURN_CODE];
        if ([returnCode intValue] == NO_ERROR) {
            //解析数据
            NSNumber *current = [dict objectForKey:@"current"];
            if (current && [current isKindOfClass:[NSNumber class]]) {
                [result setObject:current forKey:@"current"];
            }
            NSDictionary *data = [dict objectForKey:@"data"];
            if (data && [data isKindOfClass:[NSDictionary class]]) {
                NSArray *items = [data objectForKey:@"items"];
                if (items && [items isKindOfClass:[NSArray class]]) {
                    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
                    for (int i=0; i<[items count]; i++) {
                        NSDictionary *item = [items objectAtIndex:i];
                        Treasure *treasure = [[Treasure alloc] init];
                        [DataParse createItemDataByRemoteData:treasure remoteData:item];
                        [self.treasures setObject:treasure forKey:treasure.tid];
                        [resultArray addObject:treasure.tid];
                    }
                    [LocalSettings saveTreasures:self.treasures];
                    if (!self.searchResultItems) {
                        self.searchResultItems = [[NSMutableArray alloc] init];
                    }
                    self.searchResultItems = [NSMutableArray arrayWithArray:[self.searchResultItems arrayByAddingObjectsFromArray:resultArray]];
                    int count = [items count];
                    [result setObject:[NSNumber numberWithInt:count] forKey:@"count"];
                }
            }
        } else {
            [result setObject:[ErrorCodeUtils errorDetailFromErrorCode:[returnCode intValue]] forKey:TOUI_REQUEST_ERROR_MESSAGE];
        }
    } else {
        [result setObject:[NSNumber numberWithInt:TSB_ERROR_CODE_SERVER_ERROR] forKey:RETURN_CODE];
        [result setObject:[ErrorCodeUtils errorDetailFromErrorCode:TSB_ERROR_CODE_SERVER_ERROR] forKey:TOUI_REQUEST_ERROR_MESSAGE];
    }
    [self callBack:result forRequest:identifier];
}

// 搜索
- (void)search:(NSString *)keyword
          sort:(int)sort
       current:(int)current
          size:(int)size
          from:(NSString *)source
{
    NSString *request = [self getAPIRequestString];
    NSString *param = [DataCompose search:[APP_ID intValue]
                               appVersion:APP_VERSION
                                  keyword:keyword
                                     sort:[NSNumber numberWithInt:sort]
                                  current:[NSNumber numberWithInt:current]
                                     size:[NSNumber numberWithInt:size]];
    if (current == 0) {
        [self.searchResultItems removeAllObjects];
        self.searchResultItems = [[NSMutableArray alloc] init];
    }
    if (!self.searchHistory) {
        self.searchHistory = [[NSMutableArray alloc] init];
    } else {
        if (![self.searchHistory containsObject:keyword]) {
            NSMutableArray *searchHistoryArrayTemp = [[NSMutableArray alloc] init];
            [searchHistoryArrayTemp addObject:keyword];
            searchHistoryArrayTemp = [NSMutableArray arrayWithArray:[searchHistoryArrayTemp arrayByAddingObjectsFromArray:self.searchHistory]];
            self.searchHistory = searchHistoryArrayTemp;
            [LocalSettings saveSearchHistory:self.searchHistory];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SEARCH_HISTORY_CHANGE object:nil];
        }
    }
    
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:request, @"request", @"search_category", @"action", param, @"param", nil];
    NSString *identifier = [HttpEngine doHttpPost:HTTP_REQUEST_RUL
                                          timeOut:URL_REQUEST_TIMEOUT
                                           header:nil
                                             body:params
                                            error:^(NSError *error, NSString *identifier) {
                                                [self requestFaild:error with:identifier];
                                            }
                                         complete:^(NSDictionary *dictionary, NSString *identifier) {
                                             [self searchReceived:dictionary with:identifier];
                                         }];
    
    [self addTarget:REQUEST_SEARCH from:source identifier:identifier];
}

- (void)clickMenu:(NSNumber *)bannerId
{
    if (!bannerId) {
        return;
    }
    for (int i=0; i<[self.hasNew count]; i++) {
        NSNumber *newBannerId = [self.hasNew objectAtIndex:i];
        if ([newBannerId longLongValue] == [bannerId longLongValue]) {
            [self.hasNew removeObjectAtIndex:i];
            [LocalSettings saveHasNew:self.hasNew];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_HAS_NEW object:nil];
            return;
        }
    }
}

//- (void)getRecommendItemsReceived:(NSDictionary *)dictionary
//                             with:(NSString *)identifier
//{
//    NSData *response = [dictionary objectForKey:@"data"];
//    NSDictionary *dict = [JsonUtils JSONObjectWithData:response];
//    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:4];
//    NSNumber *returnCode = [dict objectForKey:RETURN_CODE];
//    if (returnCode && [returnCode isKindOfClass:[NSNumber class]]) {
//        [result setObject:returnCode forKey:RETURN_CODE];
//        if ([returnCode intValue] == NO_ERROR) {
//            NSDictionary *data = [dict objectForKey:@"data"];
//            if (data && [data isKindOfClass:[NSDictionary class]]) {
//                NSArray *items = [data objectForKey:@"items"];
//                int count = [items count];
//                if (items && [items isKindOfClass:[NSArray class]] && count > 0) {
//                    _recommendItems = nil;
//                    _recommendItems = [[NSMutableArray alloc] initWithCapacity:count];
//                    for (NSDictionary *dic in items) {
//                        // 推荐数组
//                        Treasure *treasure = [[Treasure alloc] init];
//                        [DataParse createItemDataByRemoteData:treasure remoteData:dic];
//                        [_recommendItems addObject:treasure];
//                        
//                        // 支持推荐页进入详情页可以左右滑动
//                        Treasure *trea = [_treasures objectForKey:[dic objectForKey:@"item_id"]];
//                        if (trea == nil) {
//                            trea = [[Treasure alloc] init];
//                        }
//                        [DataParse createItemDataByRemoteData:trea remoteData:dic];
//                        [_treasures setObject:trea forKey:trea.tid];
//                    }
//                }
//            }
//        } else {
//            [result setObject:[ErrorCodeUtils errorDetailFromErrorCode:[returnCode intValue]] forKey:TOUI_REQUEST_ERROR_MESSAGE];
//        }
//    } else {
//        [result setObject:[NSNumber numberWithInt:TSB_ERROR_CODE_SERVER_ERROR] forKey:RETURN_CODE];
//        [result setObject:[ErrorCodeUtils errorDetailFromErrorCode:TSB_ERROR_CODE_SERVER_ERROR] forKey:TOUI_REQUEST_ERROR_MESSAGE];
//    }
//    [self callBack:result forRequest:identifier];
//}
//
//- (void)getRecommendItems:(NSString *)source
//{
//    NSString *request = [self getAPIRequestString];
//    NSString *param = [DataCompose getRecommends:[APP_ID intValue]
//                                      appVersion:APP_VERSION];
//    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:request, @"request", @"recommend", @"action", param, @"param", nil];
//    NSString *identifier = [HttpEngine doHttpPost:HTTP_REQUEST_RUL
//                                          timeOut:URL_REQUEST_TIMEOUT
//                                           header:nil
//                                             body:params
//                                            error:^(NSError *error, NSString *identifier) {
//                                                [self requestFaild:error with:identifier];
//                                            }
//                                         complete:^(NSDictionary *dictionary, NSString *identifier) {
//                                             [self getRecommendItemsReceived:dictionary with:identifier];
//                                         }];
//    
//	[self addTarget:REQUEST_RECOMMENDITEMS from:source identifier:identifier];
//}

@end
