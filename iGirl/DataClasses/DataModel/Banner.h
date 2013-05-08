//
//  Banner.h
//  iAccessories
//
//  Created by 王 兆琦 on 12-10-17.
//  Copyright (c) 2012年 MobileWoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

typedef enum {
    kTileActionTypeList = 0,
    kTileActionTypeListAuto = 1,
    kTileActionTypeListDiscount = 2,
    kTileActionTypeDetail = 3,
    kTileActionTypeLink = 4,
    kTileActionTypeSubsence = 5,
} TileActionType;

@interface Banner : NSObject <NSCoding>
{
    //banner id
    NSNumber            *_bannerId;
    //标题名称
    NSString            *_title;
    //Tile对象的数组
    NSMutableArray      *_items;
}

@property (nonatomic, retain) NSNumber *bannerId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, retain) NSMutableArray *items;

@end

////////////////////////////////////////////////////////////

@interface Tile : NSObject <NSCoding>
{
    //tile id
    NSNumber            *_tileId;
    //tile名称
    NSString            *_tileTitle;
    //tile图片（和_picUrl只有一个有值）
    NSString            *_tileUUID;
    //tile淘宝图片（和_tileUUID只有一个有值）
    NSString            *_picUrl;
    //点击后的动作
    NSNumber            *_type;
    //外链链接
    NSString            *_link;
    //淘宝商品的id
    NSNumber            *_itemId;
    //淘宝商品的价格
    NSNumber            *_treasurePrice;
    //商品推荐理由
    NSString            *_recommand;
    //商品销量
    NSNumber            *_volumn;
    //优惠结束时间
    NSDate              *_couponTime;
    //子情景数据
    NSMutableArray      *_subTiles;
    //商品列表类型
    TreasureShowType    _treasureShowType;
}

@property (nonatomic, retain) NSNumber *tileId;
@property (nonatomic, copy) NSString *tileTitle;
@property (nonatomic, copy) NSString *tileUUID;
@property (nonatomic, copy) NSString *picUrl;
@property (nonatomic, retain) NSNumber *type;
@property (nonatomic, copy) NSString *link;
@property (nonatomic, retain) NSNumber *itemId;
@property (nonatomic, retain) NSNumber *treasurePrice;
@property (nonatomic, copy) NSString *recommand;
@property (nonatomic, retain) NSNumber *volumn;
@property (nonatomic, retain) NSDate *couponTime;
@property (nonatomic, retain) NSMutableArray *subTiles;
@property (nonatomic, assign) TreasureShowType treasureShowType;

@end
