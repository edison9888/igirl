//
//  ShareTemplate.h
//  iAccessories
//
//  Created by 王 兆琦 on 12-12-18.
//  Copyright (c) 2012年 MobileWoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShareTemplate : NSObject <NSCoding>
{
    NSString        *_title;
    NSString        *_content;
}

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *content;

@end
