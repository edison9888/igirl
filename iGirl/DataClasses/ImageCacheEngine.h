//
//  ImageCacheEngine.h
//  Three Hundred
//
//  Created by skye on 8/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageCacheEngine : NSObject {
    NSString            *_imageRootDir;
	NSFileManager       *_fileManager;
}

@property (nonatomic, readonly) NSString *imageRootDir;

+ (ImageCacheEngine *)sharedInstance;
- (ImageCacheEngine *)init;

// get image from disk.
- (NSString *)getImagePathByUrl:(NSString *)url;

// store image to local storage.
- (NSString *)setImagePath:(NSData *)data 
                    forUrl:(NSString *)url;


@end
