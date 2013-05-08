//
//  DiscussDetailViewController.h
//  iAccessories
//
//  Created by zhang on 13-3-29.
//  Copyright (c) 2013年 MobileWoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DiscussDetailViewController : UIViewController<UIWebViewDelegate>
{
    IBOutlet UIButton *replyButton;
    IBOutlet UIWebView *discussDetailWebView;
    NSString *discussDetailUrl;
    NSNumber *discussId;
}
@property (nonatomic, retain) NSString *discussDetailUrl;
@property (nonatomic, retain) NSNumber *discussId;

- (IBAction)replyButtonClick:(id)sender;

@end
