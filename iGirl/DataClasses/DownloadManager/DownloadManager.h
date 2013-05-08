//
//  DownloadManager.h
//  TingTing
//
//  Created by zhang on 12-11-25.
//  Copyright (c) 2012年 Comic78. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownloadObject.h"

@interface DownloadManager : NSObject <NSURLConnectionDelegate> {
	NSString *_source;
	NSMutableURLRequest *request;
    NSURLConnection *conn;

    NSString *mimeType;
    NSString *downloadingBookPath;
    
    long long downloadingFileLength;
    long long receiveDataLength;

    int downloadingIndex;
    int receivedStatus;

    int retryCount;
    BOOL isDownloading;
    
    NSTimer *sendStatusTimer;
}

@property (readonly) BOOL isDownloading;

- (void)startDownload;
- (void)pauseDownload;
- (void)cancelDownload:(int)index;

- (void)addDownloadObject:(NSNumber *) bookId
              downloadUrl:(NSString *) downloadUrl;

@end
