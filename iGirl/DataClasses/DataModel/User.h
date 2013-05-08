//
//  User.h
//  Three Hundred
//
//  Created by skye on 8/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OAuth.h"

/**
 * 用户基类
 */
@interface UserBase : NSObject <NSCoding>
{
    NSNumber            *_userId;                   //用户id
	NSString            *_userName;                 //用户名字
	NSString            *_avatar;                   //头像
}

@property (nonatomic, retain) NSNumber *userId;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *avatar;

@end

/**
 * 我
 */
@interface Me : UserBase
{
    NSString                *_session;                      //服务端session
    NSMutableDictionary     *_oauthes;                      //我的oauth信息
}

@property (nonatomic, copy) NSString *session;
@property (nonatomic, retain) NSMutableDictionary *oauthes;

@end


