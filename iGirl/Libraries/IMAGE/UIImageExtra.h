//
//  UIImageExtra.h
//  
//
//  Created by shenjianguo on 10-8-3.
//  Copyright 2010 roosher. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIImage (UIImageExtra) 

- (UIImage *)imageScaledToSize:(CGSize)thumbSize;

- (UIImage *)rescaleImage:(UIImage *)inImage toSize:(CGSize)thumbSize;

- (UIImage *)addImageReflection:(CGFloat)reflectionFraction;

- (UIImage *)createRoundedRectImageWithSize:(CGSize)size;

- (UIImage *)createRoundedRectImageWithSize:(CGSize)size oval:(int)oval;

- (UIImage *)transformWithWidth:(CGFloat)width height:(CGFloat)height;

- (UIImage *)cropImage:(UIImage *)originalImage size:(CGSize)size;

- (UIImage *)stretchToSize:(CGSize)size leftCapWidth:(int)left topCapHeight:(int)top resolution:(BOOL)isRetina;

- (UIImage *)orientationUpImage;
- (UIImage *)cropImage:(CGRect)rect;
- (UIImage *)cropImage:(CGSize)size center:(CGPoint)center;
- (UIImage *)rescaleToSize:(CGSize)size;

- (UIImage *)imageInRect:(CGRect)rect;

- (UIImage *)scaleAndRotate:(CGFloat)boundWidth and:(CGFloat)boundHeight;

@end
