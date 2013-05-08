//
//  NearbyController.m
//  Pic it
//
//  Created by 郭雪 on 11-10-18.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "FavouriteViewController.h"
#import "Constants.h"
#import "DataEngine.h"
#import "AppDelegate.h"
#import "DistanceUtils.h"
#import "ThumbPhotoView.h"
#import "ImageCacheEngine.h"
#import "CustomNavigationBar.h"
#import "Treasure.h"
#import "ItemDetailViewController.h"
#import "RIButtonItem.h"
#import "UIAlertView+Blocks.h"

#define kRecommendListPageSize      30
#define kThumbnailSize              100
#define kThumbnailSpacing           5

@interface FavouriteViewController (Private)

- (void)loadImagesForOnscreenRows;

- (IBAction)handleThumbClick:(id)sender;

- (void)requestDownloadFile:(NSString *)url
                       type:(DownloadFileType)type;

- (void)responseDownloadFile:(NSNotification *)notification;

- (void)responseFavoriesChanged:(NSNotification *)notification;

- (void)toEdit:(id)sender;
- (void)finishEdit:(id)sender;
- (void)confirmEdit:(id)sender;
- (void)moreButtonClick:(id)sender;
- (void)back:(id)sender;
@end

@implementation FavouriteViewController

@synthesize tableView = _tableView;
@synthesize fromTab;

- (id)init{
    if (self == [super init]) {
        fromTab = NO;
    }
    return self;
}

