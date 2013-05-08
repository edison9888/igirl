//
//  CustomPlaceholderTextview.h
//  Three Hundred
//
//  Created by 郭雪 on 11-8-4.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CustomPlaceholderTextview : UITextView {
    
    NSString *_placeholder;
    UIColor *_placeholderColor;
    
    BOOL _shouldDrawPlaceholder;
}

@property (nonatomic, retain) NSString *placeholder;
@property (nonatomic, retain) UIColor *placeholderColor;

@end
