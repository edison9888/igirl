//
//  RecommendScrollView.m
//  iTBK
//
//  Created by 王 兆琦 on 12-9-28.
//
//

#import "DiscountView.h"
#import "DataEngine.h"
#import "ImageCacheEngine.h"

@implementation DiscountView

@synthesize treasureId              = _treasureId;
@synthesize imageUrl                = _imageUrl;
@synthesize delegate                = _delegate;
@synthesize treasureView            = _treasureView;
@synthesize treasureViewBg          = _treasureViewBg;
@synthesize treasureTitle           = _treasureTitle;
@synthesize thumbImage              = _thumbImage;
@synthesize recommandReason         = _recommandReason;
@synthesize priceLabel              = _priceLabel;
@synthesize orgPriceLabel           = _orgPriceLabel;
@synthesize discountLevel           = _discountLevel;
@synthesize treasureStatusView      = _treasureStatusView;
@synthesize treasureStatusViewBg    = _treasureStatusViewBg;
@synthesize timeIcon                = _timeIcon;
@synthesize timeText                = _timeText;
@synthesize treasureStatusLabel     = _treasureStatusLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [[NSBundle mainBundle] loadNibNamed:@"DiscountView" owner:self options:nil];
        [self addSubview:_treasureView];
        [self addSubview:_treasureStatusView];
        
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleClick:)];
        [_treasureView addGestureRecognizer:recognizer];
    }
    return self;
}

- (IBAction)handleClick:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(clickDiscountView:)]) {
        [_delegate clickDiscountView:self];
    }
}

- (void)setImageUrl:(NSString *)url
{
    _imageUrl = url;
    UIImage *image = [UIImage imageWithContentsOfFile:[[ImageCacheEngine sharedInstance] getImagePathByUrl:url]];
    if (image) {
        [_thumbImage setImage:image];
    } else {
        [_thumbImage setImage:[UIImage imageNamed:@"recommendScrollViewEmpty.png"]];
        [_delegate getDiscountViewImage:url];
    }
}

@end
