//
//  RecommendItemView.h
//  iAccessories
//
//  Created by sunxq on 12-12-19.
//  Copyright (c) 2012年 MobileWoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Treasure;
@class EditRecommendViewController;

@interface EditRecommendView : UIView
{
    UIImageView         *_imageView;
    UILabel             *_priceLabel;
    UILabel             *_salesLabel;
    UILabel             *_contentLabel;
}

@property (nonatomic, retain) Treasure *treasure;
@property (nonatomic, assign) EditRecommendViewController *cotroller;


- (void)loadValues:(Treasure *)treasure;
- (void)loadTreasureImage:(UIImage *)image;

@end
