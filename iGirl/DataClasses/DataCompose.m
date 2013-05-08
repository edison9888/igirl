//
//  DataCompose.m
//  Three Hundred
//
//  Created by skye on 8/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DataCompose.h"
#import "JsonUtils.h"
#import "CLog.h"

@implementation DataCompose

+ (NSString *)getBanners:(int)appID
              appVersion:(NSString *)appVersion
                inReview:(BOOL)inReview
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:4];
    [params setObject:[NSNumber numberWithInt:appID] forKey:@"app_id"];
    [params setObject:[NSNumber numberWithInt:inReview ? 1 : 0] forKey:@"in_review"];
    if (appVersion && [appVersion isKindOfClass:[NSString class]] && [appVersion length]) {
        [params setObject:appVersion forKey:@"app_version"];
    }
    NSString *jsonString = [JsonUtils DataWithJSONObject:params];
    NSLog(@"getBanners : %@", jsonString);
    return jsonString;
}

+ (NSString *)getCategory:(int)appID
               appVersion:(NSString *)appVersion
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:4];
    [params setObject:[NSNumber numberWithInt:appID] forKey:@"app_id"];
    if (appVersion && [appVersion isKindOfClass:[NSString class]] && [appVersion length]) {
        [params setObject:appVersion forKey:@"app_version"];
    }
    NSString *jsonString = [JsonUtils DataWithJSONObject:params];
    NSLog(@"getCategory : %@", jsonString);
    return jsonString;
}

+ (NSString *)getCatItemList:(NSNumber *)cid
                        sort:(int)sort
                        size:(int)size
                     current:(int)current
                       appId:(int)appID
                  appVersion:(NSString *)appVersion
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:4];
    if (cid && [cid isKindOfClass:[NSNumber class]]) {
        [params setObject:cid forKey:@"cid"];
    }
    [params setObject:[NSNumber numberWithInt:sort] forKey:@"sort"];
    [params setObject:[NSNumber numberWithInt:size] forKey:@"size"];
    [params setObject:[NSNumber numberWithInt:current] forKey:@"current"];
    [params setObject:[NSNumber numberWithInt:appID] forKey:@"app_id"];
    if (appVersion && [appVersion isKindOfClass:[NSString class]] && [appVersion length]) {
        [params setObject:appVersion forKey:@"app_version"];
    }
    NSString *jsonString = [JsonUtils DataWithJSONObject:params];
    NSLog(@"getCategoryItems : %@", jsonString);
    return jsonString;    
}

+ (NSString *)getTiles:(NSNumber *)bannerId
              dataType:(NSNumber *)dataType
                  size:(int)size
               current:(int)current
                 appId:(int)appID
            appVersion:(NSString *)appVersion
              inReview:(BOOL)inReview
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:4];
    [params setObject:[NSNumber numberWithInt:inReview ? 1 : 0] forKey:@"in_review"];
    if (bannerId && [bannerId isKindOfClass:[NSNumber class]]) {
        [params setObject:bannerId forKey:@"banner_id"];
    }
    if (dataType && [dataType isKindOfClass:[NSNumber class]]) {
        [params setObject:dataType forKey:@"data_type"];
    }
    [params setObject:[NSNumber numberWithInt:size] forKey:@"size"];
    [params setObject:[NSNumber numberWithInt:current] forKey:@"current"];
    [params setObject:[NSNumber numberWithInt:appID] forKey:@"app_id"];
    if (appVersion && [appVersion isKindOfClass:[NSString class]] && [appVersion length]) {
        [params setObject:appVersion forKey:@"app_version"];
    }
    NSString *jsonString = [JsonUtils DataWithJSONObject:params];
    NSLog(@"getTiles : %@", jsonString);
    return jsonString;
}

+ (NSString *)getTileItems:(NSNumber *)tileId
                      sort:(int)sort
                      type:(int)type
                      size:(int)size
                   current:(int)current
                     appId:(int)appID
                appVersion:(NSString *)appVersion
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:4];
    if (tileId && [tileId isKindOfClass:[NSNumber class]]) {
        [params setObject:tileId forKey:@"tile_id"];
    }
    [params setObject:[NSNumber numberWithInt:sort] forKey:@"sort"];
    [params setObject:[NSNumber numberWithInt:type] forKey:@"type"];
    [params setObject:[NSNumber numberWithInt:size] forKey:@"size"];
    [params setObject:[NSNumber numberWithInt:current] forKey:@"current"];
    [params setObject:[NSNumber numberWithInt:appID] forKey:@"app_id"];
    if (appVersion && [appVersion isKindOfClass:[NSString class]] && [appVersion length]) {
        [params setObject:appVersion forKey:@"app_version"];
    }
    NSString *jsonString = [JsonUtils DataWithJSONObject:params];
    NSLog(@"getTileIiems : %@", jsonString);
    return jsonString;
}

