//
//  BookListViewController.h
//  iGirl
//
//  Created by Gao Fuxiao on 13-5-2.
//  Copyright (c) 2013年 MobileWoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "LoadMoreTableFooterView.h"
#import "Constants.h"


@interface BookListViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, EGORefreshTableHeaderDelegate, LoadMoreTableFooterDelegate>
{
    NSString                                    *_controllerId;
    
    NSMutableArray                              *_currentArray;
    
    // 下拉
    EGORefreshTableHeaderView                   *_refreshHeaderView;
    BOOL                                        _reloading;
    
    // 上拉
    LoadMoreTableFooterView                     *_loadMoreFooterView;
    BOOL                                        _loadingMore;
    BOOL                                        _loadMoreShowing;
    BOOL                                        _isNeedRefresh;
    
    IBOutlet UITableView *itemsListTableView;
    int _currentPage;
    
    NSNumber *_bannerId;
    NSString *_showTitle;
    BOOL _isFirstClass;
    NSString *forAnalysisPath;
    BOOL fromTab;
    UIImageView *hasNewImageView;

    NSNumber *bookIdWaitForLogined;
}

@property (assign) BOOL fromTab;
@property (nonatomic, retain) NSNumber *bannerId;
@property (nonatomic, retain) NSString *showTitle;
@property (assign) BOOL isFirstClass;
@property (nonatomic, retain) NSString *forAnalysisPath;
@property (assign) ItemDataType dataType;
@property (nonatomic, assign) ItemDetailSource source;

@property (retain, nonatomic) NSMutableArray *currentArray;

@end
