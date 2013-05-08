//
//  Treasure.h
//  Three Hundred
//
//  Created by skye on 10/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Rate : NSObject <NSCoding>
{
    NSString       *_nick;                 //评论用户
    NSString       *_result;               //评论级别，good 好评, neutral 中评, bad 差评
    NSString       *_content;              //评论内容
    NSString       *_created;              //评论时间，yyyy-MM-dd HH:mm:ss
    NSString       *_deal;                 //分类信息
}
@property (nonatomic, copy) NSString *nick;
@property (nonatomic, copy) NSString *result;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *created;
@property (nonatomic, copy) NSString *deal;

@end

@interface Treasure : NSObject <NSCoding>
{
    //商品id
    NSNumber        *_tid;
    //商品标题
    NSString        *_title;
    //商品价格
    NSNumber        *_price;
    //商品原价
    NSNumber        *_orgPrice;
    //图片链接
    NSString        *_picUrl;
    //图片uuid
    NSString        *_picUuid;
    //商品推广URL
    NSString        *_clickUrl;
    //创建时间
    NSDate          *_create;
    //推荐内容
    NSString        *_recommend;
    //折扣结束时间
    NSDate          *_couponTime;
    //30天销量
    NSNumber        *_volume;
    //卖家信用评分
    NSNumber        *_sellerCredit;            
}
@property (nonatomic, retain) NSNumber *tid;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, retain) NSNumber *price;
@property (nonatomic, retain) NSNumber *orgPrice;
@property (nonatomic, copy) NSString *picUrl;
@property (nonatomic, copy) NSString *picUuid;
@property (nonatomic, copy) NSString *clickUrl;
@property (nonatomic, retain) NSDate *create;
@property (nonatomic, copy) NSString *recommend;
@property (nonatomic, retain) NSDate *couponTime;
@property (nonatomic, retain) NSNumber *volume;
@property (nonatomic, retain) NSNumber *sellerCredit;

@end



/////////////////////////////////////////////////////////////////


@interface TreasureDetail : Treasure
{
    NSString *_nick;
    NSString *_desc;
    NSArray  *_images;
    //评论列表
    NSArray         *_rate;
    NSString        *_location;
}

@property (nonatomic, copy) NSString *nick;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, retain) NSArray *images;
@property (nonatomic, retain) NSArray *rate;
@property (nonatomic, copy) NSString *location;

- (id)initWithTreasure:(Treasure *)treasure;

@end




