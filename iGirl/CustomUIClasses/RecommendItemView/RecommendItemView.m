//
//  RecommandItemView.m
//  iAccessories
//
//  Created by zhang on 12-10-17.
//  Copyright (c) 2012年 MobileWoo. All rights reserved.
//

#import "RecommendItemView.h"
#import <QuartzCore/QuartzCore.h>

@interface RecommendItemView (Private)

- (void) open:(id)sender;

@end


@implementation RecommendItemView

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        recommendButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [recommendButton addTarget:self action:@selector(open:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:recommendButton];
        
        recommendLabelBackground = [[UIView alloc] initWithFrame:CGRectMake(5, frame.size.height - 14, 99, 16)];
        [recommendLabelBackground setBackgroundColor:[UIColor clearColor]];
        [recommendLabelBackground.layer setCornerRadius:6];
        [recommendLabelBackground.layer setMasksToBounds:YES];
        [recommendLabelBackground setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5f]];
        [recommendLabelBackground setUserInteractionEnabled:NO];
        [self addSubview:recommendLabelBackground];

        recommendName = [[UILabel alloc] initWithFrame:CGRectMake(5, frame.size.height - 23, 99, 16)];
        [recommendName setBackgroundColor:[UIColor clearColor]];
        [recommendName setTextColor:[UIColor whiteColor]];
        [recommendName setFont:[UIFont systemFontOfSize:11]];
        [recommendName setLineBreakMode:NSLineBreakByClipping];
        [recommendName setText:@""];
        [recommendName setUserInteractionEnabled:NO];
        [self addSubview:recommendName];
    }
    return self;
}

- (void)setText:(NSString *) text
{
    [recommendName setText:text];
    CGSize opSize = [text sizeWithFont:[UIFont systemFontOfSize:11] constrainedToSize:CGSizeMake(85, 16)];
    float width = opSize.width;
    float height = opSize.height;
    float x = 10;
    [recommendName setFrame:CGRectMake(x, recommendName.frame.origin.y, width, height)];
    [recommendLabelBackground setFrame:CGRectMake(recommendLabelBackground.frame.origin.x, recommendName.frame.origin.y - 3, width + 12, height + 6)];
    if ([text length] == 0 || [text isEqualToString:@""]) {
        [recommendName setHidden:YES];
        [recommendLabelBackground setHidden:YES];
    } else {
        [recommendName setHidden:NO];
        [recommendLabelBackground setHidden:NO];
    }
}

- (void)setTag:(NSInteger)tag
{
    [super setTag:tag];
    [recommendButton setTag:tag];
}

- (void)setImage:(UIImage *) image
{
    [recommendButton setImage:image forState:UIControlStateNormal];
}

- (void) open:(id)sender
{
    [delegate open:sender];
}

@end
