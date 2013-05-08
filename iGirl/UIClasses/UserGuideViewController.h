//
//  UserGuideViewController.h
//  iAccessories
//
//  Created by zhang on 13-4-25.
//  Copyright (c) 2013年 MobileWoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Ke : NSObject {
    NSString *text;
    NSString *image;
}
@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSString *image;

@end

@interface UserGuideViewController : UIViewController
{
    IBOutlet UIImageView *phoneLeftImageView;
    IBOutlet UIImageView *phoneRightImageView;
    IBOutlet UIImageView *phoneShadow;
    
    IBOutlet UIImageView *image1;
    IBOutlet UIImageView *image2;
    IBOutlet UIImageView *huangImage;

    IBOutlet UIButton *skipButton;
    
    IBOutlet UIView *phoneImageView;
    IBOutlet UIView *huangBodyView;
    
    IBOutlet UILabel *textLabel;
    IBOutlet UIButton *closeButton;
    
    NSMutableArray *ke;
    
    int animationIndex;
    
    BOOL isSkiped;
}

- (IBAction)close:(id)sender;
- (IBAction)skipButtonClick:(id)sender;

@end
