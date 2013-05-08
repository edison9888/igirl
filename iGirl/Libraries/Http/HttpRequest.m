//
//  HttpRequest.m
//  Roosher
//
//  Created by shenjianguo on 10-9-30.
//  Copyright 2010 Roosher. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>
#import "HttpRequest.h"
#import "NSString+Extra.h"
#import "RequestParameter.h"
#import "DeviceHardware.h"
#import "CLog.h"
//#import "Constants.h"

#define UPLOADIMAGE_REQUEST_BOUNDARY  @"-------------binaryupload-------------"

// Private stuff
@interface HttpRequest ()

@property (copy,   readwrite) NSHTTPURLResponse *lastResponse;

// Internal properties
@property (assign, readwrite) BOOL                  firstData;

- (NSString *)URLStringWithoutQueryFromURL:(NSURL *)theUrl;
- (void)onTimeout;
- (NSData *)buildPostData:(NSDictionary *)params;
- (NSData *)buildUploadData:(NSDictionary *)params uploadData:(NSDictionary *)uploadData;
- (NSDictionary *)buildUploadHeader;

@end


@implementation HttpRequest

@synthesize httpError = _httpError;
@synthesize inProcessNotify = _inProcessNotify;

@synthesize identifier = _identifier;

@synthesize requestMethod;
@synthesize processNotify;


- (void)setPath:(NSString *)path 
{
    _url = [[NSURL alloc] initWithString:path];
}


#pragma mark
#pragma mark Request

- (id)initWithMethod:(NSString *)method
                 url:(NSString *)url
             timeOut:(NSInteger)timeOut 
              header:(NSDictionary *)header
                body:(NSDictionary *)body
               error:(HttpErrorHandler)errorHandler
            complete:(HttpCompleteHandler)completeHandler
{
    self = [super init];
    [self setRequestMethod:method];
    _receiveData   = [[NSMutableData alloc] initWithCapacity:32];
    processNotify  = NO;    
    _header = [[NSDictionary alloc] initWithDictionary:header];
    _errorHandler = errorHandler;
    _completeHandler = completeHandler;
    _url = [[NSURL alloc] initWithString:url];
    _timeOut = timeOut;
    _postBody = [self buildPostData:body];
    
    return self;
}

- (id)initWithMethod:(NSString *)method
                 url:(NSString *)url
             timeOut:(NSInteger)timeOut 
              params:(NSDictionary *)params
          uploadData:(NSDictionary *)uploadData
               error:(HttpErrorHandler)errorHandler
            complete:(HttpCompleteHandler)completeHandler
{
    self = [super init];
    [self setRequestMethod:method];
    _receiveData   = [[NSMutableData alloc] initWithCapacity:32];
    processNotify  = NO;    
    _header = [self buildUploadHeader];
    _errorHandler = errorHandler;
    _completeHandler = completeHandler;
    _url = [[NSURL alloc] initWithString:url];
    _timeOut = timeOut;
    _postBody = [self buildUploadData:params uploadData:uploadData];
    
    return self;
}

#pragma mark * Properties

@synthesize lastResponse    = _lastResponse;
@synthesize firstData       = _firstData;

#pragma mark
#pragma mark Utility

- (NSString *)URLStringWithoutQueryFromURL:(NSURL *)theUrl 
{
    NSArray *parts = [[theUrl absoluteString] componentsSeparatedByString:@"?"];
    return [parts objectAtIndex:0];
}

#pragma mark
#pragma mark * Start and finish overrides

