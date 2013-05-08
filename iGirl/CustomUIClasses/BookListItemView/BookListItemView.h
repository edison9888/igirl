//
//  BookListItemView.h
//  iGirl
//
//  Created by Gao Fuxiao on 13-4-27.
//  Copyright (c) 2013年 MobileWoo. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Book;

@interface BookListItemView : UIView
{
    UIImageView *bgView;
    UIImageView *bookImage;
    UILabel *statusLabel;
}
@property (nonatomic, retain) Book *itemBook;

-(CGFloat)getCellHeight:(Book *)book;

@end