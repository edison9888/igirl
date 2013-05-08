//
//  ShopWindowViewController.m
//  iAccessories
//
//  Created by zhang on 13-1-6.
//  Copyright (c) 2013年 MobileWoo. All rights reserved.
//

#import "ShopWindowViewController.h"
#import "ShopWindowItemView.h"
#import "Banner.h"
#import "AppDelegate.h"
#import "DataEngine.h"
#import "Constants+APIRequest.h"
#import "Constants+ErrorCodeDef.h"
#import "Constants.h"
#import "CustomNavigationBar.h"
#import "ImageCacheEngine.h"
#import "ItemListViewController.h"
#import "ItemDetailViewController.h"
#import "TSBWebViewController.h"
#import "RecommendForDrawerViewController.h"
#import "Itemlist2ViewController.h"

#define LIST_PAGE_SIZE 10

@interface ShopWindowViewController ()
- (void)responseGetItems:(NSNotification *) notification;
- (void)responseDownloadImage:(NSNotification *) notification;
- (void)moreButtonClick:(id)sender;
- (void)responseHasNew:(NSNotification*) notification;

@end

@implementation ShopWindowViewController
@synthesize forAnalysisPath = forAnalysisPath;
@synthesize bannerId = _bannerId, isFirstClass = _isFirstClass, showTitle = _showTitle, fromTab, source, dataType;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _currentPage = 0;
        _isFirstClass = YES;
        _showTitle = @"";
        forAnalysisPath = @"";
    }
    return self;
}

- (void)viewDidLoad
{
    [MobClick event:@"大图模式页面" label:@"进入页面"];
    [UBAnalysis event:@"大图模式页面" label:@"进入页面"];

    [super viewDidLoad];
    _controllerId = [NSString stringWithFormat:@"%p", self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(responseGetItems:)
                                                 name:REQUEST_GETTILE
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(responseDownloadImage:)
                                                 name:REQUEST_DOWNLOADFILE_NOTIFICATION_NAME
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(responseHasNew:)
                                                 name:NOTIFICATION_HAS_NEW
                                               object:nil];

    CustomNavigationBar* customNavigationBar = (CustomNavigationBar *)self.navigationController.navigationBar;
    if (self.isFirstClass) {
        UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [moreButton setImage:[UIImage imageNamed:@"recommendMoreButton.png"] forState:UIControlStateNormal];
        [moreButton setImage:[UIImage imageNamed:@"recommendMoreButton_highlight.png"] forState:UIControlStateHighlighted];
        moreButton.frame = CGRectMake(0, 0, 47, 44);
        [moreButton addTarget:self action:@selector(moreButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:moreButton];
        hasNewImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"new"]];
        [hasNewImageView setFrame:CGRectMake(30, 4, 23, 17)];
        [moreButton addSubview:hasNewImageView];
        [hasNewImageView setHidden:YES];

    } else {
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [backButton setBackgroundImage:[[UIImage imageNamed:@"navigationBarBackButton.png"] stretchableImageWithLeftCapWidth:20.0 topCapHeight:16.0] forState:UIControlStateNormal];
        // Set the title to use the same font and shadow as the standard back button
        backButton.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
        backButton.titleLabel.textColor = [UIColor whiteColor];
        backButton.titleLabel.shadowOffset = CGSizeMake(0,-1);
        backButton.titleLabel.shadowColor = [UIColor darkGrayColor];
        // Set the break mode to truncate at the end like the standard back button
        backButton.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
        // Inset the title on the left and right
        backButton.titleEdgeInsets = UIEdgeInsetsMake(0, 6.0, 0, 3.0);
        // Make the button as high as the passed in image
        backButton.frame = CGRectMake(0, 0, 48, 28);
        [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
        [customNavigationBar setText:NSLocalizedString(@"返回", @"") onBackButton:backButton leftCapWidth:20.0];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:backButton];
    }
    if (fromTab) {
        self.navigationItem.leftBarButtonItem = NO;
    }
    [itemsListTableView setSeparatorStyle:NO];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"mainBackground"]]];
    [itemsListTableView setBackgroundColor:[UIColor clearColor]];
    self.navigationItem.title = _showTitle;

    if (_refreshHeaderView == nil) {
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - itemsListTableView.bounds.size.height, self.view.frame.size.width, itemsListTableView.bounds.size.height)];
        view.backgroundColor = [UIColor colorWithRed:247.0 / 255.0 green:246.0  / 255.0 blue:245.0  / 255.0 alpha:1.0];
		view.delegate = self;
		[itemsListTableView addSubview:view];
		_refreshHeaderView = view;
	}

	[_refreshHeaderView refreshLastUpdatedDate];
    
    if (_loadMoreFooterView == nil) {
		LoadMoreTableFooterView *view = [[LoadMoreTableFooterView alloc] initWithFrame:CGRectMake(0.0f, itemsListTableView.contentSize.height, itemsListTableView.frame.size.width, itemsListTableView.bounds.size.height)];
        view.backgroundColor = [UIColor colorWithRed:247.0 / 255.0 green:246.0  / 255.0 blue:245.0  / 255.0 alpha:1.0];
		view.delegate = self;
		[itemsListTableView addSubview:view];
		_loadMoreFooterView = view;
        _loadMoreShowing = NO;
	}
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate showActivityView:NSLocalizedString(@"正在载入", @"") inView:delegate.window];
    _currentPage = 0;
    [self requestGetItems];
}