+ (NSString *)getBannerItems:(NSNumber *)bannerId
                        sort:(int)sort
                        type:(int)type
                        size:(int)size
                     current:(int)current
                       appId:(int)appID
                  appVersion:(NSString *)appVersion
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:4];
    if (bannerId && [bannerId isKindOfClass:[NSNumber class]]) {
        [params setObject:bannerId forKey:@"banner_id"];
    }
    [params setObject:[NSNumber numberWithInt:sort] forKey:@"sort"];
    [params setObject:[NSNumber numberWithInt:type] forKey:@"type"];
    [params setObject:[NSNumber numberWithInt:size] forKey:@"size"];
    [params setObject:[NSNumber numberWithInt:current] forKey:@"current"];
    [params setObject:[NSNumber numberWithInt:appID] forKey:@"app_id"];
    if (appVersion && [appVersion isKindOfClass:[NSString class]] && [appVersion length]) {
        [params setObject:appVersion forKey:@"app_version"];
    }
    NSString *jsonString = [JsonUtils DataWithJSONObject:params];
    NSLog(@"getBannerIiems : %@", jsonString);
    return jsonString;
}

+ (NSString *)getItemDetail:(NSNumber *)tid
                      appId:(int)appID
                 appVersion:(NSString *)appVersion
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:5];
    if (tid && [tid isKindOfClass:[NSNumber class]]) {
        [params setObject:tid forKey:@"item_id"];
    }
    [params setObject:[NSNumber numberWithInt:appID] forKey:@"app_id"];
    if (appVersion && [appVersion isKindOfClass:[NSString class]] && [appVersion length]) {
        [params setObject:appVersion forKey:@"app_version"];
    }
    NSString *jsonString = [JsonUtils DataWithJSONObject:params];
    NSLog(@"getItemDetail : %@", jsonString);
    return jsonString;
}

+ (NSString *)share:(int)type
         treasureId:(NSNumber *)treasureId
        description:(NSString *)desc
              appId:(int)appID
         appVersion:(NSString *)appVersion
               link:(NSString *)link
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:5];
    [params setObject:[NSNumber numberWithInt:type] forKey:@"share"];
    if (treasureId && [treasureId isKindOfClass:[NSNumber class]]) {
        [params setObject:treasureId forKey:@"item_id"];
    }
    if (desc && [desc isKindOfClass:[NSString class]] && [desc length] > 0) {
        [params setObject:desc forKey:@"text"];
    }
    [params setObject:[NSNumber numberWithInt:appID] forKey:@"app_id"];
    if (appVersion && [appVersion isKindOfClass:[NSString class]] && [appVersion length]) {
        [params setObject:appVersion forKey:@"app_version"];
    }
    if (link && [link isKindOfClass:[NSString class]] && [link length]) {
        [params setObject:link forKey:@"link"];
    }
    NSString *jsonString = [JsonUtils DataWithJSONObject:params];
    NSLog(@"share : %@", jsonString);
    return jsonString;
}

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
               expiredIn:(NSDate *)expiredIn
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:10];
    [params setObject:[NSNumber numberWithInt:appId] forKey:@"app_id"];
    if (appVersion && [appVersion isKindOfClass:[NSString class]] && [appVersion length] > 0) {
        [params setObject:appVersion forKey:@"app_version"];
    }
    if (avatar && [avatar isKindOfClass:[NSString class]] && [avatar length] > 0) {
        [params setObject:avatar forKey:@"avatar"];
    }
    [params setObject:[NSNumber numberWithInt:type] forKey:@"oauth_type"];
    if (token && [token isKindOfClass:[NSString class]] && [token length] > 0) {
        [params setObject:token forKey:@"oauth_token"];
    }
    if (tokenSecret && [tokenSecret isKindOfClass:[NSString class]] && [tokenSecret length] > 0) {
        [params setObject:tokenSecret forKey:@"oauth_token_secret"];
    }
    if (userId && [userId isKindOfClass:[NSString class]] && [userId length] > 0) {
        [params setObject:userId forKey:@"oauth_uid"];
    }
    if (screenName && [screenName isKindOfClass:[NSString class]] && [screenName length] > 0) {
        [params setObject:screenName forKey:@"screenname"];
    }
    if (refreshToken && [refreshToken isKindOfClass:[NSString class]] && [refreshToken length] > 0) {
        [params setObject:refreshToken forKey:@"refresh_token"];
    }
    [params setObject:[NSNumber numberWithInt:followZb] forKey:@"follow"];
    NSMutableDictionary *info = [[NSMutableDictionary alloc] initWithCapacity:4];
    if (expiredIn && [expiredIn isKindOfClass:[NSDate class]]) {
        [info setObject:[NSNumber numberWithDouble:[expiredIn timeIntervalSince1970]] forKey:@"expired_in"];
    }
    if (info && [info isKindOfClass:[NSMutableDictionary class]]) {
        NSString *infoString = [JsonUtils DataWithJSONObject:info];
        [params setObject:infoString forKey:@"info"];
    }
    NSString *jsonString = [JsonUtils DataWithJSONObject:params];
    NSLog(@"oauthLogin : %@", jsonString);
    return jsonString;
}

