//
//  AboutController.h
//  ThreeHundred
//
//  Created by 郭雪 on 11-12-30.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTLabel.h"

@interface AboutController : UIViewController <RTLabelDelegate>
{
    
    IBOutlet UIScrollView           *scrollView;
    IBOutlet RTLabel                *detailLabel;
    IBOutlet UIImageView            *versionBg;
    IBOutlet UILabel                *versionWords;
    IBOutlet UILabel                *versionNumbers;
}

- (IBAction) cancel:(id)sender;

@end