- (void)responseHasNew:(NSNotification*) notification
{
    if ([DataEngine sharedDataEngine].hasNew && [[DataEngine sharedDataEngine].hasNew count] > 0) {
        [hasNewImageView setHidden:NO];
    } else {
        [hasNewImageView setHidden:YES];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [MobClick beginLogPageView:@"大图模式页面"];
    [MobClick event:@"大图模式页面" label:@"页面显示"];
    [UBAnalysis event:@"大图模式页面" label:@"页面显示"];
    [UBAnalysis startTracPage:@"大图模式页面" labels:0];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [MobClick endLogPageView:@"大图模式页面"];
    [MobClick event:@"大图模式页面" label:@"页面隐藏"];
    [UBAnalysis event:@"大图模式页面" label:@"页面隐藏"];
    [UBAnalysis endTracPage:@"大图模式页面" labels:0];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_currentArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
        for (UIView *view in cell.subviews) {
            if ([view isKindOfClass:[ShopWindowItemView class]]) {
                [view removeFromSuperview];
            }
        }
    }
    [cell setBackgroundColor:[UIColor clearColor]];
    Tile *tile = [self getTile:indexPath.row];

    ShopWindowItemView *itemView = [[ShopWindowItemView alloc] initWithFrame:CGRectMake(0, 0, 320, 500)];
    [itemView setTag:[tile.tileId longLongValue]];
    [itemView setItemTile:tile];

    NSString *realUrl = nil;
    if (tile.tileUUID && [tile.tileUUID isKindOfClass:[NSString class]] && [tile.tileUUID length] > 0) {
        realUrl = [[DataEngine sharedDataEngine] getImageUrlByUUID:tile.tileUUID];
    } else if (tile.picUrl && [tile.picUrl isKindOfClass:[NSString class]] && [tile.picUrl length] > 0) {
        realUrl = [NSString stringWithFormat:@"%@_%@.jpg", tile.picUrl, [[DataEngine sharedDataEngine] getImageSize:kImageSizeDetail]];
    }
    if (realUrl) {
        NSString *imagePath = [[ImageCacheEngine sharedInstance] getImagePathByUrl:realUrl];
        if (imagePath == nil) {
            // 下图
            [[DataEngine sharedDataEngine] downloadFileByUrl:realUrl
                                                        type:kDownloadFileTypeImage
                                                        from:_controllerId];
        }
    }

    [cell addSubview:itemView];
    CGRect cellFrame = cell.frame;
    cellFrame.size.height = [[ShopWindowItemView alloc] getCellHeight:[self getTile:indexPath.row]];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    float cellHeight = [[ShopWindowItemView alloc] getCellHeight:[self getTile:indexPath.row]];
    return cellHeight;
}

