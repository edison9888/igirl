//
//  Constants_Enum.h
//  iAccessories
//
//  Created by 王 兆琦 on 12-12-17.
//  Copyright (c) 2012年 MobileWoo. All rights reserved.
//


typedef enum {
    kMenuActionTypeList = 0,
    kMenuActionTypeListAuto = 1,            //同kMenuActionTypeList 数据源不同
    kMenuActionTypeListDiscount = 2,        //同kMenuActionTypeList 数据源不同
    kMenuActionTypeTreasure = 3,
    kMenuActionTypeLink = 4,
    kMenuActionTypeSence = 5,
    kMenuActionTypeCategory = 6,
    kMenuActionTypeDiscount = 7,            //废弃
    kMenuActionTypeEditorRecommand = 8,     //废弃
    kMenuActionTypeFavorite = 9,
    kMenuActionTypeSettings = 10,
    kMenuActionTypeBackHomePage = 11,
    kMenuActionTypePin = 12
} MenuActionType;

enum{
	kPushActionLanuch = 0,
	kPushActionUrl = 1,
	kPushActionTreasure = 2,
	kPushActionSence = 3,
	kPushActionList = 4
} PushActionType;

typedef enum {
    kAdvertiseBanner = 0,
    kAdvertiseShare = 1
} AdvertiseType;

typedef enum {
    kTileShowType123 = 0,
    kTileShowTypeBigPicture = 1
} TileShowType;

typedef enum {
    kTreasureListShowTypeList = 0,
    kTreasureListShowType222 = 1
} TreasureShowType;

typedef enum {
    kDataSwitchPrice = 1,
    kDataSwitchVolumn = 2
} TreasureDataSwitch;

typedef enum {
    kItemDetailFromOrder = 1
} ItemDetailSource;


typedef enum {
    kTileDataTypeLeftDrawer = 0,
    kTileDataTypeDaofu = 1,
    kTileDataTypePingCe = 2
} ItemDataType;

