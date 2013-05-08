//
//  RecommendViewItemCell.m
//  iAccessories
//
//  Created by zhang on 13-3-18.
//  Copyright (c) 2013年 MobileWoo. All rights reserved.
//

#import "RecommendViewItemCell.h"

#import "Banner.h"
#import "RecommendItemView.h"
#import "DataEngine.h"
#import "ImageCacheEngine.h"

@implementation RecommendViewItemCell
@synthesize subItemView1 = subItemView1;
@synthesize subItemView2 = subItemView2;
@synthesize subItemView3 = subItemView3;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        subItemView1 = [[RecommendItemView alloc] initWithFrame:CGRectMake(0, 2, 106, 106)];
        [subItemView1 setImage:[UIImage imageNamed:@"recommendSmallNoPic.png"]];
        subItemView2 = [[RecommendItemView alloc] initWithFrame:CGRectMake(108, 2, 106, 106)];
        [subItemView2 setImage:[UIImage imageNamed:@"recommendSmallNoPic.png"]];
        subItemView3 = [[RecommendItemView alloc] initWithFrame:CGRectMake(216, 2, 106, 106)];
        [subItemView3 setImage:[UIImage imageNamed:@"recommendSmallNoPic.png"]];
        [self addSubview:subItemView1];
        [self addSubview:subItemView2];
        [self addSubview:subItemView3];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)hideSubItem:(int)pos
{
    if (pos == 0) {
        [subItemView1 setHidden:YES];
    } else if (pos == 1) {
        [subItemView2 setHidden:YES];
    } else if (pos == 2) {
        [subItemView3 setHidden:YES];
    }
}

- (void)displaySubItem:(int) pos
{
    if (pos == 0) {
        [subItemView1 setHidden:NO];
    } else if (pos == 1) {
        [subItemView2 setHidden:NO];
    } else if (pos == 2) {
        [subItemView3 setHidden:NO];
    }
}

@end