- (void)moreButtonClick:(id)sender
{
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate showLeft];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    _controllerId = [[NSString alloc] initWithFormat:@"%p", self];
    isEdit = NO;
    _deleteArray = [[NSMutableArray alloc] init];
    if (_tableView == nil) {
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    
    [self.view addSubview:_tableView];
    if (!fromTab) {
        UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [moreButton setImage:[UIImage imageNamed:@"recommendMoreButton.png"] forState:UIControlStateNormal];
        [moreButton setImage:[UIImage imageNamed:@"recommendMoreButton_highlight.png"] forState:UIControlStateHighlighted];
        moreButton.frame = CGRectMake(0, 0, 47, 44);
        [moreButton addTarget:self action:@selector(moreButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:moreButton];
    } else {
        // 返回
        CustomNavigationBar* customNavigationBar = (CustomNavigationBar*)self.navigationController.navigationBar;
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
    
    self.navigationItem.title = NSLocalizedString(@"我的收藏", @"");
    
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"mainBackground.png"]];    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone; 
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(responseDownloadFile:)
                                                 name:REQUEST_DOWNLOADFILE_NOTIFICATION_NAME 
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(responseFavoriesChanged:)
                                                 name:FAVORITES_COUNT_CHANGE
                                               object:nil];
    
    if (_thumbsPerLine == 0) {
        _thumbsPerLine = self.tableView.frame.size.width / kThumbnailSize;
        _thumbsPerLine = (_thumbsPerLine == 0 ? 3 : _thumbsPerLine);
    }
    
    DataEngine *dataEngine = [DataEngine sharedDataEngine];
    _currentArray = [NSMutableArray arrayWithArray:dataEngine.favories];

    if ([_currentArray count] == 0) {
        UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"favouriteListBg.png"]];
        bg.contentMode = UIViewContentModeScaleAspectFit;
        [self.tableView setBackgroundView:bg];
    } else {
        [self.tableView setBackgroundView:nil];
        CustomNavigationBar *customNavigationBar = (CustomNavigationBar *)self.navigationController.navigationBar;
        
        UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [editButton setBackgroundImage:[[UIImage imageNamed:@"navigationBarButton"] stretchableImageWithLeftCapWidth:20.0 topCapHeight:16.0] forState:UIControlStateNormal];
        [editButton setBackgroundImage:[[UIImage imageNamed:@"navigationBarButton_selected"] stretchableImageWithLeftCapWidth:20.0 topCapHeight:16.0] forState:UIControlStateHighlighted];
        editButton.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
        editButton.titleLabel.textColor = [UIColor whiteColor];
        editButton.titleLabel.shadowOffset = CGSizeMake(0,-1);
        editButton.titleLabel.shadowColor = [UIColor darkGrayColor];
        editButton.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
        editButton.frame = CGRectMake(0, 0, 48, 28);
        [customNavigationBar setText:NSLocalizedString(@"编辑", @"") onBackButton:editButton leftCapWidth:20.0];
        [editButton addTarget:self action:@selector(toEdit:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:editButton];
    }
    
    int totalCount = [_currentArray count];
    _totalLines = totalCount / _thumbsPerLine + (totalCount % _thumbsPerLine == 0 ? 0 : 1);
    [self loadImagesForOnscreenRows];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.tableView = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (_isNeedRefresh) {
        [self.tableView reloadData];
        _isNeedRefresh = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{    
    return _totalLines;  
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kThumbnailSize + kThumbnailSpacing;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ThumbPhotoCell";
        
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
        for (UIView *view in cell.subviews) {
            if ([view isKindOfClass:[ThumbPhotoView class]]) {
                [view removeFromSuperview];
            }
        }
    }
        
    NSInteger startIndex = _thumbsPerLine * indexPath.row;
    DataEngine *dataEngine = [DataEngine sharedDataEngine];
    int totalCount = [_currentArray count];
    float dx = kThumbnailSpacing - 1;

    for (int i = 0; i < _thumbsPerLine; i++) {
        if (startIndex + i >= totalCount) {
            break;
        }
        
        NSNumber *treasureId = [_currentArray objectAtIndex:(startIndex + i)];
        Treasure *treasure = [dataEngine getTreasureByItemId:treasureId];
 
        CGRect rect = CGRectMake(dx, kThumbnailSpacing - 1, kThumbnailSize, kThumbnailSize);
        dx += kThumbnailSize + kThumbnailSpacing;
        ThumbPhotoView *thumbView = [[ThumbPhotoView alloc] initWithFrame:rect target:self action:@selector(handleThumbClick:)];
        [thumbView.imageBg setImage:[UIImage imageNamed:@"favouriteTreasureBg.png"]];
        thumbView.treasureId = treasure.tid;
        
        NSString *price = [NSString stringWithFormat:@"￥%1.2f", [treasure.price floatValue]];
        [thumbView.price setText:price];
        [thumbView.price setFrame:CGRectMake(thumbView.price.frame.origin.x, thumbView.price.frame.origin.y, thumbView.frame.size.width, thumbView.price.frame.size.height)];

//        if (treasure.volume) {
//            NSString *volumeString = [NSString stringWithFormat:@"销量%@", treasure.volume];
//            [thumbView.sellCount setText:volumeString];
//        }
        
        if (treasure.picUrl && [treasure.picUrl length] > 0) {
            NSString *realUrl = [NSString stringWithFormat:@"%@_%@.jpg", treasure.picUrl, [dataEngine getImageSize:kImageSizeThumb]];
            NSString *imagePath = [[ImageCacheEngine sharedInstance] getImagePathByUrl:realUrl];
            if (imagePath) {
                UIImage *image = [[UIImage alloc] initWithContentsOfFile:imagePath];
                [thumbView.imageView setImage:image];
            } else {
                [thumbView.imageView setImage:[UIImage imageNamed:@"recommendSmallEmpty.png"]];
                if (![_tableView isDragging] && ![_tableView isDecelerating]) {
                    [self requestDownloadFile:realUrl type:kDownloadFileTypeImage];
                }
            }
        }
        else {
            [thumbView.imageView setImage:[UIImage imageNamed:@"recommendSmallNoPic.png"]];
        }
        
        [thumbView setContentMode:UIViewContentModeScaleAspectFill];
        [thumbView setClipsToBounds:YES];
        [cell addSubview:thumbView];
        if (isEdit && _deleteArray && [_deleteArray count] > 0) {
            for (int i=0; i<[_deleteArray count]; i++) {
                NSNumber *treasureId = [_deleteArray objectAtIndex:i];
                if ([treasureId isEqualToNumber:treasure.tid]) {
                    UIView *delBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, thumbView.frame.size.width, thumbView.frame.size.height)];
                    [delBackgroundView setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.5]];
                    [thumbView addSubview:delBackgroundView];
                    UIImageView *delImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"delFavourite"]];
                    [delImageView setFrame:CGRectMake(thumbView.frame.size.width - 25, thumbView.frame.size.height - 25, 25, 25)];
                    [delImageView setUserInteractionEnabled:NO];
                    [delImageView.layer setZPosition:999999];
                    [delBackgroundView setUserInteractionEnabled:NO];
                    [thumbView addSubview:delImageView];
                    break;
                }
            }
        }
    }
    return cell;
}

