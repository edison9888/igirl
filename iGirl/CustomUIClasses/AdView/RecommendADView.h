//
//  RecommendADView.h
//  iAccessories
//
//  Created by zhang on 12-12-18.
//  Copyright (c) 2012年 MobileWoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Advertise.h"

@protocol RecommendADViewDelegate

- (void)openAD:(Advertise*) ad;

- (void)closeRecommendADView;

- (void)showAD:(BOOL)isShowAD;

@end

@interface RecommendADView : UIView<UIScrollViewDelegate> {
    id source;
    id<RecommendADViewDelegate> delegate;
    
    UIScrollView *adScrollView;
    UIButton *closeButton;
    
    UIPageControl *pageControl;
    int nowIndex;
    NSMutableArray *adArray;
    NSMutableArray *needDownloadImage;
}
@property (nonatomic, retain) id<RecommendADViewDelegate> delegate;
@property (nonatomic, retain) id source;

- (void) setAD:(NSMutableArray *) adArray;

@end
