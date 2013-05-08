//
//  RecommendScrollView.h
//  iTBK
//
//  Created by 王 兆琦 on 12-9-28.
//
//

#import <UIKit/UIKit.h>

@protocol DiscountViewDelegate <NSObject>

- (void)clickDiscountView:(id)sender;
- (void)getDiscountViewImage:(NSString *)url;

@end

@interface DiscountView : UIView
{
    IBOutlet UIView             *_treasureView;
    IBOutlet UIImageView        *_treasureViewBg;
    IBOutlet UILabel            *_treasureTitle;
    IBOutlet UIImageView        *_thumbImage;
    IBOutlet UILabel            *_recommandReason;
    IBOutlet UILabel            *_priceLabel;
    IBOutlet UILabel            *_orgPriceLabel;
    IBOutlet UIButton           *_discountLevel;
    
    IBOutlet UIView             *_treasureStatusView;
    IBOutlet UIButton           *_treasureStatusViewBg;
    IBOutlet UIImageView        *_timeIcon;
    IBOutlet UILabel            *_timeText;
    IBOutlet UILabel            *_treasureStatusLabel;
    
    NSNumber                    *_treasureId;
    NSString                    *_imageUrl;
    id <DiscountViewDelegate> __unsafe_unretained _delegate;
}

@property (nonatomic, copy) NSNumber *treasureId;
@property (nonatomic, copy) NSString *imageUrl;
@property (nonatomic, assign) id <DiscountViewDelegate> __unsafe_unretained delegate;

@property (nonatomic, retain) UIView *treasureView;
@property (nonatomic, retain) UIImageView *treasureViewBg;
@property (nonatomic, retain) UILabel *treasureTitle;
@property (nonatomic, retain) UIImageView *thumbImage;
@property (nonatomic, retain) UILabel *recommandReason;
@property (nonatomic, retain) UILabel *priceLabel;
@property (nonatomic, retain) UILabel *orgPriceLabel;
@property (nonatomic, retain) UIButton *discountLevel;
@property (nonatomic, retain) UIView *treasureStatusView;
@property (nonatomic, retain) UIButton *treasureStatusViewBg;
@property (nonatomic, retain) UIImageView *timeIcon;
@property (nonatomic, retain) UILabel *timeText;
@property (nonatomic, retain) UILabel *treasureStatusLabel;

- (IBAction)handleClick:(id)sender;

- (void)setImageUrl:(NSString *)url;

@end
