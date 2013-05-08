//
//  DownloadManager.m
//  TingTing
//
//  Created by zhang on 12-11-25.
//  Copyright (c) 2012年 Comic78. All rights reserved.
//

#import "DownloadManager.h"
#import "Constants.h"
#import "Constants+APIRequest.h"
#import "Constants+ErrorCodeDef.h"
#import "Constants+NotificationName.h"
#import "DataEngine.h"
#import "LocalSettings.h"

@interface DownloadManager (Private)

- (void)responseGetUrl:(NSNotification *) notification;
- (void)sendStatus;
@end

@implementation DownloadManager
@synthesize isDownloading;
- (id)init
{
    if ([super init]) {
        isDownloading = NO;
        _source = [NSString stringWithFormat:@"%@", self];
        request = [[NSMutableURLRequest alloc] init];
        downloadingIndex = 0;
        retryCount = 0;
    }
    return self;
}

- (void)addDownloadObject:(NSNumber *) bookId
              downloadUrl:(NSString *) downloadUrl
{
    for (int i=0; i<[[DataEngine sharedDataEngine].downloadings count]; i++) {
        DownloadObject *obj = [[DataEngine sharedDataEngine].downloadings objectAtIndex:i];
        if ([obj.bookId isEqualToNumber:bookId]) {
            // 滤重
            return;
        }
    }
    
    DownloadObject *downloadObject = [[DownloadObject alloc] init];
    downloadObject.bookId = bookId;
    downloadObject.downloadUrl = downloadUrl;
    downloadObject.nowRange = [NSNumber numberWithInt:0];
    downloadObject.allRange = [NSNumber numberWithInt:0];
    downloadObject.status = kDownloadObjectStatusWaitDownload;
    
    [[DataEngine sharedDataEngine].downloadings addObject:downloadObject];
}

- (void)startDownload
{
    NSMutableArray *array = [DataEngine sharedDataEngine].downloadings;
    NSLog(@"downloadList:%@", array);
    if (isDownloading) {
        return;
    }
    if (array && [array count] > 0) {
        DownloadObject *object = [array objectAtIndex:downloadingIndex];
        
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
        [userInfo setObject:object.bookId forKey:@"bookId"];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DOWNLOAD_ITEM_START
                                                            object:nil
                                                          userInfo:userInfo];

        NSString *downloadPath = [LocalSettings downloadPdfPath];
        NSString *downloadDownloadBookPath = [downloadPath stringByAppendingFormat:@"/%@", object.bookId];
        if (![[NSFileManager defaultManager] fileExistsAtPath:downloadDownloadBookPath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:downloadDownloadBookPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        // 删掉原先没有下载完或者下载过的临时文件以及pdf
        NSString *downloadFilePath = [downloadDownloadBookPath stringByAppendingString:[NSString stringWithFormat:@"/%@.pdf", object.bookId]];
        NSString *downloadTempFilePath = [downloadDownloadBookPath stringByAppendingString:[NSString stringWithFormat:@"/%@.pdf.m15", object.bookId]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:downloadFilePath] || [[NSFileManager defaultManager] fileExistsAtPath:downloadTempFilePath]) {
            [[NSFileManager defaultManager] removeItemAtPath:downloadFilePath error:nil];
            [[NSFileManager defaultManager] removeItemAtPath:downloadTempFilePath error:nil];
        }
        
        // URL ENCODE
        NSString *url =[object.downloadUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"down url:%@", url);
        request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]
                                               cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                           timeoutInterval:60];
        
        // 伪造header
        //            [request addValue:[DataEngine sharedDataEngine].getUserAgent forHTTPHeaderField:@"User-Agent"];
        
        // 断点续传
        if (object.nowRange && [object.nowRange longLongValue] > 0) {
            NSLog(@"断点续传");
            [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
            NSString *rangeString = [NSString stringWithFormat:@"bytes=%lld-%lld", [object.nowRange longLongValue], [object.allRange longLongValue]];
            [request setValue:rangeString forHTTPHeaderField:@"Range"];
            receiveDataLength = [object.nowRange longLongValue];
        } else {
            receiveDataLength = 0;
        }
        
        if (conn) {
            [conn cancel];
            conn = nil;
        }
        downloadingFileLength = 0;
        mimeType = nil;
        downloadingBookPath = nil;
        UIApplication* app = [UIApplication sharedApplication];
        app.networkActivityIndicatorVisible = YES;
        conn = [[NSURLConnection alloc] initWithRequest:request
                                               delegate:self
                                       startImmediately:YES];
        [self sendStatus];
    }
}

- (void)connection:(NSURLConnection *)aConn didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
	receivedStatus = [httpResponse statusCode];
    if(httpResponse && [httpResponse respondsToSelector:@selector(allHeaderFields)]){
        NSDictionary *httpResponseHeaderFields = [httpResponse allHeaderFields];
        // 取文件长度
        downloadingFileLength = [[httpResponseHeaderFields objectForKey:@"Content-Length"] longLongValue];
    }
    mimeType = [httpResponse MIMEType];
    isDownloading = YES;
    sendStatusTimer = [NSTimer scheduledTimerWithTimeInterval:1.5f target:self selector:@selector(sendStatus) userInfo:nil repeats:YES];
    [sendStatusTimer fire];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

