//
//  OrderAddViewController.h
//  iAccessories
//
//  Created by sunxq on 13-3-29.
//  Copyright (c) 2013年 MobileWoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderAddViewController : UITableViewController <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>
{
    NSString                    *_controllerId;
    
    NSMutableDictionary         *_cells;
    
//    IBOutlet UILabel            *_orderNameLabel;
//    IBOutlet UIButton           *_orderNumAddButton;
//    IBOutlet UIButton           *_orderNumCutButton;
//    IBOutlet UITextField        *_orderNumField;
//    IBOutlet UITextField        *_userNameField;
//    IBOutlet UITextField        *_mobileField;
//    IBOutlet UITextField        *_addressField;
//    IBOutlet UITextField        *_remarkField;
    
}

@property(nonatomic, copy) NSNumber *itemId;
@property(nonatomic, copy) NSString *itemName;

- (IBAction)changeBuyCount:(id)sender;

@end
