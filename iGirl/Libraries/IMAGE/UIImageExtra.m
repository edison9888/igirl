//
//  UIImageExtra.m
//  
//
//  Created by shenjianguo on 10-8-3.
//  Copyright 2010 roosher. All rights reserved.
//

#import "UIImageExtra.h"


@implementation UIImage (UIImageExtra)


- (UIImage *)imageScaledToSize:(CGSize)thumbSize { 
	
	CGImageRef		 imageRef = [self CGImage];
	CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef);
	
    // There's a wierdness with kCGImageAlphaNone and CGBitmapContextCreate
    // see Supported Pixel Formats in the Quartz 2D Programming Guide
    // Creating a Bitmap Graphics Context section
    // only RGB 8 bit images with alpha of kCGImageAlphaNoneSkipFirst, kCGImageAlphaNoneSkipLast, kCGImageAlphaPremultipliedFirst,
    // and kCGImageAlphaPremultipliedLast, with a few other oddball image kinds are supported
    // The images on input here are likely to be png or jpeg files
	if (alphaInfo == kCGImageAlphaNone)
		alphaInfo = kCGImageAlphaNoneSkipLast;
	
    // Build a bitmap context that's the size of the thumbRect    
    // The width and bytesPerRow parameters of CGBitmapContextCreate are declared as integers. When passing a floating point value, it gets truncated.
    // Suppose thumbSize.width is 1.25. Then you will end up passing 1 for the width, and floor(1.25 * 4) == 5 as the bytes per row. That's inconsistent. You always want to pass four times whatever you passed for the width for the bytes per row.
    // You can also just leave bytesPerRow as 0, by the way. Then the system picks the best bytesPerRow 

//	int bytesPerRow;
//	if( thumbSize.width > thumbSize.height ) {
//		bytesPerRow = 4 * thumbSize.width;
//	}
//    else {
//		bytesPerRow = 4 * thumbSize.height;
//	}
	
	CGContextRef context = CGBitmapContextCreate(	
                                                NULL,
                                                thumbSize.width,		// width
                                                thumbSize.height,		// height
                                                8, //CGImageGetBitsPerComponent(imageRef),	// really needs to always be 8
                                                0, //bytesPerRow, //4 * thumbRect.size.width,	// rowbytes
                                                CGImageGetColorSpace(imageRef),
                                                alphaInfo
                                                );
    
	CGRect thumbRect = CGRectMake(0, 0, thumbSize.width, thumbSize.height);
        
    // Draw into the context, this scales the image
	CGContextDrawImage(context, thumbRect, imageRef);
	
    // Get an image from the context and a UIImage
	CGImageRef	ref = CGBitmapContextCreateImage(context);
	UIImage  *result = [UIImage imageWithCGImage:ref];
	
	CGContextRelease(context);	// ok if NULL
	CGImageRelease(ref);
	
	return result;
}

//	==============================================================
//	resizedImage
//	==============================================================
// Return a scaled down copy of the image.
- (UIImage *)rescaleImage:(UIImage *)inImage toSize:(CGSize)thumbSize {
	CGImageRef			imageRef = [inImage CGImage];
	CGImageAlphaInfo	alphaInfo = CGImageGetAlphaInfo(imageRef);
	
    // There's a wierdness with kCGImageAlphaNone and CGBitmapContextCreate
    // see Supported Pixel Formats in the Quartz 2D Programming Guide
    // Creating a Bitmap Graphics Context section
    // only RGB 8 bit images with alpha of kCGImageAlphaNoneSkipFirst, kCGImageAlphaNoneSkipLast, kCGImageAlphaPremultipliedFirst,
    // and kCGImageAlphaPremultipliedLast, with a few other oddball image kinds are supported
    // The images on input here are likely to be png or jpeg files
	if (alphaInfo == kCGImageAlphaNone)
		alphaInfo = kCGImageAlphaNoneSkipLast;
    
    // Build a bitmap context that's the size of the thumbRect
	CGContextRef bitmap = CGBitmapContextCreate(
                                                NULL,
                                                thumbSize.width,		// width
                                                thumbSize.height,		// height
                                                CGImageGetBitsPerComponent(imageRef),	// really needs to always be 8
                                                4 * thumbSize.width,	// rowbytes
                                                CGImageGetColorSpace(imageRef),
                                                alphaInfo
                                                );
    
    CGRect rect = CGRectMake(0.0, 0.0, thumbSize.width, thumbSize.height);
    // Draw into the context, this scales the image
	CGContextDrawImage(bitmap, rect, imageRef);
    
    // Get an image from the context and a UIImage
	CGImageRef	ref = CGBitmapContextCreateImage(bitmap);
	UIImage *result = [UIImage imageWithCGImage:ref];
    
	CGContextRelease(bitmap);	// ok if NULL
	CGImageRelease(ref);
    
	return result;
}

