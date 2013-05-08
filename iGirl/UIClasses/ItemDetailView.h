//
//  ItemDetailView.h
//  iTBK
//
//  Created by 郭雪 on 12-9-28.
//
//

#import <Foundation/Foundation.h>

@class ItemDetailViewController;

@class Treasure;
@class Rate;

@interface ItemDetailView : NSObject <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UIScrollView* bodyScrollView;
    
    IBOutlet UIView* topView;
    IBOutlet UIImageView* mainItemImage;
    IBOutlet UIView* titleView;
    IBOutlet UILabel* titleLabel;
    IBOutlet UILabel* priceLabel;
    IBOutlet UIImageView* topShadowImage;
    
//    IBOutlet UIView* sellerView;
//    IBOutlet UILabel* sellerLabel;
//    IBOutlet UIImageView* sellerSplitImage;
//    IBOutlet UIView* sellerInfoView;
//    IBOutlet UIImageView* sellerAvatarImage;
//    IBOutlet UILabel* sellerNameLabel;
//    IBOutlet UILabel* sellerLocationLabel;
//    IBOutlet UILabel* sellerRateLabel;
//    IBOutlet UIImageView* sellerShadowImage;
    
    IBOutlet UIView* commentView;
    IBOutlet UILabel* commentLabel;
    IBOutlet UIImageView* commentSplitImage;
    IBOutlet UITableView* commentTableView;
    IBOutlet UIImageView* commentShadowImage;
    
    IBOutlet UIView* detailView;
    IBOutlet UILabel* detailLabel;
    IBOutlet UIImageView* detailSplitImage;
    IBOutlet UIView* detailImagesView;
    IBOutlet UIImageView* detailShadowImage;
    
    IBOutlet UIView* similarView;
    IBOutlet UILabel* similarLabel;
    IBOutlet UIImageView* similarSplitImage;
    IBOutlet UIScrollView* similarInfoView;
    IBOutlet UIImageView* similarShadowImage;
    
    IBOutlet UIImageView *scrollToLeft, *scrollToRight;
    
    BOOL isVisiable;
    
    __unsafe_unretained ItemDetailViewController* itemDetailViewController;
    
    NSNumber* treasureId;
    
    NSMutableArray* commentLabelsArray;
    
    NSMutableArray* similarItemsArray;
    
    NSString *_controllerId;
    
    BOOL hideSimilar;
    UIImage *detailBackground;
}

@property (nonatomic, strong) NSNumber* treasureId;
@property (nonatomic, assign) ItemDetailViewController* itemDetailViewController;
@property (nonatomic, readonly) UIScrollView* bodyScrollView;
@property (nonatomic, readonly, getter = getTreasure) Treasure* treasure;
@property (assign) BOOL hideSimilar;

- (void)boundItemValues:(BOOL)visiable;
- (void)updateFavouriteButton;
- (void)setVisiable;

@end
