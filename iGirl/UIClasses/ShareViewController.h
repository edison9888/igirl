//
//  ShareViewController.h
//  iAccessories
//
//  Created by zhang on 12-10-19.
//  Copyright (c) 2012年 MobileWoo. All rights reserved.
//

#import <UIKit/UIKit.h>

#define DESCRIPTION_MAX_LENGTH          100
#define DESCRIPTION_TIP_LENGTH          3

@interface ShareViewController : UIViewController<UITextViewDelegate, UIGestureRecognizerDelegate> {
    NSString *_controllerId;
    
    IBOutlet UIImageView *imageView, *adImageView;
    IBOutlet UITextView *shareTextView;
    IBOutlet UILabel    *textLabel;
    
    IBOutlet UIButton *shareTemplate1, *shareTemplate2, *shareTemplate3, *shareTemplate4, *shareButton;
    
    IBOutlet UIButton *clearTextButton;
    
    IBOutlet UIView *shareBodyView;
    
    NSMutableArray *templateArray;
    
    NSString *shareImagePath;
    NSNumber *treasureId;
    int lastSelectButtonTag;
}
@property (nonatomic, retain) NSNumber *treasureId;
@property (nonatomic, retain) NSString *shareImagePath;

@end
