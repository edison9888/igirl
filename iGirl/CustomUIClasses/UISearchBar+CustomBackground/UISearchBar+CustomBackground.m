//
//  UISearchBar+CustomBackground.m
//  iAccessories
//
//  Created by zhang on 13-4-19.
//  Copyright (c) 2013年 MobileWoo. All rights reserved.
//

#import "UISearchBar+CustomBackground.h"

@implementation UISearchBar (CustomBackground)
- (void)drawRect:(CGRect)rect {
//    UIImage *image = [UIImage imageNamed: @"background.png"];
//    [image drawInRect:rect];
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
    UIImage *img = [UIImage imageNamed: @"categorySearchBarBackground"];
    UIImageView *v = [[UIImageView alloc] initWithFrame:CGRectZero];
    [v setImage:img];
    v.bounds = CGRectMake(0, 0, img.size.width, img.size.height);
    NSArray *subs = self.subviews;
    for (int i = 0; i < [subs count]; i++) {
        id subv = [self.subviews objectAtIndex:i];
        if ([subv isKindOfClass:NSClassFromString(@"UISegmentedControl")]) {
            [subv setHidden:YES];
        }
        if ([subv isKindOfClass:NSClassFromString(@"UISearchBarBackground")])
        {
            [subv setHidden:YES];
        }
    }
    [v setNeedsDisplay];
    [v setNeedsLayout];
}
@end
