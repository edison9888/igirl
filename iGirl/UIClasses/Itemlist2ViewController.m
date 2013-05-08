//
//  Itemlist2ViewController.m
//  iAccessories
//
//  Created by sunxq on 13-1-6.
//  Copyright (c) 2013年 MobileWoo. All rights reserved.
//

#import "Itemlist2ViewController.h"
#import "Itemlist2View.h"
#import "DataEngine.h"
#import "CustomNavigationBar.h"
#import "Treasure.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "ImageCacheEngine.h"
#import "ItemDetailViewController.h"
#import "Menu.h"
#import "TSBWebViewController.h"
#import "Advertise.h"

#define ITEM_CELL_HEIGHT        190
#define PAGESIZE                20

#define ITEM_CELLVIEW_LENGTH    155
#define AD_LENGTH               150

@interface Itemlist2ViewController ()

- (void)moreButtonClick:(id)sender;
- (void)responseHasNew:(NSNotification*) notification;
@end

@implementation Itemlist2ViewController
@synthesize forAnalysisPath = forAnalysisPath;
@synthesize fromTab;
@synthesize source;
@synthesize dataType;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _isFirstClass = NO;
        forAnalysisPath = @"";
        fromTab = NO;
    }
    return self;
}

- (void)moreButtonClick:(id)sender
{
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate showLeft];
}

- (void)viewDidLoad
{
    [MobClick event:@"222模式列表" label:@"进入页面"];
    [UBAnalysis event:@"222模式列表" label:@"进入页面"];

    [super viewDidLoad];
	// Do any additional setup after loading the view.
    _controllerId = [[NSString alloc] initWithFormat:@"%p", self];
    
    CustomNavigationBar* customNavigationBar = (CustomNavigationBar*)self.navigationController.navigationBar;
    
    if (_isFirstClass) {
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
    }
    else {
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
        [customNavigationBar setText:[customNavigationBar onlyBackText] onBackButton:backButton leftCapWidth:20.0];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:backButton];
    }
    if (fromTab) {
        self.navigationItem.leftBarButtonItem = NO;
    }
    _tableView.separatorStyle = NO;
    [_tableView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"mainBackground.png"]]];
    
    if (_refreshHeaderView == nil) {
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - _tableView.bounds.size.height, self.view.frame.size.width, _tableView.bounds.size.height)];
        view.backgroundColor = [UIColor colorWithRed:247.0 / 255.0 green:246.0  / 255.0 blue:245.0  / 255.0 alpha:1.0];
		view.delegate = self;
		[_tableView addSubview:view];
		_refreshHeaderView = view;
	}
	
	//  update the last update date
	[_refreshHeaderView refreshLastUpdatedDate];
    
    if (_loadMoreFooterView == nil) {
		LoadMoreTableFooterView *view = [[LoadMoreTableFooterView alloc] initWithFrame:CGRectMake(0.0f, _tableView.contentSize.height, _tableView.frame.size.width, _tableView.bounds.size.height)];
        view.backgroundColor = [UIColor colorWithRed:247.0 / 255.0 green:246.0  / 255.0 blue:245.0  / 255.0 alpha:1.0];
		view.delegate = self;
		[_tableView addSubview:view];
		_loadMoreFooterView = view;
        _loadMoreShowing = NO;
	}
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(responseGetItems:)
                                                 name:REQUEST_GETCATITEMS
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(responseGetItems:)
                                                 name:REQUEST_GETTILEITEMS
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(responseGetItems:)
                                                 name:REQUEST_GETBANNERITEMS
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(responseDownloadImage:)
                                                 name:REQUEST_DOWNLOADFILE_NOTIFICATION_NAME
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(responseHasNew:)
                                                 name:NOTIFICATION_HAS_NEW
                                               object:nil];
    // 请求
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [MobClick beginLogPageView:@"222模式列表"];
    [MobClick event:@"222模式列表" label:@"页面显示"];
    [UBAnalysis event:@"222模式列表" label:@"页面显示"];
    [UBAnalysis startTracPage:@"222模式列表" labels:0];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [MobClick endLogPageView:@"222模式列表"];
    [MobClick event:@"222模式列表" label:@"页面隐藏"];
    [UBAnalysis event:@"222模式列表" label:@"页面隐藏"];
    [UBAnalysis endTracPage:@"222模式列表" labels:0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    _refreshHeaderView = nil;
    _loadMoreFooterView = nil;
    [super viewDidUnload];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)initValues
{
    if (self.advertisingUUID && [self.advertisingUUID length] > 0) {
        _rowAdd = 1;
        _addImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, AD_LENGTH)];
        // 载入图片
        NSString *addImageUrl = [[DataEngine sharedDataEngine] getImageUrlByUUID:self.advertisingUUID];
        NSString *imagePath = [[ImageCacheEngine sharedInstance] getImagePathByUrl:addImageUrl];
        if (imagePath) {
            UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
            [_addImage setImage:image];
        } else {
            //下载图片
            [self requestDownloadImage:addImageUrl];
        }
        
        [_addImage setContentMode:UIViewContentModeScaleAspectFill];
        _addImage.clipsToBounds = YES;
        _addImage.userInteractionEnabled = YES;
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickWebImage:)];
        [_addImage addGestureRecognizer:recognizer];
    } else {
        _rowAdd = 0;
    }
}

