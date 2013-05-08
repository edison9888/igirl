//
//  ItemDetailViewController.m
//  iTBK
//
//  Created by 郭雪 on 12-9-28.
//
//

#import "ItemDetailViewController.h"
#import "ItemDetailView.h"
#import "CustomNavigationBar.h"
#import "DataEngine.h"
#import "AppDelegate.h"
#import "Reachability.h"
#import "TSBWebViewController.h"
#import "Constants.h"
#import "Treasure.h"
#import "ShareViewController.h"
#import "ImageCacheEngine.h"
#import "RecommendViewController.h"
#import "OrderAddViewController.h"

@interface ItemDetailViewController ()

- (void)responseGetItemDetail:(NSNotification *)notification;

- (IBAction)favourite:(id)sender;
- (IBAction)buy:(id)sender;
- (IBAction)share:(id)sender;
- (void)close:(id)sender;
- (void)back:(id)sender;
- (void)moreButtonClick:(id)sender;
- (void)updateFavouriteButton;

@end

@implementation ItemDetailViewController

@synthesize treasureId;
@synthesize treasuresArray;
//@synthesize favouriteButton;
@synthesize source = _source;
@synthesize buyButton;
@synthesize isFirstClass = _isFirstClass;
@synthesize isJumpIndex = _isJumpIndex;
@synthesize preViewName         = _preViewName;
@synthesize fromSimilar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _isFirstClass = NO;
        _isJumpIndex = NO;
        fromSimilar = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [MobClick event:@"商品详情页面" label:@"进入页面"];
    [UBAnalysis event:@"商品详情页面" label:@"进入页面"];

    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(responseGetItemDetail:)
                                                 name:REQUEST_GETITEMDETAIL
                                               object:nil];
    
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
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeButton setBackgroundImage:[[UIImage imageNamed:@"navigationBarButton.png"] stretchableImageWithLeftCapWidth:20.0 topCapHeight:16.0] forState:UIControlStateNormal];
        [closeButton setBackgroundImage:[[UIImage imageNamed:@"navigationBarButton_selected.png"] stretchableImageWithLeftCapWidth:20.0 topCapHeight:16.0] forState:UIControlStateHighlighted];
        // Set the title to use the same font and shadow as the standard back button
        closeButton.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
        closeButton.titleLabel.textColor = [UIColor whiteColor];
        closeButton.titleLabel.shadowOffset = CGSizeMake(0,-1);
        closeButton.titleLabel.shadowColor = [UIColor darkGrayColor];
        // Set the break mode to truncate at the end like the standard back button
        closeButton.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
        // Inset the title on the left and right
        closeButton.titleEdgeInsets = UIEdgeInsetsMake(0, 6.0, 0, 3.0);
        // Make the button as high as the passed in image
        closeButton.frame = CGRectMake(0, 0, 48, 28);
        [closeButton addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
        [customNavigationBar setText:[customNavigationBar closeText] onBackButton:closeButton leftCapWidth:20.0];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:closeButton];
    }
    if (fromSimilar) {
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
    
    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [shareButton setBackgroundImage:[[UIImage imageNamed:@"navigationBarButton.png"] stretchableImageWithLeftCapWidth:20.0 topCapHeight:16.0] forState:UIControlStateNormal];
    [shareButton setBackgroundImage:[[UIImage imageNamed:@"navigationBarButton_selected.png"] stretchableImageWithLeftCapWidth:20.0 topCapHeight:16.0] forState:UIControlStateHighlighted];
    // Set the title to use the same font and shadow as the standard back button
    shareButton.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
    shareButton.titleLabel.textColor = [UIColor whiteColor];
    shareButton.titleLabel.shadowOffset = CGSizeMake(0,-1);
    shareButton.titleLabel.shadowColor = [UIColor darkGrayColor];
    // Set the break mode to truncate at the end like the standard back button
    shareButton.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
    // Inset the title on the left and right
    shareButton.titleEdgeInsets = UIEdgeInsetsMake(0, 6.0, 0, 3.0);
    // Make the button as high as the passed in image
    shareButton.frame = CGRectMake(0, 0, 48, 28);
    [shareButton setImage:[UIImage imageNamed:@"shareIcon"] forState:UIControlStateNormal];
//    [customNavigationBar setText:NSLocalizedString(@"分享", @"") onBackButton:shareButton leftCapWidth:20.0];
    [shareButton addTarget:self action:@selector(share:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:shareButton];
    
    self.navigationItem.title = NSLocalizedString(@"宝贝详情", @"");
    
    scrollView.delegate = self;
    scrollView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"mainBackground.png"]];
    centerView = [[ItemDetailView alloc] init];
    centerView.itemDetailViewController = self;
    [[NSBundle mainBundle] loadNibNamed:@"ItemDetailView" owner:centerView options:nil];
    
    centerView.treasureId = treasureId;
    [centerView boundItemValues:YES];
    [scrollView addSubview:centerView.bodyScrollView];
    [self updateFavouriteButton];
    centerView.bodyScrollView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [scrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height)];
    [scrollView setContentOffset:CGPointMake(0, 0)];
    
    DataEngine *dataEngine = [DataEngine sharedDataEngine];    
    
    if (self.source == kItemDetailFromOrder) {
        [buyButton setTitle:@"货到付款" forState:UIControlStateNormal];
    }else if (dataEngine.buyButtonText && [dataEngine.buyButtonText length] > 0) {
        [buyButton setTitle:dataEngine.buyButtonText forState:UIControlStateNormal];
    }
    else {
        [buyButton setTitle:NSLocalizedString(@"立即购买", @"") forState:UIControlStateNormal];
    }
    
    centerIndex = -1;
    
    if (treasuresArray && [treasuresArray count] > 0) {
        for (int i = 0; i < [treasuresArray count]; i++) {
            NSNumber* item_id = [treasuresArray objectAtIndex:i];
            if ([item_id isEqualToNumber:treasureId]) {
                centerIndex = i;
                break;
            }
        }
        
        if (centerIndex - 1 >= 0) {//left exist
            Treasure *theTreasure = [dataEngine.treasures objectForKey:[treasuresArray objectAtIndex:centerIndex - 1]];
            if (theTreasure) {
                leftView = [[ItemDetailView alloc] init];
                leftView.itemDetailViewController = self;
                [[NSBundle mainBundle] loadNibNamed:@"ItemDetailView" owner:leftView options:nil];
                leftView.treasureId = theTreasure.tid;
                [leftView boundItemValues:NO];
                [scrollView addSubview:leftView.bodyScrollView];
                
                leftView.bodyScrollView.frame = centerView.bodyScrollView.frame;
                centerView.bodyScrollView.frame = CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
                [scrollView setContentSize:CGSizeMake(self.view.frame.size.width * 2, self.view.frame.size.height)];
                [scrollView setContentOffset:CGPointMake(self.view.frame.size.width, 0)];
            }
        }
        if (centerIndex + 1 > 0 && centerIndex + 1 < [treasuresArray count]) {//right exist
            Treasure *theTreasure = [dataEngine.treasures objectForKey:[treasuresArray objectAtIndex:centerIndex + 1]];
            if (theTreasure) {
                rightView = [[ItemDetailView alloc] init];
                rightView.itemDetailViewController = self;
                [[NSBundle mainBundle] loadNibNamed:@"ItemDetailView" owner:rightView options:nil];
                
                rightView.treasureId = theTreasure.tid;
                [rightView boundItemValues:NO];
                [scrollView addSubview:rightView.bodyScrollView];
                
                rightView.bodyScrollView.frame = CGRectMake(centerView.bodyScrollView.frame.origin.x + self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
                [scrollView setContentSize:CGSizeMake(self.view.frame.size.width + scrollView.contentSize.width, self.view.frame.size.height)];
            }
        }
    }
    
    if (leftView == nil && rightView == nil) {
        [scrollView setScrollEnabled:FALSE];
    }
    
    if (self.source == kItemDetailFromOrder) {
        // 到付隐藏收藏
        favouriteButton.hidden = YES;
        [buyButton setFrame:CGRectMake(27, 5, 267, 41)];
        centerView.hideSimilar = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [MobClick beginLogPageView:@"商品详情页面"];
    [MobClick event:@"商品详情页面" label:@"页面显示"];
    [UBAnalysis event:@"商品详情页面" label:@"页面显示"];
    [UBAnalysis startTracPage:@"商品详情页面" labels:0];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [MobClick endLogPageView:@"商品详情页面"];
    [MobClick event:@"商品详情页面" label:@"页面隐藏"];
    [UBAnalysis event:@"商品详情页面" label:@"页面隐藏"];
    [UBAnalysis endTracPage:@"商品详情页面" labels:0];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)close:(id)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    treasuresArray = nil;
    [[self parentViewController] dismissModalViewControllerAnimated:true];
}

