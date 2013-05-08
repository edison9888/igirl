//
//  DiscussReplyViewController.h
//  iAccessories
//
//  Created by zhang on 13-3-29.
//  Copyright (c) 2013年 MobileWoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DiscussReplyViewController : UIViewController<UITextFieldDelegate, UITextViewDelegate>
{
    NSString *_controllerId;
    IBOutlet UITextField *nickNameTextField;
    IBOutlet UITextView *contentTextView;
    NSNumber *discussId;
}
@property (nonatomic, retain) NSNumber *discussId;

@end
