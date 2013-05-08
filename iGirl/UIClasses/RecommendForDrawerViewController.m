//
//  RecommendViewController.m
//  iAccessories
//
//  Created by zhang on 12-10-16.
//  Copyright (c) 2012年 MobileWoo. All rights reserved.
//

#import "RecommendForDrawerViewController.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "Constants+NotificationName.h"
#import <QuartzCore/QuartzCore.h>
#import "DataEngine.h"
#import "Banner.h"
#import "ImageCacheEngine.h"
#import "ItemDetailViewController.h"
#import "TSBWebViewController.h"
#import "ItemListViewController.h"
#import "CustomNavigationBar.h"
#import "Itemlist2ViewController.h"
#import "RecommendViewItemCell.h"
#import "RecommendItemView.h"

@interface RecommendForDrawerViewController (Private)

- (void)initBanners;
- (void)initHeadRecommends;
- (void)updateHeadRecommends;
- (void)open:(id)sender;
- (void)segmentSelected:(id)sender;
- (void)loadImagesForOnscreenRows;

- (void)responseBanner:(NSNotification *) notification;
- (void)responseGetRecommends:(NSNotification *)notification;
- (void)responseDownloadImage:(NSNotification*) notification;
- (void)responseHasNew:(NSNotification*) notification;

- (void)resetLabelWidth;
- (void)moreButtonClick:(id)sender;

- (void)responseHomeLeftButtonAnimation:(NSNotification *) notification;
@end

@implementation RecommendForDrawerViewController
@synthesize tableView = _tableView;
@synthesize bannerId = _bannerId;
@synthesize isFirstClass = _isFirstClass;
@synthesize forAnalysisPath = forAnalysisPath;
@synthesize fromTab;
@synthesize source;
@synthesize dataType;

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

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
        _rowItemCount = 3;
        _isFirstClass = NO;
        forAnalysisPath = @"";
        fromTab = NO;
        dataType = kTileDataTypeLeftDrawer;
    }
    return self;
}

- (void)viewDidLoad
{
    [MobClick event:@"无标签首页" label:@"进入页面"];
    [UBAnalysis event:@"无标签首页" label:@"进入页面"];

    [super viewDidLoad];
    _controllerId = [[NSString alloc] initWithFormat:@"%p", self];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(responseBanner:)
                                                 name:REQUEST_GETBANNER
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(responseGetRecommends:)
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

    CustomNavigationBar* customNavigationBar = (CustomNavigationBar*)self.navigationController.navigationBar;
    
    if (_isFirstClass) {
        UIView *moreView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 47, 44)];
        moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [moreButton setImage:[UIImage imageNamed:@"recommendMoreButton.png"] forState:UIControlStateNormal];
        [moreButton setImage:[UIImage imageNamed:@"recommendMoreButton_highlight.png"] forState:UIControlStateHighlighted];
        moreButton.frame = CGRectMake(0, 0, 47, 44);
        [moreButton addTarget:self action:@selector(moreButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [moreView addSubview:moreButton];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:moreView];
        hasNewImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"new"]];
        [hasNewImageView setFrame:CGRectMake(30, 4, 23, 17)];
        [moreButton addSubview:hasNewImageView];
        [hasNewImageView setHidden:YES];

        [self.tableView setBackgroundColor:[UIColor clearColor]];
    }
    else {
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [backButton setBackgroundImage:[[UIImage imageNamed:@"navigationBarBackButton.png"] stretchableImageWithLeftCapWidth:20.0 topCapHeight:16.0] forState:UIControlStateNormal];
        [backButton setBackgroundImage:[[UIImage imageNamed:@"navigationBarBackButton_selected.png"] stretchableImageWithLeftCapWidth:20.0 topCapHeight:16.0] forState:UIControlStateHighlighted];
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
    
    if (_refreshHeaderView == nil) {
		EGORefreshTableHeaderViewForRecommend *view = [[EGORefreshTableHeaderViewForRecommend alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.tableView.frame.size.width, self.tableView.bounds.size.height)];

		view.delegate = self;
		[self.tableView addSubview:view];
		_refreshHeaderView = view;
        [_refreshHeaderView refreshLastUpdatedDate];
	}
    
    if (_loadMoreFooterView == nil) {
		LoadMoreTableFooterView *view = [[LoadMoreTableFooterView alloc] initWithFrame:CGRectMake(0.0f, self.tableView.contentSize.height, self.tableView.frame.size.width, self.tableView.bounds.size.height)];
        view.backgroundColor = [UIColor colorWithRed:247.0 / 255.0 green:246.0  / 255.0 blue:245.0  / 255.0 alpha:1.0];
		view.delegate = self;
		[self.tableView addSubview:view];
		_loadMoreFooterView = view;
        _loadMoreShowing = YES;
	}
    [self initBanners];
    [self.tableView setSeparatorStyle:NO];
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
    [MobClick beginLogPageView:@"无标签首页"];
    [MobClick event:@"无标签首页" label:@"页面显示"];
    [UBAnalysis event:@"无标签首页" label:@"页面显示"];
    [UBAnalysis startTracPage:@"无标签首页" labels:0];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [MobClick endLogPageView:@"无标签首页"];
    [MobClick event:@"无标签首页" label:@"页面隐藏"];
    [UBAnalysis event:@"无标签首页" label:@"页面隐藏"];
    [UBAnalysis endTracPage:@"无标签首页" labels:0];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)initBanners
{
    Banner *banner = [[DataEngine sharedDataEngine] getBannerById:self.bannerId];
    if (banner && banner.title) {
        self.navigationItem.title = banner.title;
    }
    if (banner == nil || banner.items == nil || ([banner.items isKindOfClass:[NSArray class]] && [banner.items count] == 0)) {
        [self requestGetRecommends];
    } else {
        _currentArray = [[NSMutableArray alloc] initWithArray:banner.items];
        int totalCount = [_currentArray count];
        if (totalCount && totalCount > 0) {
            if (totalCount != kRecommendForDrawerListPageSize) {
                _loadMoreShowing = NO;
            } else {
                _loadMoreShowing = YES;
            }
        } else {
            _loadMoreShowing = NO;
        }
        if (!_loadMoreShowing) {
            self.tableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
        }
        [self.tableView reloadData];
    }
    [self initHeadRecommends];
}

