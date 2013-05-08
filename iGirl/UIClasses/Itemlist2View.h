//
//  Itemlist2View.h
//  iAccessories
//
//  Created by sunxq on 13-1-6.
//  Copyright (c) 2013年 MobileWoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants+Enum.h"

@class Treasure;
@class Itemlist2ViewController;

@interface Itemlist2View : UIView
{
    UIImageView         *background;
    UIImageView         *_treasureImage;
//    UIView              *_infoView;
    UILabel             *_infoLabel;
    
    UILabel             *priceLabel, *salesLabel;
}

@property (nonatomic, retain) Treasure *treasure;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, assign) Itemlist2ViewController *cotroller;
@property (nonatomic, retain) NSNumber *dataSwitch;
@property (nonatomic, assign) ItemDetailSource source;

- (void)loadValues:(Treasure *)treasure;

@end