- (void)requestDownloadFile:(NSString *)url
                       type:(DownloadFileType)type
{
    DataEngine *dataEngine = [DataEngine sharedDataEngine];
 	[dataEngine downloadFileByUrl:url type:type from:_controllerId];
}

- (void)responseDownloadFile:(NSNotification *)notification
{
    NSDictionary *dictionary = (NSDictionary *)[notification userInfo];
//    if (![[dictionary objectForKey:REQUEST_SOURCE_KEY] isEqualToString:_controllerId]) {
//        return;
//    }
    
    NSString *imagePath = [dictionary objectForKey:TOUI_PARAM_DOWNLOADFILE_FILEPATH];
    if (imagePath) {
        [self.tableView reloadData];
    }
}

- (void)responseFavoriesChanged:(NSNotification *)notification
{
    DataEngine *dataEngine = [DataEngine sharedDataEngine];
    _currentArray = [NSMutableArray arrayWithArray:dataEngine.favories];
    
    _isNeedRefresh = YES;
    int totalCount = [_currentArray count];
    _totalLines = totalCount / _thumbsPerLine + (totalCount % _thumbsPerLine == 0 ? 0 : 1);
    if ([_currentArray count] == 0) {
        UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"favouriteListBg.png"]];
        bg.contentMode = UIViewContentModeScaleAspectFit;
        [self.tableView setBackgroundView:bg];
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
        self.navigationItem.rightBarButtonItem = nil;
    } else {
        [self.tableView setBackgroundView:nil];
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
        CustomNavigationBar *customNavigationBar = (CustomNavigationBar *)self.navigationController.navigationBar;
        
        UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [editButton setBackgroundImage:[[UIImage imageNamed:@"navigationBarButton"] stretchableImageWithLeftCapWidth:20.0 topCapHeight:16.0] forState:UIControlStateNormal];
        [editButton setBackgroundImage:[[UIImage imageNamed:@"navigationBarButton_selected"] stretchableImageWithLeftCapWidth:20.0 topCapHeight:16.0] forState:UIControlStateHighlighted];
        editButton.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
        editButton.titleLabel.textColor = [UIColor whiteColor];
        editButton.titleLabel.shadowOffset = CGSizeMake(0,-1);
        editButton.titleLabel.shadowColor = [UIColor darkGrayColor];
        editButton.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
        editButton.frame = CGRectMake(0, 0, 48, 28);
        [customNavigationBar setText:NSLocalizedString(@"编辑", @"") onBackButton:editButton leftCapWidth:20.0];
        [editButton addTarget:self action:@selector(toEdit:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:editButton];
    }
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{

}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{	
    if (!decelerate) {
        [self loadImagesForOnscreenRows];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
}

- (IBAction)handleThumbClick:(id)sender
{
	ThumbPhotoView *photoView = (ThumbPhotoView*)[(UIGestureRecognizer *)sender view];
    if (isEdit) {
        // 编辑模式,加到数组里
        for (int i=0; i<[_deleteArray count]; i++) {
            NSNumber *delArrayTreasureId = [_deleteArray objectAtIndex:i];
            // 查找数组,如果找到,代表本次点击之前想要删除,再次点击想要取消
            if ([photoView.treasureId isEqualToNumber:delArrayTreasureId]) {
                [_deleteArray removeObjectAtIndex:i];
                [self.tableView reloadData];
                return;
            }
        }
        [_deleteArray addObject:photoView.treasureId];
        [self.tableView reloadData];
    } else {
        if (photoView.treasureId) {
            [MobClick event:@"商品详情页面" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@"收藏", @"进入来源", nil]];
            [UBAnalysis event:@"商品详情页面" labels:2, @"进入来源", [NSString stringWithFormat:@"收藏"]];

            ItemDetailViewController *itemDetail = [[ItemDetailViewController alloc] initWithNibName:@"ItemDetailViewController" bundle:nil];
            itemDetail.treasureId = photoView.treasureId;
            itemDetail.treasuresArray = nil;
            itemDetail.preViewName = NSLocalizedString(@"我的收藏", @"");
            AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [delegate presentModalViewController:itemDetail animated:YES];
        }
    }
}

- (void)loadImagesForOnscreenRows
{
    DataEngine *dataEngine = [DataEngine sharedDataEngine];
    int totalCount = [_currentArray count];
    if (totalCount > 0) {
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths) {
            if (indexPath.row < _totalLines) {
                NSInteger startIndex = _thumbsPerLine * indexPath.row;
                for (int i = 0; i < _thumbsPerLine; i++) {
                    if (startIndex + i >= totalCount) {
                        break;
                    }
                    
                    NSNumber *treasureId = [_currentArray objectAtIndex:(startIndex + i)];
                    Treasure *treasure = [dataEngine getTreasureByItemId:treasureId];
                    if (treasure.tid && treasure.picUrl && [treasure.picUrl length] > 0) {
                        NSString *realUrl = [NSString stringWithFormat:@"%@_%@.jpg", treasure.picUrl, [dataEngine getImageSize:kImageSizeThumb]];
                        NSString *imagePath = [[ImageCacheEngine sharedInstance] getImagePathByUrl:realUrl];
                        if (imagePath == nil) {
                            [self requestDownloadFile:treasure.picUrl type:kDownloadFileTypeImage];
                        }
                    }
                }
            }           
        }
    }
}


