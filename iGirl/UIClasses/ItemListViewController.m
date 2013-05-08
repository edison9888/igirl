//
//  ItemListViewController.m
//  iAccessories
//
//  Created by Tony Sun on 12-10-17.
//  Copyright (c) 2012年 MobileWoo. All rights reserved.
//

#import "ItemListViewController.h"
#import "ItemListCell.h"
#import "Treasure.h"
#import "DataEngine.h"
#import "ImageCacheEngine.h"
#import "ITSegmentedControl.h"
#import "AppDelegate.h"
#import "Constants+APIRequest.h"
#import "Constants+RetrunParamDef.h"
#import "Constants+ErrorCodeDef.h"
#import "Constants+NotificationName.h"
#import "Constants.h"
#import "CustomNavigationBar.h"
#import "ItemDetailViewController.h"
#import "Category.h"
#import "Banner.h"

#define ITEM_CELL_HEIGHT        100
#define PAGESIZE                40

#define ITEM_LSIT_CELL_TAG_IMAGE            1
#define ITEM_LSIT_CELL_TAG_TITLE            2
#define ITEM_LSIT_CELL_TAG_PRICE            3
#define ITEM_LSIT_CELL_TAG_SALES            4
#define ITEM_LSIT_CELL_TAG_CREDIT           5
#define ITEM_LSIT_CELL_TAG_SELECT_BACKGROUND           6


@interface ItemListViewController ()

- (void)moreButtonClick:(id)sender;
@end

@implementation ItemListViewController

@synthesize isFirstClass = _isFirstClass;
@synthesize forAnalysisPath = forAnalysisPath;
@synthesize source, dataType, fromTab, searchKeyword;

- (void)moreButtonClick:(id)sender
{
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate showLeft];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _isFirstClass = NO;
        forAnalysisPath = @"";
        searchKeyword = @"";
        fromTab = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [MobClick event:@"商品列表" label:@"进入页面"];
    [UBAnalysis event:@"商品列表" label:@"进入页面"];

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
    DataEngine *dataEngine = [DataEngine sharedDataEngine];
    
    // 分类列表
    if (self.listSource == kItemListFromCategory) {
        Category *cate = nil;
        for (int i=0; i<[dataEngine.categories count]; i++) {
            Category *cateItem = [dataEngine.categories objectAtIndex:i];
            if ([cateItem.cid isEqualToNumber:self.cid]) {
                cate = cateItem;
                self.navigationItem.title = cate.name;
                break;
            }
        }
    }
    
    _tableView.separatorStyle = NO;
    
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
                                             selector:@selector(responseGetItems:)
                                                 name:REQUEST_SEARCH
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(responseDownloadImage:)
                                                 name:REQUEST_DOWNLOADFILE_NOTIFICATION_NAME
                                               object:nil];
    // 第一次初始化排序标签按钮
    [self initSortButtonFirstly];
    
    // 请求
    _currentPage = 0;
    [self requestGetItems];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [MobClick beginLogPageView:@"商品列表"];
    [MobClick event:@"商品列表" label:@"页面显示"];
    [UBAnalysis event:@"商品列表" label:@"页面显示"];
    [UBAnalysis startTracPage:@"商品列表" labels:0];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [MobClick endLogPageView:@"商品列表"];
    [MobClick event:@"商品列表" label:@"页面隐藏"];
    [UBAnalysis event:@"商品列表" label:@"页面隐藏"];
    [UBAnalysis endTracPage:@"商品列表" labels:0];
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