- (void)clickWebImage:(UIGestureRecognizer *)gestureRecognizer
{
    [MobClick event:@"222模式列表"  attributes:[NSDictionary dictionaryWithObjectsAndKeys:_advertise && _advertise.name ? _advertise.name : KPlaceholder, @"点击222广告", nil]];
    [UBAnalysis event:@"222模式列表" labels:2, @"点击222广告", _advertise && _advertise.name ? _advertise.name : KPlaceholder];
    
    TSBWebViewController *tradeView = [[TSBWebViewController alloc] initWithNibName:@"TSBWebViewController" bundle:nil];
    tradeView.url = self.advertisingUrl;
    tradeView.showTitle = self.title;
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate presentModalViewController:tradeView animated:YES];
//    [self.navigationController pushViewController:tradeView animated:YES];
}

- (void)requestGetItems
{
    if (!_loadingMore) {
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [delegate showActivityView:NSLocalizedString(@"请稍候...", @"") inView:delegate.window];
    }
    
    if (self.listSource == kItemListFromBanner) {
        // tile列表
        [[DataEngine sharedDataEngine] getBannerItems:PAGESIZE
                                              current:_currentPage
                                                 type:self.tileType
                                                 sort:kSortByCredenceDescending
                                             bannerId:self.bannerId
                                                 from:_controllerId];
    } else {
        // tile列表
        [[DataEngine sharedDataEngine] getTileItems:PAGESIZE
                                            current:_currentPage
                                               type:self.tileType
                                               sort:kSortByCredenceDescending
                                                cid:self.tileId
                                               from:_controllerId];
    }

    
//    [[DataEngine sharedDataEngine] getTileItems:PAGESIZE
//                                        current:_currentPage
//                                           type:0
//                                           sort:kSortByCredenceDescending
//                                            cid:self.tileId
//                                           from:_controllerId];
    
//    [[DataEngine sharedDataEngine] getBannerItems:PAGESIZE
//                                          current:_currentPage
//                                             type:1
//                                             sort:kSortByCredenceDescending
//                                         bannerId:[NSNumber numberWithLong:175]
//                                             from:_controllerId];
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
        
        Advertise *ad = [dictionary objectForKey:TOUI_PARAM_TILEITEMS_AD];
        if (ad && ad.uuid && [ad.uuid length] > 0) {
            _advertise = ad;
            self.advertisingUUID = _advertise.uuid;
            self.advertisingUrl = _advertise.url;
        }
        if ([dictionary objectForKey:TOUI_PARAM_TILEITEMS_DATASWITCH]) {
            self.dataSwitch = [dictionary objectForKey:TOUI_PARAM_TILEITEMS_DATASWITCH];
        }
        
        // 只有第一次进入该页面，才会刷新广告
        if (_addImage == nil) {
            [self initValues];
        }
        
        _currentArray = nil;
        if (self.listSource == kItemListFromTile) {
            _currentArray = [NSArray arrayWithArray:[dataEngine.tileItems objectForKey:self.tileId]];
        } else if (self.listSource == kItemListFromBanner) {
            _currentArray = [NSArray arrayWithArray:[dataEngine.bannerItems objectForKey:self.bannerId]];
        }
        
        NSNumber *itemsCount = [dictionary objectForKey:@"count"];
        if (itemsCount && [itemsCount isKindOfClass:[NSNumber class]] && [itemsCount intValue] > 0) {
            if ([itemsCount intValue] != PAGESIZE) {
                _loadMoreShowing = NO;
            } else {
                _loadMoreShowing = YES;
            }
        } else {
            _loadMoreShowing = NO;
        }
        if (!_loadMoreShowing) {
            _tableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
        }
        [_tableView reloadData];
        
    } else {
        [delegate showFailedActivityView:[dictionary objectForKey:TOUI_REQUEST_ERROR_MESSAGE] interval:ERROR_MESSAGE_SHOW_INTERVAL_NORMAL inView:delegate.window];
    }
}

- (void)requestDownloadImage:(NSString *)url
{
    [self requestDownloadImage:url type:kDownloadFileTypeImage];
}

- (void)requestDownloadImage:(NSString *)url
                        type:(DownloadFileType)type
{
    [[DataEngine sharedDataEngine] downloadFileByUrl:url type:type from:_controllerId];
}