- (UIImage *)addImageReflection:(CGFloat)reflectionFraction {
	int reflectionHeight = self.size.height * reflectionFraction;
	
    // create a 2 bit CGImage containing a gradient that will be used for masking the 
    // main view content to create the 'fade' of the reflection.  The CGImageCreateWithMask
    // function will stretch the bitmap image as required, so we can create a 1 pixel wide gradient
	CGImageRef gradientMaskImage = NULL;
	
    // gradient is always black-white and the mask must be in the gray colorspace
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    // create the bitmap context
    CGContextRef gradientBitmapContext = CGBitmapContextCreate(nil, 1, reflectionHeight,
                                                               8, 0, colorSpace, kCGImageAlphaNone);
    
    // define the start and end grayscale values (with the alpha, even though
    // our bitmap context doesn't support alpha the gradient requires it)
    CGFloat colors[] = {0.0, 1.0, 1.0, 1.0};
    
    // create the CGGradient and then release the gray color space
    CGGradientRef grayScaleGradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);
    CGColorSpaceRelease(colorSpace);
    
    // create the start and end points for the gradient vector (straight down)
    CGPoint gradientStartPoint = CGPointMake(0, reflectionHeight);
    CGPoint gradientEndPoint = CGPointZero;
    
    // draw the gradient into the gray bitmap context
    CGContextDrawLinearGradient(gradientBitmapContext, grayScaleGradient, gradientStartPoint,
                                gradientEndPoint, kCGGradientDrawsAfterEndLocation);
	CGGradientRelease(grayScaleGradient);
	
	// add a black fill with 50% opacity
	CGContextSetGrayFillColor(gradientBitmapContext, 0.0, 0.5);
	CGContextFillRect(gradientBitmapContext, CGRectMake(0, 0, 1, reflectionHeight));
    
    // convert the context into a CGImageRef and release the context
    gradientMaskImage = CGBitmapContextCreateImage(gradientBitmapContext);
    CGContextRelease(gradientBitmapContext);
	
    // create an image by masking the bitmap of the mainView content with the gradient view
    // then release the  pre-masked content bitmap and the gradient bitmap
    CGImageRef reflectionImage = CGImageCreateWithMask(self.CGImage, gradientMaskImage);
    CGImageRelease(gradientMaskImage);
	
	CGSize size = CGSizeMake(self.size.width, self.size.height + reflectionHeight);
	
	UIGraphicsBeginImageContext(size);
	
	[self drawAtPoint:CGPointZero];
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextDrawImage(context, CGRectMake(0, self.size.height, self.size.width, reflectionHeight), reflectionImage);
	
	UIImage* result = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    CGImageRelease(reflectionImage);
	
	return result;
}

static void addRoundedRectToPath(CGContextRef context, CGRect rect, float ovalWidth, float ovalHeight) { //ovalWidth,ovalHeight:圆角大小
	
    float fw, fh;
    if (ovalWidth == 0 || ovalHeight == 0) {
		CGContextAddRect(context, rect);
		return;
    }
    
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextScaleCTM(context, ovalWidth, ovalHeight);
    fw = CGRectGetWidth(rect) / ovalWidth;
    fh = CGRectGetHeight(rect) / ovalHeight;
    
    CGContextMoveToPoint(context, fw, fh/2);  // Start at lower right corner
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);  // Top right corner
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1); // Top left corner
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1); // Lower left corner
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1); // Back to lower right
    
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}

- (UIImage *)createRoundedRectImageWithSize:(CGSize)size {
	// the size of CGContextRef
    int w = size.width;
    int h = size.height;
    
    //UIImage *img = image;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
    CGRect rect = CGRectMake(0, 0, w, h);
    
    CGContextBeginPath(context);
    addRoundedRectToPath(context, rect, 3, 3);
    CGContextClosePath(context);
    CGContextClip(context);
    CGContextDrawImage(context, CGRectMake(0, 0, w, h), self.CGImage);
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    UIImage *image = [UIImage imageWithCGImage:imageMasked];
	CGImageRelease(imageMasked);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return image;
}

- (UIImage *)createRoundedRectImageWithSize:(CGSize)size oval:(int)oval {
        // the size of CGContextRef
    int w = size.width;
    int h = size.height;
    
        //UIImage *img = image;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
    CGRect rect = CGRectMake(0, 0, w, h);
    
    CGContextBeginPath(context);
    addRoundedRectToPath(context, rect, oval, oval);
    CGContextClosePath(context);
    CGContextClip(context);
    CGContextDrawImage(context, CGRectMake(0, 0, w, h), self.CGImage);
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
	UIImage *image = [UIImage imageWithCGImage:imageMasked];
	CGImageRelease(imageMasked);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return image;
}