- (void)requestGetItems
{
    if (!_loadingMore) {
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [delegate showActivityView:NSLocalizedString(@"请稍候...", @"") inView:delegate.window];
    }
    // 分类列表
    if (self.listSource == kItemListFromCategory) {
        [[DataEngine sharedDataEngine] getCatItems:PAGESIZE
                                           current:_currentPage
                                              sort:_itemlistSort
                                               cid:self.cid
                                              from:_controllerId];
    } else if (self.listSource == kItemListFromBanner) {
        // tile列表
        [[DataEngine sharedDataEngine] getBannerItems:PAGESIZE
                                              current:_currentPage
                                                 type:self.tileType
                                                 sort:_itemlistSort
                                             bannerId:self.bannerId
                                               from:_controllerId];
    } else if (self.listSource == kItemListFromSearch) {
        // 搜索
        [[DataEngine sharedDataEngine] search:searchKeyword
                                         sort:_itemlistSort
                                      current:_currentPage
                                         size:PAGESIZE
                                         from:_controllerId];
    } else {
        // tile列表
        [[DataEngine sharedDataEngine] getTileItems:PAGESIZE
                                            current:_currentPage
                                               type:self.tileType
                                               sort:_itemlistSort
                                                cid:self.tileId
                                               from:_controllerId];
    }
    
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
        if (self.listSource == kItemListFromCategory) {
            _currentArray = [NSArray arrayWithArray:[dataEngine.catItems objectForKey:self.cid]];
        } else if (self.listSource == kItemListFromSearch) {
            _currentArray = [NSArray arrayWithArray:dataEngine.searchResultItems];
        } else if (self.listSource == kItemListFromBanner) {
            _currentArray = [NSArray arrayWithArray:[dataEngine.bannerItems objectForKey:self.bannerId]];
        } else {
            _currentArray = [NSArray arrayWithArray:[dataEngine.tileItems objectForKey:self.tileId]];
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
    return [_currentArray count];
}

- (UIImageView *)creditImage:(int)num lbWidth:(CGFloat)lbWidth
{
    UIImageView *iv = [[UIImageView alloc] init];
    iv.frame = CGRectMake(num * 10 + 2 + lbWidth, 3, 10, 10);
    
    return iv;
}

// 生成信用等级
- (UIView *)creditView:(CGRect)frame Tag:(int)tag Score:(int)score
{
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.tag = tag;
    view.backgroundColor = [UIColor clearColor];
    
    UILabel *creLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, view.frame.size.height)];
    creLabel.text = NSLocalizedString(@"信用:", @"");
    creLabel.backgroundColor = [UIColor clearColor];
    creLabel.font = [UIFont systemFontOfSize:11.0];
    creLabel.textColor = [UIColor colorWithRed:150.f / 255.f green:150.f / 255.f blue:150.f / 255.f alpha:1];
//    creLabel.shadowColor = [UIColor whiteColor];
//    creLabel.shadowOffset = CGSizeMake(0, 0.5);
    [creLabel setHighlightedTextColor:[UIColor whiteColor]];
    [view addSubview:creLabel];
    
    CGFloat labelWidth = creLabel.frame.size.width - 24;

    // 桃心
    if (score >= 1 && score <= 5) {
        for (int i = 0; i < score; i++) {
            UIImageView *iv = [self creditImage:i lbWidth:labelWidth];
            [iv setImage:[UIImage imageNamed:@"credit_tx.png"]];
            
            [view addSubview:iv];
        }
    }
    // 钻石
    else if (score >= 6 && score <= 10) {
        for (int i = 0; i < score - 5; i++) {
            UIImageView *iv = [self creditImage:i lbWidth:labelWidth];
            [iv setImage:[UIImage imageNamed:@"credit_zs.png"]];
            
            [view addSubview:iv];
        }
    }
    // 蓝冠
    else if (score >= 11 && score <= 15) {
        for (int i = 0; i < score - 10; i++) {
            UIImageView *iv = [self creditImage:i lbWidth:labelWidth];
            [iv setImage:[UIImage imageNamed:@"credit_lg.png"]];
            
            [view addSubview:iv];
        }
    }
    // 皇冠
    else if (score >= 16 && score <= 20) {
        for (int i = 0; i < score - 15; i++) {
            UIImageView *iv = [self creditImage:i lbWidth:labelWidth];
            [iv setImage:[UIImage imageNamed:@"credit_hg.png"]];
            
            [view addSubview:iv];
        }
    }
    
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DataEngine *dataEngine = [DataEngine sharedDataEngine];
    static NSString *CellIdentifier = @"ItemListCell11";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    [cell setUserInteractionEnabled:YES];
    
    // Configure the cell...
    [[cell viewWithTag:ITEM_LSIT_CELL_TAG_IMAGE] removeFromSuperview];
    [[cell viewWithTag:ITEM_LSIT_CELL_TAG_PRICE] removeFromSuperview];
    [[cell viewWithTag:ITEM_LSIT_CELL_TAG_SALES] removeFromSuperview];
    [[cell viewWithTag:ITEM_LSIT_CELL_TAG_TITLE] removeFromSuperview];
    [[cell viewWithTag:ITEM_LSIT_CELL_TAG_CREDIT] removeFromSuperview];
    [[cell viewWithTag:ITEM_LSIT_CELL_TAG_SELECT_BACKGROUND] removeFromSuperview];

    if (_currentArray && [_currentArray isKindOfClass:[NSArray class]] && [_currentArray count] >= indexPath.row) {
        Treasure *treasure = [dataEngine getTreasureByItemId:_currentArray[indexPath.row]];
        
        // 设置cell的背景相关
        UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(0, 99, 320, 2)];
        [line setImage:[UIImage imageNamed:@"listCellLine.png"]];
        [cell addSubview:line];