- (void)back:(id)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    treasuresArray = nil;
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)favourite:(id)sender
{    
    AppDelegate *delegate= (AppDelegate *)[[UIApplication sharedApplication] delegate];
    DataEngine *dataEngine = [DataEngine sharedDataEngine];
    if ([dataEngine.favories containsObject:centerView.treasureId]) {
        [dataEngine removeFavorieTreasure:centerView.treasureId];
        [self updateFavouriteButton];
        [MobClick event:@"商品详情页面" label:@"取消收藏"];
        [UBAnalysis event:@"商品详情页面" label:@"取消收藏"];
        [delegate showFinishActivityView:NSLocalizedString(@"已取消收藏！", @"") interval:ERROR_MESSAGE_SHOW_INTERVAL_NORMAL inView:delegate.window];
    } else {
        Treasure *treasure = [dataEngine getTreasureByItemId:centerView.treasureId];
        if (treasure) {
            [dataEngine addFavorieTreasure:centerView.treasureId];
            [self updateFavouriteButton];
            [MobClick event:@"商品详情页面" label:@"点击收藏"];
            [UBAnalysis event:@"商品详情页面" label:@"点击收藏"];
            [delegate showFinishActivityView:NSLocalizedString(@"已收藏！", @"") interval:ERROR_MESSAGE_SHOW_INTERVAL_NORMAL inView:delegate.window];
        } else {
            [delegate showFinishActivityView:NSLocalizedString(@"未获得商品信息无法收藏！", @"") interval:ERROR_MESSAGE_SHOW_INTERVAL_NORMAL inView:delegate.window];
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:FAVORITES_COUNT_CHANGE object:nil];
}

- (IBAction)buy:(id)sender
{
    [MobClick event:@"商品详情页面" attributes:[NSDictionary dictionaryWithObjectsAndKeys:_preViewName ? _preViewName : KPlaceholder, @"点击购买", nil]];
    [UBAnalysis event:@"商品详情页面" labels:2, @"点击购买", _preViewName ? _preViewName : KPlaceholder];
    [MobClick event:@"商品详情页面" label:@"点击购买"];
    [UBAnalysis event:@"商品详情页面" label:@"点击购买"];

    if(NotReachable == [[Reachability reachabilityForInternetConnection] currentReachabilityStatus]) {
        NSString *statusString = NSLocalizedString(@"没有找到可用的互联网连接。", @"");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"没有连接到互联网", @"")
                                                        message:statusString
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
        [alert show];
    } else {
        if (self.source == kItemDetailFromOrder) {
            OrderAddViewController *orderAdd = [[OrderAddViewController alloc] init];
            orderAdd.itemId = treasureId;
            orderAdd.itemName = ((Treasure *) [[DataEngine sharedDataEngine].treasures objectForKey:treasureId]).title;
            [self.navigationController pushViewController:orderAdd animated:YES];
        } else {
            TSBWebViewController *tradeView = [[TSBWebViewController alloc] initWithNibName:@"TSBWebViewController" bundle:nil];
            if(centerView.treasure.clickUrl && [centerView.treasure.clickUrl length] > 0) {
                tradeView.url = [NSString stringWithFormat:@"%@&ttid=%@&sid=%@", centerView.treasure.clickUrl, TAOBAO_TTID, [DataEngine sharedDataEngine].sid];
            } else {
                tradeView.url = [NSString stringWithFormat:@"http://a.m.taobao.com/i%ld.html&ttid=%@&sid=%@", [treasureId longValue], TAOBAO_TTID, [DataEngine sharedDataEngine].sid];
            }
            tradeView.showTitle = NSLocalizedString(@"手机淘宝网", @"");
            [self.navigationController pushViewController:tradeView animated:YES];
        }
    }
}