// Called by QRunLoopOperation when the operation starts.  This kicks of an 
// asynchronous NSURLConnection.
- (void)operationDidStart 
{
    assert(_connection == nil);
    
    // Construct an NSMutableURLRequest for the URL and set appropriate request method.
    NSMutableURLRequest *theRequest = [[NSMutableURLRequest alloc] initWithURL:_url 
                                                                   cachePolicy:NSURLRequestReloadIgnoringCacheData 
                                                               timeoutInterval:_timeOut];
    if (requestMethod) {
        [theRequest setHTTPMethod:requestMethod];
    }
    
    NSArray* headerKeys = [_header allKeys];
    for(NSString *key in headerKeys){
        NSString *value = [_header objectForKey:key];
        [theRequest setValue:value forHTTPHeaderField:key];
    }
    
    [theRequest setHTTPBody:_postBody];
    NSString *contentLength = [[NSString alloc] initWithFormat:@"%d", [_postBody length]];
    [theRequest setValue:contentLength forHTTPHeaderField:@"Content-Length"];
    
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = YES;
    
    // Create a connection that's scheduled in the required run loop modes.
    _connection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self startImmediately:NO];
    assert(_connection != nil);
    
    [_connection start];        

#ifdef DEBUG_TIMEINTERVAL
    startTime = [NSDate timeIntervalSinceReferenceDate];
//        NSLog(@"the request timeout: %f", [theRequest timeoutInterval]);
    NSLog(@"the request start: [ %@ ]", self.identifier);
#endif            
        
    _timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:_timeOut target:self selector:@selector(onTimeout) userInfo:nil repeats:NO];
    
//    if ([[UIDevice currentDevice] hasMultitasking]) {
    while(_connection != nil) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];   
    }   
//    }
}

// Called by QRunLoopOperation when the operation has finished.  We 
// do various bits of tidying up.
- (void)operationWillFinish 
{    
    // I can't think of any circumstances under which the debug delay timer 
    // might still be running at this point, but add an assert just to be sure.
    
    [_connection cancel];
    _connection = nil;
        
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = NO;
}

- (void)finishWithError:(NSError *)theError 
{
    if (self.httpError == nil) {
        self.httpError = theError;
    }
    [self operationWillFinish];
}

- (NSData *)buildPostData:(NSDictionary *)params
{
#ifdef DEBUG
    if ([params objectForKey:@"action"]) {
        action = [params objectForKey:@"action"];
    }
    if ([params objectForKey:@"method"]) {
        action = [params objectForKey:@"method"];
    }
    if ([params objectForKey:@"api"]) {
        action = [params objectForKey:@"api"];
    }
#endif

    NSMutableString *encodedParameterPairs = [[NSMutableString alloc] initWithCapacity:256];
    int position = 1;
    for (NSString *key in params) {
        id value = [params objectForKey:key];
//        if ([value isKindOfClass:[NSData class]]) {
//            [encodedParameterPairs appendString:[key URLEncodedString]];
//            [encodedParameterPairs appendString:@"="];
                        
//            NSString *data = [[NSString alloc] initWithBytes:[value bytes] length:[value length] encoding:NSUTF8StringEncoding];
//            [encodedParameterPairs appendString:[NSString stringWithFormat:@"%@=%@", [key URLEncodedString], [data URLEncodedString]]];
//        }
//        else {
            [encodedParameterPairs appendString:[NSString stringWithFormat:@"%@=%@", [key isMemberOfClass:[NSString class]] ? [key URLEncodedString] : key, [value isMemberOfClass:[NSString class]] ? [value URLEncodedString] : value]];
//        }

        if (position < [params count])
            [encodedParameterPairs appendString:@"&"];		
        position++;
    }
#ifdef DEBUG
    NSLog(@"%@", encodedParameterPairs);
#endif
    NSData *postbody = [encodedParameterPairs dataUsingEncoding:NSUTF8StringEncoding];
        
    return postbody;
}

