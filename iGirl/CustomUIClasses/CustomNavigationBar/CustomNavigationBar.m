//
//  CustomNavigationBar.m
//  CustomBackButton
//
//  Created by Peter Boctor on 1/11/11.
//
//  Copyright (c) 2011 Peter Boctor
// 
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE

#import "CustomNavigationBar.h"
#import <QuartzCore/QuartzCore.h>

#define MAX_BACK_BUTTON_WIDTH 160.0
#define TITLE_TAG 100000

@implementation CustomNavigationBar
@synthesize navigationBarBackgroundImage;
@synthesize height;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        navigationBarBackgroundImage = [[UIImageView alloc] initWithFrame:self.frame];
        navigationBarBackgroundImage.image = [UIImage imageNamed:@"navigationBarBackground.png"];
        height = 44.0;
        self.barStyle = UIBarStyleBlack;
        [self addShadow];
    }
    return self;
}

- (id)init
{
    if (self = [super init]) {
        navigationBarBackgroundImage = [[UIImageView alloc] initWithFrame:self.frame];
        navigationBarBackgroundImage.image = [UIImage imageNamed:@"navigationBarBackground.png"];
        height = 44.0;
        self.barStyle = UIBarStyleBlack;
        [self addShadow];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        navigationBarBackgroundImage = [[UIImageView alloc] initWithFrame:self.frame];
        navigationBarBackgroundImage.image = [UIImage imageNamed:@"navigationBarBackground.png"];
        height = 44.0;
        self.barStyle = UIBarStyleBlack;
        [self addShadow];
    }
    return self;
}

// If we have a custom background image, then draw it, othwerwise call super and draw the standard nav bar
- (void)drawRect:(CGRect)rect
{
  if (navigationBarBackgroundImage)
    [navigationBarBackgroundImage.image drawInRect:rect];
  else
    [super drawRect:rect];
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize oldSize = [super sizeThatFits:size];
    CGSize newSize = CGSizeMake(oldSize.width, height);
    return newSize;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

// Save the background image and call setNeedsDisplay to force a redraw
-(void) setBackgroundWith:(UIImage*)backgroundImage
{
  self.navigationBarBackgroundImage = [[UIImageView alloc] initWithFrame:self.frame];
  navigationBarBackgroundImage.image = backgroundImage;
  [self setNeedsDisplay];
}

// clear the background image and call setNeedsDisplay to force a redraw
-(void) clearBackground
{
  self.navigationBarBackgroundImage = nil;
  [self setNeedsDisplay];
}

// Set the text on the custom back button
-(void) setText:(NSString*)text onBackButton:(UIButton*)backButton leftCapWidth:(CGFloat)capWidth
{
  // Measure the width of the text
  CGSize textSize = [text sizeWithFont:backButton.titleLabel.font];
  // Change the button's frame. The width is either the width of the new text or the max width
  backButton.frame = CGRectMake(backButton.frame.origin.x, backButton.frame.origin.y, (textSize.width + (capWidth * 1.5)) > MAX_BACK_BUTTON_WIDTH ? MAX_BACK_BUTTON_WIDTH : (textSize.width + (capWidth * 1.5)), backButton.frame.size.height);

  // Set the text on the button
  [backButton setTitle:text forState:UIControlStateNormal];
}

-(NSString*) backButtonText
{
    return [NSString stringWithFormat:@" %@", self.topItem.title ? self.topItem.title : NSLocalizedString(@"返回", @"")];
}

-(NSString*) onlyBackText
{
    return [NSString stringWithFormat:@" %@", NSLocalizedString(@"返回", @"")];
}

- (NSString*) closeText
{
    return [NSString stringWithFormat:@"%@", NSLocalizedString(@"关闭", @"")];
}

- (void)addShadow
{
    CGMutablePathRef shadowPath = CGPathCreateMutable();
    CGPathMoveToPoint(shadowPath, NULL, 1, 41);
    CGPathAddLineToPoint(shadowPath, NULL, 319, 41);
    CGPathAddLineToPoint(shadowPath, NULL, 319, 43);
    CGPathAddLineToPoint(shadowPath, NULL, 1, 43);
    CGPathAddLineToPoint(shadowPath, NULL, 1, 41);
    
    // 位移
    [self.layer setShadowOffset:CGSizeMake(0.0, 1.0)];
    
    // 散射半径
    [self.layer setShadowRadius:2];
    
    // 透明
    [self.layer setShadowOpacity:1];
    
    // 路径
    [self.layer setShadowPath:shadowPath];
    
    [self.layer setShadowColor:[UIColor blackColor].CGColor];
}

@end