- (void)initHeadRecommends
{
    recommendHeadBody = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 275)];
    [recommendHeadBody.layer setZPosition:-1];
    [recommendHeadBody setBackgroundColor:[UIColor clearColor]];
    [recommendHeadBody setTag:kRecommendForDrawerHeadBodyTag];
    
    UIButton *headButton1 = [[UIButton alloc] initWithFrame:CGRectMake(0, -65, 320, 213)];
    [headButton1 setImage:[UIImage imageNamed:@"recommendBigEmpty.png"] forState:UIControlStateNormal];
    [headButton1 setTag:kRecommendForDrawerHeadBodyItemImageTag + 1];
    [headButton1 addTarget:self action:@selector(open:) forControlEvents:UIControlEventTouchUpInside];
    [recommendHeadBody addSubview:headButton1];

    UILabel *headLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(5, 118, 300, 35)];
    [headLabel1 setTextColor:[UIColor whiteColor]];
    [headLabel1 setFont:[UIFont systemFontOfSize:12]];
    [headLabel1 setTextAlignment:NSTextAlignmentCenter];
    [headLabel1 setTag:kRecommendForDrawerHeadBodyItemLabelTag + 1];
    [headLabel1 setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5f]];
    [headLabel1.layer setCornerRadius:6];
    [headLabel1.layer setMasksToBounds:YES];

    [recommendHeadBody addSubview:headLabel1];
    if ([_currentArray count] >=1) {
        Tile *tile = [_currentArray objectAtIndex:0];
        NSString *realUrl = nil;
        if (tile.tileUUID && [tile.tileUUID isKindOfClass:[NSString class]] && [tile.tileUUID length] > 0) {
            realUrl = [[DataEngine sharedDataEngine] getImageUrlByUUID:tile.tileUUID];
        } else if (tile.picUrl && [tile.picUrl isKindOfClass:[NSString class]] && [tile.picUrl length] > 0) {
            realUrl = [NSString stringWithFormat:@"%@_%@.jpg", tile.picUrl, [[DataEngine sharedDataEngine] getImageSize:kImageSizeThumb]];
        }
        UIImage *headImage = nil;
        if (realUrl) {
            NSString *imagePath = [[ImageCacheEngine sharedInstance] getImagePathByUrl:realUrl];
            if (imagePath == nil) {
                headImage = [UIImage imageNamed:@"recommendBigEmpty.png"];
                [[DataEngine sharedDataEngine] downloadFileByUrl:realUrl
                                                            type:kDownloadFileTypeImage
                                                            from:_controllerId];
            } else {
                headImage = [UIImage imageWithContentsOfFile:imagePath];
            }
        } else {
            headImage = [UIImage imageNamed:@"recommendBigEmpty.png"];
        }
        [headButton1 setImage:headImage forState:UIControlStateNormal];
        [headLabel1 setText:tile.tileTitle];
    }
    else {
        headButton1.hidden = YES;
        headLabel1.hidden = YES;
    }
    
    UIButton *headButton2 = [[UIButton alloc] initWithFrame:CGRectMake(0, 150, 159, 125)];
    [headButton2 setImage:[UIImage imageNamed:@"recommendBigEmpty.png"] forState:UIControlStateNormal];
    [headButton2 setTag:kRecommendForDrawerHeadBodyItemImageTag + 2];
    [headButton2 addTarget:self action:@selector(open:) forControlEvents:UIControlEventTouchUpInside];
    [recommendHeadBody addSubview:headButton2];

    UILabel *headLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(5, 245, 300, 35)];
    [headLabel2 setTextColor:[UIColor whiteColor]];
    [headLabel2 setFont:[UIFont systemFontOfSize:11]];
    [headLabel2 setTextAlignment:NSTextAlignmentCenter];
    [headLabel2 setTag:kRecommendForDrawerHeadBodyItemLabelTag + 2];
    [headLabel2 setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5f]];
    [headLabel2.layer setCornerRadius:6];
    [headLabel2.layer setMasksToBounds:YES];

    [recommendHeadBody addSubview:headLabel2];

    if ([_currentArray count] >= 2) {
        Tile *tile = [_currentArray objectAtIndex:1];
        NSString *realUrl = nil;
        if (tile.tileUUID && [tile.tileUUID isKindOfClass:[NSString class]] && [tile.tileUUID length] > 0) {
            realUrl = [[DataEngine sharedDataEngine] getImageUrlByUUID:tile.tileUUID];
        } else if (tile.picUrl && [tile.picUrl isKindOfClass:[NSString class]] && [tile.picUrl length] > 0) {
            realUrl = [NSString stringWithFormat:@"%@_%@.jpg", tile.picUrl, [[DataEngine sharedDataEngine] getImageSize:kImageSizeThumb]];
        }
        UIImage *headImage = nil;
        if (realUrl) {
            NSString *imagePath = [[ImageCacheEngine sharedInstance] getImagePathByUrl:realUrl];
            if (imagePath == nil) {
                headImage = [UIImage imageNamed:@"recommendBigEmpty.png"];
                [[DataEngine sharedDataEngine] downloadFileByUrl:realUrl
                                                            type:kDownloadFileTypeImage
                                                            from:_controllerId];
            } else {
                headImage = [UIImage imageWithContentsOfFile:imagePath];
            }
        } else {
            headImage = [UIImage imageNamed:@"recommendBigEmpty.png"];
        }
        [headButton2 setImage:headImage forState:UIControlStateNormal];
        [headLabel2 setText:tile.tileTitle];
    }
    else {
        headButton2.hidden = YES;
        headLabel2.hidden = YES;
    }
    
    UIButton *headButton3 = [[UIButton alloc] initWithFrame:CGRectMake(161, 150, 159, 125)];
    [headButton3 setImage:[UIImage imageNamed:@"recommendBigEmpty.png"] forState:UIControlStateNormal];
    [headButton3 setTag:kRecommendForDrawerHeadBodyItemImageTag + 3];
    [headButton3 addTarget:self action:@selector(open:) forControlEvents:UIControlEventTouchUpInside];
    [recommendHeadBody addSubview:headButton3];
    
    UILabel *headLabel3 = [[UILabel alloc] initWithFrame:CGRectMake(166, 245, 300, 35)];
    [headLabel3 setTextColor:[UIColor whiteColor]];
    [headLabel3 setFont:[UIFont systemFontOfSize:11]];
    [headLabel3 setTextAlignment:NSTextAlignmentCenter];
    [headLabel3 setTag:kRecommendForDrawerHeadBodyItemLabelTag + 3];
    [headLabel3 setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5f]];
    [headLabel3.layer setCornerRadius:6];
    [headLabel3.layer setMasksToBounds:YES];

    [recommendHeadBody addSubview:headLabel3];

    if ([_currentArray count] >= 3) {
        Tile *tile = [_currentArray objectAtIndex:2];
        NSString *realUrl = nil;
        if (tile.tileUUID && [tile.tileUUID isKindOfClass:[NSString class]] && [tile.tileUUID length] > 0) {
            realUrl = [[DataEngine sharedDataEngine] getImageUrlByUUID:tile.tileUUID];
        } else if (tile.picUrl && [tile.picUrl isKindOfClass:[NSString class]] && [tile.picUrl length] > 0) {
            realUrl = [NSString stringWithFormat:@"%@_%@.jpg", tile.picUrl, [[DataEngine sharedDataEngine] getImageSize:kImageSizeThumb]];
        }
        UIImage *headImage = nil;
        if (realUrl) {
            NSString *imagePath = [[ImageCacheEngine sharedInstance] getImagePathByUrl:realUrl];
            if (imagePath == nil) {
                headImage = [UIImage imageNamed:@"recommendBigEmpty.png"];
                [[DataEngine sharedDataEngine] downloadFileByUrl:realUrl
                                                            type:kDownloadFileTypeImage
                                                            from:_controllerId];
            } else {
                headImage = [UIImage imageWithContentsOfFile:imagePath];
            }
        } else {
            headImage = [UIImage imageNamed:@"recommendBigEmpty.png"];
        }
        [headButton3 setImage:headImage forState:UIControlStateNormal];
        [headLabel3 setText:tile.tileTitle];
    }
    else {
        headButton3.hidden = YES;
        headLabel3.hidden = YES;
    }
    
    self.tableView.tableHeaderView = recommendHeadBody;
    [self resetLabelWidth];
}