//        [cell setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"listCellBackground.png"]]];
//        [cell setSelectedBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"itemlist_cellbg_selected.png"]]];
        [cell setBackgroundColor:[UIColor colorWithRed:237.0f/255.0f green:237.0f/255.0f blue:237.0f/255.0f alpha:1]];
        
        UIView *bgColorView = [[UIView alloc] initWithFrame:cell.bounds];
        [bgColorView setTag:ITEM_LSIT_CELL_TAG_SELECT_BACKGROUND];
        [bgColorView setBackgroundColor:[UIColor colorWithRed:74.0f/255.0f green:83.0f/255.0f blue:99.0f/255.0f alpha:1]];
        [cell setSelectedBackgroundView:bgColorView];

        UIImageView *treasurThumb = [[UIImageView alloc] initWithFrame:CGRectMake(7, 7, 85, 85)];
        [treasurThumb setContentMode:UIViewContentModeScaleAspectFill];
        [treasurThumb setClipsToBounds:YES];
        [treasurThumb setTag:ITEM_LSIT_CELL_TAG_IMAGE];
        [cell addSubview:treasurThumb];
        
        UILabel *description = [[UILabel alloc] initWithFrame:CGRectMake(101, 7, 212, 40)];
        [description setTag:ITEM_LSIT_CELL_TAG_TITLE];
        description.backgroundColor = [UIColor clearColor];
        description.font = [UIFont systemFontOfSize:13.0];
        description.textColor = [UIColor colorWithRed:26.f / 255.f green:26.f / 255.f blue:26.f / 255.f alpha:1];
        [description setHighlightedTextColor:[UIColor whiteColor]];
//        description.shadowColor = [UIColor whiteColor];
//        description.shadowOffset = CGSizeMake(0, 0.5);
        description.numberOfLines = 2;
        [cell addSubview:description];
        
        UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(101, 48, 220, 15)];
        [priceLabel setTag:ITEM_LSIT_CELL_TAG_PRICE];
        priceLabel.backgroundColor = [UIColor clearColor];
        priceLabel.font = [UIFont systemFontOfSize:15.0];
        priceLabel.textColor = [UIColor colorWithRed:204.f / 255.f green:0.f / 255.f blue:1.f / 255.f alpha:1];
//        priceLabel.shadowColor = [UIColor whiteColor];
//        priceLabel.shadowOffset = CGSizeMake(0, 0.5);
        [priceLabel setHighlightedTextColor:[UIColor whiteColor]];
        [cell addSubview:priceLabel];
        
        UILabel *salesLabel = [[UILabel alloc] initWithFrame:CGRectMake(101, 71, 220, 15)];
        [salesLabel setTag:ITEM_LSIT_CELL_TAG_SALES];
        salesLabel.backgroundColor = [UIColor clearColor];
        salesLabel.font = [UIFont systemFontOfSize:11.0];
        salesLabel.textColor = [UIColor colorWithRed:150.f / 255.f green:150.f / 255.f blue:150.f / 255.f alpha:1];
//        salesLabel.shadowColor = [UIColor whiteColor];
//        salesLabel.shadowOffset = CGSizeMake(0, 0.5);
        [salesLabel setHighlightedTextColor:[UIColor whiteColor]];
        [cell addSubview:salesLabel];
        
        CGRect frame = CGRectMake(235, 71, 70, 16);
        UIView *creditView = [self creditView:frame Tag:ITEM_LSIT_CELL_TAG_CREDIT Score:[treasure.sellerCredit intValue]];
        [cell addSubview:creditView];
        
        //商品缩略图
        if (treasure.picUrl && [treasure.picUrl length] > 0) {
            NSString *realUrl = [NSString stringWithFormat:@"%@_%@.jpg", treasure.picUrl, [dataEngine getImageSize:kImageSizeThumb]];
            NSString *imagePath = [[ImageCacheEngine sharedInstance] getImagePathByUrl:realUrl];
            if (imagePath) {
                UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
                [treasurThumb setImage:image];
            } else {
                //下载图片
                UIImage *image = [UIImage imageNamed:@"itemlistIconEmpty.png"];
                [treasurThumb setImage:image];
                if (![_tableView isDragging] && ![_tableView isDecelerating]) {
                    [self requestDownloadImage:realUrl type:kDownloadFileTypeImage];
                }
            }
        }
        else {
            UIImage *image = [UIImage imageNamed:@"itemlistIconNoPic.png"];
            [treasurThumb setImage:image];
        }

        description.text = treasure.title;
        priceLabel.text = [[NSString alloc] initWithFormat:@"￥%1.2f", [treasure.price floatValue]];
        
        salesLabel.text = [[NSString alloc] initWithFormat:@"月销量:%d件", [treasure.volume intValue]];
        
    }
    
    return cell;

}


