//
//  RecommandItemView.h
//  iAccessories
//
//  Created by zhang on 12-10-17.
//  Copyright (c) 2012年 MobileWoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RecommendItemViewDelegate <NSObject>

- (void)open:(id)sender;

@end

@interface RecommendItemView : UIView {
    UILabel     *recommendName;
    UIButton    *recommendButton;
    UIView      *recommendLabelBackground;
    id <RecommendItemViewDelegate> delegate;
}

@property(nonatomic, retain) id <RecommendItemViewDelegate> delegate;

- (void)setText:(NSString *) text;
- (void)setImage:(UIImage *) image;
@end