- (void)connection:(NSURLConnection *)aConn didReceiveData:(NSData *)data
{
    NSMutableArray *array = [DataEngine sharedDataEngine].downloadings;
    DownloadObject *object = [array objectAtIndex:downloadingIndex];
    if (!downloadingBookPath || [downloadingBookPath length] == 0) {
        downloadingBookPath = [NSString stringWithFormat:@"%@/%@/%@.pdf.m15", [LocalSettings downloadPdfPath], object.bookId, object.bookId];
        NSLog(@"downloadingBookPath:%@", downloadingBookPath);
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:downloadingBookPath isDirectory:NO]) {
        NSFileHandle  *outFile = [NSFileHandle fileHandleForWritingAtPath:downloadingBookPath];
        [outFile seekToEndOfFile];
        [outFile writeData:data];
        [outFile closeFile];
    } else {
        [data writeToFile:downloadingBookPath atomically:YES];
    }
//	[receiveData appendData:data];
    receiveDataLength += [data length];
    
//    NSLog(@"receiveDataLength len:%lld, need len:%lld, %f", receiveDataLength, downloadingFileLength, ((double)receiveDataLength / (double)downloadingFileLength));

    object.nowRange = [NSNumber numberWithUnsignedLongLong:receiveDataLength];
    if ([object.allRange doubleValue] <= 0) {
        object.allRange = [NSNumber numberWithUnsignedLongLong:downloadingFileLength];
    }
    [LocalSettings saveDownloading:array];
}

- (void)connection:(NSURLConnection *)aConn didFailWithError:(NSError *)error
{
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = NO;
	NSLog(@"error=%@", error);

    // 重试两次
    if (retryCount < 2) {
        retryCount += 1;
        isDownloading = NO;
        [self startDownload];
    } else {
        DownloadObject *obj = [[DataEngine sharedDataEngine].downloadings objectAtIndex:downloadingIndex];
        [obj setStatus:kDownloadObjectStatusWaitDownload];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DOWNLOAD_ITEM_ERROR
                                                            object:nil];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)aConn
{
	NSMutableArray *array = [DataEngine sharedDataEngine].downloadings;

    isDownloading = NO;

    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = NO;

    NSString *finishPath = [downloadingBookPath stringByReplacingOccurrencesOfString:@".m15" withString:@""];
    [[NSFileManager defaultManager] copyItemAtPath:downloadingBookPath toPath:finishPath error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:downloadingBookPath error:nil];
    DownloadObject *downloadObject = [array objectAtIndex:downloadingIndex];
    downloadObject.status = kDownloadObjectStatusDownloadFinish;
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setValue:[NSNumber numberWithInt:[downloadObject.bookId intValue]] forKey:@"bookId"];
    [array removeObjectAtIndex:downloadingIndex];
    if ([array count] > 0) {
        // 继续下载其他的
        [self startDownload];
    }
    [LocalSettings saveDownloading:array];
    [sendStatusTimer invalidate];
    sendStatusTimer = nil;
    [self sendStatus];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DOWNLOAD_ITEM_FINISH
                                                        object:nil
                                                      userInfo:userInfo];
}

- (void)responseGetUrl:(NSNotification *) notification
{
    NSDictionary *dictionary = (NSDictionary *)[notification userInfo];
    if (![[dictionary objectForKey:REQUEST_SOURCE_KEY] isEqualToString:_source]) {
        return;
    }
    NSString *info = [[notification userInfo] objectForKey:RETURN_CODE];
    if (info && [info isKindOfClass:[NSString class]] && [info length] > 0) {
        DownloadObject *object = [[DataEngine sharedDataEngine].downloadings objectAtIndex:downloadingIndex];
        object.downloadUrl = info;
        object.status = kDownloadObjectStatusWaitDownload;
        [LocalSettings saveDownloading:[DataEngine sharedDataEngine].downloadings];
        [self startDownload];
    }
}

- (void)sendStatus
{
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    if ([[DataEngine sharedDataEngine].downloadings count] > 0) {
        DownloadObject *object = [[DataEngine sharedDataEngine].downloadings objectAtIndex:downloadingIndex];

        [userInfo setObject:[NSNumber numberWithInt:[object.bookId intValue]] forKey:@"bookId"];
        
        float progress = ((double)receiveDataLength / (double)downloadingFileLength);
        [userInfo setObject:[NSNumber numberWithFloat:progress] forKey:@"progress"];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DOWNLOAD_STATUS_REFRESH
                                                        object:nil
                                                      userInfo:userInfo];
}

- (void)cancelDownload:(int)index
{
    // 取消下载并删除正在下载的临时文件
    DownloadObject *obj = [[DataEngine sharedDataEngine].downloadings objectAtIndex:index];
    [self pauseDownload];
    NSString *deleteFilePath = [NSString stringWithFormat:@"%@/%@/%@.pdf.m15", [LocalSettings downloadPdfPath], obj.bookId, obj.bookId];
    if ([[NSFileManager defaultManager] fileExistsAtPath:deleteFilePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:deleteFilePath error:nil];
    }
    [[DataEngine sharedDataEngine].downloadings removeObjectAtIndex:index];
}

- (void)pauseDownload
{
    [conn cancel];
    isDownloading = NO;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