#pragma mark -
#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ITEM_CELL_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [MobClick event:@"商品列表"  attributes:[NSDictionary dictionaryWithObjectsAndKeys:self.title ? self.title : KPlaceholder, @"点击商品", nil]];
    [UBAnalysis event:@"商品列表" labels:2, @"点击商品", self.title ? self.title : KPlaceholder];
    
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DataEngine *dataEngine = [DataEngine sharedDataEngine];
    Treasure *treasure = [dataEngine getTreasureByItemId:[_currentArray objectAtIndex:indexPath.row]];
    
    NSString *fromText = @"";
    if (self.listSource == kItemListFromBanner) {
        fromText = [NSString stringWithFormat:@"%@列表,%@,%lld", forAnalysisPath, self.title, [self.bannerId longLongValue]];
    } else {
        fromText = [NSString stringWithFormat:@"%@列表,%@,%lld", forAnalysisPath, self.title, [self.tileId longLongValue]];
    }
    [MobClick event:@"商品详情页面" attributes:[NSDictionary dictionaryWithObjectsAndKeys:fromText, @"进入来源", nil]];
    [UBAnalysis event:@"商品详情页面" labels:2, @"进入来源", fromText];

    ItemDetailViewController *itemDetail = [[ItemDetailViewController alloc] initWithNibName:@"ItemDetailViewController" bundle:nil];
    itemDetail.treasureId = treasure.tid;
    itemDetail.treasuresArray = nil;
    itemDetail.preViewName = self.navigationItem.title;
    itemDetail.source = self.source;
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate presentModalViewController:itemDetail animated:YES];
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
            if (indexPath.row < totalCount) {
                // 取出每一项
                DataEngine *dataEngine = [DataEngine sharedDataEngine];
                Treasure *treasure = [dataEngine getTreasureByItemId:[_currentArray objectAtIndex:indexPath.row]];
                if (treasure.picUrl && [treasure.picUrl length] > 0) {
                    NSString *realUrl = [NSString stringWithFormat:@"%@_%@.jpg", treasure.picUrl, [dataEngine getImageSize:kImageSizeThumb]];
                    NSString *imagePath = [[ImageCacheEngine sharedInstance] getImagePathByUrl:realUrl];
                    if (imagePath == nil) {
                        [self requestDownloadImage:realUrl type:kDownloadFileTypeImage];
                    }
                }
            }
        }
    }
}

# pragma mark - Sort Button

// 页面第一次加载时的初始化标签 相关
- (void)initSortButtonFirstly
{
    // 初始化默认标签页选择
    _leftButtonSelected = YES;
    _centerButtonSelected = NO;
    _rightButtonSelected = NO;
    // 按钮升降序
    _leftButtonSort = YES;
    _rightButtonSort = YES;
    _centerButtonSort = NO;
    
    // 初始化按钮风格
    [self initSortButton];
    
    [_leftButton addTarget:self action:@selector(clickSortButton:) forControlEvents:UIControlEventTouchUpInside];
    [_centerButton addTarget:self action:@selector(clickSortButton:) forControlEvents:UIControlEventTouchUpInside];
    [_rightButton addTarget:self action:@selector(clickSortButton:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)initSortButton
{
    // 初始化排序值
    [self setSortKey];
    
    // 重新显示3个按钮
    [self showSortButton:_leftButton isSelected:_leftButtonSelected sort:_leftButtonSort];
    [self showSortButton:_centerButton isSelected:_centerButtonSelected sort:_centerButtonSort];
    [self showSortButton:_rightButton isSelected:_rightButtonSelected sort:_rightButtonSort];
}

- (void)showSortButton:(UIButton *)button
            isSelected:(BOOL)isSelected
                  sort:(BOOL)sort
{
    // left button
    if (button.tag == 11111)
    {
        // @"信用"
        [button setTitle:NSLocalizedString(@"信用", @"") forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"itemlist_seg_selected.png"] forState:UIControlStateHighlighted];
        [self initArrow:_leftArrow isSelected:isSelected sort:sort];
    }
    // center button
    if (button.tag == 11112)
    {
        // @"销量"
        [button setTitle:NSLocalizedString(@"销量", @"") forState:UIControlStateNormal];
        [self initArrow:_centerArrow isSelected:isSelected sort:sort];
    }
    // right button
    if (button.tag == 11113)
    {
        // @"价格"
        [button setTitle:NSLocalizedString(@"价格", @"") forState:UIControlStateNormal];
        [self initArrow:_rightArrow isSelected:isSelected sort:sort];
    }
    // 按钮是否选择后的背景图
    if (isSelected)
    {
        [button setBackgroundImage:[UIImage imageNamed:@"itemlist_seg_selected.png"] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithRed:168.f / 255.f green:168.f / 255.f blue:170.f / 255.f alpha:1] forState:UIControlStateNormal];
    }else {
        [button setBackgroundImage:[UIImage imageNamed:@"itemlist_seg_normal.png"] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithRed:247.f / 255.f green:247.f / 255.f blue:247.f / 255.f alpha:1] forState:UIControlStateNormal];
    }
    
    [button setTitleShadowColor:[UIColor colorWithRed:0.f / 255.f green:0.f / 255.f blue:0.f / 255.f alpha:0.75] forState:UIControlStateNormal];
    button.titleLabel.shadowOffset = CGSizeMake(0, 1);
    [button.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
}

