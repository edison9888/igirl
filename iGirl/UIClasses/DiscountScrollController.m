//
//  RecommendScrollController.m
//  iTBK
//
//  Created by 王 兆琦 on 12-9-28.
//
//

#import "DiscountScrollController.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "DataEngine.h"
#import "Treasure.h"
#import "ImageCacheEngine.h"
#import "IIViewDeckController.h"
#import "ItemDetailViewController.h"
#import "MobClick.h"
#import "CLog.h"

#define kTreasureWidth      284
#define kTreasureHeight     377

@interface DiscountScrollController (private)

- (void)setScrollViewData;

- (void)requestGetDiscounts;
- (void)responseGetDiscounts:(NSNotification *)notification;

- (void)requestDownloadFile:(NSString *)url
                       type:(DownloadFileType)type;

- (void)responseDownloadFile:(NSNotification *)notification;

@end

@implementation DiscountScrollController

@synthesize showTitle           = _showTitle;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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
    [MobClick event:@"抢购页面" label:@"进入页面"];

    [super viewDidLoad];
    [self.view setClipsToBounds:YES];
    _controllerId = [[NSString alloc] initWithFormat:@"%p", self];
    self.navigationItem.title = _showTitle;

    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [moreButton setImage:[UIImage imageNamed:@"recommendMoreButton.png"] forState:UIControlStateNormal];
    [moreButton setImage:[UIImage imageNamed:@"recommendMoreButton_highlight.png"] forState:UIControlStateHighlighted];
    moreButton.frame = CGRectMake(0, 0, 47, 44);
    [moreButton addTarget:self.viewDeckController action:@selector(toggleLeftView) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:moreButton];

    [_discountViewBg setImage:[UIImage imageNamed:@"discountScrollBg.png"]];
    [_discountViewBg setContentMode:UIViewContentModeScaleAspectFill];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(responseDownloadFile:)
                                                 name:REQUEST_DOWNLOADFILE_NOTIFICATION_NAME
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(responseGetDiscounts:)
                                                 name:REQUEST_DISCOUNT
                                               object:nil];
    [self requestGetDiscounts];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
     _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerFireMethod:) userInfo:nil repeats:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [MobClick beginLogPageView:@"抢购页面"];
    [MobClick event:@"抢购页面" label:@"页面显示"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [_timer invalidate];
    _timer = nil;
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [MobClick endLogPageView:@"抢购页面"];
    [MobClick event:@"抢购页面" label:@"页面隐藏"];
}

#pragma mark - private method
- (void)requestGetDiscounts
{
    [[DataEngine sharedDataEngine] getDiscountItems:_controllerId];
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate showActivityView:@"获取数据，请稍后..." inView:delegate.window];
}

