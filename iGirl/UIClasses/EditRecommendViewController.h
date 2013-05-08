//
//  RecommendItemsViewController.h
//  iAccessories
//
//  Created by sunxq on 12-12-19.
//  Copyright (c) 2012年 MobileWoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Treasure;

@interface EditRecommendViewController : UIViewController
{
    NSString                         *_controllerId;
    
    IBOutlet UIScrollView            *_scrollView;
    NSArray                          *_items;
    NSMutableArray                   *_catId;
}

@property (nonatomic, retain) NSString *controllerId;
@property (nonatomic, retain) NSMutableArray *catId;

- (void)requestDownloadImage:(Treasure *)treasure;

@end