- (IBAction)share:(id)sender
{
    [MobClick event:@"商品详情页面" label:@"点击分享"];
    [UBAnalysis event:@"商品详情页面" label:@"点击分享"];

    ShareViewController *share = [[ShareViewController alloc] initWithNibName:@"ShareViewController" bundle:nil];
    share.treasureId = treasureId;
    if (centerView.treasure.picUrl) {
        share.shareImagePath = centerView.treasure.picUrl;//[[ImageCacheEngine sharedInstance] getImagePathByUrl:centerView.treasure.picUrl];
    }
    [self.navigationController pushViewController:share animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)theScrollView
{
    if (theScrollView.contentOffset.x != 0.0 && theScrollView.contentOffset.x != 320.0 && theScrollView.contentOffset.x != 640.0) {
        if (theScrollView.contentOffset.y != 0.0) {
            theScrollView.contentOffset = CGPointMake(theScrollView.contentOffset.x, 0);
        }
    }
}

//currentOffsetX
- (void)scrollRight
{
    DataEngine *dataEngine = [DataEngine sharedDataEngine];
    if (centerIndex <= 1) {
        if (centerIndex == 1) {
            centerIndex --;
            self.treasureId = [treasuresArray objectAtIndex:centerIndex];
            if (rightView) {
                [rightView.bodyScrollView removeFromSuperview];
            }
            
            rightView = centerView;
            centerView = leftView;
            leftView = nil;
            
            [self updateFavouriteButton];
        }
        
        return;
    }
    centerIndex --;
    self.treasureId = [treasuresArray objectAtIndex:centerIndex];
    if (rightView) {
        [rightView.bodyScrollView removeFromSuperview];
    }
    
    rightView = centerView;
    centerView = leftView;
    leftView = nil;
    
    Treasure *theTreasure = [dataEngine.treasures objectForKey:[treasuresArray objectAtIndex:centerIndex - 1]];
    if (theTreasure) {
        leftView = [[ItemDetailView alloc] init];
        leftView.itemDetailViewController = self;
        [[NSBundle mainBundle] loadNibNamed:@"ItemDetailView" owner:leftView options:nil];
        leftView.treasureId = theTreasure.tid;
        [leftView boundItemValues:NO];
        [scrollView addSubview:leftView.bodyScrollView];
        
        leftView.bodyScrollView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        centerView.bodyScrollView.frame = CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
        rightView.bodyScrollView.frame = CGRectMake(self.view.frame.size.width * 2, 0, self.view.frame.size.width, self.view.frame.size.height);
        [scrollView setContentSize:CGSizeMake(self.view.frame.size.width * 3, self.view.frame.size.height)];
        [scrollView setContentOffset:CGPointMake(self.view.frame.size.width, 0)];
    }
    if (leftView == nil) {
        centerView.bodyScrollView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        rightView.bodyScrollView.frame = CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
        [scrollView setContentSize:CGSizeMake(self.view.frame.size.width * 2, self.view.frame.size.height)];
        [scrollView setContentOffset:CGPointMake(self.view.frame.size.width, 0)];
    }
    
    [self updateFavouriteButton];
}

- (void)scrollLeft
{
    DataEngine *dataEngine = [DataEngine sharedDataEngine];
    if (centerIndex >= [treasuresArray count] - 2) {
        if (centerIndex == [treasuresArray count] - 2) {
            centerIndex ++;
            self.treasureId = [treasuresArray objectAtIndex:centerIndex];
            if (leftView) {
                [leftView.bodyScrollView removeFromSuperview];
            }
            
            leftView = centerView;
            centerView = rightView;
            rightView = nil;
            
            [self updateFavouriteButton];
        }
        
        return;
    }
    
    centerIndex ++;
    self.treasureId = [treasuresArray objectAtIndex:centerIndex];
    if (leftView) {
        [leftView.bodyScrollView removeFromSuperview];
    }
    
    leftView = centerView;
    centerView = rightView;
    rightView = nil;
    
    Treasure *theTreasure = [dataEngine.treasures objectForKey:[treasuresArray objectAtIndex:centerIndex + 1]];
    if (theTreasure) {
        rightView = [[ItemDetailView alloc] init];
        rightView.itemDetailViewController = self;
        [[NSBundle mainBundle] loadNibNamed:@"ItemDetailView" owner:rightView options:nil];
        rightView.treasureId = theTreasure.tid;
        [rightView boundItemValues:NO];
        [scrollView addSubview:rightView.bodyScrollView];
        
        leftView.bodyScrollView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        centerView.bodyScrollView.frame = CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
        rightView.bodyScrollView.frame = CGRectMake(self.view.frame.size.width * 2, 0, self.view.frame.size.width, self.view.frame.size.height);
        [scrollView setContentSize:CGSizeMake(self.view.frame.size.width * 3, self.view.frame.size.height)];
        [scrollView setContentOffset:CGPointMake(self.view.frame.size.width, 0)];
    }
    if (rightView == nil) {
        leftView.bodyScrollView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        centerView.bodyScrollView.frame = CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
        [scrollView setContentSize:CGSizeMake(self.view.frame.size.width * 2, self.view.frame.size.height)];
        [scrollView setContentOffset:CGPointMake(self.view.frame.size.width, 0)];
    }
    
    [self updateFavouriteButton];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)sender
{
    currentOffsetX = sender.contentOffset.x;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)sender willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        CGFloat offsetX = sender.contentOffset.x - currentOffsetX;
        currentOffsetX = sender.contentOffset.x;
        
        if (offsetX > 0) {//left
            [self scrollLeft];
            [centerView setVisiable];
        }
        else if (offsetX < 0) {//right
            [self scrollRight];
            [centerView setVisiable];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)sender {
    CGFloat offsetX = sender.contentOffset.x - currentOffsetX;
    currentOffsetX = sender.contentOffset.x;
    
    if (offsetX > 0) {//left
        [self scrollLeft];
        [centerView setVisiable];
    }
    else if (offsetX < 0) {//right
        [self scrollRight];
        [centerView setVisiable];
    }
}


- (void)responseGetItemDetail:(NSNotification *)notification {
    NSDictionary *dictionary = (NSDictionary *)[notification userInfo];
    if (![[dictionary objectForKey:REQUEST_SOURCE_KEY] isEqualToString:[[NSString alloc] initWithFormat:@"%p", centerView]]) {
        return;
    }
    NSNumber *returnCode = [dictionary objectForKey:RETURN_CODE];
    if (!returnCode || ![returnCode isKindOfClass:[NSNumber class]] || [returnCode intValue] != NO_ERROR) {
        [favouriteButton setEnabled:NO];
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
        [centerView.bodyScrollView setScrollEnabled:NO];
        if (self.isJumpIndex) {
            RecommendViewController *recommendViewController = [[RecommendViewController alloc] initWithNibName:@"RecommendViewController" bundle:nil];
            UINavigationController *navRec = [[UINavigationController alloc] initWithRootViewController:recommendViewController];
            [navRec setValue:[[CustomNavigationBar alloc] init] forKeyPath:@"navigationBar"];
            AppDelegate *appDelegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
            [appDelegate hideActivityView:appDelegate.window];
            [appDelegate setTabBarItem:navRec theIndex:0];
        }
    }
}

- (void)moreButtonClick:(id)sender
{
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate showLeft];
}

