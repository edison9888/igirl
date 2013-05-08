//
//  TBSeller.h
//  iAccessories
//
//  Created by sunxq on 12-12-18.
//  Copyright (c) 2012年 MobileWoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TBSeller : NSObject
{
    // 昵称
    NSString        *_nick;
    // 用户头像
    NSString        *_avatar;
    // 用户所在地
    NSString        *_location;
    // 卖家级别
    NSNumber        *_sellerCredit;
    // 是否参加消保
    BOOL            _isConsumerProtection;
    // 是否是金牌卖家
    BOOL            _isGoldenSeller;
    // 好评率
    NSString        *_goodRate;
}

@property (nonatomic, copy) NSString *nick;
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *location;
@property (nonatomic, retain) NSNumber *sellerCredit;
@property (nonatomic, assign) BOOL isConsumerProtection;
@property (nonatomic, assign) BOOL isGoldenSeller;
@property (nonatomic, copy) NSString *goodRate;

@end