- (UIImage *)transformWithWidth:(CGFloat)width height:(CGFloat)height {
    
    CGFloat destW = width;
    CGFloat destH = height;
    CGFloat sourceW = width;
    CGFloat sourceH = height;
    CGImageRef imageRef = self.CGImage;
    CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                                destW,
                                                destH,
                                                CGImageGetBitsPerComponent(imageRef),
                                                4 * destW,
                                                CGImageGetColorSpace(imageRef),
                                                (kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst));
    CGContextDrawImage(bitmap, CGRectMake(0, 0, sourceW, sourceH), imageRef);
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    UIImage *result = [UIImage imageWithCGImage:ref];
    CGContextRelease(bitmap);
    CGImageRelease(ref);
    
    return result;
}

- (UIImage *)cropImage:(UIImage *)originalImage size:(CGSize)size {
    if (originalImage == nil) {
        return nil;
    }
	
	CGFloat rate = size.width/size.height;
    CGSize originalSize = originalImage.size;
    CGSize desiredSize = originalSize;
    CGRect cropRect;
    
    // calculate crop rect
    if (desiredSize.width > desiredSize.height * rate) {
        desiredSize.width = fabsf(desiredSize.height * rate);
        cropRect = CGRectMake(0.0, 0.0, desiredSize.width, desiredSize.height);
        cropRect.origin.x = fabsf((originalSize.width - desiredSize.width) / 2);
    }
    else if (desiredSize.height > desiredSize.width / rate) {
        desiredSize.height = fabsf(desiredSize.width / rate);
        cropRect = CGRectMake(0.0, 0.0, desiredSize.width, desiredSize.height);
        cropRect.origin.y = fabsf((originalSize.height - desiredSize.height) / 2);
    }
    else {
        cropRect = CGRectMake(0.0, 0.0, desiredSize.width, desiredSize.height);
    }
	
    // Crop image using crop rect
    UIGraphicsBeginImageContext(desiredSize);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGImageRef imageRef = CGImageCreateWithImageInRect([originalImage CGImage], cropRect);
    CGRect imageRect = CGRectMake(0.0f, 0.0f, desiredSize.width, desiredSize.height);
    
    CGContextClearRect(context, imageRect);
    CGContextScaleCTM(context, 1, -1);
    CGContextTranslateCTM(context, 0, -desiredSize.height);
	CGContextDrawImage(context, imageRect, imageRef);
	UIImage *croppedImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	CGImageRelease(imageRef);
    
    return croppedImage;
}

- (UIImage *)cropImageRect:(CGRect)rect resolution:(BOOL)isRetina {

    // 只在纵向裁剪，且在图片范围内
    if ((self.size.width != rect.size.width) || (rect.origin.y + rect.size.height > self.size.height)) {
        return nil;
    }
	
    // 在这里 iphone 4 需要把裁剪矩形加倍，原因还没考虑清楚.
    if (isRetina) {
        rect.origin.x *=2;
        rect.origin.y *=2;
        rect.size.width *= 2;
        rect.size.height *= 2;
    }
    
    // Crop image using crop rect
    UIGraphicsBeginImageContext(rect.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], rect);
    CGRect imageRect = CGRectMake(0.0f, 0.0f, rect.size.width, rect.size.height);
    
    CGContextClearRect(context, imageRect);
//    CGContextScaleCTM(context, 1, -1);
//    CGContextTranslateCTM(context, 0, -rect.size.height);
	CGContextDrawImage(context, imageRect, imageRef);
	UIImage *croppedImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	CGImageRelease(imageRef);
    
    return croppedImage;
}

