//
//  ThumbPhotoView.h
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface ThumbPhotoView : UIView <UIGestureRecognizerDelegate>
{
    IBOutlet UIImageView                *_imageBg;
	IBOutlet UIImageView                *_imageView;
	IBOutlet UILabel                    *_price;
    IBOutlet UILabel                    *_sellCount;
    IBOutlet UILabel                    *_labelBg;
    NSNumber                            *_treasureId;
}

@property (nonatomic, readonly) UIImageView *imageBg;
@property (nonatomic, readonly) UIImageView *imageView;
@property (nonatomic, readonly) UILabel *price;
@property (nonatomic, readonly) UILabel *sellCount;
@property (nonatomic, readonly) UILabel *labelBg;
@property (nonatomic, copy) NSNumber *treasureId;

// inits this view to have a button over the image
- (id)initWithFrame:(CGRect)frame target:(id)target action:(SEL)action;

@end
