//
//  ShopWindowViewController.h
//  iAccessories
//
//  Created by zhang on 13-1-6.
//  Copyright (c) 2013年 MobileWoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "LoadMoreTableFooterView.h"
#import "Constants.h"

@interface ShopWindowViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, EGORefreshTableHeaderDelegate, LoadMoreTableFooterDelegate> {
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
}

@property (assign) BOOL fromTab;
@property (nonatomic, retain) NSNumber *bannerId;
@property (nonatomic, retain) NSString *showTitle;
@property (assign) BOOL isFirstClass;
@property (nonatomic, retain) NSString *forAnalysisPath;
@property (assign) ItemDataType dataType;
@property (nonatomic, assign) ItemDetailSource source;
@end
