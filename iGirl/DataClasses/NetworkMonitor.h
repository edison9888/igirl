//
//  NetworkMonitor.h
//  ThreeHundred
//
//  Created by skye on 1/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

@interface NetworkMonitor : NSObject <UIAlertViewDelegate>
{
    Reachability *hostReach;
    Reachability *internetReach;
    BOOL networkReachable;
    NetworkStatus _networkStatus;
    id _showingAlert;
}

@property (assign) NetworkStatus networkStatus;

+ (NetworkMonitor *)sharedInstance;
+ (NetworkStatus)status;

- (void)start;
- (BOOL)reachable;

@end
