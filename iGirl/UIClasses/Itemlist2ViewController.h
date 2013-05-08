//
//  Itemlist2ViewController.h
//  iAccessories
//
//  Created by sunxq on 13-1-6.
//  Copyright (c) 2013年 MobileWoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "LoadMoreTableFooterView.h"
#import "ItemListViewController.h"
#import "Constants+Enum.h"

@class MenuItemTreasureList;
@class Advertise;

@interface Itemlist2ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, EGORefreshTableHeaderDelegate, LoadMoreTableFooterDelegate>
{
    IBOutlet UITableView                        *_tableView;
    
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
//    NSUInteger                                  _totalNum;
    
    NSString                                    *_controllerId;
    
    BOOL                                        _isFirstClass;
    
    int                                         _rowAdd;
    UIImageView                                 *_addImage;
    
    Advertise                                   *_advertise;
    NSString *forAnalysisPath;
    BOOL fromTab;
    UIImageView *hasNewImageView;
}

@property (assign) BOOL fromTab;
@property (nonatomic, assign) BOOL isFirstClass;
@property (nonatomic, copy) NSString *advertisingUUID;
@property (nonatomic, copy) NSString *advertisingUrl;
@property (nonatomic, retain) NSNumber *dataSwitch;
@property (nonatomic, retain) NSString *forAnalysisPath;
@property (nonatomic) ItemListSource listSource;
// 从banner进入
@property (nonatomic, retain) NSNumber *bannerId;
// 从tile进入
@property (nonatomic, retain) NSNumber *tileId;
@property (assign) NSInteger tileType;
@property (nonatomic, assign) ItemDetailSource source;
@property (assign) ItemDataType dataType;

- (void)requestDownloadImage:(NSString *)url;

@end
