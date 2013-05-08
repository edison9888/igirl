//
//  RecommendViewItemCell.h
//  iAccessories
//
//  Created by zhang on 13-3-18.
//  Copyright (c) 2013年 MobileWoo. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kRecommendListPageSize      21
#define kRecommendItemWidth         106
#define kRecommendHeadBodyTag       10000

#define kRecommendHeadBodyItemImageTag 1000
#define kRecommendHeadBodyItemLabelTag 2000

@class Tile;
@class RecommendItemView;
@interface RecommendViewItemCell : UITableViewCell{

    RecommendItemView *subItemView1;
    RecommendItemView *subItemView2;
    RecommendItemView *subItemView3;

}

@property (nonatomic, retain) RecommendItemView *subItemView1;
@property (nonatomic, retain) RecommendItemView *subItemView2;
@property (nonatomic, retain) RecommendItemView *subItemView3;

// 隐藏
- (void)hideSubItem:(int) pos;

// 显示
- (void)displaySubItem:(int) pos;
@end
