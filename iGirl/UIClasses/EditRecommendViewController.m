//
//  RecommendItemsViewController.m
//  iAccessories
//
//  Created by sunxq on 12-12-19.
//  Copyright (c) 2012年 MobileWoo. All rights reserved.
//

#import "EditRecommendViewController.h"
#import "DataEngine.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "EditRecommendView.h"
#import "Treasure.h"
#import "IIViewDeckController.h"

#define VIEW_WIDTH              303.0
#define VIEW_HEIGHT             352.0

#define SCROLLVIEW_START_X      8
#define SCROLLVIEW_START_Y      8
#define SCROLLVIEW_GAP          14

@interface EditRecommendViewController ()

@end

@implementation EditRecommendViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [MobClick event:@"小编推荐" label:@"进入页面"];

    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.navigationItem.title = NSLocalizedString(@"今日推荐", @"");
    if (_controllerId || [_controllerId length] == 0) {
        _controllerId = [[NSString alloc] initWithFormat:@"%p", self];
    }
    
    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [moreButton setImage:[UIImage imageNamed:@"recommendMoreButton.png"] forState:UIControlStateNormal];
    [moreButton setImage:[UIImage imageNamed:@"recommendMoreButton_highlight.png"] forState:UIControlStateHighlighted];
    moreButton.frame = CGRectMake(0, 0, 47, 44);
    [moreButton addTarget:self.viewDeckController action:@selector(toggleLeftView) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:moreButton];
    
    // scrollView
    _scrollView.backgroundColor = [UIColor colorWithRed:233.0f/255.0f green:233.0f/255.0f blue:233.0f/255.0f alpha:1];
    
    // add notification
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(responseGetRecommendItems:)
                                                 name:REQUEST_RECOMMENDITEMS
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(responseDownloadImage:)
                                                 name:REQUEST_DOWNLOADFILE_NOTIFICATION_NAME
                                               object:nil];
    
    [self requestRecommendItems];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [MobClick beginLogPageView:@"小编推荐"];
    [MobClick event:@"小编推荐" label:@"页面显示"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [MobClick endLogPageView:@"小编推荐"];
    [MobClick event:@"小编推荐" label:@"页面隐藏"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Request & Response

- (void)requestRecommendItems
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate showActivityView:NSLocalizedString(@"请稍候...", @"") inView:delegate.window];
    [[DataEngine sharedDataEngine] getRecommendItems:_controllerId];
}

- (void)responseGetRecommendItems:(NSNotification *)notification
{
    NSDictionary *dict = [notification userInfo];
    if ([dict objectForKey:REQUEST_SOURCE_KEY] != _controllerId) {
        return;
    }
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSNumber *returnCode = [dict objectForKey:RETURN_CODE];
    if (returnCode && [returnCode isKindOfClass:[NSNumber class]] && [returnCode intValue] == 0) {
        [delegate hideActivityView:delegate.window];
        [self updateUI];
    } else {
        [delegate showFailedActivityView:[dict objectForKey:TOUI_REQUEST_ERROR_MESSAGE] interval:ERROR_MESSAGE_SHOW_INTERVAL_NORMAL inView:delegate.window];
    }
}

- (void)requestDownloadImage:(Treasure *)treasure
{
    DataEngine *dataEngine = [DataEngine sharedDataEngine];
    NSString *url = nil;
    if (treasure.picUuid && [treasure.picUuid length] > 0) {
        url = [dataEngine getImageUrlByUUID:treasure.picUuid];
    } else {
        url = treasure.picUrl;
    }
    [dataEngine downloadFileByUrl:url type:kDownloadFileTypeImage from:_controllerId];
}

- (void)responseDownloadImage:(NSNotification*) notification
{
    NSDictionary *dictionary = (NSDictionary *)[notification userInfo];
    if (![[dictionary objectForKey:REQUEST_SOURCE_KEY] isEqualToString:_controllerId]) {
        return;
    }
    NSString *imagePath = [dictionary objectForKey:TOUI_PARAM_DOWNLOADFILE_FILEPATH];
    NSString *imageUrl = [dictionary objectForKey:TOUI_PARAM_DOWNLOADFILE_FILEURL];
    if (imagePath) {
        [self loadImages:imagePath imageUrl:imageUrl];
    }
}

#pragma mark - Update UI

- (void)updateUI
{
    DataEngine *dataEngine = [DataEngine sharedDataEngine];
    _items = [[NSArray alloc] initWithArray:dataEngine.recommendItems];
    int count = [_items count];
    _catId = [[NSMutableArray alloc] initWithCapacity:count];
    
    if (_items && count > 0) {
        for (int i = 0; i < count; i++) {
            Treasure *treasure = [_items objectAtIndex:i];
            [_catId addObject:treasure.tid];
            
            CGFloat x = SCROLLVIEW_START_X;
            CGFloat y = SCROLLVIEW_START_Y + i * (VIEW_HEIGHT + SCROLLVIEW_GAP);
            CGFloat width = VIEW_WIDTH;
            CGFloat height = VIEW_HEIGHT;
            EditRecommendView *view = [[EditRecommendView alloc] initWithFrame:CGRectMake(x, y, width, height)];
            view.tag = i;
            view.cotroller = self;
            view.treasure = treasure;
            [view loadValues:treasure];
            
            [_scrollView addSubview:view];
        }
        
        CGFloat h = 2 * SCROLLVIEW_START_Y + count * VIEW_HEIGHT + (count -1) * SCROLLVIEW_GAP;
        [_scrollView setContentSize:CGSizeMake(self.view.bounds.size.width, h)];
    }
}

- (void)loadImages:(NSString *)imagePath imageUrl:(NSString *)imageUrl
{
    for (id sub in [_scrollView subviews]) {
        if ([sub isKindOfClass:[EditRecommendView class]]) {
            EditRecommendView *view = (EditRecommendView *) sub;
            if (_items && [_items count] > 0) {
                Treasure *treausre = [_items objectAtIndex:view.tag];
                if (treausre.picUrl && [treausre.picUrl isEqualToString:imageUrl]) {
                    [view loadTreasureImage:[UIImage imageWithContentsOfFile:imagePath]];
                }
            }
        }
    }
}


@end