- (void)toEdit:(id)sender
{
    CustomNavigationBar *customNavigationBar = (CustomNavigationBar *)self.navigationController.navigationBar;
    UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [editButton setBackgroundImage:[[UIImage imageNamed:@"navigationBarButton"] stretchableImageWithLeftCapWidth:20.0 topCapHeight:16.0] forState:UIControlStateNormal];
    [editButton setBackgroundImage:[[UIImage imageNamed:@"navigationBarButton_selected"] stretchableImageWithLeftCapWidth:20.0 topCapHeight:16.0] forState:UIControlStateHighlighted];
    editButton.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
    editButton.titleLabel.textColor = [UIColor whiteColor];
    editButton.titleLabel.shadowOffset = CGSizeMake(0,-1);
    editButton.titleLabel.shadowColor = [UIColor darkGrayColor];
    editButton.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
    editButton.frame = CGRectMake(0, 0, 48, 28);
    [customNavigationBar setText:NSLocalizedString(@"完成", @"") onBackButton:editButton leftCapWidth:20.0];
    [editButton addTarget:self action:@selector(finishEdit:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc]initWithCustomView:editButton] animated:YES];
    
    UIButton *delButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [delButton setBackgroundImage:[[UIImage imageNamed:@"loginout"] stretchableImageWithLeftCapWidth:20.0 topCapHeight:16.0] forState:UIControlStateNormal];
    [delButton setBackgroundImage:[[UIImage imageNamed:@"loginout_selected"] stretchableImageWithLeftCapWidth:20.0 topCapHeight:16.0] forState:UIControlStateHighlighted];
    delButton.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
    delButton.titleLabel.textColor = [UIColor whiteColor];
    delButton.titleLabel.shadowOffset = CGSizeMake(0,-1);
    delButton.titleLabel.shadowColor = [UIColor darkGrayColor];
    delButton.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
    delButton.frame = CGRectMake(0, 0, 48, 28);
    [customNavigationBar setText:NSLocalizedString(@"删除所选", @"") onBackButton:delButton leftCapWidth:20.0];
    [delButton addTarget:self action:@selector(confirmEdit:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc]initWithCustomView:delButton] animated:YES];
    
    isEdit = YES;
}

