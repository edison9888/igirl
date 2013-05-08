//
//  Book.h
//  iGirl
//
//  Created by zhang on 13-5-2.
//  Copyright (c) 2013年 MobileWoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Book : NSObject {
    NSNumber *bookId;
    NSString *picUrl;
    NSString *link;
}

@property (nonatomic, retain) NSNumber *bookId;
@property (nonatomic, retain) NSString *picUrl;
@property (nonatomic, retain) NSString *link;

@end
