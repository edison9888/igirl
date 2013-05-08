//
//  Share2ViewController.h
//  iAccessories
//
//  Created by zhang on 13-4-19.
//  Copyright (c) 2013年 MobileWoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Share2ViewController : UIViewController<UITextViewDelegate> {
    NSString *_controllerId;
    
    NSString *shareText, *shareLink;
    IBOutlet UITextView *shareTextView;
    IBOutlet UIButton *clearTextButton;
    IBOutlet UILabel *textLabel;
    
}

@property (nonatomic, retain) NSString *shareText, *shareLink;

@end
