//
//  ItemListViewController.h
//  iAccessories
//
//  Created by Tony Sun on 12-10-17.
//  Copyright (c) 2012年 MobileWoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "LoadMoreTableFooterView.h"
#import "DataEngine.h"
#import "Constants+Enum.h"

typedef enum {
    kItemListFromTile = 0,
    kItemListFromCategory = 1,
    kItemListFromBanner = 2,
    kItemListFromSearch = 3
} ItemListSource;

@interface ItemListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, EGORefreshTableHeaderDelegate, LoadMoreTableFooterDelegate>
{    
    IBOutlet UITableView                        *_tableView;
    IBOutlet UIView                             *_segmentView;
    
    // 三个排序按钮
    IBOutlet UIButton                           *_leftButton;
    IBOutlet UIButton                           *_centerButton;
    IBOutlet UIButton                           *_rightButton;
    IBOutlet UIImageView                        *_leftArrow;
    IBOutlet UIImageView                        *_centerArrow;
    IBOutlet UIImageView                        *_rightArrow;
    // 按钮是否选择
    BOOL                                        _leftButtonSelected;
    BOOL                                        _centerButtonSelected;
    BOOL                                        _rightButtonSelected;
    // 按钮升降序状态:yes,降序  no,升序
    BOOL                                        _leftButtonSort;
    BOOL                                        _centerButtonSort;
    BOOL                                        _rightButtonSort;
    
    // 下拉
    EGORefreshTableHeaderView                   *_refreshHeaderView;
    BOOL                                        _reloading;
    
    // 上拉
    LoadMoreTableFooterView                     *_loadMoreFooterView;
    BOOL                                        _loadingMore;
    BOOL                                        _loadMoreShowing;
    BOOL                                        _isNeedRefresh;
    
    NSUInteger                                  _currentPage;
    NSMutableArray                              *_currentArray;
    
    NSString                                    *_controllerId;
    
    TreasureListSort                            _itemlistSort;
    
    BOOL                                        _isFirstClass;
    BOOL        fromTab;
    // 统计点击路径
    NSString *forAnalysisPath;
    
    // 搜索关键字
    NSString                                    *searchKeyword;
}

// 跳转列表页 源
@property (nonatomic) ItemListSource listSource;
// 从banner进入
@property (nonatomic, retain) NSNumber *bannerId;
// 从tile进入
@property (nonatomic, retain) NSNumber *tileId;
@property (assign) NSInteger tileType;
// 从类目进入
@property (nonatomic, retain) NSNumber *cid;
@property (nonatomic, assign) BOOL isFirstClass;
@property (nonatomic, retain) NSString *forAnalysisPath;
@property (nonatomic, assign) ItemDetailSource source;
@property (assign) ItemDataType dataType;
@property (assign) BOOL fromTab;
@property (nonatomic, retain) NSString *searchKeyword;
@end