- (Tile*) getTile:(int) pos
{
//    Tile *tile = [[Tile alloc] init];
////    tile.recommand = @"测试描述啊测试描述啊测试描述啊测试描述啊测试描述啊测试描述啊测试描述啊测试描述啊测试描述啊测试描述啊测试描述啊测试描述啊测试描述啊";
//    tile.treasurePrice = [NSNumber numberWithFloat:39.8f];
//    tile.volumn = [NSNumber numberWithInt:15];
//    tile.couponTime = [NSDate dateWithTimeIntervalSinceNow:186400.f];
//    return tile;
    
    if (_currentArray && [_currentArray count] > 0) {
        Tile *tile = [_currentArray objectAtIndex:pos];
        return tile;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    Tile *tile = [self getTile:indexPath.row];
    
    [MobClick event:@"大图模式页面" attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@,%@", tile.tileId ? tile.tileId : KPlaceholder, tile.tileTitle ? tile.tileTitle : KPlaceholder], @"点击大图", nil]];
    [UBAnalysis event:@"大图模式页面" labels:3, @"点击大图", [tile.tileId stringValue] ? [tile.tileId stringValue] : KPlaceholder, tile.tileTitle ? tile.tileTitle : KPlaceholder];

    if (forAnalysisPath && ![forAnalysisPath isEqualToString:@""] && [forAnalysisPath length] <=0) {
        forAnalysisPath = [NSString stringWithFormat:@"大图,%@,%lld", tile.tileTitle, [tile.tileId longLongValue]];
    } else {
        forAnalysisPath = [NSString stringWithFormat:@"%@,大图,%@,%lld", forAnalysisPath, tile.tileTitle, [tile.tileId longLongValue]];
    }
    
    switch ([tile.type intValue]) {
        case kTileActionTypeList:
        case kTileActionTypeListDiscount:
        case kTileActionTypeListAuto:
        {
            switch (tile.treasureShowType) {
                case kTreasureListShowTypeList:
                {
                    ItemListViewController *itemList = [[ItemListViewController alloc] initWithNibName:@"ItemListViewController" bundle:nil];
                    itemList.forAnalysisPath = forAnalysisPath;
                    itemList.tileId = tile.tileId;
                    itemList.tileType = [tile.type integerValue];
                    itemList.title = tile.tileTitle;
                    [self.navigationController pushViewController:itemList animated:YES];
                }
                    break;
                case kTreasureListShowType222:
                {
                    Itemlist2ViewController *itemList = [[Itemlist2ViewController alloc] initWithNibName:@"Itemlist2ViewController" bundle:nil];
                    itemList.forAnalysisPath = forAnalysisPath;
                    itemList.listSource = kItemListFromTile;
                    itemList.tileId = tile.tileId;
                    itemList.tileType = [tile.type intValue];
                    itemList.title = tile.tileTitle;
                    [self.navigationController pushViewController:itemList animated:YES];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case kTileActionTypeDetail: {
            [MobClick event:@"商品详情页面" attributes:[NSDictionary dictionaryWithObjectsAndKeys:forAnalysisPath, @"进入来源", nil]];
            [UBAnalysis event:@"商品详情页面" labels:2, @"进入来源", forAnalysisPath];

            ItemDetailViewController *itemDetail = [[ItemDetailViewController alloc] initWithNibName:@"ItemDetailViewController" bundle:nil];
            itemDetail.treasureId = tile.itemId;
            itemDetail.treasuresArray = nil;
            itemDetail.preViewName = tile.tileTitle;
            itemDetail.source = self.source;
            AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [delegate presentModalViewController:itemDetail animated:YES];
        }
            break;
        case kTileActionTypeLink: {
            TSBWebViewController *tradeView = [[TSBWebViewController alloc] initWithNibName:@"TSBWebViewController" bundle:nil];
            tradeView.url = tile.link;
            tradeView.showTitle = tile.tileTitle;
            if (self.dataType == kTileDataTypePingCe) {
                tradeView.showShare = YES;
            }
            AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [delegate presentModalViewController:tradeView animated:YES];

//            [self.navigationController pushViewController:tradeView animated:YES];
        }
            break;
        case kTileActionTypeSubsence: {
            Banner *banner = [[Banner alloc] init];
            banner.bannerId = tile.itemId;
            banner.title = tile.tileTitle;
            [[DataEngine sharedDataEngine] addbanner:banner];
            RecommendForDrawerViewController *drawer = [[RecommendForDrawerViewController alloc] initWithNibName:@"RecommendForDrawerViewController" bundle:nil];
            drawer.forAnalysisPath = forAnalysisPath;
            drawer.bannerId = banner.bannerId;
            [self.navigationController pushViewController:drawer animated:YES];
        }
            break;
        default:
            break;
    }
}


- (void)requestGetItems
{
    [[DataEngine sharedDataEngine] getTile:LIST_PAGE_SIZE
                                   current:_currentPage
                                  bannerId:self.bannerId
                                  dataType:[NSNumber numberWithInt:self.dataType]
                                      from:_controllerId];
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource
{
	_reloading = YES;
    _currentPage = 0;
	[self requestGetItems];
}

- (void)doneLoadingTableViewData
{
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:itemsListTableView];
    _reloading = NO;
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
	[self reloadTableViewDataSource];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
	return _reloading;
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
	return [NSDate date];
}

#pragma mark -
#pragma mark LoadMoreTableFooterDelegate Methods

- (void)loadMoreTableFooterDidTriggerRefresh:(LoadMoreTableFooterView *)view
{
	[self loadMoreTableViewDataSource];
}

- (BOOL)loadMoreTableFooterDataSourceIsLoading:(LoadMoreTableFooterView *)view
{
	return _loadingMore;
}

- (void)loadMoreTableViewDataSource
{
    _loadingMore = YES;
    _currentPage ++;
    [self requestGetItems];
}

- (void)doneLoadingMoreTableViewData
{
    _loadingMore = NO;
    [_loadMoreFooterView loadMoreScrollViewDataSourceDidFinishedLoading:itemsListTableView];
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    if (_loadMoreShowing) {
        [_loadMoreFooterView loadMoreScrollViewDidScroll:scrollView];
    }
}

#pragma mark -
#pragma mark Deferred image loading (UIScrollViewDelegate)

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    if (_loadMoreShowing) {
        [_loadMoreFooterView loadMoreScrollViewDidEndDragging:scrollView];
    }
    
    if (!decelerate)
	{
        // 停止拖拽时加载当前显示的图片
        [self loadImagesForOnscreenRows];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [_refreshHeaderView egoRefreshScrollViewDidEndDecelerating:scrollView];
    // 停止滑动时加载当前显示的图片
    [self loadImagesForOnscreenRows];
}

- (void)responseGetItems:(NSNotification *)notification
{
    NSDictionary *dictionary = (NSDictionary *)[notification userInfo];
    if (![[dictionary objectForKey:REQUEST_SOURCE_KEY] isEqualToString:_controllerId]) {
        return;
    }
    
    DataEngine *dataEngine = [DataEngine sharedDataEngine];
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSNumber *returnCode = [dictionary objectForKey:RETURN_CODE];
    if (returnCode && [returnCode isKindOfClass:[NSNumber class]] && [returnCode intValue] == NO_ERROR) {
        
        [delegate hideActivityView:delegate.window];
        if (_reloading) {
            [self doneLoadingTableViewData];
        }
        if (_loadingMore) {
            [self doneLoadingMoreTableViewData];
        }
        
        _currentArray = nil;
//        Banner *banner;
//        if (self.dataType == kTileDataTypePingCe) {
//            banner = [dataEngine.banners objectForKey:BARNNER_PINGCE];
//        } else if (self.dataType == kTileDataTypeDaofu) {
//            banner = [dataEngine.banners objectForKey:BARNNER_DAOFU];
//        } else {
//        }
        Banner *banner = [dataEngine.banners objectForKey:self.bannerId];
        if ([_showTitle isEqualToString:@""]) {
            _showTitle = banner.title;
            self.navigationItem.title = _showTitle;
        }
        _currentArray = banner.items;
        
        NSNumber *itemsCount = [dictionary objectForKey:@"count"];
        if (itemsCount && [itemsCount isKindOfClass:[NSNumber class]] && [itemsCount intValue] > 0) {
            if ([itemsCount intValue] != LIST_PAGE_SIZE) {
                _loadMoreShowing = NO;
            } else {
                _loadMoreShowing = YES;
            }
        } else {
            _loadMoreShowing = NO;
        }
        if (!_loadMoreShowing) {
            itemsListTableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
        }
        [itemsListTableView reloadData];
        
    } else {
        [delegate showFailedActivityView:[dictionary objectForKey:TOUI_REQUEST_ERROR_MESSAGE] interval:ERROR_MESSAGE_SHOW_INTERVAL_NORMAL inView:delegate.window];
    }
}

- (void)responseDownloadImage:(NSNotification *) notification
{
    NSDictionary *dictionary = (NSDictionary *)[notification userInfo];
    if (![[dictionary objectForKey:REQUEST_SOURCE_KEY] isEqualToString:_controllerId]) {
        return;
    }
    
    NSString *imagePath = [dictionary objectForKey:TOUI_PARAM_DOWNLOADFILE_FILEPATH];
    if (imagePath) {
        [itemsListTableView reloadData];
        [_loadMoreFooterView setFrame:CGRectMake(0, itemsListTableView.contentSize.height, itemsListTableView.frame.size.width, itemsListTableView.bounds.size.height)];
    }
}

- (void)loadImagesForOnscreenRows
{
    int totalCount = [_currentArray count];
    if (totalCount > 0) {
        NSArray *visiblePaths = [itemsListTableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths) {
            if (indexPath.row < totalCount) {
                // 取出每一项
                Tile *tile = [self getTile:indexPath.row];
                NSString *realUrl = nil;
                if (tile.tileUUID && [tile.tileUUID isKindOfClass:[NSString class]] && [tile.tileUUID length] > 0) {
                    realUrl = [[DataEngine sharedDataEngine] getImageUrlByUUID:tile.tileUUID];
                } else if (tile.picUrl && [tile.picUrl isKindOfClass:[NSString class]] && [tile.picUrl length] > 0) {
                    realUrl = [NSString stringWithFormat:@"%@_%@.jpg", tile.picUrl, [[DataEngine sharedDataEngine] getImageSize:kImageSizeDetail]];
                }
                if (realUrl) {
                    NSString *imagePath = [[ImageCacheEngine sharedInstance] getImagePathByUrl:realUrl];
                    if (imagePath == nil) {
                        // 下图
                        [[DataEngine sharedDataEngine] downloadFileByUrl:realUrl
                                                                    type:kDownloadFileTypeImage
                                                                    from:_controllerId];
                    }
                }
            }
        }
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)moreButtonClick:(id)sender
{
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate showLeft];
}
@end
