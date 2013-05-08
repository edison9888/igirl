//
//  BookListViewController.m
//  iGirl
//
//  Created by Gao Fuxiao on 13-5-2.
//  Copyright (c) 2013年 MobileWoo. All rights reserved.
//

#import "BookListViewController.h"
#import "BookListItemView.h"
#import "AppDelegate.h"
#import "DataEngine.h"
#import "CustomNavigationBar.h"
#import "Constants+APIRequest.h"
#import "Constants+ErrorCodeDef.h"
#import "Constants.h"
#import "ImageCacheEngine.h"
#import "ReaderViewController.h"
#import "Book.h"
#import "Banner.h"
#import "UIAlertView+Blocks.h"
#import "RIButtonItem.h"
#import "OAuth.h"

#define LIST_PAGE_SIZE 10

@interface BookListViewController ()
- (void)responseGetItems:(NSNotification *) notification;
- (void)responseDownloadImage:(NSNotification *) notification;
- (void)moreButtonClick:(id)sender;
- (void)responseHasNew:(NSNotification*) notification;
- (void)responseDownloadError:(NSNotification *) notification;
- (void)responseUserCancelLogin:(NSNotification *) notification;

@end

@implementation BookListViewController
@synthesize forAnalysisPath = forAnalysisPath;
@synthesize bannerId = _bannerId, isFirstClass = _isFirstClass, showTitle = _showTitle, fromTab, source, dataType;
@synthesize currentArray = _currentArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _currentPage = 0;
        _isFirstClass = YES;
        _showTitle = @"电子书";
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
                                                 name:REQUEST_GETBOOKS
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(responseDownloadImage:)
                                                 name:REQUEST_DOWNLOADFILE_NOTIFICATION_NAME
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(responseHasNew:)
                                                 name:NOTIFICATION_HAS_NEW
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(responseSinaUserInfo:)
                                                 name:REQUEST_SINAWEIBOUSERINFO
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(responseUserLogin:)
                                                 name:REQUEST_OAUTHLOGIN
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(responseUserCancelLogin:)
                                                 name:REQUEST_SINAWEIBOCANCEL
                                               object:nil];
    //加入对下载书籍事件的监听
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateStatusLabel:)
                                                 name:NOTIFICATION_DOWNLOAD_ITEM_START
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateStatusLabel:)
                                                 name:NOTIFICATION_DOWNLOAD_ITEM_FINISH
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(responseDownloadError:)
                                                 name:NOTIFICATION_DOWNLOAD_ITEM_ERROR
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [MobClick beginLogPageView:@"大图模式页面"];
    [MobClick event:@"大图模式页面" label:@"页面显示"];
    [UBAnalysis event:@"大图模式页面" label:@"页面显示"];
    [UBAnalysis startTracPage:@"大图模式页面" labels:0];
    [DataEngine sharedDataEngine].isInShareViewController = YES;
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
    [DataEngine sharedDataEngine].isInShareViewController = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
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
            if ([view isKindOfClass:[BookListItemView class]]) {
                [view removeFromSuperview];
            }
        }
    }
    [cell setBackgroundColor:[UIColor clearColor]];
    
    Book *book = [self getBook:indexPath.row];
    
    BookListItemView *itemView = [[BookListItemView alloc] initWithFrame:CGRectMake(0, 0, 320, 308)];

    [itemView setTag:[book.bookId longLongValue]];
    [itemView setItemBook:book]; 
    NSString *realUrl = nil;
    
    realUrl = [NSString stringWithFormat:@"%@_%@.jpg", book.picUrl, [[DataEngine sharedDataEngine] getImageSize:kImageSizeDetail]];
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

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    float cellHeight = [[BookListItemView alloc] getCellHeight:[self getBook:indexPath.row]];
    return cellHeight;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    Book *book = [self getBook:indexPath.row];

    if ([self isDownLoaded:[book.bookId intValue]]) {
        NSString *phrase = [[NSUserDefaults standardUserDefaults] valueForKey:BOOK_SECRET]; // Document password (for unlocking most encrypted PDF files)
        
        NSArray *cachesPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        
        NSString *cachePath = [cachesPaths objectAtIndex:0];
        
        NSString *filePath = [NSString stringWithFormat:@"%@/downloads/%d/%d.pdf",cachePath,[book.bookId intValue],[book.bookId intValue]];
        
        assert(filePath != nil); // Path to last PDF file
        
        ReaderDocument *document = [ReaderDocument withDocumentFilePath:filePath password:phrase];
        
        if (document != nil) // Must have a valid ReaderDocument object in order to proceed with things
        {
            ReaderViewController *readerViewController = [[ReaderViewController alloc] initWithReaderDocument:document];
            
            readerViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            readerViewController.modalPresentationStyle = UIModalPresentationFullScreen;
            AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [delegate presentModalViewController:readerViewController animated:YES];
            
        }
    } else {
        // 判断是否需要的登录
        if ([[NSUserDefaults standardUserDefaults] valueForKey:DOWNLOAD_BOOK_NEED_LOGIN]) {
            if ([[[NSUserDefaults standardUserDefaults] valueForKey:DOWNLOAD_BOOK_NEED_LOGIN] boolValue]) {
                if (![DataEngine sharedDataEngine].isLogin) {
                    // 此处登录
                    [[DataEngine sharedDataEngine] sinaWeiboLogin];
                    bookIdWaitForLogined = book.bookId;
                    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    [delegate showActivityView:NSLocalizedString(@"请稍候", @"") inView:self.view];
                    return;
                }
            }
        }
        [[DataEngine downloadManager] addDownloadObject:book.bookId downloadUrl:book.link];
        [[DataEngine downloadManager] startDownload];
    }
}

