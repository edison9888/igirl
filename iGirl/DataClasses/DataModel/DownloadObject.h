//
//  DownloadObject.h
//  iAccessories
//
//  Created by zhang on 12-11-26.
//  Copyright (c) 2012年 MobileWoo. All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
    kDownloadObjectStatusWaitDownload = 0,
    kDownloadObjectStatusDownloadFinish = 1
} typedef DownloadObjectStatus;

@interface DownloadObject : NSObject {
    NSNumber *bookId;
    NSNumber *nowRange;
    NSNumber *allRange;
    DownloadObjectStatus status;
    NSString *downloadUrl;
}

@property (nonatomic, retain) NSNumber *bookId;
@property (nonatomic, retain) NSNumber *nowRange;
@property (nonatomic, retain) NSNumber *allRange;
@property (nonatomic, retain) NSString *downloadUrl;
@property (nonatomic, assign) DownloadObjectStatus status;

@end
