//
//  RecommendViewController.m
//  iAccessories
//
//  Created by zhang on 12-10-16.
//  Copyright (c) 2012年 MobileWoo. All rights reserved.
//

#import "RecommendViewController.h"
#import "AppDelegate.h"
#import "Constants.h"
#import <QuartzCore/QuartzCore.h>
#import "ITSegmentedControl.h"
#import "DataEngine.h"
#import "Banner.h"
#import "ImageCacheEngine.h"
#import "ItemDetailViewController.h"
#import "TSBWebViewController.h"
#import "ItemListViewController.h"
#import "LocalSettings.h"
#import "TSBWebViewController.h"
#import "RecommendForDrawerViewController.h"
#import "Itemlist2ViewController.h"
#import "RecommendViewItemCell.h"

#define AD_HEIGHT 50
#define AD_VIEW_TAG 10010

@interface RecommendViewController (Private)

- (void)initBanners;
- (void)initHeadRecommends;
- (void)updateHeadRecommends;
- (void)open:(id)sender;
- (void)segmentSelected:(id)sender;
- (void)loadImagesForOnscreenRows;

- (void)responseBanner:(NSNotification *) notification;
- (void)responseGetRecommends:(NSNotification *)notification;
- (void)responseDownloadImage:(NSNotification*) notification;
- (void)responseGetAdvertise:(NSNotification*) notification;
- (void)responseHasNew:(NSNotification*) notification;

- (void)showAD;

- (void)setHeadHeight;

- (void)resetLabelWidth;

- (void)moreButtonClick:(id)sender;
@end

@implementation RecommendViewController

@synthesize tableView = _tableView;
@synthesize forAnalysisPath = forAnalysisPath;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _rowItemCount = 3;
        _currentArray = [[NSMutableArray alloc] init];
        _selectedSegmentIndex = 0;
        forAnalysisPath = @"";
    }
    return self;
}

