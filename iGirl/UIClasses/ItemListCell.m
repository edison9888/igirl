//
//  ItemListCell.m
//  iAccessories
//
//  Created by Tony Sun on 12-10-17.
//  Copyright (c) 2012年 MobileWoo. All rights reserved.
//

#import "ItemListCell.h"

@implementation ItemListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [[NSBundle mainBundle] loadNibNamed:@"ItemListCell" owner:self options:nil];

        // 设置cell里各内容的格式
        _description.font = [UIFont systemFontOfSize:13.0];
        _description.textColor = [UIColor colorWithRed:26.f / 255.f green:26.f / 255.f blue:26.f / 255.f alpha:1];
        _description.shadowColor = [UIColor whiteColor];
        _description.shadowOffset = CGSizeMake(0, 0.5);
        
        _priceLabel.font = [UIFont systemFontOfSize:15.0];
        _priceLabel.textColor = [UIColor colorWithRed:204.f / 255.f green:0.f / 255.f blue:1.f / 255.f alpha:1];
        _priceLabel.shadowColor = [UIColor whiteColor];
        _priceLabel.shadowOffset = CGSizeMake(0, 0.5);
        
        _priceLabel.font = [UIFont systemFontOfSize:11.0];
        _priceLabel.textColor = [UIColor colorWithRed:167.f / 255.f green:167.f / 255.f blue:167.f / 255.f alpha:1];
        _priceLabel.shadowColor = [UIColor whiteColor];
        _priceLabel.shadowOffset = CGSizeMake(0, 0.5);
                
        [self.contentView addSubview:_treasureThumb];
        [self.contentView addSubview:_description];
        [self.contentView addSubview:_priceLabel];
        [self.contentView addSubview:_salesLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

@end