// 目前只支持纵向扩展
- (UIImage *)stretchToSize:(CGSize)size leftCapWidth:(int)left topCapHeight:(int)top resolution:(BOOL)isRetina {
    if (size.height <= self.size.height) {
        return self;
    }
    CGRect  topRect    = CGRectMake(0, 0, self.size.width, top);
    CGRect  middleRect = CGRectMake(0, top, self.size.width, 1);
    CGRect  bottomRect = CGRectMake(0, top + 1, self.size.width, self.size.height-top-1);
    UIImage *topImage    = [self cropImageRect:topRect resolution:isRetina];
    UIImage *middleImage = [self cropImageRect:middleRect resolution:isRetina];
    UIImage *bottomImage = [self cropImageRect:bottomRect resolution:isRetina];
    bottomRect.origin.y = size.height - bottomRect.size.height;
    
    int stretchHeight = bottomRect.origin.y - top;
    
    // calculate crop rect
    CGRect stretchRect = CGRectMake(0, 0, self.size.width, size.height);

    // Crop image using crop rect
    UIGraphicsBeginImageContext(stretchRect.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextScaleCTM(context, 1, -1);
//    CGContextTranslateCTM(context, 0, -stretchRect.size.height);
//    CGContextClearRect(context, stretchRect);
//    CGContextFillRect(context, stretchRect);
//    float black[4] = {0, 0, 0, 1};
//    CGContextSetFillColor(context, black);
    
	CGContextDrawImage(context, topRect, topImage.CGImage);
	CGContextDrawImage(context, bottomRect, bottomImage.CGImage);
    
    for (int i = 0; i < stretchHeight; i++) {
        CGContextDrawImage(context, middleRect, middleImage.CGImage);
        middleRect.origin.y++;
    }
    
	UIImage *stretchedImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    
    return stretchedImage;    
}

- (UIImage *)orientationUpImage
{
    UIImageOrientation orientation = self.imageOrientation;
    // just return
    if (orientation == UIImageOrientationUp) {
        return self;
    }
    
    CGImageRef          imgRef = self.CGImage;
	CGFloat             width = CGImageGetWidth(imgRef);
	CGFloat             height = CGImageGetHeight(imgRef);
	CGAffineTransform   transform = CGAffineTransformIdentity;
	CGRect              bounds = CGRectMake(0, 0, width, height);
    CGSize              imageSize = bounds.size;
	CGFloat             boundHeight;

	switch(orientation) {
		case UIImageOrientationUp: //EXIF = 1
			transform = CGAffineTransformIdentity;
			break;
            
		case UIImageOrientationDown: //EXIF = 3
			transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
			transform = CGAffineTransformRotate(transform, M_PI);
			break;
            
		case UIImageOrientationLeft: //EXIF = 6
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
            
		case UIImageOrientationRight: //EXIF = 8
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
            
		default:
            // image is not auto-rotated by the photo picker, so whatever the user
            // sees is what they expect to get. No modification necessary
            transform = CGAffineTransformIdentity;
            break;
	}
    
	UIGraphicsBeginImageContext(bounds.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
    
    if ((orientation == UIImageOrientationDown) || (orientation == UIImageOrientationUp)) {
        // flip the coordinate space upside down
        CGContextScaleCTM(context, 1, -1);
        CGContextTranslateCTM(context, 0, -height);
    }
    if (orientation == UIImageOrientationRight) {
        // flip the coordinate space upside down
        CGContextScaleCTM(context, 1, -1);
        CGContextTranslateCTM(context, 0, -width);
    }
    
	CGContextConcatCTM(context, transform);
	CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
	UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    
	return imageCopy;
}

- (UIImage *)cropImage:(CGRect)rect
{    
    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, rect);
//    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef scale:1.0 orientation:originalImage.imageOrientation];
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return croppedImage;
}

- (UIImage *)cropImage:(CGSize)size center:(CGPoint)center
{
    CGFloat x = center.x - size.width / 2;
    CGFloat y = center.y - size.height / 2;
    CGRect cropRect = CGRectMake(x, y, size.width, size.height);

    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, cropRect);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
        
    return croppedImage;
}

- (UIImage *)rescaleToSize:(CGSize)size {
	CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    CGContextScaleCTM(context, 1, -1);
    CGContextTranslateCTM(context, 0, -size.height);
    // Draw into the context, this scales the image
	CGContextDrawImage(context, rect, self.CGImage);
    UIImage *rescaleImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();  
    
    return rescaleImage;
}

- (UIImage *)imageInRect:(CGRect)rect
{
    CGImageRef ref = CGImageCreateWithImageInRect(self.CGImage, rect);
    UIImage *cropped = [UIImage imageWithCGImage:ref];
    CGImageRelease(ref);
    return cropped;
}

- (UIImage *)scaleAndRotate:(CGFloat)boundWidth and:(CGFloat)boundHeight
{
    CGImageRef imgRef = self.CGImage;
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);

    bounds.size.width = boundWidth;
    bounds.size.height = boundHeight;
    
    CGFloat widthRatio = bounds.size.width / width;
    CGFloat heightRatio = bounds.size.height / height;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat temp;
    UIImageOrientation orient = self.imageOrientation;
    
    switch(orient) {
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            temp = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = temp;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            temp = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = temp;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            temp = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = temp;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            temp = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = temp;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid?image?orientation"];
            break;
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -widthRatio, heightRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, widthRatio, -heightRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return imageCopy;
}

@end