- (void)responseGetDiscounts:(NSNotification *)notification
{
    NSDictionary *dictionary = (NSDictionary *)[notification userInfo];
    if (![[dictionary objectForKey:REQUEST_SOURCE_KEY] isEqualToString:_controllerId]) {
        return;
    }
    
    AppDelegate *delegate= (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSNumber *returnCode = [dictionary objectForKey:RETURN_CODE];
    if (returnCode && [returnCode isKindOfClass:[NSNumber class]] && [returnCode intValue] == NO_ERROR) {
        [delegate hideActivityView:delegate.window];
        _currentArray = [NSArray arrayWithArray:[dictionary objectForKey:@"discountList"]];
        [self setScrollViewData];
    } else {
        [delegate showFailedActivityView:[dictionary objectForKey:TOUI_REQUEST_ERROR_MESSAGE] interval:ERROR_MESSAGE_SHOW_INTERVAL_NORMAL inView:delegate.window];
    }
}

- (void)requestDownloadFile:(NSString *)url
                       type:(DownloadFileType)type
{
 	[[DataEngine sharedDataEngine] downloadFileByUrl:url type:type from:_controllerId];
}

- (void)responseDownloadFile:(NSNotification *)notification
{
    NSDictionary *dictionary = (NSDictionary *)[notification userInfo];
    if (![[dictionary objectForKey:REQUEST_SOURCE_KEY] isEqualToString:_controllerId]) {
        return;
    }
    
    NSString *imagePath = [dictionary objectForKey:TOUI_PARAM_DOWNLOADFILE_FILEPATH];
    NSString *imageUrl = [dictionary objectForKey:REQUEST_DOWNLOADFILE_URL];
    
    if (imagePath) {
        for (UIView *view in _scrollView.subviews) {
            if (view && [view isKindOfClass:[DiscountView class]]) {
                if ([((DiscountView *)view).imageUrl isEqualToString:imageUrl]) {
                    [((DiscountView *)view) setImageUrl:imageUrl];
                }
            }
        }
    }
}

- (void)setScrollViewData
{
    for (UIView *view in _scrollView.subviews) {
        [view removeFromSuperview];
    }
    DataEngine *dataEngine = [DataEngine sharedDataEngine];
    int index = 0;
    for (NSNumber *treasureId in _currentArray) {
        Treasure *treasure = [dataEngine getTreasureByItemId:treasureId];
        DiscountView *view = [[DiscountView alloc] initWithFrame:CGRectMake(index * kTreasureWidth, 0, kTreasureWidth, kTreasureHeight)];
        [view setDelegate:self];
        [view setTreasureId:treasureId];
        [view.treasureView setBackgroundColor:[UIColor clearColor]];
        [view.treasureViewBg setImage:[UIImage imageNamed:@"discountTreasureViewBg.png"]];
        [view.treasureStatusView setBackgroundColor:[UIColor clearColor]];
        [view.treasureStatusViewBg setBackgroundImage:[UIImage imageNamed:@"discountTreasureStatusBg.png"] forState:UIControlStateNormal];
        [view.treasureStatusViewBg setBackgroundImage:[UIImage imageNamed:@"discountTreasureStatusHighlightBg.png"] forState:UIControlStateHighlighted];
        [view.treasureStatusViewBg setBackgroundImage:[UIImage imageNamed:@"discountTreasureStatusBgDisabled.png"] forState:UIControlStateDisabled];
        [view.timeIcon setImage:[UIImage imageNamed:@"discountTimeIcon.png"]];
        
        if (treasure.picUuid) {
            NSString *realUrl = [[DataEngine sharedDataEngine] getImageUrlByUUID:treasure.picUuid];
            [view setImageUrl:realUrl];
        } else {
            [view setImageUrl:treasure.picUrl];
        }

        [view.treasureTitle setText:treasure.title];
        [view.recommandReason setText:treasure.recommend];
        [view.priceLabel setText:[NSString stringWithFormat:NSLocalizedString(@"￥%@", @""), treasure.price]];
        int priceLabelWidth = [view.priceLabel.text sizeWithFont:view.priceLabel.font].width;
        CGRect priceLabelFrame = view.priceLabel.frame;
        [view.priceLabel setFrame:CGRectMake(priceLabelFrame.origin.x, priceLabelFrame.origin.y, priceLabelWidth, priceLabelFrame.size.height)];
        
        [view.orgPriceLabel setText:[NSString stringWithFormat:NSLocalizedString(@"原价: ￥%@", @""), treasure.orgPrice]];
        int orgPriceLabelWidth = [view.orgPriceLabel.text sizeWithFont:view.orgPriceLabel.font].width;
        CGRect orgPriceLabelFrame = view.orgPriceLabel.frame;
        [view.orgPriceLabel setFrame:CGRectMake(priceLabelFrame.origin.x + priceLabelWidth + 15, orgPriceLabelFrame.origin.y, orgPriceLabelWidth, orgPriceLabelFrame.size.height)];
        
        if ([treasure.price doubleValue] < [treasure.orgPrice doubleValue] && [treasure.orgPrice doubleValue] != 0.0) {
            [view.discountLevel setHidden:NO];
            [view.discountLevel setBackgroundImage:[UIImage imageNamed:@"discountButtonBackground.png"] forState:UIControlStateNormal];
            [view.discountLevel setTitle:[NSString stringWithFormat:@"%.0f折", ([treasure.price doubleValue] / [treasure.orgPrice doubleValue] * 10)] forState:UIControlStateNormal];
        } else {
            [view.discountLevel setHidden:YES];
        }
        
        NSDate *date = treasure.couponTime;
        NSString *time = [self refreshViewTimeLabel:date];
        if (time == nil) {
            [view.timeText setText:@"已过期"];
            [view.treasureStatusViewBg setEnabled:NO];
            [view.treasureStatusLabel setText:NSLocalizedString(@"抢光了", @"")];
        } else {
            [view.timeText setText:[NSString stringWithFormat:@"剩余时间:%@",time]];
            [view.treasureStatusViewBg setEnabled:YES];
            [view.treasureStatusLabel setText:NSLocalizedString(@"立即抢购", @"")];
        }
        
        [_timer invalidate];
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerFireMethod:) userInfo:nil repeats:YES];

        [_scrollView addSubview:view];
        index++;
    }
    NSLog(@"%@", self.view);
    [_scrollView setClipsToBounds:NO];
    [_scrollView setContentOffset:CGPointMake(-1, 0)];
    [_scrollView setContentSize:CGSizeMake(_scrollView.frame.size.width * index, _scrollView.frame.size.height)];
}

