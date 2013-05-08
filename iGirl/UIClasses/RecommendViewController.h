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
#import "RecommendADView.h"

@class ITSegmentedControl;

@interface RecommendViewController : UIViewController <UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, EGORefreshTableHeaderViewForRecommendDelegate, LoadMoreTableFooterDelegate, RecommendItemViewDelegate, RecommendADViewDelegate> {
    
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
    
    // 当前选择的哪一个选项卡
    int                                  _selectedSegmentIndex;

    NSNumber                                    *bannerId;
    
    // 当前页
    NSUInteger                                  _currentPage;
    NSMutableArray                              *_currentArray;

    // 每行显示的个数
    NSInteger                                   _rowItemCount;
    // 总行数
    NSInteger                                   _totalLines;
    
    UIView                                      *recommendHeadBody;
    ITSegmentedControl                          *_segment;
    
    RecommendADView           *adView;
    BOOL isInHeadView;
    NSString *forAnalysisPath;
    UIImageView *hasNewImageView;
}

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSString *forAnalysisPath;
@end
