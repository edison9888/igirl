//
//  NearbyController.h
//  Pic it
//
//  Created by 郭雪 on 11-10-18.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "EGORefreshTableHeaderView.h"
#import "LoadMoreTableFooterView.h"


@interface FavouriteViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate>
{
    //页面id
    NSString                        *_controllerId;
    
    UITableView                     *_tableView;
    //是否需要再页面显示的时候刷新数据
    BOOL                            _isNeedRefresh;
    //列表页面商品数组
    NSMutableArray                  *_currentArray;
    //每行显示的个数
    NSInteger                       _thumbsPerLine;
    //总行数
    NSInteger                       _totalLines;
    // 删除的数组
    NSMutableArray *_deleteArray;
    // 是否在编辑状态
    BOOL isEdit;
    // 从tab点过去的
    BOOL fromTab;
}

@property (nonatomic, retain) UITableView *tableView;
@property (assign) BOOL fromTab;
@end