- (void)updateHeadRecommends
{
    UIButton *recommendItemButton1 = (UIButton*)[self.tableView.tableHeaderView viewWithTag:kRecommendForDrawerHeadBodyItemImageTag + 1];
    UILabel *recommendItemLabel1 = (UILabel*)[self.tableView.tableHeaderView viewWithTag:kRecommendForDrawerHeadBodyItemLabelTag + 1];
    if ([_currentArray count] >=1) {
        recommendItemButton1.hidden = NO;
        recommendItemLabel1.hidden = NO;
        
        Tile *tile = [_currentArray objectAtIndex:0];
        [recommendItemLabel1 setText:tile.tileTitle];
        NSString *realUrl = nil;
        if (tile.tileUUID && [tile.tileUUID isKindOfClass:[NSString class]] && [tile.tileUUID length] > 0) {
            realUrl = [[DataEngine sharedDataEngine] getImageUrlByUUID:tile.tileUUID];
        } else if (tile.picUrl && [tile.picUrl isKindOfClass:[NSString class]] && [tile.picUrl length] > 0) {
            realUrl = [NSString stringWithFormat:@"%@_%@.jpg", tile.picUrl, [[DataEngine sharedDataEngine] getImageSize:kImageSizeThumb]];
        }
        UIImage *headImage = nil;
        if (realUrl) {
            NSString *imagePath = [[ImageCacheEngine sharedInstance] getImagePathByUrl:realUrl];
            if (imagePath == nil) {
                headImage = [UIImage imageNamed:@"recommendBigEmpty.png"];
                [[DataEngine sharedDataEngine] downloadFileByUrl:realUrl
                                                            type:kDownloadFileTypeImage
                                                            from:_controllerId];
            } else {
                headImage = [UIImage imageWithContentsOfFile:imagePath];
            }
        } else {
            headImage = [UIImage imageNamed:@"recommendBigEmpty.png"];
        }
        [recommendItemButton1 setImage:headImage forState:UIControlStateNormal];
    }
    else {
        recommendItemButton1.hidden = YES;
        recommendItemLabel1.hidden = YES;
    }
    
    UIButton *recommendItemButton2 = (UIButton*)[self.tableView.tableHeaderView viewWithTag:kRecommendForDrawerHeadBodyItemImageTag + 2];
    UILabel *recommendItemLabel2 = (UILabel*)[self.tableView.tableHeaderView viewWithTag:kRecommendForDrawerHeadBodyItemLabelTag + 2];
    if ([_currentArray count] >=2) {
        recommendItemButton2.hidden = NO;
        recommendItemLabel2.hidden = NO;
        
        Tile *tile = [_currentArray objectAtIndex:1];
        [recommendItemLabel2 setText:tile.tileTitle];
        NSString *realUrl = nil;
        if (tile.tileUUID && [tile.tileUUID isKindOfClass:[NSString class]] && [tile.tileUUID length] > 0) {
            realUrl = [[DataEngine sharedDataEngine] getImageUrlByUUID:tile.tileUUID];
        } else if (tile.picUrl && [tile.picUrl isKindOfClass:[NSString class]] && [tile.picUrl length] > 0) {
            realUrl = [NSString stringWithFormat:@"%@_%@.jpg", tile.picUrl, [[DataEngine sharedDataEngine] getImageSize:kImageSizeThumb]];
        }
        UIImage *headImage = nil;
        if (realUrl) {
            NSString *imagePath = [[ImageCacheEngine sharedInstance] getImagePathByUrl:realUrl];
            if (imagePath == nil) {
                headImage = [UIImage imageNamed:@"recommendBigEmpty.png"];
                [[DataEngine sharedDataEngine] downloadFileByUrl:realUrl
                                                            type:kDownloadFileTypeImage
                                                            from:_controllerId];
            } else {
                headImage = [UIImage imageWithContentsOfFile:imagePath];
            }
        } else {
            headImage = [UIImage imageNamed:@"recommendBigEmpty.png"];
        }
        [recommendItemButton2 setImage:headImage forState:UIControlStateNormal];
    }
    else {
        recommendItemButton2.hidden = YES;
        recommendItemLabel2.hidden = YES;
    }
    
    UIButton *recommendItemButton3 = (UIButton*)[self.tableView.tableHeaderView viewWithTag:kRecommendForDrawerHeadBodyItemImageTag + 3];
    UILabel *recommendItemLabel3 = (UILabel*)[self.tableView.tableHeaderView viewWithTag:kRecommendForDrawerHeadBodyItemLabelTag + 3];
    if ([_currentArray count] >=3) {
        recommendItemButton3.hidden = NO;
        recommendItemLabel3.hidden = NO;
        
        Tile *tile = [_currentArray objectAtIndex:2];
        [recommendItemLabel3 setText:tile.tileTitle];
        NSString *realUrl = nil;
        if (tile.tileUUID && [tile.tileUUID isKindOfClass:[NSString class]] && [tile.tileUUID length] > 0) {
            realUrl = [[DataEngine sharedDataEngine] getImageUrlByUUID:tile.tileUUID];
        } else if (tile.picUrl && [tile.picUrl isKindOfClass:[NSString class]] && [tile.picUrl length] > 0) {
            realUrl = [NSString stringWithFormat:@"%@_%@.jpg", tile.picUrl, [[DataEngine sharedDataEngine] getImageSize:kImageSizeThumb]];
        }
        UIImage *headImage = nil;
        if (realUrl) {
            NSString *imagePath = [[ImageCacheEngine sharedInstance] getImagePathByUrl:realUrl];
            if (imagePath == nil) {
                headImage = [UIImage imageNamed:@"recommendBigEmpty.png"];
                [[DataEngine sharedDataEngine] downloadFileByUrl:realUrl
                                                            type:kDownloadFileTypeImage
                                                            from:_controllerId];
            } else {
                headImage = [UIImage imageWithContentsOfFile:imagePath];
            }
        } else {
            headImage = [UIImage imageNamed:@"recommendBigEmpty.png"];
        }
        [recommendItemButton3 setImage:headImage forState:UIControlStateNormal];
    }
    else {
        recommendItemButton3.hidden = YES;
        recommendItemLabel3.hidden = YES;
    }
    [self resetLabelWidth];
}

