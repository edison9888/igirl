//
//  Constants.h
//  Three Hundred
//
//  Created by skye on 8/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Constants+ErrorCodeDef.h"
#import "Constants+RetrunParamDef.h"
#import "Constants+APIRequest.h"
#import "Constants+NotificationName.h"
#import "Constants+Enum.h"

#define IPJ 1

#define TEST_SERVER 1
#define TEST_ENTERFORGOUND      0
#define TEST_WEIBOEXPIREDIN     0

#define APP_ID                  @"40"
#define APP_VERSION             @"1.0.0"
#define APP_USER_AGENT          @"m15"
#define APP_TOKEN               @"f792f1d1cebc88009b8aca9b1cc5a3c7"

// 引导动画版本号
#define USERGUIDE_VERSION         @"20130424"

#define TAOBAO_TTID             @"400000_21231432@izhoubian_iphone_1.0.3"

#ifdef TEST_SERVER
#define HTTP_REQUEST_RUL                            @"http://tgirl.tshenbian.com/"
#else
#define HTTP_REQUEST_RUL                            @"http://girl.tshenbian.com/"
#endif

#ifdef TEST_SERVER
#define UM_AppKey               @"-1"
#define UM_LabelName            @"-1"
#else
#define UM_AppKey               @"50bf28f752701557f6000023"
#define UM_LabelName            @"LabelName"
#endif

#define APP_ITUNES_ID              @"579858439"
#define APP_RATING_URL             @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=579858439"
#define APP_DOWNLOAD_URL           @"http://itunes.apple.com/app/id579858439?mt=8"

#define SINA_APPKEY             @"3140957945"
#define SINA_SECRET             @"ffd04b48d8ebdb1f88e313eef6900810"
#define SINA_CALLBACK           @"https://api.weibo.com/oauth2/default.html"

// 微信跳转
#ifdef TEST_SERVER
#define WEIXIN_URL      [NSString stringWithFormat:@"http://twap.tshenbian.com/pj/weixin.php?app_id=%@", APP_ID]
#else
#define WEIXIN_URL      [NSString stringWithFormat:@"http://m.tshenbian.com/pj/weixin.php?app_id=%@", APP_ID]
#endif

#define ShutDownUmeng                                   @"shutDownUmeng"
#define LASTAPPLAUNCHVERSION                            @"lastAppLaunchVersion"
#define CATEGORYVERSION                                 @"category_version"
#define BANNERVERSION                                   @"tile_version"
#define ADVERSION                                       @"ad_version"
#define MENUVERSION                                     @"menu_version"
#define SHARETEMPLATEVERSION                            @"share_template_version"
#define MENUBANNERIDVERSION                             @"menu_banner_id_version"
#define APPINREVIEW                                     @"app_in_review"

// 书籍密码
#define BOOK_SECRET                                     @"book_secret"
// 下载书籍提示是否需要登录
#define DOWNLOAD_BOOK_NEED_LOGIN                        @"need_login"


#define LASTINTOFOREGROUND              @"lastIntoForeground"
#define UPDATERELOADDATATIMEINTERVAL    (1*60*60)

#define ERROR_MESSAGE_SHOW_INTERVAL_NORMAL          1.5
#define ERROR_MESSAGE_SHOW_INTERVAL_LONG            2.0

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#define ISPHONE5 (CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) ? YES : NO)
#define isRetina ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? (CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size)  || ISPHONE5) : NO)
