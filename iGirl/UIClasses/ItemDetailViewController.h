//
//  ItemDetailViewController.h
//  iTBK
//
//  Created by 郭雪 on 12-9-28.
//
//

#import <UIKit/UIKit.h>
#import "Constants+Enum.h"

@class ItemDetailView;

@interface ItemDetailViewController : UIViewController <UIScrollViewDelegate> {
    IBOutlet UIScrollView* scrollView;
    IBOutlet UIView *bottomView;
    IBOutlet UIButton *buyButton, *favouriteButton;
    
    NSNumber* treasureId;
    NSArray* treasuresArray;
    ItemDetailView *centerView;
    ItemDetailView *leftView;
    ItemDetailView *rightView;
    
    int centerIndex;
    CGFloat currentOffsetX;
    
    // 进入详情来源
    ItemDetailSource _source;
    
    BOOL _isFirstClass;
	
	BOOL _isJumpIndex;
    
    BOOL fromSimilar;
    
    //前一个页面的相关数据（统计专用）
    NSString                    *_preViewName;
}

@property (nonatomic, strong) NSNumber* treasureId;
@property (nonatomic, strong) NSArray* treasuresArray;
@property (nonatomic, assign) ItemDetailSource source;
@property (nonatomic, readonly) UIButton* buyButton;
@property (nonatomic, assign) BOOL isFirstClass;
@property (nonatomic, assign) BOOL isJumpIndex;
@property (nonatomic, copy) NSString *preViewName;
@property (assign) BOOL fromSimilar;

- (void)scrollLeft;
- (void)scrollRight;

@end
