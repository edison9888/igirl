//
//  StrikeThroughLabel.m
//  StrikeThroughLabel
//
//

#import "StrikeThroughLabel.h"

@implementation StrikeThroughLabel

#pragma mark -
#pragma mark Initializer

- (void)drawTextInRect:(CGRect)rect
{    
    [super drawTextInRect:rect];
    
    CGSize textSize = [self.text sizeWithFont:self.font forWidth:self.frame.size.width lineBreakMode:self.lineBreakMode];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(ctx, 85.0f/255.0f, 85.0f/255.0f, 85.0f/255.0f, 1.0f); // RGBA
    CGContextSetLineWidth(ctx, 1.0f);
    
    CGContextMoveToPoint(ctx, rect.origin.x, rect.origin.y + rect.size.height / 2 + 1);
    CGContextAddLineToPoint(ctx, rect.origin.x + textSize.width, rect.origin.y + rect.size.height / 2 + 1);
    
    CGContextStrokePath(ctx);
}

@end