+ (NSString *)apns:(NSString *)token
        appVersion:(NSString *)appVerson
             appId:(int)appId
              imei:(NSString *)imei
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc]initWithCapacity:3];
    [params setObject:[NSNumber numberWithInt:appId] forKey:@"app_id"];
    if (token && [token isKindOfClass:[NSString class]] && [token length] > 0) {
        [params setObject:token forKey:@"device"];
    }
    if (appVerson && [appVerson isKindOfClass:[NSString class]] && [appVerson length] > 0) {
        [params setObject:appVerson forKey:@"app_version"];
    }
    if (imei && [imei isKindOfClass:[NSString class]] && [imei length] > 0) {
        [params setObject:imei forKey:@"imei"];
    }
    NSString *jsonString = [JsonUtils DataWithJSONObject:params];
    NSLog(@"apns : %@", jsonString);
    return jsonString;
}

+ (NSString *)checkNewVersion:(int)appID
                   appVersion:(NSString *)appVersion
                    userAgent:(NSString *)userAgent
                         imei:(NSString *)imei
                       device:(NSString *)device
                           OS:(NSString *)OS
                      network:(NSString *)network
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:4];
    [params setObject:[NSNumber numberWithInt:appID] forKey:@"app_id"];
    if (appVersion && [appVersion isKindOfClass:[NSString class]] && [appVersion length]) {
        [params setObject:appVersion forKey:@"app_version"];
    }
    if (userAgent && [userAgent isKindOfClass:[NSString class]] && [userAgent length] > 0) {
        [params setObject:userAgent forKey:@"useragent"];
    }
    if (imei && [imei isKindOfClass:[NSString class]] && [imei length] > 0) {
        [params setObject:imei forKey:@"imei"];
    }
    if (device && [device isKindOfClass:[NSString class]] && [device length] > 0) {
        [params setObject:device forKey:@"device"];
    }
    if (OS && [OS isKindOfClass:[NSString class]] && [OS length] > 0) {
        [params setObject:OS forKey:@"os"];
    }
    if (network && [network isKindOfClass:[NSString class]] && [network length] > 0) {
        [params setObject:network forKey:@"network"];
    }
    NSString *jsonString = [JsonUtils DataWithJSONObject:params];
    NSLog(@"checkNewVersion : %@", jsonString);    
    return jsonString;
}

+ (NSString *)feedback:(int)appID
            appVersion:(NSString *)appVersion
                  imei:(NSString *)imei
                 email:(NSString *)email
              feedback:(NSString *)content
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:4];
    [params setObject:[NSNumber numberWithInt:appID] forKey:@"app_id"];
    
    if (appVersion && [appVersion isKindOfClass:[NSString class]] && [appVersion length]) {
        [params setObject:appVersion forKey:@"app_version"];
    }
    if (imei && [imei isKindOfClass:[NSString class]] && [imei length] > 0) {
        [params setObject:imei forKey:@"imei"];
    }
    if (email && [email isKindOfClass:[NSString class]] && [email length] > 0) {
        [params setObject:email forKey:@"email"];
    }
    if (content && [content isKindOfClass:[NSString class]] && [content length] > 0) {
        [params setObject:content forKey:@"feedback"];
    }
    
    NSString *jsonString = [JsonUtils DataWithJSONObject:params];
    NSLog(@"feedback : %@", jsonString);
    return jsonString;    
}

