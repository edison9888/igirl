//
//  RecommendViewController.h
//  iAccessories
//
//  Created by zhang on 12-10-16.
//  Copyright (c) 2012年 MobileWoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderViewForRecommend.h"
#import "LoadMoreTableFooterView.h"
#import "RecommendItemView.h"
#import "Constants.h"

#define kRecommendForDrawerListPageSize      21
#define kRecommendForDrawerItemWidth         106
#define kRecommendForDrawerHeadBodyTag       10000

#define kRecommendForDrawerHeadBodyItemImageTag 1000
#define kRecommendForDrawerHeadBodyItemLabelTag 2000

@class ITSegmentedControl;

@interface RecommendForDrawerViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, EGORefreshTableHeaderViewForRecommendDelegate, LoadMoreTableFooterDelegate, RecommendItemViewDelegate> {
    
    NSString                                    *_controllerId;
    
    IBOutlet UITableView                        *_tableView;
    
    // 下拉
    EGORefreshTableHeaderViewForRecommend       *_refreshHeaderView;
    BOOL                                        _reloading;

    // 上拉
    LoadMoreTableFooterView                     *_loadMoreFooterView;
    BOOL                                        _loadingMore;
    BOOL                                        _loadMoreShowing;
    BOOL                                        _isNeedRefresh;

    // 当前显示的哪一个banner
    NSNumber                                    *_bannerId;
    
    // 当前页
    NSUInteger                                  _currentPage;
    NSMutableArray                              *_currentArray;

    // 每行显示的个数
    NSInteger                                   _rowItemCount;
    // 总行数
    NSInteger                                   _totalLines;
    
    UIView                                      *recommendHeadBody;
    
    BOOL                                        _isFirstClass;
    NSString        *forAnalysisPath;
    BOOL fromTab;
    UIImageView     *hasNewImageView;
    
    UIButton *moreButton;
}

@property (assign) BOOL fromTab;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSNumber *bannerId;
@property (nonatomic, assign) BOOL isFirstClass;
@property (nonatomic, retain) NSString *forAnalysisPath;
@property (nonatomic, assign) ItemDetailSource source;
@property (assign) ItemDataType dataType;
@end