- (void)finishEdit:(id)sender
{
    [_deleteArray removeAllObjects];
    CustomNavigationBar *customNavigationBar = (CustomNavigationBar *)self.navigationController.navigationBar;
    UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [editButton setBackgroundImage:[[UIImage imageNamed:@"navigationBarButton"] stretchableImageWithLeftCapWidth:20.0 topCapHeight:16.0] forState:UIControlStateNormal];
    [editButton setBackgroundImage:[[UIImage imageNamed:@"navigationBarButton_selected"] stretchableImageWithLeftCapWidth:20.0 topCapHeight:16.0] forState:UIControlStateHighlighted];
    editButton.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
    editButton.titleLabel.textColor = [UIColor whiteColor];
    editButton.titleLabel.shadowOffset = CGSizeMake(0,-1);
    editButton.titleLabel.shadowColor = [UIColor darkGrayColor];
    editButton.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
    editButton.frame = CGRectMake(0, 0, 48, 28);
    [customNavigationBar setText:NSLocalizedString(@"编辑", @"") onBackButton:editButton leftCapWidth:20.0];
    [editButton addTarget:self action:@selector(toEdit:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc]initWithCustomView:editButton] animated:YES];
    
    if (!fromTab) {
        UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [moreButton setImage:[UIImage imageNamed:@"recommendMoreButton.png"] forState:UIControlStateNormal];
        [moreButton setImage:[UIImage imageNamed:@"recommendMoreButton_highlight.png"] forState:UIControlStateHighlighted];
        moreButton.frame = CGRectMake(0, 0, 47, 44);
        [moreButton addTarget:self action:@selector(moreButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc]initWithCustomView:moreButton] animated:YES];
    } else {
        CustomNavigationBar* customNavigationBar = (CustomNavigationBar*)self.navigationController.navigationBar;
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
    isEdit = NO;
    [self.tableView reloadData];
}

- (void)confirmEdit:(id)sender
{
    if (_deleteArray && [_deleteArray count] <= 0) {
        return;
    }
    RIButtonItem *cancelButton = [[RIButtonItem alloc] init];
    [cancelButton setLabel:NSLocalizedString(@"取消", @"")];
    [cancelButton setAction:^{
        
    }];
    RIButtonItem *okButton = [[RIButtonItem alloc] init];
    [okButton setLabel:NSLocalizedString(@"确定", @"")];
    [okButton setAction:^{
        if (_deleteArray && [_deleteArray count] > 0) {
            for (int i=0; i<[_deleteArray count]; i++) {
                NSNumber *treasureId = [_deleteArray objectAtIndex:i];
                [[DataEngine sharedDataEngine] removeFavorieTreasure:treasureId];
            }
            [_deleteArray removeAllObjects];
            _currentArray = nil;
            _currentArray = [DataEngine sharedDataEngine].favories;
            if (_currentArray && [_currentArray count] <= 0) {
                [self finishEdit:nil];
                [self responseFavoriesChanged:nil];
            } else {
                [self.tableView reloadData];
            }
        }
    }];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"确定要删除所选的宝贝吗?", @"") message:nil cancelButtonItem:cancelButton otherButtonItems:okButton, nil];
    [alert show];
}

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
