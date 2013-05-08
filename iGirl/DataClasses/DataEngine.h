//
//  DataEngine.h
//  Three Hundred
//
//  Created by skye on 8/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "SinaWeibo.h"
#import "DownloadManager.h"

#define BARNNER_PINGCE      @"barnnerforpingce"
#define BARNNER_DAOFU       @"barnner_daofu"


@class Treasure;
@class OAuth;
@class Me;
@class Banner;
@class Menu;
@class TBSeller;
@class MenuItem;

typedef enum {
    kDownloadFileTypeUnknow = 0,
    kDownloadFileTypeImage = 1,
    kDownloadFileTypeImageAvatar = 2,
} DownloadFileType;

typedef enum {
    kImageSizeThumb = 0,
    kImageSizeDetail = 1,
    kImageSize22 = 2
} ImageSizeType;

typedef enum {
    kSortByCredenceDescending = 0,
    kSortByCredenceAscending = 1,
    kSortBySalesDescending = 2,
    kSortBySalesAscending = 3,
    kSortByPriceDescending = 4,
    kSortByPriceAscending = 5,
} TreasureListSort;

@interface DataEngine : NSObject <SinaWeiboDelegate, SinaWeiboRequestDelegate>
{
    // 是否高清屏
    BOOL                        _hasRetinaDisplay;
    
    // HTTP请求字典
    NSMutableDictionary         *_sourceDict;
    
    // 设备uuid
    NSMutableString             *_uuid;
    
    // 
    NSString                    *_sid;

    // 宝贝字典
    NSMutableDictionary         *_treasures;
    
    // 首页segment数据
    NSArray                     *_segmentBannerIds;
    
    // banner的字典
    NSMutableDictionary         *_banners;
    
    // tile字典
    NSMutableDictionary         *_tileItems;
    
    // banner字典
    NSMutableDictionary         *_bannerItems;
        
    // 类目列表
    NSArray                     *_categories;
    
    // 类目商品字典
    NSMutableDictionary         *_catItems;
    
    // 收藏列表
    NSMutableArray              *_favories;
    
    // 用户个人信息
    Me                          *_me;
    
    //详情页购买文字
    NSString                    *_buyButtonText;
    
    //详情页分享文字
    NSString                    *_shareButtonText;
    
    //分享页面广告图片的UUID
    NSString                    *_shareViewAdvertise;
    
    //菜单
    Menu                        *_menu;
    
    // 新浪微博
    SinaWeibo                   *_weiboEngine;
    
    //app 是否在审核中
    BOOL                        _appInReview;
    
    // 宝贝卖家信息
    NSMutableDictionary         *_catSellers;
    
    // 小编推荐商品
    NSMutableArray              *_recommendItems;
    
    // 是否隐藏广告
    BOOL    _adIsHide;
    
    // 保存货到付款显示类型
    int orderBannerId, orderShowType, orderSceneShowType, orderListShowType;
    // 保存评测显示类型
    int pingceBannerId, pingceShowType, pingceSceneShowType, pingceListShowType;
    BOOL pingceHasNew;
    
    // 搜索结果
    NSMutableArray              *_searchResultItems;
    // 搜索历史
    NSMutableArray              *_searchHistory;
    NSMutableArray              *_hasNew;
    
    // 用于标识是否在详情页
    BOOL isInShareWebViewController;
    
    // 下载书籍列表
    NSMutableArray *downloadings;
    
    // 书籍列表
    NSMutableArray *books;
}

@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, copy) NSString *sid;
@property (nonatomic, retain) NSMutableDictionary *treasures;
@property (nonatomic, retain) NSArray *segmentBannerIds;
@property (nonatomic, retain) NSMutableDictionary *banners;
@property (nonatomic, retain) NSMutableDictionary *tileItems;
@property (nonatomic, retain) NSMutableDictionary *bannerItems;
@property (nonatomic, retain) NSArray *categories;
@property (nonatomic, retain) NSMutableDictionary *catItems;
@property (nonatomic, retain) NSMutableArray *favories;
@property (nonatomic, retain) NSMutableArray *searchResultItems;
@property (nonatomic, retain) NSMutableArray *searchHistory;
@property (nonatomic, retain) NSMutableArray *hasNew;
@property (nonatomic, retain) Me *me;
@property (nonatomic, copy) NSString *buyButtonText;
@property (nonatomic, copy) NSString *shareButtonText;
@property (nonatomic, copy) NSString *shareViewAdvertise;
@property (nonatomic, retain) Menu *menu;
@property (nonatomic, retain) SinaWeibo *weiboEngine;
@property (nonatomic, assign) BOOL appInReview;
@property (nonatomic, retain) NSMutableDictionary *catSellers;
@property (nonatomic, retain) NSMutableArray *recommendItems;
@property (assign) BOOL adIsHide;
@property (assign) int orderBannerId, orderShowType, orderListShowType,orderSceneShowType, pingceBannerId, pingceShowType, pingceSceneShowType, pingceListShowType;
@property (assign) BOOL pingceHasNew;
@property (assign) BOOL isInShareViewController;
@property (nonatomic, retain) NSMutableArray *downloadings;
@property (nonatomic, retain) NSMutableArray *books;

+ (DownloadManager *)downloadManager;
+ (DataEngine *)sharedDataEngine;
- (DataEngine *)init;

- (void)doSomeThingAfterDataEngineCreate;

#pragma mark - 清除缓存

// 删除所有图片缓存
- (void)removeAllImageCaches;

