//
//  Advertise.h
//  iAccessories
//
//  Created by 王 兆琦 on 12-12-18.
//  Copyright (c) 2012年 MobileWoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Advertise : NSObject <NSCoding>
{
    NSString        *_name;
    NSString        *_uuid;
    NSString        *_url;
}

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, copy) NSString *url;

@end