- (void)viewDidLoad
{
    [MobClick event:@"首页" label:@"进入页面"];
    [UBAnalysis event:@"首页" label:@"进入页面"];

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
                                             selector:@selector(responseGetAdvertise:)
                                                 name:REQUEST_ADVERTISE
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(responseHasNew:)
                                                 name:NOTIFICATION_HAS_NEW
                                               object:nil];
    
    
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

    [self.tableView setBackgroundColor:[UIColor clearColor]];

    if ([DataEngine sharedDataEngine].segmentBannerIds && [[DataEngine sharedDataEngine].segmentBannerIds count] > 0) {
        NSNumber *selectedBannerId = [[DataEngine sharedDataEngine].segmentBannerIds objectAtIndex:_selectedSegmentIndex];
        _currentArray = [NSMutableArray arrayWithArray:[[DataEngine sharedDataEngine] getBannerById:selectedBannerId].items];
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
    NSLog(@"has new array:%@", [DataEngine sharedDataEngine].hasNew);
    if ([DataEngine sharedDataEngine].hasNew && [[DataEngine sharedDataEngine].hasNew count] > 0) {
        [hasNewImageView setHidden:NO];
    } else {
        [hasNewImageView setHidden:YES];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [MobClick beginLogPageView:@"首页"];
    [MobClick event:@"首页" label:@"页面显示"];
    [UBAnalysis event:@"首页" label:@"页面显示"];
    [UBAnalysis startTracPage:@"首页" labels:0];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [MobClick endLogPageView:@"首页"];
    [MobClick event:@"首页" label:@"页面隐藏"];
    [UBAnalysis event:@"首页" label:@"页面隐藏"];
    [UBAnalysis endTracPage:@"首页" labels:0];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)initBanners
{
    if ([DataEngine sharedDataEngine].segmentBannerIds && [[DataEngine sharedDataEngine].segmentBannerIds count] >= 3) {
        DataEngine *dataEngine = [DataEngine sharedDataEngine];
        NSNumber *bannerId1 = [dataEngine.segmentBannerIds objectAtIndex:0];
        Banner *banner1 = [dataEngine getBannerById:bannerId1];
        NSNumber *bannerId2 = [dataEngine.segmentBannerIds objectAtIndex:1];
        Banner *banner2 = [dataEngine getBannerById:bannerId2];
        NSNumber *bannerId3 = [dataEngine.segmentBannerIds objectAtIndex:2];
        Banner *banner3 = [dataEngine getBannerById:bannerId3];
        
        NSArray *sortItems = [NSArray arrayWithObjects:banner1.title, banner2.title, banner3.title, nil];
        if (!_segment) {
            _segment = [[ITSegmentedControl alloc] initWithItems:sortItems];
            _segment.frame = CGRectMake(0, 0, 234, 30);
            [_segment setNormalImageLeft:[UIImage imageNamed:@"block"]];
            [_segment setSelectedImageLeft:[UIImage imageNamed:@"recommendSegmentSelected"]];
            [_segment setNormalImageMiddle:[UIImage imageNamed:@"block"]];
            [_segment setSelectedImageMiddle:[UIImage imageNamed:@"recommendSegmentSelected"]];
            [_segment setNormalImageRight:[UIImage imageNamed:@"block"]];
            [_segment setSelectedImageRight:[UIImage imageNamed:@"recommendSegmentSelected"]];
            
            [_segment setImageAndTitle:nil
                         selectedImage:nil
                                 title:[sortItems objectAtIndex:0]
                      normalTitleColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1.0f]
                    selectedTitleColor:[UIColor colorWithRed:148.0f/255.0f green:148.0f/255.0f blue:148.0f/255.0f alpha:1.0f]
                     forSegmentAtIndex:0];
            
            [_segment setImageAndTitle:nil
                         selectedImage:nil
                                 title:[sortItems objectAtIndex:1]
                      normalTitleColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1.0f]
                    selectedTitleColor:[UIColor colorWithRed:148.0f/255.0f green:148.0f/255.0f blue:148.0f/255.0f alpha:1.0f]
                     forSegmentAtIndex:1];
            
            [_segment setImageAndTitle:nil
                         selectedImage:nil
                                 title:[sortItems objectAtIndex:2]
                      normalTitleColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1.0f]
                    selectedTitleColor:[UIColor colorWithRed:148.0f/255.0f green:148.0f/255.0f blue:148.0f/255.0f alpha:1.0f]
                     forSegmentAtIndex:2];
            [_segment addTarget:self action:@selector(segmentSelected:) forControlEvents:UIControlEventValueChanged];
            [self.navigationItem setTitleView:_segment];
        }
        
        Banner *banner = [dataEngine getBannerById:[dataEngine.segmentBannerIds objectAtIndex:_selectedSegmentIndex]];
        
//        NSLog(@"[DataEngine sharedDataEngine].segmentBanners:%@", banner.items);
        _currentArray = [NSMutableArray arrayWithArray:banner.items];
        int totalCount = [_currentArray count];
        if (totalCount && totalCount > 0) {
            if (totalCount != kRecommendListPageSize) {
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

        [self initHeadRecommends];
        [self.tableView reloadData];
        [_segment setSelectedSegmentIndex:_selectedSegmentIndex];
        [_segment setTitle:[sortItems objectAtIndex:0] forSegmentAtIndex:0];
        [_segment setTitle:[sortItems objectAtIndex:1] forSegmentAtIndex:1];
        [_segment setTitle:[sortItems objectAtIndex:2] forSegmentAtIndex:2];
    } else {
        if ([[DataEngine sharedDataEngine].segmentBannerIds count] == 1) {
            NSNumber *tempBannerId = [[DataEngine sharedDataEngine].segmentBannerIds objectAtIndex:0];
            Banner *banner = [[DataEngine sharedDataEngine].banners objectForKey:tempBannerId];
            _currentArray = [NSMutableArray arrayWithArray:banner.items];
            self.navigationItem.title = banner.title;
            [self initHeadRecommends];
        }
    }
    if (![DataEngine sharedDataEngine].adIsHide) {
        [self showAD];
    }
}

