//
//  OAuth.h
//  Pic it
//
//  Created by skye on 9/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * OAuth的类型：新浪、开心、qq等等
 */
typedef enum {
    kOAuthTypeNone = 0,
    kOAuthTypeSinaWeibo = 1,
    kOAuthTypeKaixin = 2,
    kOAuthTypeQQ = 4,
    kOAuthTypeRenren = 8,
    kOAuthTypeMSN = 16,
    kOAuthTypeTaobao = 32
} OAuthType;


@interface OAuthFactory : NSObject 

+ (id)createOAuthByType:(int)type;

@end

/**
 * OAuth(授权)基类
 */
@interface OAuth : NSObject <NSCoding>
{
    OAuthType   _type;              //OAuth类型（新浪、淘宝）
    NSString    *_token;            //token
    NSString    *_tokenSecret;      //加密token
    NSString    *_refreshToken;     //延长期限的token
    NSString    *_authId;           //id（新浪、淘宝id）
    NSString    *_screenName;       //显示名称
    NSString    *_avatar;           //头像
}

@property (nonatomic, assign) OAuthType type;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *tokenSecret;
@property (nonatomic, copy) NSString *refreshToken;
@property (nonatomic, copy) NSString *authId;
@property (nonatomic, copy) NSString *screenName;
@property (nonatomic, copy) NSString *avatar;

@end

/**
 * OAuth的子类：新浪OAuth
 */
@interface SinaOAuth : OAuth
{
    NSDate      *_expiredIn;           //过期时间
}
@property (nonatomic, copy) NSString *account;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *weiboAuthDetail;
@property (nonatomic, copy) NSString *weiboUserSex;
@property (nonatomic, retain) NSDate *expiredIn;

@end
