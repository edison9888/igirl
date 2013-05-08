//
//  FeedbackViewController.h
//  trover
//
//  Created by skye on 8/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CustomPlaceholderTextview;

@interface FeedbackViewController : UIViewController <UITextViewDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate>
{
    NSString                                *_controllerId;
    
    // 联系方式
    IBOutlet UIImageView                    *_contactBg;
    IBOutlet UITextField                    *_contactField;
    
    // 反馈输入框背景图片
    IBOutlet UIImageView                    *feedbackBg;
    // 反馈输入框
    IBOutlet CustomPlaceholderTextview      *feedbackTextView;
}

- (IBAction) cancel:(id)sender;

@end
