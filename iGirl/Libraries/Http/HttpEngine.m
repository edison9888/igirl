//
//  HttpEngine.m
//  TestAsiHttp
//
//  Created by shenjianguo on 10-9-26.
//  Copyright 2010 Roosher. All rights reserved.
//

#import "HttpEngine.h"
#import "NSString+Extra.h"
#import "RequestParameter.h"

@interface HttpEngine (Private)

+ (void)createRequestWithMethod:(NSString *)method
                            url:(NSString *)url 
                        timeOut:(NSInteger)timeOut 
                         header:(NSDictionary *)headerField 
                           body:(NSDictionary *)body 
                          error:(HttpErrorHandler)errorHandler
                       complete:(HttpCompleteHandler)completeHandler
                inProcessNotify:(BOOL)inProcessNotify
                     identifier:(NSString *)identifier;
+ (void)createRequestWithMethod:(NSString *)method
                            url:(NSString *)url 
                        timeOut:(NSInteger)timeOut 
                         params:(NSDictionary *)params
                      imageData:(NSData *)imageData
                          error:(HttpErrorHandler)errorHandler
                       complete:(HttpCompleteHandler)completeHandler
                inProcessNotify:(BOOL)inProcessNotify
                     identifier:(NSString *)identifier;
@end


@implementation HttpEngine

+ (void)createRequestWithMethod:(NSString *)method
                            url:(NSString *)url 
                        timeOut:(NSInteger)timeOut 
                         header:(NSDictionary *)headerField 
                           body:(NSDictionary *)body 
                          error:(HttpErrorHandler)errorHandler
                       complete:(HttpCompleteHandler)completeHandler
                inProcessNotify:(BOOL)inProcessNotify
                     identifier:(NSString *)identifier
{
    HttpRequest *operation = [[HttpRequest alloc] initWithMethod:method url:url timeOut:timeOut header:headerField body:body error:errorHandler complete:completeHandler];
    [operation setInProcessNotify:inProcessNotify];
    [operation setIdentifier:identifier];
    [operation operationDidStart];
}

+ (void)createRequestWithMethod:(NSString *)method
                            url:(NSString *)url 
                        timeOut:(NSInteger)timeOut 
                         params:(NSDictionary *)params
                     uploadData:(NSDictionary *)uploadData
                          error:(HttpErrorHandler)errorHandler
                       complete:(HttpCompleteHandler)completeHandler
                inProcessNotify:(BOOL)inProcessNotify
                     identifier:(NSString *)identifier
{
    HttpRequest *operation = [[HttpRequest alloc] initWithMethod:method url:url timeOut:timeOut params:params uploadData:uploadData error:errorHandler complete:completeHandler];
    [operation setInProcessNotify:inProcessNotify];
    [operation setIdentifier:identifier];
    [operation operationDidStart];
}

+ (NSString *)doHttpPost:(NSString *)url 
                 timeOut:(NSInteger)timeOut 
                  header:(NSDictionary *)headerField 
                    body:(NSDictionary *)body 
                   error:(HttpErrorHandler)errorHandler
                complete:(HttpCompleteHandler)completeHandler
{
    NSString *identifier = [[NSProcessInfo processInfo] globallyUniqueString];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        [self createRequestWithMethod:@"POST"
                                  url:url
                              timeOut:timeOut
                               header:headerField
                                 body:body
                                error:errorHandler
                             complete:completeHandler
                      inProcessNotify:NO
                           identifier:identifier];
    });
    return identifier;
}

+ (NSString *)doHttpGet:(NSString *)url
                timeOut:(NSInteger)timeOut
                 header:(NSDictionary *)headerField
                  error:(HttpErrorHandler)errorHandler
               complete:(HttpCompleteHandler)completeHandler
{
    NSString *identifier = [[NSProcessInfo processInfo] globallyUniqueString];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        [self createRequestWithMethod:@"GET"
                                  url:url
                              timeOut:timeOut
                               header:headerField
                                 body:nil
                                error:errorHandler
                             complete:completeHandler
                      inProcessNotify:NO
                           identifier:identifier];
    });
    return identifier;
}

+ (NSString *)doHttpGet:(NSString *)url
                timeOut:(NSInteger)timeOut
                 header:(NSDictionary *)headerField
                   body:(NSDictionary *)body
                  error:(HttpErrorHandler)errorHandler
               complete:(HttpCompleteHandler)completeHandler
{
    NSString *identifier = [[NSProcessInfo processInfo] globallyUniqueString];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        NSMutableString *realUrl = [NSMutableString stringWithString:url];
        if (body && body.count > 0) {
            NSMutableArray *pairs = [NSMutableArray array];
            for (NSString *key in [body keyEnumerator]) {
                if (!([[body valueForKey:key] isKindOfClass:[NSString class]])) {
                    continue;
                }
                
                [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, [[body objectForKey:key] URLEncodedString]]];
            }
            if (pairs.count > 0) {
                NSURL *parsedURL = [NSURL URLWithString:url];
                NSString *queryPrefix = parsedURL.query ? @"&" : @"?";
                NSString *urlTail = [pairs componentsJoinedByString:@"&"];
                [realUrl appendFormat:@"%@%@", queryPrefix, urlTail];
            }
        }
        [self createRequestWithMethod:@"GET"
                                  url:realUrl
                              timeOut:timeOut
                               header:headerField
                                 body:nil
                                error:errorHandler
                             complete:completeHandler
                      inProcessNotify:NO
                           identifier:identifier];
    });
    return identifier;
}

+ (NSString *)doUploadImage:(NSString *)url
                    timeOut:(NSInteger)timeOut
                     params:(NSDictionary *)params
                 uploadData:(NSDictionary *)uploadData
                      error:(HttpErrorHandler)errorHandler
                   complete:(HttpCompleteHandler)completeHandler
{    
    NSString *identifier = [[NSProcessInfo processInfo] globallyUniqueString];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        [self createRequestWithMethod:@"POST"
                                  url:url
                              timeOut:timeOut
                               params:params
                           uploadData:uploadData
                                error:errorHandler
                             complete:completeHandler
                      inProcessNotify:NO
                           identifier:identifier];
    });
    return identifier;
}

#pragma mark
#pragma mark Constructors

@end
