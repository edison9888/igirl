//
//  CategoryViewController.h
//  iAccessories
//
//  Created by zhang on 12-10-16.
//  Copyright (c) 2012年 MobileWoo. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CATEGORY_LSIT_CELL_TAG_IMAGE 1
#define CATEGORY_LSIT_CELL_TAG_LABEL 2
#define CATEGORY_LSIT_CELL_TAG_LINE  3
#define CATEGORY_LSIT_CELL_TAG_CLEAR_BUTTON  4
#define CATEGORY_LSIT_CELL_TAG_SELECTED_BACKGROUND  5

@interface CategoryViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate> {
    IBOutlet UITableView *_tableView, *_searchHistoryTableView;
    IBOutlet UISearchBar *_searchBar;
    IBOutlet UIView *searchBackgroundView;
    NSString *_controllerId;
    NSString *forAnalysisPath;
    BOOL fromTab;
}
@property (assign) BOOL fromTab;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSString *forAnalysisPath;

@end