- (NSData *)buildUploadData:(NSDictionary *)params uploadData:(NSDictionary *)uploadData;
{
#ifdef DEBUG
    if ([params objectForKey:@"action"]) {
        action = [params objectForKey:@"action"];
    }
    if ([params objectForKey:@"method"]) {
        action = [params objectForKey:@"method"];
    }
#endif
    NSMutableData *postbody = [[NSMutableData alloc] init];
    [postbody appendData:[[NSString stringWithFormat:@"--%@\r\n",UPLOADIMAGE_REQUEST_BOUNDARY] dataUsingEncoding:NSUTF8StringEncoding]];
    NSData *parameterBoundary = [[NSString stringWithFormat:@"\r\n--%@\r\n",UPLOADIMAGE_REQUEST_BOUNDARY] dataUsingEncoding:NSUTF8StringEncoding];
    
    if ((uploadData == nil) || ([uploadData objectForKey:@"data"] == nil)) {
        for (NSString *key in params) {
            [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
            NSString *value = [NSString stringWithFormat:@"%@", [params objectForKey:key]];
            [postbody appendData:[value dataUsingEncoding:NSUTF8StringEncoding]];
            [postbody appendData:parameterBoundary];
        }
        return postbody;
    }

    for (NSString *key in params) {
        [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
        NSString *value = [NSString stringWithFormat:@"%@", [params objectForKey:key]];
//        NSLog(@"key = %@, value = %@", key, value);
        [postbody appendData:[value dataUsingEncoding:NSUTF8StringEncoding]];
        //[postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [postbody appendData:parameterBoundary];
    }
    
    NSString *field = [uploadData objectForKey:@"field"];
    NSString *fileName = [uploadData objectForKey:@"file"];
//    [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", @"upload_file", @"image.jpg"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", field, fileName] dataUsingEncoding:NSUTF8StringEncoding]];
    
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension,
                                                            (__bridge CFStringRef)[fileName pathExtension],
                                                            NULL);
    CFStringRef mime = UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType);
    CFRelease(UTI);
    [postbody appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", (__bridge_transfer NSString *)mime] dataUsingEncoding:NSUTF8StringEncoding]];
//    CFRelease(mime);
    
    NSData *data = [uploadData objectForKey:@"data"];
    [postbody appendData:data];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",UPLOADIMAGE_REQUEST_BOUNDARY] dataUsingEncoding:NSUTF8StringEncoding]];
    
    return postbody;
}

- (NSDictionary *)buildUploadHeader
{
    NSString *contentType = [[NSString alloc] initWithFormat:@"multipart/form-data; boundary=%@", UPLOADIMAGE_REQUEST_BOUNDARY];
    NSMutableDictionary *headerField = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"gzip,deflate", @"Accept-Encoding", nil];
    [headerField setValue:contentType forKey:@"Content-Type"];
    return headerField;
}


#pragma mark
#pragma mark NSURLConnection delegate

// A delegate method called by the NSURLConnection when the request/response 
// exchange is complete.  We look at the response to check that the HTTP 
// status code is 2xx and that the Content-Type is acceptable.  If these checks 
// fail, we give up on the transfer.
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response 
{
    #pragma unused(connection)
    assert(connection == _connection);
    
    [_receiveData setLength:0];
    if ([_timeoutTimer isValid]) {
        [_timeoutTimer invalidate];
    }
    
#ifdef DEBUG_TIMEINTERVAL    
    reponseTime = [NSDate timeIntervalSinceReferenceDate];
    NSLog(@"the request didReceiveResponse: [ %@ ] time ==> %f", self.identifier, reponseTime - startTime);
#endif
    
    // Get response code.
    NSHTTPURLResponse *resp = (NSHTTPURLResponse *)response;
    assert( [resp isKindOfClass:[NSHTTPURLResponse class]]);
    self.lastResponse = (NSHTTPURLResponse *)response;
    int statusCode = [resp statusCode];
    
    if ((statusCode / 100) != 2) {        
        if (statusCode >= 400) {
            // Assume failure, and report to delegate.
            _httpError = [[NSError alloc] initWithDomain:HttpRequestErrorDomain code:statusCode userInfo:nil];
            [self finishWithError:[self httpError]];

            dispatch_async(dispatch_get_main_queue(), ^{
                if (_errorHandler)
                    _errorHandler(_httpError, _identifier);
            });
        }
    } 
    else {
        if([self inProcessNotify]){
            NSDictionary *info;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (_completeHandler) {
                    _completeHandler(info, _identifier);
                }
            });
        }
    }
    