+ (NSString *)advertising:(int)appID
               appVersion:(NSString *)appVersion
                 inReview:(BOOL)inReview
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:4];
    [params setObject:[NSNumber numberWithInt:appID] forKey:@"app_id"];
    [params setObject:[NSNumber numberWithInt:inReview ? 1 : 0] forKey:@"in_review"];
    if (appVersion && [appVersion isKindOfClass:[NSString class]] && [appVersion length]) {
        [params setObject:appVersion forKey:@"app_version"];
    }
    NSString *jsonString = [JsonUtils DataWithJSONObject:params];
    NSLog(@"advertising : %@", jsonString);
    return jsonString;
}

+ (NSString *)getMenus:(int)appID
            appVersion:(NSString *)appVersion
              inReview:(BOOL)inReview
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:4];
    [params setObject:[NSNumber numberWithInt:appID] forKey:@"app_id"];
    [params setObject:[NSNumber numberWithInt:inReview ? 1 : 0] forKey:@"in_review"];
    if (appVersion && [appVersion isKindOfClass:[NSString class]] && [appVersion length]) {
        [params setObject:appVersion forKey:@"app_version"];
    }
    NSString *jsonString = [JsonUtils DataWithJSONObject:params];
    NSLog(@"getMenus : %@", jsonString);
    return jsonString;
}

+ (NSString *)shareTemplate:(int)appID
                 appVersion:(NSString *)appVersion
                   inReview:(BOOL)inReview
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:4];
    [params setObject:[NSNumber numberWithInt:appID] forKey:@"app_id"];
    [params setObject:[NSNumber numberWithInt:inReview ? 1 : 0] forKey:@"in_review"];
    if (appVersion && [appVersion isKindOfClass:[NSString class]] && [appVersion length]) {
        [params setObject:appVersion forKey:@"app_version"];
    }
    NSString *jsonString = [JsonUtils DataWithJSONObject:params];
    NSLog(@"shareTemplate : %@", jsonString);
    return jsonString;
}

+ (NSString *)getDiscountItems:(int)appID
                    appVersion:(NSString *)appVersion
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:4];
    [params setObject:[NSNumber numberWithInt:appID] forKey:@"app_id"];
    if (appVersion && [appVersion isKindOfClass:[NSString class]] && [appVersion length]) {
        [params setObject:appVersion forKey:@"app_version"];
    }
    NSString *jsonString = [JsonUtils DataWithJSONObject:params];
    NSLog(@"getDiscountItems : %@", jsonString);
    return jsonString;
}

+ (NSString *)getTBSellerInfo:(NSString *)sellerName
                        appId:(int)appID
                   appVersion:(NSString *)appVersion
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:5];
    if (sellerName && [sellerName isKindOfClass:[NSString class]]) {
        [params setObject:sellerName forKey:@"username"];
    }
    [params setObject:[NSNumber numberWithInt:appID] forKey:@"app_id"];
    if (appVersion && [appVersion isKindOfClass:[NSString class]] && [appVersion length]) {
        [params setObject:appVersion forKey:@"app_version"];
    }
    NSString *jsonString = [JsonUtils DataWithJSONObject:params];
    NSLog(@"getTBSellerInfo : %@", jsonString);
    return jsonString;
}

+ (NSString *)getOtherItems:(NSNumber *)treasureId
                      appId:(int)appID
                 appVersion:(NSString *)appVersion
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:5];
    if (treasureId && [treasureId isKindOfClass:[NSNumber class]]) {
        [params setObject:treasureId forKey:@"item_id"];
    }
    [params setObject:[NSNumber numberWithInt:appID] forKey:@"app_id"];
    if (appVersion && [appVersion isKindOfClass:[NSString class]] && [appVersion length]) {
        [params setObject:appVersion forKey:@"app_version"];
    }
    NSString *jsonString = [JsonUtils DataWithJSONObject:params];
    NSLog(@"getOtherItems : %@", jsonString);
    return jsonString;
}

+ (NSString *)getRecommends:(int)appID
                 appVersion:(NSString *)appVersion
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:4];
    [params setObject:[NSNumber numberWithInt:appID] forKey:@"app_id"];
    if (appVersion && [appVersion isKindOfClass:[NSString class]] && [appVersion length]) {
        [params setObject:appVersion forKey:@"app_version"];
    }
    NSString *jsonString = [JsonUtils DataWithJSONObject:params];
    NSLog(@"getRecommends : %@", jsonString);
    return jsonString;
}