- (void)initHeadRecommends
{

    recommendHeadBody = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 275)];
    [recommendHeadBody.layer setZPosition:-1];
    [recommendHeadBody setBackgroundColor:[UIColor clearColor]];
    [recommendHeadBody setTag:kRecommendHeadBodyTag];

    UIButton *headButton1 = [[UIButton alloc] initWithFrame:CGRectMake(0, -65, 320, 213)];
    [headButton1 setImage:[UIImage imageNamed:@"recommendBigEmpty.png"] forState:UIControlStateNormal];
    [headButton1 setTag:kRecommendHeadBodyItemImageTag + 1];
    [headButton1 addTarget:self action:@selector(open:) forControlEvents:UIControlEventTouchUpInside];
    [recommendHeadBody addSubview:headButton1];

    UILabel *headLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(7, 118, 300, 35)];
    [headLabel1 setTextColor:[UIColor whiteColor]];
    [headLabel1 setFont:[UIFont systemFontOfSize:12]];
    [headLabel1 setTextAlignment:NSTextAlignmentCenter];
    [headLabel1 setTag:kRecommendHeadBodyItemLabelTag + 1];
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
    } else {
        headButton1.hidden = YES;
        headLabel1.hidden = YES;
    }
    
    UIButton *headButton2 = [[UIButton alloc] initWithFrame:CGRectMake(0, 150, 159, 125)];
    [headButton2 setImage:[UIImage imageNamed:@"recommendBigEmpty.png"] forState:UIControlStateNormal];
    [headButton2 setTag:kRecommendHeadBodyItemImageTag + 2];
    [headButton2 addTarget:self action:@selector(open:) forControlEvents:UIControlEventTouchUpInside];
    [recommendHeadBody addSubview:headButton2];

    UILabel *headLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(7, 248, 300, 35)];
    [headLabel2 setBackgroundColor:[UIColor clearColor]];
    [headLabel2 setTextColor:[UIColor whiteColor]];
    [headLabel2 setFont:[UIFont systemFontOfSize:11]];
    [headLabel2 setTextAlignment:NSTextAlignmentCenter];
    [headLabel2 setTag:kRecommendHeadBodyItemLabelTag + 2];
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
    [headButton3 setTag:kRecommendHeadBodyItemImageTag + 3];
    [headButton3 addTarget:self action:@selector(open:) forControlEvents:UIControlEventTouchUpInside];
    [recommendHeadBody addSubview:headButton3];
    
    UILabel *headLabel3 = [[UILabel alloc] initWithFrame:CGRectMake(168, 248, 300, 35)];
    [headLabel3 setTextColor:[UIColor whiteColor]];
    [headLabel3 setFont:[UIFont systemFontOfSize:11]];
    [headLabel3 setTextAlignment:NSTextAlignmentCenter];
    [headLabel3 setTag:kRecommendHeadBodyItemLabelTag + 3];
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
    UIButton *recommendItemButton1 = (UIButton*)[self.tableView.tableHeaderView viewWithTag:kRecommendHeadBodyItemImageTag + 1];
    UILabel *recommendItemLabel1 = (UILabel*)[self.tableView.tableHeaderView viewWithTag:kRecommendHeadBodyItemLabelTag + 1];
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
    } else {
        recommendItemButton1.hidden = YES;
        recommendItemLabel1.hidden = YES;
        [recommendItemLabel1 setText:@""];
    }
    
    UIButton *recommendItemButton2 = (UIButton*)[self.tableView.tableHeaderView viewWithTag:kRecommendHeadBodyItemImageTag + 2];
    UILabel *recommendItemLabel2 = (UILabel*)[self.tableView.tableHeaderView viewWithTag:kRecommendHeadBodyItemLabelTag + 2];
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
        [recommendItemLabel2 setText:@""];
    }
    
    UIButton *recommendItemButton3 = (UIButton*)[self.tableView.tableHeaderView viewWithTag:kRecommendHeadBodyItemImageTag + 3];
    UILabel *recommendItemLabel3 = (UILabel*)[self.tableView.tableHeaderView viewWithTag:kRecommendHeadBodyItemLabelTag + 3];

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
        [recommendItemLabel3 setText:@""];
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
    NSLog(@"RecommendViewController didReceiveMemoryWarning!!!");
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
    DataEngine *dataEngine = [DataEngine sharedDataEngine];
    Banner *banner = [dataEngine getBannerById:[dataEngine.segmentBannerIds objectAtIndex:_selectedSegmentIndex]];
    [dataEngine getTile:kRecommendListPageSize
                current:_currentPage
               bannerId:banner.bannerId
               dataType:nil
                   from:_controllerId];
}