#ifdef DEBUG    
    // Display headers for debugging.
    if ((statusCode / 100) != 2) {
        NSLog(@"%@ HttpResponse: (%d) [%@]:\r%@", _identifier, statusCode, 
              [NSHTTPURLResponse localizedStringForStatusCode:statusCode], 
              [resp allHeaderFields]);
    }
#endif
}

// A delegate method called by the NSURLConnection as data arrives.
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data 
{
    #pragma unused(connection)    
    assert(connection == _connection);
    assert(data != nil);
    
    [_receiveData appendData:data];
    
    if ([_timeoutTimer isValid]) {
        [_timeoutTimer invalidate];
    }

    if([self inProcessNotify]){
        NSDictionary *info;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_completeHandler) {
                _completeHandler(info, _identifier);
            }
        });
    }
    
    
#ifdef DEBUG_TIMEINTERVAL    
    NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];
    NSLog(@"the request didReceiveData: [ %@ ] time ==> %f", self.identifier, currentTime - reponseTime);
#endif        
    self.firstData = NO;

}

// A delegate method called by the NSURLConnection when the connection has been 
// done successfully
- (void)connectionDidFinishLoading:(NSURLConnection *)connection 
{
    #pragma unused(connection)
    assert(connection == _connection);
    assert(self.lastResponse != nil);
    
    if ([_timeoutTimer isValid]) {
        [_timeoutTimer invalidate];
    }
    
    [self finishWithError:nil];

    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
                          _receiveData,     @"data",
                          nil];
    
#ifdef DEBUG    
    NSString *responseString = [[NSString alloc] initWithData:_receiveData encoding:NSUTF8StringEncoding];    
    if(responseString){
        NSLog(@"id:%@\r\naction:%@\r\nresponse data:%@", _identifier, action, responseString);
    }
#endif
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_completeHandler) {
            _completeHandler(info, _identifier);
        }
    });
}

// A delegate method called by the NSURLConnection if the connection fails
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error 
{
#pragma unused(connection)
    assert(connection == _connection);
    assert(error != nil);
    
    if ([_timeoutTimer isValid]) {
        [_timeoutTimer invalidate];
    }
    
    [self setHttpError:error];
    
    [self finishWithError:[self httpError]];
    
#ifdef DEBUG    
    NSLog(@"%@ HttpRequest: %@", _identifier, [self httpError]);
#endif
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_errorHandler)
            _errorHandler(_httpError, _identifier);
    });
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace 
{
    #pragma unused(connection)
    if([[protectionSpace authenticationMethod] isEqualToString:NSURLAuthenticationMethodServerTrust]){
        //NSLog(@"Server Trust will be checked");
        // didReceiveAuthenticationChallenge takes care of certificate control
        return YES;
    }
    return NO;
}

-(void)connection:(NSURLConnection *)connection
didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge 
{
    #pragma unused(connection)
    SecTrustRef         trustRef = challenge.protectionSpace.serverTrust;
    SecTrustResultType  result = 0;
    NSURLCredential    *credential = nil;
    
    SecTrustEvaluate(trustRef, &result);
    credential = [NSURLCredential credentialForTrust:trustRef];
    if(credential) {
        [challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
    }
    else {
        [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
    }   
}

//handle request time out
- (void) onTimeout 
{
#ifdef DEBUG    
    NSLog(@"%@ HttpRequest timeout", _identifier);
#endif

    _httpError = [[NSError alloc] initWithDomain:NSURLErrorDomain code:-1001 userInfo:nil];
    [self finishWithError:_httpError];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_errorHandler)
            _errorHandler(_httpError, _identifier);
    });
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite 
{
    if ([self inProcessNotify]) {
        NSDictionary *info;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_completeHandler) {
                _completeHandler(info, _identifier);
            }
        });
    }
}

@end
