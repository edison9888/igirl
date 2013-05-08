//
//  DistanceUtils.h
//  Three Hundred
//
//  Created by 郭雪 on 11-8-16.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#include <math.h>

#define kEarthRadiusInMeters 6378100.0 //based off google calculator 
#define kEarthRadiusInMiles 3962.71353

@interface DistanceUtils : NSObject {
    
}

+ (float)distance:(CLLocationCoordinate2D)first second:(CLLocationCoordinate2D)second;
+ (int)distanceInMeters:(CLLocationCoordinate2D)first second:(CLLocationCoordinate2D)second;

+ (float)calculatePaddingMaxCoord:(CLLocationCoordinate2D)maxCoord minCoord:(CLLocationCoordinate2D)minCoord vertical:(BOOL)vertical;

+ (float)toRadians:(float)degrees;
+ (float)toDegrees:(float)radians;

+ (NSString*) getBearingNameFromDegrees:(double)degrees;
+ (int) getBearingFromCoordinate:(CLLocationCoordinate2D)fromCoordinate toCoordinate:(CLLocationCoordinate2D)toCoordinate;

+ (CLLocationCoordinate2D) inverseFromCoordinate:(CLLocationCoordinate2D)coordinate miles:(NSInteger)miles degrees:(NSInteger)degrees;
+ (CLLocationCoordinate2D) inverseFromCoordinate:(CLLocationCoordinate2D)coordinate meters:(NSInteger)meters degrees:(NSInteger)degrees;
+ (int)milesToMeters:(float)miles;
+ (float)metersToMiles:(int)meters;
+ (float)ngt1:(float)x;
+ (float)hav:(float)x;
+ (float)ahav:(float)x;
+ (float)sec:(float)x;
+ (float)csc:(float)x;

//add by wangzhaoqi
+ (NSString *)getDistanceString:(double)lon 
                            lat:(double)lat 
                          mylon:(double)mylon 
                          mylat:(double)mylat;

@end
