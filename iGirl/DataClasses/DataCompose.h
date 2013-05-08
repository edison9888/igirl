//
//  DataCompose.h
//  Three Hundred
//
//  Created by skye on 8/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataCompose : NSObject 

+ (NSString *)getBanners:(int)appID
              appVersion:(NSString *)appVersion
                inReview:(BOOL)inReview;

+ (NSString *)getCategory:(int)appID
               appVersion:(NSString *)appVersion;

+ (NSString *)getCatItemList:(NSNumber *)cid
                        sort:(int)sort
                        size:(int)size
                     current:(int)current
                       appId:(int)appID
                  appVersion:(NSString *)appVersion;

+ (NSString *)getTiles:(NSNumber *)bannerId
              dataType:(NSNumber *)dataType
                  size:(int)size
               current:(int)current
                 appId:(int)appID
            appVersion:(NSString *)appVersion
              inReview:(BOOL)inReview;

+ (NSString *)getTileItems:(NSNumber *)tileId
                      sort:(int)sort
                      type:(int)type
                      size:(int)size
                   current:(int)current
                     appId:(int)appID
                appVersion:(NSString *)appVersion;

+ (NSString *)getBannerItems:(NSNumber *)bannerId
                        sort:(int)sort
                        type:(int)type
                        size:(int)size
                     current:(int)current
                       appId:(int)appID
                  appVersion:(NSString *)appVersion;

+ (NSString *)getItemDetail:(NSNumber *)tid
                      appId:(int)appID
                 appVersion:(NSString *)appVersion;

+ (NSString *)share:(int)type
         treasureId:(NSNumber *)treasureId
        description:(NSString *)desc
              appId:(int)appID
         appVersion:(NSString *)appVersion
               link:(NSString *)link;

+ (NSString *)oauthLogin:(int)appId
              appVersion:(NSString *)appVersion
                    type:(int)type
                   token:(NSString *)token
             tokenSecret:(NSString *)tokenSecret
                  userId:(NSString *)userId
                    name:(NSString *)screenName
            refreshToken:(NSString *)refreshToken
                  avatar:(NSString *)avatar
                followZb:(int)followZb
               expiredIn:(NSDate *)expiredIn;

+ (NSString *)apns:(NSString *)token
        appVersion:(NSString *)appVerson
             appId:(int)appId
              imei:(NSString *)imei;

+ (NSString *)checkNewVersion:(int)appID
                   appVersion:(NSString *)appVersion
                    userAgent:(NSString *)userAgent
                         imei:(NSString *)imei
                       device:(NSString *)device
                           OS:(NSString *)OS
                      network:(NSString *)network;

+ (NSString *)feedback:(int)appID
            appVersion:(NSString *)appVersion
                  imei:(NSString *)imei
                 email:(NSString *)email
              feedback:(NSString *)content;

+ (NSString *)advertising:(int)appID
               appVersion:(NSString *)appVersion
                 inReview:(BOOL)inReview;

+ (NSString *)getMenus:(int)appID
            appVersion:(NSString *)appVersion
              inReview:(BOOL)inReview;

+ (NSString *)shareTemplate:(int)appID
                 appVersion:(NSString *)appVersion
                   inReview:(BOOL)inReview;

+ (NSString *)getDiscountItems:(int)appID
                    appVersion:(NSString *)appVersion;

+ (NSString *)getTBSellerInfo:(NSString *)sellerName
                        appId:(int)appID
                   appVersion:(NSString *)appVersion;

+ (NSString *)getOtherItems:(NSNumber *)treasureId
                      appId:(int)appID
                 appVersion:(NSString *)appVersion;

+ (NSString *)getRecommends:(int)appID
                 appVersion:(NSString *)appVersion;

+ (NSString *)getReplyDiscuss:(int)appID
                   appVersion:(NSString *)appVersion
                    discussID:(NSNumber *)discussID
                         nick:(NSString *)nick
                         imei:(NSString *)imei
                      content:(NSString *)content;

+ (NSString *)getAddOrder:(int)appID
               appVersion:(NSString *)appVersion
                   itemId:(NSNumber *)itemId
                     name:(NSString *)name
                     imei:(NSString *)imei
                   remark:(NSString *)remark
                 buyCount:(NSNumber *)buyCount
                    phone:(NSString *)phone
                  address:(NSString *)address;

+ (NSString *)search:(int)appID
          appVersion:(NSString *)appVersion
             keyword:(NSString *)keyword
                sort:(NSNumber *)sort
             current:(NSNumber *)current
                size:(NSNumber *)size;

+ (NSString *)getBooks:(int)appID
            appVersion:(NSString *)appVersion
               current:(NSNumber *)current
                  size:(NSNumber *)size;

@end
