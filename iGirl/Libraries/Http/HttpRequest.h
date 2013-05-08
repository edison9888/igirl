//
//  HttpRequest.h
//  Roosher
//
//  Created by shenjianguo on 10-9-30.
//  Copyright 2010 Roosher. All rights reserved.
//

#import <Foundation/Foundation.h>

#define HttpRequestErrorDomain  @"HttpRequestErrorDomain"

typedef void (^HttpCompleteHandler)(NSDictionary *info, NSString *identifier);
typedef void (^HttpErrorHandler)(NSError *error, NSString *identifier);

// positive error codes are HTML status codes (when they are not allowed via acceptableStatusCodes)
//
// 0 is, of course, not a valid error code
//
// negative error codes are errors from the module

enum {
    kHttpRequestErrorResponseTooLarge = -1, 
    kHttpRequestErrorOnOutputStream   = -2, 
    kHttpRequestErrorBadContentType   = -3
};

@interface HttpRequest : NSObject 
{
    NSInteger                               _timeOut;
    NSString                                *_identifier;
    
    NSURL                                   *_url;
    NSDictionary                            *_header;
    NSData                                  *_postBody;
    NSString                                *requestMethod;
    NSMutableData                           *_receiveData;
    
    NSError                                 *_httpError;
        
    BOOL                                    _inProcessNotify;
            
    NSURLConnection     *_connection;
    
    NSTimer             *_timeoutTimer;
//    BOOL                processNotify;
    
//#ifdef DEBUG_TIMEINTERVAL    
//    NSTimeInterval      startTime;
//    NSTimeInterval      redirectTime;
//    NSTimeInterval      reponseTime;
//#endif
    HttpCompleteHandler _completeHandler;
    HttpErrorHandler _errorHandler;
    
#ifdef DEBUG
    NSString *action;
#endif
}

@property (strong) NSError *httpError;
@property (assign) BOOL inProcessNotify;

@property (copy) NSString *identifier;
@property (copy) NSString *requestMethod;

@property (copy, readonly) NSHTTPURLResponse * lastResponse;       

@property (assign) BOOL processNotify;

#pragma mark init / dealloc

// constructor
- (id)initWithMethod:(NSString *)method
                 url:(NSString *)url
             timeOut:(NSInteger)timeOut 
              header:(NSDictionary *)header
                body:(NSDictionary *)body
               error:(HttpErrorHandler)errorHandler
            complete:(HttpCompleteHandler)completeHandler;

- (id)initWithMethod:(NSString *)method
                 url:(NSString *)url
             timeOut:(NSInteger)timeOut 
              params:(NSDictionary *)params
          uploadData:(NSDictionary *)uploadData
               error:(HttpErrorHandler)errorHandler
            complete:(HttpCompleteHandler)completeHandler;

- (void)setPath:(NSString *)path;
- (void)operationDidStart;

@end