- (void)responseGetRecommends:(NSNotification *)notification
{
    NSDictionary *dictionary = (NSDictionary *)[notification userInfo];
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
        
        DataEngine *dataEngine = [DataEngine sharedDataEngine];
        if (([dataEngine getBannerById:[dataEngine.segmentBannerIds objectAtIndex:_selectedSegmentIndex]]).items && [([dataEngine getBannerById:[dataEngine.segmentBannerIds objectAtIndex:_selectedSegmentIndex]]).items count] > 0) {
            _currentArray = [[NSMutableArray alloc] initWithArray:([dataEngine getBannerById:[dataEngine.segmentBannerIds objectAtIndex:_selectedSegmentIndex]]).items];
        }
        int totalCount = [_currentArray count];
        _totalLines = totalCount / _rowItemCount + (totalCount % _rowItemCount == 0 ? 0 : 1);
        NSNumber *itemsCount = [dictionary objectForKey:@"count"];
        if (itemsCount && [itemsCount isKindOfClass:[NSNumber class]] && [itemsCount intValue] > 0) {
            if ([itemsCount intValue] != kRecommendListPageSize) {
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
    [_segment setEnabled:NO];
}

- (void)doneLoadingTableViewData
{
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    _reloading = NO;
    [self updateHeadRecommends];
    [_segment setEnabled:YES];
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
    [_segment setEnabled:NO];
}

- (void)doneLoadingMoreTableViewData
{
    _loadingMore = NO;
    [_loadMoreFooterView loadMoreScrollViewDataSourceDidFinishedLoading:self.tableView];
    [_segment setEnabled:YES];
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(loadImagesForOnscreenRows) object:nil];
    // 滚动时隐藏或者显示头部背景
    // 以及是否让广告永远浮动在表格最上面
    float nowY = scrollView.contentOffset.y;
    if (nowY < 0) {
        if (!isInHeadView) {
            [adView removeFromSuperview];
            [self.view addSubview:adView];
            isInHeadView = YES;
        }    } else if (nowY > 0) {
        if (isInHeadView) {
            [adView removeFromSuperview];
            [recommendHeadBody addSubview:adView];
            isInHeadView = NO;
        }
    }
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    if (_loadMoreShowing) {
        [_loadMoreFooterView loadMoreScrollViewDidScroll:scrollView];
    }
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
    
    int index = [button tag] - 1 - kRecommendHeadBodyItemImageTag;
    if (_currentArray && [_currentArray count] > index && index >= 0) {
        DataEngine *dataEngine = [DataEngine sharedDataEngine];
        Banner *banner = [dataEngine getBannerById:[dataEngine.segmentBannerIds objectAtIndex:_selectedSegmentIndex]];
        Tile *tile = [_currentArray objectAtIndex:index];
        [MobClick event:@"首页" attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@,%@,%@", banner.title ? banner.title : KPlaceholder, tile.tileId ? tile.tileId : KPlaceholder, tile.tileTitle ? tile.tileTitle : KPlaceholder], @"点击瓷砖图片", nil]];
        [UBAnalysis event:@"首页" labels:4, @"点击瓷砖图片", banner.title ? banner.title : KPlaceholder, [tile.tileId stringValue] ? [tile.tileId stringValue] : KPlaceholder, tile.tileTitle ? tile.tileTitle : KPlaceholder];
        
        if (forAnalysisPath && [forAnalysisPath isEqualToString:@""] && [forAnalysisPath length] <= 0) {
            forAnalysisPath = [NSString stringWithFormat:@"首页,%@,%lld>", banner.title, [banner.bannerId longLongValue]];
        } else {
            forAnalysisPath = [NSString stringWithFormat:@"%@首页,%@,%lld>", forAnalysisPath, banner.title, [banner.bannerId longLongValue]];
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
                forAnalysisPath = [NSString stringWithFormat:@"首页,%@,%lld", banner.title, [banner.bannerId longLongValue]];

                [MobClick event:@"商品详情页面" attributes:[NSDictionary dictionaryWithObjectsAndKeys:forAnalysisPath, @"进入来源", nil]];
                [UBAnalysis event:@"商品详情页面" labels:2, @"进入来源", forAnalysisPath];

                ItemDetailViewController *itemDetail = [[ItemDetailViewController alloc] initWithNibName:@"ItemDetailViewController" bundle:nil];
                itemDetail.treasureId = tile.itemId;
                itemDetail.treasuresArray = nil;
                itemDetail.preViewName = NSLocalizedString(@"123情景", @"");
                AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                [delegate presentModalViewController:itemDetail animated:YES];
            }
                break;
            case kTileActionTypeLink: {
                TSBWebViewController *tradeView = [[TSBWebViewController alloc] initWithNibName:@"TSBWebViewController" bundle:nil];
                tradeView.url = tile.link;
                tradeView.showTitle = tile.tileTitle;
                AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                [delegate presentModalViewController:tradeView animated:YES];
//                [self.navigationController pushViewController:tradeView animated:YES];
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
}

- (void)segmentSelected:(id)sender
{
    if (_segment == sender) {
        _currentPage = 0;
        _selectedSegmentIndex = _segment.selectedSegmentIndex;
        if ([_currentArray count] > 0) {
            self.tableView.contentOffset = CGPointMake(0, 0);
        }
        DataEngine *dataEngine = [DataEngine sharedDataEngine];
        if (_selectedSegmentIndex >= [dataEngine.segmentBannerIds count]) {
            return;
        }
//        return;
        _loadingMore = NO;
        _loadMoreShowing = YES;

        Banner *banner = [dataEngine getBannerById:[dataEngine.segmentBannerIds objectAtIndex:_selectedSegmentIndex]];
        _currentArray = [NSMutableArray arrayWithArray:banner.items];
        
        [MobClick event:@"首页" attributes:[NSDictionary dictionaryWithObjectsAndKeys:banner.title ? banner.title : KPlaceholder, @"切换标签", nil]];
        [UBAnalysis event:@"首页" labels:2, @"切换标签", banner.title ? banner.title : KPlaceholder];

        int totalCount = [_currentArray count];
        if (totalCount && totalCount > 0) {
            if (totalCount < kRecommendListPageSize) {
                _loadMoreShowing = NO;
            } else {
                if (totalCount > kRecommendListPageSize) {
                    // 从别的tab点过来，重新计算当前的页数
                    _currentPage = totalCount / kRecommendListPageSize - 1;
                }
                // 如果总数取余不是0，代表已经到最后一页了
                if (totalCount % kRecommendListPageSize == 0) {
                    _loadMoreShowing = YES;
                } else {
                    _loadMoreShowing = NO;
                }
            }
        } else {
            _loadMoreShowing = NO;
        }
        if (!_loadMoreShowing) {
            self.tableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
        }

        [self.tableView reloadData];
        [self updateHeadRecommends];
    }
}

- (void)responseDownloadImage:(NSNotification*) notification
{
    NSDictionary *dictionary = (NSDictionary *)[notification userInfo];
    if (![[dictionary objectForKey:REQUEST_SOURCE_KEY] isEqualToString:_controllerId]) {
        return;
    }
    NSString *imagePath = [dictionary objectForKey:TOUI_PARAM_DOWNLOADFILE_FILEPATH];
    if (imagePath) {
//        NSLog(@"self.tableView.isDragging:%@, ", ([self.tableView isDragging] ? @"YES" : @"NO"));
        [self updateHeadRecommends];
        if (![self.tableView isDragging] && ![self.tableView isDecelerating]) {
            [self loadImagesForOnscreenRows];
        }
    }
}

- (void)responseGetAdvertise:(NSNotification*) notification
{
    NSArray *ads = [LocalSettings loadAdvertise];
    if ([ads count] > 0) {
        if (adView) {
            // 有广告,显示出来
            [self showAD];
        }
    } else {
        [self closeRecommendADView];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    NSLog(@"RecommendViewContrller viewDidUnload");
    _refreshHeaderView = nil;
    _loadMoreFooterView = nil;
}

- (void)resetLabelWidth
{
    UILabel *recommendItemLabel1 = (UILabel*)[self.tableView.tableHeaderView viewWithTag:kRecommendHeadBodyItemLabelTag + 1];
    CGSize opSize = [recommendItemLabel1.text sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(307, 16)];
    [recommendItemLabel1 setFrame:CGRectMake(recommendItemLabel1.frame.origin.x, recommendItemLabel1.frame.origin.y, opSize.width + 14, opSize.height + 10)];
    if ([recommendItemLabel1.text isEqualToString:@""] || [recommendItemLabel1.text length] == 0) {
        [recommendItemLabel1 setHidden:YES];
    } else {
        [recommendItemLabel1 setHidden:NO];
    }
    
    UILabel *recommendItemLabel2 = (UILabel*)[self.tableView.tableHeaderView viewWithTag:kRecommendHeadBodyItemLabelTag + 2];
    CGSize opSize2 = [recommendItemLabel2.text sizeWithFont:[UIFont systemFontOfSize:11] constrainedToSize:CGSizeMake(143, 16)];
    [recommendItemLabel2 setFrame:CGRectMake(recommendItemLabel2.frame.origin.x, recommendItemLabel2.frame.origin.y, opSize2.width + 12, opSize2.height + 6)];
    if ([recommendItemLabel2.text isEqualToString:@""] || [recommendItemLabel2.text length] == 0) {
        [recommendItemLabel2 setHidden:YES];
    } else {
        [recommendItemLabel2 setHidden:NO];
    }

    UILabel *recommendItemLabel3 = (UILabel*)[self.tableView.tableHeaderView viewWithTag:kRecommendHeadBodyItemLabelTag + 3];
    CGSize opSize3 = [recommendItemLabel3.text sizeWithFont:[UIFont systemFontOfSize:11] constrainedToSize:CGSizeMake(143, 16)];
    [recommendItemLabel3 setFrame:CGRectMake(recommendItemLabel3.frame.origin.x, recommendItemLabel3.frame.origin.y, opSize3.width + 12, opSize3.height + 6)];
    if ([recommendItemLabel3.text isEqualToString:@""] || [recommendItemLabel3.text length] == 0) {
        [recommendItemLabel3 setHidden:YES];
    } else {
        [recommendItemLabel3 setHidden:NO];
    }
}

- (void)showAD
{
    NSArray *ads = [LocalSettings loadAdvertise];
    
    if (!adView) {
        adView = [[RecommendADView alloc] initWithFrame:CGRectMake(0, 0, 320, AD_HEIGHT)];
        [adView setDelegate:self];
    }
    adView.source = _controllerId;
    [adView setTag:AD_VIEW_TAG];
    [adView setBackgroundColor:[UIColor blackColor]];
    [[recommendHeadBody viewWithTag:AD_VIEW_TAG] removeFromSuperview];
    [recommendHeadBody addSubview:adView];
    [adView setAD:[NSMutableArray arrayWithArray:ads]];
    [DataEngine sharedDataEngine].adIsHide = NO;
    [adView setHidden:NO];
    if ([ads count] == 0) {
        // 没有广告,隐藏顶部广告条
        [DataEngine sharedDataEngine].adIsHide = YES;
        [adView setHidden:YES];
    }
    [self setHeadHeight];
}

- (void)setHeadHeight
{
    float floatHeight = AD_HEIGHT;
    if (adView.isHidden) {
        floatHeight = 0;
    }
    UIButton *headButton1 = (UIButton *) [recommendHeadBody viewWithTag:kRecommendHeadBodyItemImageTag + 1];
    UILabel *headLabel1 = (UILabel *)[recommendHeadBody viewWithTag:kRecommendHeadBodyItemLabelTag + 1];
    UIButton *headButton2 = (UIButton *) [recommendHeadBody viewWithTag:kRecommendHeadBodyItemImageTag + 2];
    UILabel *headLabel2 = (UILabel *)[recommendHeadBody viewWithTag:kRecommendHeadBodyItemLabelTag + 2];
    UIButton *headButton3 = (UIButton *) [recommendHeadBody viewWithTag:kRecommendHeadBodyItemImageTag + 3];
    UILabel *headLabel3 = (UILabel *)[recommendHeadBody viewWithTag:kRecommendHeadBodyItemLabelTag + 3];
    [headLabel1 setFrame:CGRectMake(7, 118 + floatHeight, headLabel1.frame.size.width, headLabel1.frame.size.height)];
    [headButton1 setFrame:CGRectMake(0, -65 + floatHeight, headButton1.frame.size.width, headButton1.frame.size.height)];
    
    [headLabel2 setFrame:CGRectMake(7, 248 + floatHeight, headLabel2.frame.size.width, headLabel2.frame.size.height)];
    [headButton2 setFrame:CGRectMake(0, 150 + floatHeight, headButton2.frame.size.width, headButton2.frame.size.height)];
    
    [headLabel3 setFrame:CGRectMake(168, 248 + floatHeight, headLabel3.frame.size.width, headLabel3.frame.size.height)];
    [headButton3 setFrame:CGRectMake(161, 150 + floatHeight, headButton3.frame.size.width, headButton3.frame.size.height)];
    
    [recommendHeadBody setFrame:CGRectMake(0, 0, 320, 275 + floatHeight)];
    self.tableView.tableHeaderView = recommendHeadBody;
    
}

- (void)openAD:(Advertise *)ad
{
    NSLog(@"openAD");
    [MobClick event:@"首页" attributes:[NSDictionary dictionaryWithObjectsAndKeys:ad.name ? ad.name : KPlaceholder, @"点击广告", nil]];
    [UBAnalysis event:@"首页" labels:2, @"点击广告", ad.name ? ad.name : KPlaceholder];

    TSBWebViewController *web = [[TSBWebViewController alloc] initWithNibName:@"TSBWebViewController" bundle:nil];
    [web setUrl:ad.url];
    AppDelegate *delegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
    [delegate presentModalViewController:web animated:YES];
//    [self.navigationController pushViewController:web
//                                         animated:YES];
}

- (void)closeRecommendADView
{
    NSLog(@"closeRecommendADView");
    [DataEngine sharedDataEngine].adIsHide = YES;
    [adView setHidden:YES];
    [self setHeadHeight];
    adView = nil;
}

- (void)showAD:(BOOL)isShowAD
{
    [adView setAlpha:isShowAD ? 1.0f : 0.0f];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)moreButtonClick:(id)sender
{
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate showLeft];
}
@end
