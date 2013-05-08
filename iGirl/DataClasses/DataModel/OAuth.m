//
//  OAuth.m
//  Pic it
//
//  Created by skye on 9/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "OAuth.h"

@implementation OAuthFactory

+ (id)createOAuthByType:(int)type
{
    OAuth *oauth = nil;
    switch (type) {
        case kOAuthTypeSinaWeibo:
            oauth = [[SinaOAuth alloc] init];
            oauth.type = kOAuthTypeSinaWeibo;
            break;
        case kOAuthTypeKaixin:
            break;
        case kOAuthTypeQQ:
            break;
        case kOAuthTypeRenren:
            break;
        case kOAuthTypeMSN:
            break;
        case kOAuthTypeTaobao:
            break;
        default:
            break;
    }
    return oauth;
}

@end


@implementation OAuth

@synthesize type                = _type;
@synthesize token               = _token;
@synthesize tokenSecret         = _tokenSecret;
@synthesize refreshToken        = _refreshToken;
@synthesize authId              = _authId;
@synthesize screenName          = _screenName;
@synthesize avatar              = _avatar;

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        self.type           = [coder decodeIntForKey:@"type"];
        self.token          = [coder decodeObjectForKey:@"token"];
        self.tokenSecret    = [coder decodeObjectForKey:@"secret"];
        self.refreshToken   = [coder decodeObjectForKey:@"refreshToken"];
        self.authId         = [coder decodeObjectForKey:@"authid"];
        self.screenName     = [coder decodeObjectForKey:@"screenName"];
        self.avatar         = [coder decodeObjectForKey:@"avatar"];
    }
    return self;
}

-(void) encodeWithCoder:(NSCoder *)coder
{
    [coder encodeInt:self.type forKey:@"type"];
    [coder encodeObject:self.token forKey:@"token"];
    [coder encodeObject:self.tokenSecret forKey:@"secret"];
    [coder encodeObject:self.refreshToken forKey:@"refreshToken"];
    [coder encodeObject:self.authId forKey:@"authid"];
    [coder encodeObject:self.screenName forKey:@"screenName"];
    [coder encodeObject:self.avatar forKey:@"avatar"];
}

@end

@implementation SinaOAuth

@synthesize expiredIn       = _expiredIn;

#pragma mark - NSCoding

- (id) initWithCoder:(NSCoder *)coder
{
    self =[super initWithCoder:coder];
    if(self){
        self.expiredIn          = [coder decodeObjectForKey:@"expiredIn"];
    }
    return self;
}

-(void) encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    [coder encodeObject:self.expiredIn forKey:@"expiredIn"];
}

@end