- (void)initArrow:(UIImageView *)imageView isSelected:(BOOL)isSelected sort:(BOOL)sort
{
    if (isSelected) {
        imageView.hidden = NO;
        if (sort) {
            // 降序
            [imageView setImage:[UIImage imageNamed:@"itemlist_seg_arrow_selected.png"]];
        } else {
            // 升序
            [imageView setImage:[UIImage imageNamed:@"itemlist_arrow_up_selected.png"]];
        }
        
    } else {
        imageView.hidden = YES;
//        [imageView setImage:[UIImage imageNamed:@"itemlist_seg_arrow.png"]];
    }
}

// 按下按钮时，初始化排序值
- (void)setSortKey
{
    // 每次点击不同排序时，设置为第一页
    _currentPage = 0;
//    [_currentArray removeAllObjects];
    if ([_currentArray count] > 0) {
        _tableView.contentOffset = CGPointMake(0, 0);
    }
    _loadingMore = NO;
    _loadMoreShowing = NO;
    
    if (_leftButtonSelected) {
        if (_leftButtonSort) {
            _itemlistSort = kSortByCredenceDescending;
        } else {
            _itemlistSort = kSortByCredenceAscending;
        }
        
    }
    else if (_centerButtonSelected) {
        if (_centerButtonSort) {
            _itemlistSort = kSortBySalesDescending;
        } else {
            _itemlistSort = kSortBySalesAscending;
        }
        
    }
    else {
        if (_rightButtonSort) {
            _itemlistSort = kSortByPriceDescending;
        } else {
            _itemlistSort = kSortByPriceAscending;
        }
        
    }
    
}

- (void)clickSortButton:(id)sender
{
    UIButton *button = sender;
    
    if (button.tag == 11111) {
        if (_leftButtonSelected) {
            return ;
        }
        _leftButtonSelected = YES;
        _centerButtonSelected = NO;
        _rightButtonSelected = NO;
        
        // 增加箭头排序的控制
        _leftButtonSort = !_leftButtonSort;
        _centerButtonSort = NO;
        _rightButtonSort = NO;
    }
    else if (button.tag == 11112) {
//        if (_centerButtonSelected) {
//            return ;
//        }
        _leftButtonSelected = NO;
        _centerButtonSelected = YES;
        _rightButtonSelected = NO;
        
        // 增加箭头排序的控制
        _centerButtonSort = !_centerButtonSort;
        _leftButtonSort = NO;
        _rightButtonSort = NO;
    }
    else {
//        if (_rightButtonSelected) {
//            return ;
//        }
        _leftButtonSelected = NO;
        _centerButtonSelected = NO;
        _rightButtonSelected = YES;
        
        // 增加箭头排序的控制
        _rightButtonSort = !_rightButtonSort;
        _leftButtonSort = NO;
        _centerButtonSort = NO;
    }
    
    [self initSortButton];
    
    [self requestGetItems];
    [MobClick event:@"商品列表" attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", _itemlistSort], @"切换排序", nil]];
    [UBAnalysis event:@"商品列表" labels:2, @"切换排序", [NSString stringWithFormat:@"%d", _itemlistSort]];
}


@end
