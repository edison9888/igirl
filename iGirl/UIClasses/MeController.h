//
//  MeController.h
//  iAccessories
//
//  Created by Tony Sun on 12-10-17.
//  Copyright (c) 2012年 MobileWoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

@interface MeController : UIViewController <UITableViewDelegate, UITableViewDataSource, SKStoreProductViewControllerDelegate>
{
    NSString            *_controllerId;
    
    IBOutlet UITableView *_tableView;
    
    BOOL                _isLogined;
    
    UIButton            *_bindSinaButton;
    
    BOOL                _appInreview;
    BOOL fromTab;
}

@property (assign) BOOL fromTab;
@property (nonatomic, retain) UITableView *tableView;

@end
