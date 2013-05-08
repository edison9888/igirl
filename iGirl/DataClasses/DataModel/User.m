//
//  User.m
//  Three Hundred
//
//  Created by skye on 8/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "User.h"
#import "Constants.h"

@implementation UserBase

@synthesize userId                  = _userId;
@synthesize userName                = _userName;
@synthesize avatar                  = _avatar;

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)coder
{    
    self = [super init];
    if(self){
        self.userId                 = [coder decodeObjectForKey:@"userId"];
        self.userName               = [coder decodeObjectForKey:@"userName"];        
        self.avatar                 = [coder decodeObjectForKey:@"avatar"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.userId forKey:@"userId"];
    [coder encodeObject:self.userName forKey:@"userName"];
    [coder encodeObject:self.avatar forKey:@"avatar"];
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////

@implementation Me

@synthesize session                 = _session;
@synthesize oauthes                 = _oauthes;

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if(self){
        self.session            = [coder decodeObjectForKey:@"session"];
        self.oauthes            = [NSMutableDictionary dictionaryWithDictionary:[coder decodeObjectForKey:@"oauthes"]];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    [coder encodeObject:self.session forKey:@"session"];
    [coder encodeObject:self.oauthes forKey:@"oauthes"];
}

@end