- (void)updateFavouriteButton
{
    DataEngine *dataEngine = [DataEngine sharedDataEngine];
    if ([dataEngine.favories containsObject:treasureId]) {
        [favouriteButton setTitle:NSLocalizedString(@"取消收藏", @"") forState:UIControlStateNormal];
        [favouriteButton setTitleColor:[UIColor colorWithRed:80.0f/255.0f green:80.0f/255.0f blue:80.0f/255.0f alpha:1] forState:UIControlStateNormal];
        [favouriteButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [favouriteButton setImage:[UIImage imageNamed:@"detail_unfavourite_icon"] forState:UIControlStateNormal];
        [favouriteButton setImage:[UIImage imageNamed:@"detail_unfavourite_icon"] forState:UIControlStateHighlighted];
        [favouriteButton setBackgroundImage:[UIImage imageNamed:@"detail_unfavourite_button"] forState:UIControlStateNormal];
        [favouriteButton setBackgroundImage:[UIImage imageNamed:@"detail_unfavourite_button_highlight"] forState:UIControlStateHighlighted];
    } else {
        [favouriteButton setTitle:NSLocalizedString(@"收藏", @"") forState:UIControlStateNormal];
        [favouriteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [favouriteButton setTitleShadowColor:[UIColor colorWithRed:83.0f/255.0f green:83.0f/255.0f blue:83.0f/255.0f alpha:1] forState:UIControlStateNormal];
        [favouriteButton setImage:[UIImage imageNamed:@"detailFavouriteIcon"] forState:UIControlStateNormal];
        [favouriteButton setImage:[UIImage imageNamed:@"detailFavouriteIcon"] forState:UIControlStateHighlighted];
        [favouriteButton setBackgroundImage:[UIImage imageNamed:@"shareButton"] forState:UIControlStateNormal];
        [favouriteButton setBackgroundImage:[UIImage imageNamed:@"shareButton_selected"] forState:UIControlStateHighlighted];
    }
}

@end
