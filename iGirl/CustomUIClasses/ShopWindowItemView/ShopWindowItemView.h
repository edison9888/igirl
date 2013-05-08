//
//  ShopWindowItemView.h
//  iAccessories
//
//  Created by zhang on 13-1-6.
//  Copyright (c) 2013年 MobileWoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Tile;

@interface ShopWindowItemView : UIView {
    UILabel *contentLabel;
    UILabel *salesAndPriceLabel;

    UIImageView *bgView;
    UIImageView *tileImage;
    
    UIView *remainTimeBodyView;
    UIButton *remainTimeButton;
    Tile *_itemTile;
}
@property (nonatomic, retain) Tile *itemTile;

- (float)getCellHeight:(Tile*) tile;
@end