- (void)responseDownloadImage:(NSNotification*) notification
{
    NSDictionary *dictionary = (NSDictionary *)[notification userInfo];
    if (![[dictionary objectForKey:REQUEST_SOURCE_KEY] isEqualToString:_controllerId]) {
        return;
    }
    NSString *imagePath = [dictionary objectForKey:TOUI_PARAM_DOWNLOADFILE_FILEPATH];
    if (imagePath) {
        [_tableView reloadData];
    }
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self totalNum] + _rowAdd;
}

- (NSInteger)totalNum
{
    int add = 0;
    if ([_currentArray count] % 2 == 1) {
        add = 1;
    }
    
    return [_currentArray count] / 2 + add;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DataEngine *dataEngine = [DataEngine sharedDataEngine];
    static NSString *CellIdentifier = @"Itemlist2Cell11";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    [cell setUserInteractionEnabled:YES];
    
    // Configure the cell...
    for (UIView *view in [cell subviews]) {
        if (view == _addImage) {
            [view removeFromSuperview];
        }
        if (view && [view isKindOfClass:[Itemlist2View class]]) {
            [view removeFromSuperview];
        }
    }
    
    if (_rowAdd == 1) {
        if (indexPath.row == 0) {
            NSString *addImageUrl = [[DataEngine sharedDataEngine] getImageUrlByUUID:self.advertisingUUID];
            NSString *imagePath = [[ImageCacheEngine sharedInstance] getImagePathByUrl:addImageUrl];
            if (imagePath) {
                UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
                [_addImage setImage:image];
            } else {
                //下载图片
                [self requestDownloadImage:addImageUrl];
            }

            [cell addSubview:_addImage];
            return cell;
        }
    }
    
    if (_currentArray && [_currentArray isKindOfClass:[NSArray class]]) {
        if ([_currentArray count] >= 2 * (indexPath.row - _rowAdd) + 1) {
            Treasure *treasure = [dataEngine getTreasureByItemId:_currentArray[2 * (indexPath.row - _rowAdd)]];
            Itemlist2View *view1 = [[Itemlist2View alloc] initWithFrame:CGRectMake(8, 8, 149, 195)];
            view1.tableView = _tableView;
            view1.cotroller = self;
            view1.treasure = treasure;
            view1.dataSwitch = self.dataSwitch;
            [view1 loadValues:treasure];
            [cell addSubview:view1];
        }
        if ([_currentArray count] >= 2 * (indexPath.row - _rowAdd) + 2) {
            Treasure *treasure = [dataEngine getTreasureByItemId:_currentArray[2 * (indexPath.row - _rowAdd) + 1]];
            Itemlist2View *view2 = [[Itemlist2View alloc] initWithFrame:CGRectMake(163, 8, 149, 195)];
            view2.tableView = _tableView;
            view2.cotroller = self;
            view2.treasure = treasure;
            view2.dataSwitch = self.dataSwitch;
            [view2 loadValues:treasure];
            [cell addSubview:view2];
        }

    }
    
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_rowAdd == 1) {
        if (indexPath.row == 0) {
            return AD_LENGTH + 2.5;
        }
    }
    return ITEM_CELL_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    

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
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
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
    [_loadMoreFooterView loadMoreScrollViewDataSourceDidFinishedLoading:_tableView];
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

// Load images for all onscreen rows when scrolling is finished
// 停止拖拽时执行
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

// 减速停止时执行
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [_refreshHeaderView egoRefreshScrollViewDidEndDecelerating:scrollView];
    // 停止滑动时加载当前显示的图片
    [self loadImagesForOnscreenRows];
}

- (void)loadImagesForOnscreenRows
{
    int totalCount = [_currentArray count];
    if (totalCount > 0) {
        NSArray *visiblePaths = [_tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths) {
            if (2 * (indexPath.row - _rowAdd) >= 0 && 2 * (indexPath.row - _rowAdd) < totalCount) {
                // 取出每一项
                DataEngine *dataEngine = [DataEngine sharedDataEngine];
                for (int i = 2 * (indexPath.row - _rowAdd); i <= 2 * (indexPath.row - _rowAdd) + 1; i++) {
                    if (i + 1 <= totalCount) {
                        Treasure *treasure = [dataEngine getTreasureByItemId:[_currentArray objectAtIndex:i]];
                        if (treasure.picUrl && [treasure.picUrl length] > 0) {
                            NSString *realUrl = [NSString stringWithFormat:@"%@_%@.jpg", treasure.picUrl, [dataEngine getImageSize:kImageSize22]];
                            NSString *imagePath = [[ImageCacheEngine sharedInstance] getImagePathByUrl:realUrl];
                            if (imagePath == nil) {
                                [self requestDownloadImage:realUrl type:kDownloadFileTypeImage];
                            }
                        }
                    }
                }
            }
        }
    }
}

@end