- (void)timerFireMethod:(NSTimer *)timer
{
    DataEngine *dataEngine = [DataEngine sharedDataEngine];
    for (DiscountView *view in [_scrollView subviews]) {
        if (view && [view isKindOfClass:[DiscountView class]]) {
            Treasure *treasure = [dataEngine.treasures objectForKey:view.treasureId];
            if (treasure && treasure.couponTime != 0) {
                NSDate *date = treasure.couponTime;
                NSString *time = [self refreshViewTimeLabel:date];
                if (time == nil) {
                    [view.timeText setText:@"已过期"];
                    [view.treasureStatusViewBg setEnabled:NO];
                } else {
                    [view.timeText setText:[NSString stringWithFormat:@"剩余时间:%@",time]];
                    [view.treasureStatusViewBg setEnabled:YES];
                }
            }
        }
    }
}

- (NSString *)refreshViewTimeLabel:(NSDate *)fireDate
{
    NSDate *today = [NSDate date];
    if ([today timeIntervalSince1970] > [fireDate timeIntervalSince1970]) {
        return nil;
    }
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    unsigned int unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    //计算时间差
    NSDateComponents *d = [calendar components:unitFlags fromDate:today toDate:fireDate options:0];
    //倒计时显示
    return [NSString stringWithFormat:@"%d:%02d:%02d", [d day] * 24 + [d hour], [d minute], [d second]];
}

#pragma mark - RecommendScrollViewDelegate

- (void)clickDiscountView:(id)sender
{
    DiscountView *clickedView = (DiscountView *)sender;
	if ([clickedView treasureId] && [[clickedView treasureId] isKindOfClass:[NSNumber class]]) {
        [MobClick event:@"抢购页面" attributes:[NSDictionary dictionaryWithObjectsAndKeys:[[clickedView treasureId] stringValue], @"点击抢购", nil]];
        ItemDetailViewController *itemDetail = [[ItemDetailViewController alloc] initWithNibName:@"ItemDetailViewController" bundle:nil];
        itemDetail.treasureId = [clickedView treasureId];
        itemDetail.treasuresArray = nil;
        itemDetail.preViewName = @"限时抢购";
        [self.navigationController pushViewController:itemDetail animated:YES];
    }
}

- (void)getDiscountViewImage:(NSString *)url
{
    [self requestDownloadFile:url type:kDownloadFileTypeImage];
}

@end