+ (NSString *)getReplyDiscuss:(int)appID
                   appVersion:(NSString *)appVersion
                    discussID:(NSNumber *)discussID
                         nick:(NSString *)nick
                         imei:(NSString *)imei
                      content:(NSString *)content
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:5];
    [params setObject:[NSNumber numberWithInt:appID] forKey:@"app_id"];
    if (appVersion && [appVersion isKindOfClass:[NSString class]] && [appVersion length]) {
        [params setObject:appVersion forKey:@"app_version"];
    }
    [params setObject:discussID forKey:@"discuss_id"];
    if (nick && [nick isKindOfClass:[NSString class]]) {
        [params setObject:nick forKey:@"nick"];
    }
    if (imei && [imei isKindOfClass:[NSString class]]) {
        [params setObject:imei forKey:@"imei"];
    }
    if (content && [content isKindOfClass:[NSString class]]) {
        [params setObject:content forKey:@"content"];
    }
    NSString *jsonString = [JsonUtils DataWithJSONObject:params];
    NSLog(@"getReplyDiscuss : %@", jsonString);
    return jsonString;
}

+ (NSString *)getAddOrder:(int)appID
               appVersion:(NSString *)appVersion
                   itemId:(NSNumber *)itemId
                     name:(NSString *)name
                     imei:(NSString *)imei
                   remark:(NSString *)remark
                 buyCount:(NSNumber *)buyCount
                    phone:(NSString *)phone
                  address:(NSString *)address
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:5];
    [params setObject:[NSNumber numberWithInt:appID] forKey:@"app_id"];
    if (appVersion && [appVersion isKindOfClass:[NSString class]] && [appVersion length]) {
        [params setObject:appVersion forKey:@"app_version"];
    }
    [params setObject:itemId forKey:@"item_id"];
    if (name && [name isKindOfClass:[NSString class]]) {
        [params setObject:name forKey:@"name"];
    }
    if (imei && [imei isKindOfClass:[NSString class]]) {
        [params setObject:imei forKey:@"imei"];
    }
    if (imei && [imei isKindOfClass:[NSString class]]) {
        [params setObject:imei forKey:@"imei"];
    }
    if (remark && [remark isKindOfClass:[NSString class]]) {
        [params setObject:remark forKey:@"remark"];
    }
    if (buyCount && [buyCount isKindOfClass:[NSNumber class]]) {
        [params setObject:buyCount forKey:@"buy_count"];
    }
    if (phone && [phone isKindOfClass:[NSString class]]) {
        [params setObject:phone forKey:@"phone"];
    }
    if (address && [address isKindOfClass:[NSString class]]) {
        [params setObject:address forKey:@"address"];
    }
    NSString *jsonString = [JsonUtils DataWithJSONObject:params];
    NSLog(@"getAddOrder : %@", jsonString);
    return jsonString;
}

+ (NSString *)search:(int)appID
          appVersion:(NSString *)appVersion
             keyword:(NSString *)keyword
                sort:(NSNumber *)sort
             current:(NSNumber *)current
                size:(NSNumber *)size
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:5];
    [params setObject:[NSNumber numberWithInt:appID] forKey:@"app_id"];
    if (appVersion && [appVersion isKindOfClass:[NSString class]] && [appVersion length]) {
        [params setObject:appVersion forKey:@"app_version"];
    }
    if (keyword && [keyword isKindOfClass:[NSString class]]) {
        [params setObject:keyword forKey:@"keyword"];
    }
    if (sort && [sort isKindOfClass:[NSNumber class]]) {
        [params setObject:sort forKey:@"sort"];
    }
    if (current && [current isKindOfClass:[NSNumber class]]) {
        [params setObject:current forKey:@"current"];
    }
    if (size && [size isKindOfClass:[NSNumber class]]) {
        [params setObject:size forKey:@"size"];
    }
    NSString *jsonString = [JsonUtils DataWithJSONObject:params];
    NSLog(@"search : %@", jsonString);
    return jsonString;
}


+ (NSString *)getBooks:(int)appID
            appVersion:(NSString *)appVersion
               current:(NSNumber *)current
                  size:(NSNumber *)size
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:5];
    [params setObject:[NSNumber numberWithInt:appID] forKey:@"app_id"];
    if (appVersion && [appVersion isKindOfClass:[NSString class]] && [appVersion length]) {
        [params setObject:appVersion forKey:@"app_version"];
    }
    if (current && [current isKindOfClass:[NSNumber class]]) {
        [params setObject:current forKey:@"current"];
    }
    if (size && [size isKindOfClass:[NSNumber class]]) {
        [params setObject:size forKey:@"size"];
    }
    NSString *jsonString = [JsonUtils DataWithJSONObject:params];
    NSLog(@"getBooks : %@", jsonString);
    return jsonString;
}

@end
