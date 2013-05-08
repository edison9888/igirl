//
//  ItemListCell.h
//  iAccessories
//
//  Created by Tony Sun on 12-10-17.
//  Copyright (c) 2012年 MobileWoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ItemListCell : UITableViewCell
{
    IBOutlet UIButton               *_treasureThumb;
    IBOutlet UILabel                *_description;
    IBOutlet UILabel                *_priceLabel;
    IBOutlet UILabel                *_salesLabel;
}

@property (nonatomic, retain) UIButton *treasurThumb;
@property (nonatomic, retain) UILabel *description;
@property (nonatomic, retain) UILabel *priceLabel;
@property (nonatomic, retain) UILabel *salesLabel;

@end
