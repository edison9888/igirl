//
//  ThumbPhotoView.m
//
//

#import "ThumbPhotoView.h"

@interface ThumbPhotoView (Private)

@end

@implementation ThumbPhotoView

@synthesize imageBg             = _imageBg;
@synthesize imageView           = _imageView;
@synthesize price               = _price;
@synthesize sellCount           = _sellCount;
@synthesize labelBg             = _labelBg;
@synthesize treasureId          = _treasureId;

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"ThumbPhoto" owner:self options:nil];
        self.userInteractionEnabled = YES;
        self.clipsToBounds = YES;
        self.contentMode = UIViewContentModeCenter;
        
        [_imageView setImage:[UIImage imageNamed:@"recommendSmallNoPic.png"]];
        [self addSubview:_imageBg];
        [self addSubview:_imageView];
        [self addSubview:_labelBg];
        [self addSubview:_price];
        [self addSubview:_sellCount];
    }
	return self;
}

- (id)initWithFrame:(CGRect)frame target:(id)target action:(SEL)action
{
	self = [self initWithFrame:frame];
	   
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
    [self addGestureRecognizer:recognizer];
    
	return self;
}

- (void)dealloc
{
    
}

@end