- (void)responseBanner:(NSNotification *) notification
{
    [self initBanners];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"RecommendForDrawerViewContrller didReceiveMemoryWarning");

    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = [_currentArray count] - 3;
    if (count > 3) {
        count = count / _rowItemCount + (count % _rowItemCount == 0 ? 0 : 1);
        return count;
    } else {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 108;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    
    RecommendViewItemCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[RecommendViewItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    for (int i = 0; i < _rowItemCount; i++) {
        int position = (indexPath.row + 1) * _rowItemCount + i;
        if (position >= [_currentArray count]) {
            for (int j=i; j<3; j++) {
                [cell hideSubItem:j];
            }
            break;
        }
        [cell displaySubItem:i];
        Tile *tile = [_currentArray objectAtIndex:position];
        float x = i * kRecommendItemWidth + (i * 2);
        if (i == 0) {
            x = 0;
        }
        
        RecommendItemView *itemView = nil;
        if (i == 0) {
            itemView = cell.subItemView1;
        } else if (i == 1) {
            itemView = cell.subItemView2;
        } else if (i == 2) {
            itemView = cell.subItemView3;
        }
        [itemView setBackgroundColor:[UIColor clearColor]];
        [itemView setTag:kRecommendHeadBodyItemImageTag + position + 1];
        [itemView setDelegate:self];
        
        NSString *realUrl = nil;
        if (tile.tileUUID && [tile.tileUUID isKindOfClass:[NSString class]] && [tile.tileUUID length] > 0) {
            realUrl = [[DataEngine sharedDataEngine] getImageUrlByUUID:tile.tileUUID];
        } else if (tile.picUrl && [tile.picUrl isKindOfClass:[NSString class]] && [tile.picUrl length] > 0) {
            realUrl = [NSString stringWithFormat:@"%@_%@.jpg", tile.picUrl, [[DataEngine sharedDataEngine] getImageSize:kImageSizeThumb]];
        }
        UIImage *image = [UIImage imageNamed:@"recommendSmallNoPic.png"];
        NSString *imagePath = [[ImageCacheEngine sharedInstance] getImagePathByUrl:realUrl];
        if (realUrl) {
            if (imagePath == nil) {
                image = [UIImage imageNamed:@"recommendSmallEmpty.png"];
                [[DataEngine sharedDataEngine] downloadFileByUrl:realUrl
                                                            type:kDownloadFileTypeImage
                                                            from:_controllerId];
            }
        }
        //        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        //        });
        dispatch_async(dispatch_get_main_queue(), ^{
            if (imagePath) {
                UIImage *lazyImage = [UIImage imageWithContentsOfFile:imagePath];
                [itemView setImage:lazyImage];
            } else {
                [itemView setImage:image];
            }
        });
        
        
        NSString *text = tile.tileTitle;
        [itemView setText:text];
    }
    return cell;
}


- (void)requestGetRecommends
{
    // 加载更多
    [[DataEngine sharedDataEngine] getTile:kRecommendForDrawerListPageSize
                                   current:_currentPage
                                  bannerId:self.bannerId
                                  dataType:[NSNumber numberWithInt:self.dataType]
                                      from:_controllerId];
}

- (void)responseGetRecommends:(NSNotification *)notification
{
    NSDictionary *dictionary = (NSDictionary *)[notification userInfo];
    if (![[dictionary objectForKey:REQUEST_SOURCE_KEY] isEqualToString:_controllerId]) {
        return;
    }
//    NSLog(@"dictionary:%@", dictionary);
    AppDelegate *delegate= (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSNumber *returnCode = [dictionary objectForKey:RETURN_CODE];
    if (returnCode && [returnCode isKindOfClass:[NSNumber class]] && [returnCode intValue] == NO_ERROR) {
        [delegate hideActivityView:delegate.window];
        if (_reloading) {
            [self doneLoadingTableViewData];
        }
        if (_loadingMore) {
            [self doneLoadingMoreTableViewData];
        }

        Banner *banner = [[DataEngine sharedDataEngine].banners objectForKey:self.bannerId];
        _currentArray =  [[NSMutableArray alloc] initWithArray:banner.items];
        int totalCount = [_currentArray count];
        _totalLines = totalCount / _rowItemCount + (totalCount % _rowItemCount == 0 ? 0 : 1);
        NSNumber *itemsCount = [dictionary objectForKey:@"count"];
        if (itemsCount && [itemsCount isKindOfClass:[NSNumber class]] && [itemsCount intValue] > 0) {
            if ([itemsCount intValue] != kRecommendForDrawerListPageSize) {
                _loadMoreShowing = NO;
            } else {
                _loadMoreShowing = YES;
            }
        } else {
            _loadMoreShowing = NO;
        }
        if (!_loadMoreShowing) {
            self.tableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
        }
        // 有可能是在接到push时有bannerId,但是本地还没有更新banner数组,所以在这里更新后重新设置下title
        if (banner && banner.title) {
            self.navigationItem.title = banner.title;
        }
        [self updateHeadRecommends];
        [self.tableView reloadData];
    } else {
        [delegate showFailedActivityView:[dictionary objectForKey:TOUI_REQUEST_ERROR_MESSAGE] interval:ERROR_MESSAGE_SHOW_INTERVAL_NORMAL inView:delegate.window];
    }
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource
{
	_reloading = YES;
    _currentPage = 0;
    [self requestGetRecommends];
}

- (void)doneLoadingTableViewData
{
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    _reloading = NO;
    [self updateHeadRecommends];
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderViewForRecommend*)view
{
	[self reloadTableViewDataSource];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderViewForRecommend*)view
{
	return _reloading;
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderViewForRecommend*)view
{
	return [NSDate date];
}

#pragma mark - LoadMoreTableFooterDelegate Methods

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
    [self requestGetRecommends];
}

- (void)doneLoadingMoreTableViewData
{
    _loadingMore = NO;
    [_loadMoreFooterView loadMoreScrollViewDataSourceDidFinishedLoading:self.tableView];
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    if (_loadMoreShowing) {
        [_loadMoreFooterView loadMoreScrollViewDidScroll:scrollView];
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(loadImagesForOnscreenRows) object:nil];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    if (_loadMoreShowing) {
        [_loadMoreFooterView loadMoreScrollViewDidEndDragging:scrollView];
    }
    if (!_tableView.decelerating && !_tableView.isDragging) {
        [self performSelector:@selector(loadImagesForOnscreenRows) withObject:nil afterDelay:0.5f];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [_refreshHeaderView egoRefreshScrollViewDidEndDecelerating:scrollView];
    if (!_tableView.decelerating && !_tableView.isDragging) {
        [self performSelector:@selector(loadImagesForOnscreenRows) withObject:nil afterDelay:0.5f];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (!_tableView.decelerating && !_tableView.isDragging) {
        [self performSelector:@selector(loadImagesForOnscreenRows) withObject:nil afterDelay:0.5f];
    }
}

- (void)loadImagesForOnscreenRows
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(loadImagesForOnscreenRows) object:nil];

    int totalCount = [_currentArray count];
    if (totalCount > 0) {
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths) {
            // 取出每一项
            for (int i=0; i<_rowItemCount; i++) {
                int position = (indexPath.row + 1) * _rowItemCount + i;
                if (position >= [_currentArray count]) {
                    break;
                }
                Tile *tile = [_currentArray objectAtIndex:position];
                NSString *realUrl = nil;
                if (tile.tileUUID && [tile.tileUUID isKindOfClass:[NSString class]] && [tile.tileUUID length] > 0) {
                    realUrl = [[DataEngine sharedDataEngine] getImageUrlByUUID:tile.tileUUID];
                } else if (tile.picUrl && [tile.picUrl isKindOfClass:[NSString class]] && [tile.picUrl length] > 0) {
                    realUrl = [NSString stringWithFormat:@"%@_%@.jpg", tile.picUrl, [[DataEngine sharedDataEngine] getImageSize:kImageSizeThumb]];
                }
                if (realUrl) {
                    NSString *imagePath = [[ImageCacheEngine sharedInstance] getImagePathByUrl:realUrl];
                    if (imagePath == nil) {
                        [[DataEngine sharedDataEngine] downloadFileByUrl:realUrl
                                                                    type:kDownloadFileTypeImage
                                                                    from:_controllerId];
                    }
                }
            }
        }
        [self.tableView reloadData];
    }
}

- (void)open:(id)sender
{
    UIButton *button = (UIButton *)sender;
    Banner *banner = [[DataEngine sharedDataEngine] getBannerById:self.bannerId];
    Tile *tile = [_currentArray objectAtIndex:[button tag] - 1 - kRecommendForDrawerHeadBodyItemImageTag];
    [MobClick event:@"无标签首页" attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@,%@,%@", banner.title ? banner.title : KPlaceholder, tile.tileId ? tile.tileId : KPlaceholder, tile.tileTitle ? tile.tileTitle : KPlaceholder], @"点击瓷砖图片", nil]];
    [UBAnalysis event:@"无标签首页" labels:4, @"点击瓷砖图片", banner.title ? banner.title : KPlaceholder, [tile.tileId stringValue] ? [tile.tileId stringValue] : KPlaceholder, tile.tileTitle ? tile.tileTitle : KPlaceholder];
    
    if (forAnalysisPath && [forAnalysisPath isEqualToString:@""] && [forAnalysisPath length] <= 0) {
        forAnalysisPath = [NSString stringWithFormat:@"123情景,%@,%lld>", banner.title, [banner.bannerId longLongValue]];
    } else {
        forAnalysisPath = [NSString stringWithFormat:@"%@123情景,%@,%lld>", forAnalysisPath, banner.title, [banner.bannerId longLongValue]];
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
            itemDetail.preViewName = NSLocalizedString(@"123情景", @"");
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
        default:
            break;
    }
}

- (void)responseDownloadImage:(NSNotification*) notification
{
    NSDictionary *dictionary = (NSDictionary *)[notification userInfo];
    if (![[dictionary objectForKey:REQUEST_SOURCE_KEY] isEqualToString:_controllerId]) {
        return;
    }
//    NSLog(@"notification:%@", notification);
    NSString *imagePath = [dictionary objectForKey:TOUI_PARAM_DOWNLOADFILE_FILEPATH];
    if (imagePath) {
        [self updateHeadRecommends];
        if (![self.tableView isDragging] && ![self.tableView isDecelerating]) {
            [self loadImagesForOnscreenRows];
        }
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    NSLog(@"RecommendForDrawerViewContrller viewDidUnload");
    _refreshHeaderView = nil;
    _loadMoreFooterView = nil;
}

- (void)resetLabelWidth
{
    UILabel *recommendItemLabel1 = (UILabel*)[self.tableView.tableHeaderView viewWithTag:kRecommendForDrawerHeadBodyItemLabelTag + 1];
    CGSize opSize = [recommendItemLabel1.text sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(307, 16)];
    [recommendItemLabel1 setFrame:CGRectMake(recommendItemLabel1.frame.origin.x, recommendItemLabel1.frame.origin.y, opSize.width + 10, opSize.height + 10)];
    if ([recommendItemLabel1.text isEqualToString:@""] || [recommendItemLabel1.text length] == 0) {
        [recommendItemLabel1 setHidden:YES];
    } else {
        [recommendItemLabel1 setHidden:NO];
    }

    UILabel *recommendItemLabel2 = (UILabel*)[self.tableView.tableHeaderView viewWithTag:kRecommendForDrawerHeadBodyItemLabelTag + 2];
    CGSize opSize2 = [recommendItemLabel2.text sizeWithFont:[UIFont systemFontOfSize:11] constrainedToSize:CGSizeMake(143, 16)];
    [recommendItemLabel2 setFrame:CGRectMake(recommendItemLabel2.frame.origin.x, recommendItemLabel2.frame.origin.y, opSize2.width + 10, opSize2.height + 10)];
    if ([recommendItemLabel2.text isEqualToString:@""] || [recommendItemLabel2.text length] == 0) {
        [recommendItemLabel2 setHidden:YES];
    } else {
        [recommendItemLabel2 setHidden:NO];
    }

    UILabel *recommendItemLabel3 = (UILabel*)[self.tableView.tableHeaderView viewWithTag:kRecommendForDrawerHeadBodyItemLabelTag + 3];
    CGSize opSize3 = [recommendItemLabel3.text sizeWithFont:[UIFont systemFontOfSize:11] constrainedToSize:CGSizeMake(143, 16)];
    [recommendItemLabel3 setFrame:CGRectMake(recommendItemLabel3.frame.origin.x, recommendItemLabel3.frame.origin.y, opSize3.width + 10, opSize3.height + 10)];
    if ([recommendItemLabel3.text isEqualToString:@""] || [recommendItemLabel3.text length] == 0) {
        [recommendItemLabel3 setHidden:YES];
    } else {
        [recommendItemLabel3 setHidden:NO];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)responseHomeLeftButtonAnimation:(NSNotification *) notification
{
    
}
@end