// 根据文件夹删除图片缓存
- (NSString*)removeAllImageByPath:(NSString*) path;

#pragma mark - 获取图片大小和后缀

//获取淘宝图片的全url（加入大小）
- (NSString *)getImageSize:(ImageSizeType)type;

//获取izhoubian服务器图片的全url
- (NSString *)getImageUrlByUUID:(NSString *)uuid;

//获取izhoubian分类图片的全url
- (NSString *)getPNGImageUrlByUUID:(NSString *)uuid;

#pragma mark - 获取本地数据

//保存本地数据
- (void)saveData;

//读取本地数据
- (void)loadData;

//是否登录
- (BOOL)isLogin;

//获取banner
- (Banner *)getBannerById:(NSNumber *)bannerId;

- (void)addbanner:(Banner *)banner;

//获取商品
- (Treasure *)getTreasureByItemId:(NSNumber *)itemId;

//添加喜欢
- (void)addFavorieTreasure:(NSNumber *)itemId;

//取消喜欢
- (void)removeFavorieTreasure:(NSNumber *)itemId;

// 获取淘宝卖家
- (TBSeller *)getTBSellerByNick:(NSString *)nick;

// 根据bannerId获取menuItem
- (MenuItem *)getMenuItemByBarnnerId:(NSNumber *)barnnerId;

#pragma mark - 新浪微博相关方法实现

- (void)sinaWeiboLogin;

#pragma mark - API 下载图片

- (void)downloadFileByUrl:(NSString *)url 
                     type:(DownloadFileType)type 
                     from:(NSString *)source;

#pragma mark - 接口API

//获取首页第一屏数据
- (void)getBanner:(NSString *)source;

//获取类目列表
- (void)getCategory:(NSString *)source;

//获取类目商品列表
- (void)getCatItems:(int)size
            current:(int)current
               sort:(TreasureListSort)sort
                cid:(NSNumber *)cid
               from:(NSString *)source;

//获取商品详情
- (void)getItemDetail:(NSNumber *)tid
                 from:(NSString *)source;

//获取某一banner下的商品
- (void)getTile:(int)size
        current:(int)current
       bannerId:(NSNumber *)bannerId
       dataType:(NSNumber *)dataType
           from:(NSString *)source;

//获取tile商品列表
- (void)getTileItems:(int)size
             current:(int)current
                type:(int)type
                sort:(TreasureListSort)sort
                 cid:(NSNumber *)tileId
                from:(NSString *)source;

//获取banner商品列表
- (void)getBannerItems:(int)size
               current:(int)current
                  type:(int)type
                  sort:(TreasureListSort)sort
              bannerId:(NSNumber *)bannerId
                  from:(NSString *)source;

//注销登录
- (void)userLogout:(NSString *)source;

//oauth登录，新用户为注册
- (void)oauthLogin:(OAuth *)oauth
          followZb:(int)followZb
       isAutoLogin:(BOOL)isAutoLogin
              from:(NSString *)source;

- (void)share:(int)shareType
   treasureId:(NSNumber *)treasureId
  description:(NSString *)desc
         link:(NSString *)link
         from:(NSString *)source;

/*
 *  作用：获取广告
 *  返回：无
 *  参数：source：                请求源
 */
- (void)getAdvertise:(NSString *)source;

/*
 *  作用：获取菜单
 *  返回：无
 *  参数：source：                请求源
 */
- (void)getMenu:(NSString *)source;

/*
 *  作用：获取分享摸版
 *  返回：无
 *  参数：source：                请求源
 */
- (void)getShareTemplate:(NSString *)source;

///*
// *  作用：限时抢购
// *  返回：无
// *  参数：source：                请求源
// */
//- (void)getDiscountItems:(NSString *)source;

/*
 *  作用：获取宝贝的卖家信息
 *  返回：无
 *  参数：sellerName:            卖家昵称
         source:                请求源
 */
- (void)getTBSellerInfo:(NSString *)sellerName
                   from:(NSString *)source;

/*
 *  作用：获取某个商品的相关商品信息
 *  返回：无
 *  参数：treasureId:            此商品ID
         source:                请求源
 */
- (void)getOtherItems:(NSNumber *)treasureId
                 from:(NSString *)source;

///*
// *  作用：获取今日推荐列表
// *  返回：无
// *  source:                请求源
// */
//- (void)getRecommendItems:(NSString *)source;

/*
 *  作用：发布讨论区回复
 *  返回：无
 *  参数：discussId:  讨论主题ID
         nick:       昵称
         content:    内容
         source:     请求源
 */
- (void)replyDiscuss:(NSNumber *)discussId
                nick:(NSString *)nick
             content:(NSString *)content
                from:(NSString *)source;

- (void)addOrder:(NSNumber *)itemId
            name:(NSString *)name
          remark:(NSString *)remark
        buyCount:(NSNumber *)buyCount
           phone:(NSString *)phone
         address:(NSString *)address
            from:(NSString *)source;

// 搜索
- (void)search:(NSString *)keyword
          sort:(int)sort
       current:(int)current
          size:(int)size
          from:(NSString *)source;

// 书列表
- (void)getBooks:(int)current
            size:(int)size
            from:(NSString *) source;

#pragma mark - API 系统API

// 设定apns数据
- (void)apns:(NSString *)token
        from:(NSString *)source;

// 版本更新检查
- (void)checkVersion:(NSString *)source;

// 反馈
- (void)feedback:(NSString *)content
           email:(NSString *)email
            from:(NSString *)source;

// 消掉new
- (void)clickMenu:(NSNumber *)bannerId;
@end