- (Book*) getBook:(int) pos
{    
    if (_currentArray && [_currentArray count] > 0) {
        Book *book = [_currentArray objectAtIndex:pos];
        return book;
    }
    return nil;
}


-(void)updateStatusLabel:(NSNotification *)notification
{
    [itemsListTableView reloadData];
}

- (void)requestGetItems
{ 
    [[DataEngine sharedDataEngine] getBooks:_currentPage
                                       size:LIST_PAGE_SIZE
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
        
        _currentArray = [dataEngine books];
        
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
                Book *book = [self getBook:indexPath.row];
                NSString *realUrl = [NSString stringWithFormat:@"%@_%@.jpg", book.picUrl, [[DataEngine sharedDataEngine] getImageSize:kImageSizeDetail]];
                
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

-(BOOL)isDownLoaded:(int)bookId
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *docPath = [documentPaths objectAtIndex:0];
    NSString *bookPath = [docPath stringByAppendingFormat:@"/downloads/%d/%d.pdf",bookId,bookId];
    
    
    return [fileManager fileExistsAtPath:bookPath];
}

- (void)responseDownloadError:(NSNotification *) notification
{
    // 下载失败
    [itemsListTableView reloadData];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"下载失败", @"")
                                                    message:NSLocalizedString(@"有可能是网络不通畅造成的。", @"")
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"确定", @"")
                                          otherButtonTitles:nil];
    [alert show];
}


# pragma mark - response notification

- (void)responseSinaUserInfo:(NSNotification *)notification
{
    NSDictionary *dict = [notification userInfo];
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate hideActivityView:self.view];
    NSNumber *returnCode = [dict objectForKey:RETURN_CODE];
    if (returnCode && [returnCode isKindOfClass:[NSNumber class]] && [returnCode intValue] == 0) {
        SinaOAuth *sinaOauth = [dict objectForKey:TOUI_PARAM_SINA_USERINFO_OAUTHINFO];
        [[DataEngine sharedDataEngine] oauthLogin:sinaOauth followZb:1 isAutoLogin:NO from:_controllerId];
        [delegate showActivityView:NSLocalizedString(@"正在登录，请稍侯...", @"") inView:delegate.window];
    } else {
        [delegate showFailedActivityView:[dict objectForKey:TOUI_REQUEST_ERROR_MESSAGE] interval:ERROR_MESSAGE_SHOW_INTERVAL_NORMAL inView:delegate.window];
    }
}

- (void)responseUserLogin:(NSNotification *)notification
{
    NSDictionary *dict = [notification userInfo];
    if ([dict objectForKey:REQUEST_SOURCE_KEY] != _controllerId) {
        return;
    }
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSNumber *returnCode = [dict objectForKey:RETURN_CODE];
    if (returnCode && [returnCode isKindOfClass:[NSNumber class]] && [returnCode intValue] == 0) {
        // 登录成功，开始下载
        [delegate showFinishActivityView:NSLocalizedString(@"登录成功，已开始下载。", @"") interval:ERROR_MESSAGE_SHOW_INTERVAL_NORMAL inView:delegate.window];
        for (int i=0; i<[_currentArray count]; i++) {
            Book *book = [_currentArray objectAtIndex:i];
            if ([book.bookId isEqualToNumber:bookIdWaitForLogined]) {
                [[DataEngine downloadManager] addDownloadObject:book.bookId downloadUrl:book.link];
                [[DataEngine downloadManager] startDownload];
                return;
            }
        }
    } else {
        [delegate showFailedActivityView:[dict objectForKey:TOUI_REQUEST_ERROR_MESSAGE] interval:ERROR_MESSAGE_SHOW_INTERVAL_NORMAL inView:delegate.window];
    }
}

- (void)responseUserCancelLogin:(NSNotification *) notification;
{
    // 取消登录，关掉delegate提示
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate hideActivityView:self.view];
}

@end
