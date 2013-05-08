    //
//  CustomTabbarViewController.m
//  RaisedCenterTabBar
//
//  Created by Peter Boctor on 12/15/10.
//
// Copyright (c) 2011 Peter Boctor
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE
//

#import "CustomTabbarViewController.h"
#import "AppDelegate.h"
#import "DataEngine.h"
#import "NetworkMonitor.h"
#import "RIButtonItem.h"
#import "UIAlertView+Blocks.h"
#import "Constants.h"
#import "ErrorCodeUtils.h"
#import <QuartzCore/QuartzCore.h>
#import "Menu.h"
#import "CategoryViewController.h"
#import "CustomNavigationBar.h"

#import "Banner.h"
#import "FavouriteViewController.h"
#import "MeController.h"
#import "RecommendViewController.h"
#import "RecommendForDrawerViewController.h"
#import "ItemListViewController.h"
#import "ItemDetailViewController.h"
#import "TSBWebViewController.h"
#import "SecurityViewController.h"
#import "ShopWindowViewController.h"
#import "Itemlist2ViewController.h"
#import "LocalSettings.h"

#import "EGORefreshTableHeaderView.h"

#define NEW_IMAGEVIEW_TAG 12306

typedef enum
{
    kGestureDirectionNone = 0,
    kGestureDirectionLeft = 1,
    kGestureDirectionRight = 2
} GestureDirection;

@implementation TabItem

@synthesize events, controllerParam, xibName, itemIcon, itemIconHighlight, itemIconSelected, itemTitle, itemTitleFont, itemTitleFontColor, itemTitleFontSelectedColor;

@end

@interface CustomTabbarViewController ()
- (void) notificationCountChanged:(NSNotification *)notification;
- (void) panInContentView:(UIPanGestureRecognizer *) panGesture;
- (void) tapInContentView:(UITapGestureRecognizer *) tapGesture;
- (void) moveAnimationWithDirection:(GestureDirection)direction duration:(float)duration;
- (void) addShadow;
- (void) responseMenus:(NSNotification *)notification;
- (void) responseOrderShowType:(NSNotification *)notification;
- (void) responsePingCeShowType:(NSNotification *)notification;
- (void) responseHasNew:(NSNotification *)notification;
- (void) resetMenuTableViewTransform;
@end

@implementation MenuListCell

- (void) layoutSubviews {
    [super layoutSubviews];
    self.textLabel.frame = CGRectMake(self.textLabel.frame.origin.x + 10, self.textLabel.frame.origin.y, self.textLabel.frame.size.width, self.textLabel.frame.size.height);
}

@end

@implementation CustomTabbarViewController

@synthesize tabbarHidden, tabs, selectedMenuBannerId;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (id)init
{
    self = [super init];
    if (self) {

    }
    return self;
}

- (void) show
{
    _cttabbar = [[CTTabbarControl alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height  - kTabbarHeight, self.view.bounds.size.width, kTabbarHeight) withDelegate:self withCount:[tabs count]];
    [_cttabbar setSelectedIndex:0];
    _cttabbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (_controllerId == nil || [_controllerId length] == 0) {
        _controllerId = [[NSString alloc] initWithFormat:@"%p", self];
    }

    tabViewBody = [[UIView alloc] initWithFrame:self.view.bounds];
    [tabViewBody setBackgroundColor:[UIColor clearColor]];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(responseMenus:)
                                                 name:REQUEST_MENUS
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(responseOrderShowType:)
                                                 name:NOTIFICATION_ORDER_SHOW_TYPE
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(responsePingCeShowType:)
                                                 name:NOTIFICATION_PINGCE_SHOW_TYPE
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(responseHasNew:)
                                                 name:NOTIFICATION_HAS_NEW
                                               object:nil];

    [self notificationCountChanged:nil];
    
    enablePanGesture = YES;
    panGestureReconginzer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panInContentView:)];
    [tabViewBody addGestureRecognizer:panGestureReconginzer];

    UIView *view = [[UIView alloc] initWithFrame:self.view.bounds];
    [view setBackgroundColor:[UIColor clearColor]];
    [view setUserInteractionEnabled:YES];
    [view setTag:1234];
    [view.layer setZPosition:99999999];
    [tabViewBody addSubview:view];
    
    enableTapGesture = YES;
    tapGestureGeconginzer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapInContentView:)];
    [view addGestureRecognizer:tapGestureGeconginzer];
    [tapGestureGeconginzer setEnabled:NO];
    [panGestureReconginzer setEnabled:YES];

    if (menuTableView == nil) {
        menuTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
        menuTableView.dataSource = self;
        menuTableView.delegate = self;
        menuTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        menuTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"moreTableBackground.png"]];
        menuTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }

    [self.view addSubview:menuTableView];
    [self.view addSubview:tabViewBody];
    [self addShadow];
    
    menuTableView.transform = CGAffineTransformMakeScale(0.95, 0.95);

    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - menuTableView.bounds.size.height, menuTableView.frame.size.width, menuTableView.bounds.size.height)];
    UIImageView *headerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gopeijian"]];
    [headerImageView setFrame:CGRectMake(40, headerView.frame.size.height - 110, 110, 110)];
    
    [headerView addSubview:headerImageView];
    headerView.backgroundColor = [UIColor clearColor];

    [menuTableView addSubview:headerView];
}

- (void)panInContentView:(UIPanGestureRecognizer *) panGesture
{
    if (!enablePanGesture) {
        return;
    }
    if (panGestureReconginzer.state == UIGestureRecognizerStateChanged)
    {
        CGFloat translation = [panGestureReconginzer translationInView:self.view].x;
        [self resetMenuTableViewTransform];
        
        if (translation <= 0 && !tapGestureGeconginzer.enabled) {
            return;
        }
        if (tapGestureGeconginzer.enabled && translation <= -280) {
            // 不能太往左边移动
            return;
        }
        tabViewBody.transform = CGAffineTransformMakeTranslation(translation + currentTranslate, 0);
        
	} else if (panGestureReconginzer.state == UIGestureRecognizerStateEnded) {
		currentTranslate = tabViewBody.transform.tx;
        float checkX = 100;
        if (tapGestureGeconginzer.enabled) {
            // 在右侧时可以滑动收起
            checkX = 180;
        }
        if (fabs(currentTranslate >= checkX)) {
            [self moveAnimationWithDirection:kGestureDirectionLeft duration:0.2f];
        } else {
            [self moveAnimationWithDirection:kGestureDirectionNone duration:0.2f];
        }
	}
}

- (void)tapInContentView:(UITapGestureRecognizer *) tapGesture
{
    if (!enableTapGesture) {
        return;
    }
    if (tapGestureGeconginzer.state == UIGestureRecognizerStateEnded) {
        [self moveAnimationWithDirection:kGestureDirectionNone duration:0.1f];
    }
}

#pragma animation

- (void)moveAnimationWithDirection:(GestureDirection)direction duration:(float)duration
{

    void (^animations)(void) = ^{
        switch (direction) {
            case kGestureDirectionNone: {
                tabViewBody.transform = CGAffineTransformMakeTranslation(0, 0);
            }
                break;
            case kGestureDirectionLeft: {
                tabViewBody.transform  = CGAffineTransformMakeTranslation(200, 0);
            }
                break;
            default:
                break;
        }
        [self resetMenuTableViewTransform];
	};
    void (^complete)(BOOL) = ^(BOOL finished) {
        if (tabViewBody.frame.origin.x <= 0) {
            // 不禁用滑动事件
//            [panGestureReconginzer setEnabled:YES];
            [tapGestureGeconginzer setEnabled:NO];
            [[tabViewBody viewWithTag:1234] setHidden:YES];
        } else {
//            [panGestureReconginzer setEnabled:NO];
            [tapGestureGeconginzer setEnabled:YES];
            [[tabViewBody viewWithTag:1234] setHidden:NO];
            [tabViewBody bringSubviewToFront:[tabViewBody viewWithTag:1234]];
        }
        currentTranslate = tabViewBody.transform.tx;
        [self resetMenuTableViewTransform];
	};
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:animations
                     completion:complete];
}

- (void)closeByAnimation
{
    [tabViewBody removeGestureRecognizer:panGestureReconginzer];
    [self moveAnimationWithDirection:kGestureDirectionLeft duration:0.3f];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (SYSTEM_VERSION_LESS_THAN(@"5.0")) {
        [self.selectedViewController viewWillAppear:animated];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (SYSTEM_VERSION_LESS_THAN(@"5.0")) {
        [self.selectedViewController viewDidAppear:animated];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    if (SYSTEM_VERSION_LESS_THAN(@"5.0")) {
        [self.selectedViewController viewWillDisappear:animated];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
    if (SYSTEM_VERSION_LESS_THAN(@"5.0")) {
        [self.selectedViewController viewDidDisappear:animated];
    }
}

- (void)setBadgeNumber:(int)number index:(int)index
{
    if (index >= [_cttabbar.buttons count] || index < 0) {
        return;
    }
    
    if (number <= 0) {
        UIButton *bageButton = (UIButton *)[_cttabbar.bageButtons objectAtIndex:index];
        if (!bageButton.hidden) {
            bageButton.hidden = YES;
        }
    }
    else{
        UIButton *bageButton = (UIButton *)[_cttabbar.bageButtons objectAtIndex:index];
        if (bageButton.hidden) {
            bageButton.hidden = NO;
        } 
//        [bageButton setTitle:[NSString stringWithFormat:@"%d", number] forState:UIControlStateNormal];
    }
}

- (void)notificationCountChanged:(NSNotification *)notification
{
    [self setBadgeNumber:[UIApplication sharedApplication].applicationIconBadgeNumber index:4];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)selectedCityChange:(NSNotification *)notification
{
}

- (UIViewController *)selectedViewController
{
    return [_cttabbar selectedController];
}
- (UIViewController *)targetController:(int) theIndex
{
    return [_cttabbar targetController:theIndex];
}

- (NSInteger)selectedIndex
{
    return [_cttabbar selectedIndex];
}

- (void)setSelectedIndex:(NSInteger)theIndex
{
    [_cttabbar setSelectedIndex:theIndex];
}

#pragma mark - CTTabbarControl Delegate
- (UIView *)superView:(CTTabbarControl *)tabbar
{
    return tabViewBody;
}

- (NSString *)xibName:(CTTabbarControl *)tabbar atIndex:(NSInteger)theIndex
{
    if (theIndex >=0 && theIndex <= [tabs count]) {
        return ((TabItem*) [tabs objectAtIndex:theIndex]).xibName;
    }
    return nil;
}

- (BOOL)isNavigation:(CTTabbarControl *)tabbar atIndex:(NSInteger)theIndex
{
    return TRUE;
}

- (UIImage *)tabbarBgImage:(CTTabbarControl *)tabbar
{
    return [UIImage imageNamed:@"bottomTabBarBackground"];
}

- (CGRect)tabbarButtonRect:(CTTabbarControl *)tabbar atIndex:(NSInteger)theIndex
{
    CGRect theFrame = CGRectMake(80 * theIndex, 0, 80, kTabbarHeight);
    theFrame.origin.y = kTabbarHeight - kTabbarRealHeight;
    theFrame.size.height = kTabbarRealHeight;
    return theFrame;
}

- (NSString *)tabbarItemTitle:(CTTabbarControl *)tabbar
                      atIndex:(NSInteger)theIndex
{
    return ((TabItem*) [tabs objectAtIndex:theIndex]).itemTitle;
}

- (UIColor *)tabbarItemTitleColorSelected:(CTTabbarControl *)tabbar
                                  atIndex:(NSInteger)theIndex
{
    return ((TabItem*) [tabs objectAtIndex:theIndex]).itemTitleFontSelectedColor;
}

- (UIColor *)tabbarItemTitleColorNormal:(CTTabbarControl *)tabbar
                                atIndex:(NSInteger)theIndex
{
    return ((TabItem*) [tabs objectAtIndex:theIndex]).itemTitleFontColor;
}

- (UIFont *)tabbarItemTitleFont:(CTTabbarControl *)tabbar
                        atIndex:(NSInteger)theIndex
{
    return ((TabItem*) [tabs objectAtIndex:theIndex]).itemTitleFont;
}

- (UIImage *)tabbarItemIcon:(CTTabbarControl *)tabbar
                    atIndex:(NSInteger)theIndex
{
    if (theIndex >=0 && theIndex <= [tabs count]) {
        return [UIImage imageNamed:((TabItem*) [tabs objectAtIndex:theIndex]).itemIcon];
    }
    return nil;
}

- (UIImage *)tabbarItemIconHighlight:(CTTabbarControl *)tabbar
                             atIndex:(NSInteger)theIndex
{
    if (theIndex >=0 && theIndex <= [tabs count]) {
        return [UIImage imageNamed:((TabItem*) [tabs objectAtIndex:theIndex]).itemIconHighlight];
    }
    return nil;
}

- (UIImage *)tabbarItemIconSelected:(CTTabbarControl *)tabbar
                            atIndex:(NSInteger)theIndex
{
    if (theIndex >=0 && theIndex <= [tabs count]) {
        return [UIImage imageNamed:((TabItem*) [tabs objectAtIndex:theIndex]).itemIconSelected];
    }
    return nil;
}

- (BOOL)canselect:(CTTabbarControl *)tabbar atIndex:(NSInteger)theIndex
{
    return YES;
}

- (void)willSelect:(CTTabbarControl *)tabbar atIndex:(NSInteger)theIndex
{
    if (theIndex >= 0 && theIndex <= [tabs count]) {
        ((TabItem*)[tabs objectAtIndex:theIndex]).events();
    }
    return;
}

- (void)showAnimationDidStop
{
    _cttabbar.notShow = NO;
    tabbarHidden = NO;
}

- (void)hideAnimationDidStop
{
    tabbarHidden = YES;
}

- (void)showTabbar:(BOOL)leftToRight
{
    if (!tabbarHidden) {
        return;        
    }
    
    if (leftToRight) {
        _cttabbar.frame = CGRectMake(-320, _cttabbar.frame.origin.y, _cttabbar.frame.size.width, _cttabbar.frame.size.height);
    } else {
        _cttabbar.frame = CGRectMake(320, _cttabbar.frame.origin.y, _cttabbar.frame.size.width, _cttabbar.frame.size.height);
    }
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDidStopSelector:@selector(showAnimationDidStop)];
    
    _cttabbar.frame = CGRectMake(0, _cttabbar.frame.origin.y, _cttabbar.frame.size.width, _cttabbar.frame.size.height);
    
    [UIView commitAnimations];
}

- (void)hideTabbar:(BOOL)rightToLeft
{
    if (tabbarHidden) {
        return;
    }
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDidStopSelector:@selector(hideAnimationDidStop)];
    
    if (!rightToLeft) {
        [_cttabbar setFrame:CGRectMake(320, _cttabbar.frame.origin.y, _cttabbar.frame.size.width, _cttabbar.frame.size.height)];
    } else {
        [_cttabbar setFrame:CGRectMake(-320, _cttabbar.frame.origin.y, _cttabbar.frame.size.width, _cttabbar.frame.size.height)];
    }
    
    [UIView commitAnimations];
    
    _cttabbar.notShow = YES;
}

- (UIViewController *)getControllerParam:(UIViewController *)controller atIndex:(NSInteger)theIndex
{
    if (theIndex > [tabs count]) {
        return controller;
    }
    TabItem *tab = [tabs objectAtIndex:theIndex];
    controller = tab.controllerParam(controller);
    return controller;
}

- (void)resetTabbar
{
    for (int i=0; i<[tabs count]; i++) {
        [_cttabbar resetTab:i];
    }
    [self dismissModalViewControllerAnimated:YES];

    [self showTabbar:YES];
    [self setSelectedIndex:0];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    DataEngine *dataEngine = [DataEngine sharedDataEngine];
    MenuGroup *group = [dataEngine.menu.groups objectAtIndex:section];
    if (group && group.menuItems && [group.menuItems count] > 0) {
        return [group.menuItems count];
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    if (indexPath.section != 0) {
        return nil;
    }

    MenuListCell *cell = (MenuListCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    // Configure the cell...
    if (cell == nil) {
        cell = [[MenuListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"moreTableCellBackground.png"]];
        cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"moreTableCellBackgroundSelected.png"]];
        [cell.textLabel setBackgroundColor:[UIColor clearColor]];
        [cell.detailTextLabel setBackgroundColor:[UIColor clearColor]];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14.0];
        cell.textLabel.textColor = [UIColor colorWithRed:176.0 / 255.0 green:176.0 / 255.0 blue:176.0 / 255.0 alpha:1.0];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    else {
        cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"moreTableCellBackground.png"]];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    DataEngine *dataEngine = [DataEngine sharedDataEngine];
    MenuGroup *group = [dataEngine.menu.groups objectAtIndex:indexPath.section];
    MenuItem *item = [group.menuItems objectAtIndex:indexPath.row];
    
    [cell.textLabel setText:item.menuName];

    if ([selectedMenuBannerId longLongValue] == [item.bannerId longLongValue] ||
        ([item.menuType intValue] == kMenuActionTypeBackHomePage && [selectedMenuBannerId longLongValue] == 0)) {
        selectedMenuBannerId = [NSNumber numberWithLongLong:[item.bannerId longLongValue]];
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }

    [[cell viewWithTag:NEW_IMAGEVIEW_TAG] removeFromSuperview];
    if (dataEngine.hasNew && [dataEngine.hasNew count] > 0) {
        if ([dataEngine.hasNew containsObject:item.bannerId]) {
            // 有更新
            CGSize fontWidth = [item.menuName sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(cell.frame.size.width, cell.frame.size.height)];
            float x = 20 + fontWidth.width + 1;
            UIImageView *hasNewImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"new"]];
            [hasNewImageView setFrame:CGRectMake(x, 2, 23, 17)];
            [hasNewImageView setTag:NEW_IMAGEVIEW_TAG];
            [cell addSubview:hasNewImageView];
        }
    }
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DataEngine *dataEngine = [DataEngine sharedDataEngine];
    
    MenuGroup *group = [dataEngine.menu.groups objectAtIndex:indexPath.section];
    if (group == nil) {
        return;
    }
    MenuItem *item = [group.menuItems objectAtIndex:indexPath.row];
    if (item == nil) {
        return;
    }
    [MobClick event:@"菜单页面" attributes:[NSDictionary dictionaryWithObjectsAndKeys:item.menuName ? item.menuName : KPlaceholder, @"点击菜单", nil]];
    [UBAnalysis event:@"菜单页面" labels:3, @"点击菜单", item.menuName ? item.menuName : KPlaceholder, [item.bannerId stringValue]];
    NSString *fromText = @"";
    if ([selectedMenuBannerId longLongValue] == [item.bannerId longLongValue]) {
        [self showLeft];
        return;
    }
    selectedMenuBannerId = [NSNumber numberWithLongLong:[item.bannerId longLongValue]];
    UIViewController *navController = nil;
    UIViewController *controller = nil;
    [[DataEngine sharedDataEngine] clickMenu:item.bannerId];
    switch ([item.menuType intValue]) {
        case kMenuActionTypeList:
        case kMenuActionTypeListAuto:
        case kMenuActionTypeListDiscount:
        {
            

            switch (((MenuItemTreasureList *)item).treasureShowType) {
                case kTreasureListShowType222: {
                    controller = [[Itemlist2ViewController alloc] initWithNibName:@"Itemlist2ViewController" bundle:nil];
                    ((Itemlist2ViewController *) controller).forAnalysisPath = fromText;
                    ((Itemlist2ViewController *) controller).listSource = kItemListFromBanner;
                    ((Itemlist2ViewController *) controller).isFirstClass = YES;
                    ((Itemlist2ViewController *) controller).bannerId = ((MenuItemTreasureList *)item).bannerId;
                    ((Itemlist2ViewController *) controller).tileType = [item.menuType intValue];
                    ((Itemlist2ViewController *) controller).title = item.menuName;
                }
                    break;
                case kTreasureListShowTypeList: {
                    controller = [[ItemListViewController alloc] initWithNibName:@"ItemListViewController" bundle:nil];
                    ((ItemListViewController *) controller).forAnalysisPath = fromText;
                    ((ItemListViewController *) controller).listSource = kItemListFromBanner;
                    ((ItemListViewController *) controller).isFirstClass = YES;
                    ((ItemListViewController *) controller).bannerId = ((MenuItemTreasureList *)item).bannerId;
                    ((ItemListViewController *) controller).tileType = [item.menuType intValue];
                    ((ItemListViewController *) controller).title = item.menuName;
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case kMenuActionTypeTreasure:
        {
            NSString *fromText = [NSString stringWithFormat:@"左侧菜单,%@,%lld", item.menuName, [item.bannerId longLongValue]];
            [MobClick event:@"商品详情页面" attributes:[NSDictionary dictionaryWithObjectsAndKeys:fromText, @"进入来源", nil]];
            [UBAnalysis event:@"商品详情页面" labels:2, @"进入来源", fromText];
            [[DataEngine sharedDataEngine] clickMenu:((MenuItemSence *)item).bannerId];
            controller = [[ItemDetailViewController alloc] initWithNibName:@"ItemDetailViewController" bundle:nil];
            ((ItemDetailViewController *) controller).isFirstClass = YES;
            ((ItemDetailViewController *) controller).treasureId = ((MenuItemTreasureDetail *)item).tid;
            ((ItemDetailViewController *) controller).treasuresArray = nil;
            ((ItemDetailViewController *) controller).preViewName = item.menuName;
        }
            break;
        case kMenuActionTypeLink:
        {
            [[DataEngine sharedDataEngine] clickMenu:((MenuItemSence *)item).bannerId];
            controller = [[TSBWebViewController alloc] initWithNibName:@"TSBWebViewController" bundle:nil];
            ((TSBWebViewController *) controller).isFirstClass = YES;
            ((TSBWebViewController *) controller).url = ((MenuItemLink *)item).url;
            ((TSBWebViewController *) controller).showTitle = item.menuName;
        }
            break;
        case kMenuActionTypeSence:
        {
            Banner *banner = [[Banner alloc] init];
            banner.bannerId = ((MenuItemSence *)item).bannerId;
            [[DataEngine sharedDataEngine] clickMenu:banner.bannerId];

            banner.title = ((MenuItemSence *)item).menuName;
            [[DataEngine sharedDataEngine] addbanner:banner];
            switch (((MenuItemSence *)item).tileShowType) {
                case kTileShowType123: {
                    controller = [[RecommendForDrawerViewController alloc] initWithNibName:@"RecommendForDrawerViewController" bundle:nil];
                    ((RecommendForDrawerViewController *) controller).forAnalysisPath = fromText;
                    ((RecommendForDrawerViewController *) controller).isFirstClass = YES;
                    ((RecommendForDrawerViewController *) controller).bannerId = banner.bannerId;
                }
                    break;
                case kTileShowTypeBigPicture: {
                    controller = [[ShopWindowViewController alloc] initWithNibName:@"ShopWindowViewController" bundle:nil];
                    ((ShopWindowViewController *) controller).forAnalysisPath = fromText;
                    ((ShopWindowViewController *) controller).isFirstClass = YES;
                    ((ShopWindowViewController *) controller).bannerId = banner.bannerId;
                    ((ShopWindowViewController *) controller).showTitle = banner.title;
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case kMenuActionTypeCategory:
        {
            controller = [[CategoryViewController alloc] initWithNibName:@"CategoryViewController" bundle:nil];
        }
            break;
        case kMenuActionTypeFavorite:
        {
            controller = [[FavouriteViewController alloc] init];
        }
            break;
        case kMenuActionTypeSettings:
        {
            controller = [[MeController alloc] initWithNibName:@"MeController" bundle:nil];
        }
            break;
        case kMenuActionTypeBackHomePage:
        {
            controller = [[RecommendViewController alloc] initWithNibName:@"RecommendViewController" bundle:nil];
        }
            break;
        case kMenuActionTypePin:
        {
            controller = [[SecurityViewController alloc] initWithNibName:@"SecurityViewController" bundle:nil];
        }
            break;
        default:
            break;
    }
    navController = [[UINavigationController alloc] initWithRootViewController:controller];
    [navController setValue:[[CustomNavigationBar alloc] init] forKeyPath:@"navigationBar"];    
    if (navController != nil) {
        [self setTabBarItem:navController theIndex:0];
        [self hideLeft];
    }
}

- (void) addShadow
{
    CGMutablePathRef shadowPath = CGPathCreateMutable();
    CGPathMoveToPoint(shadowPath, NULL, 5, 0);
    CGPathAddLineToPoint(shadowPath, NULL, 30, 0);
    CGPathAddLineToPoint(shadowPath, NULL, 30, tabViewBody.bounds.size.height);
    CGPathAddLineToPoint(shadowPath, NULL, 5, tabViewBody.bounds.size.height);
    CGPathAddLineToPoint(shadowPath, NULL, 5, 0);
    
    // 位移
    [tabViewBody.layer setShadowOffset:CGSizeMake(0.0, 1.0)];
    
    // 散射半径
    [tabViewBody.layer setShadowRadius:15];
    
    // 透明
    [tabViewBody.layer setShadowOpacity:1];
    
    // 路径
    [tabViewBody.layer setShadowPath:shadowPath];
    
    [tabViewBody.layer setShadowColor:[UIColor blackColor].CGColor];
}

- (void)showLeft
{
    if (tabViewBody.frame.origin.x > 0) {
        [self moveAnimationWithDirection:kGestureDirectionNone duration:0.2f];
    } else {
        [self moveAnimationWithDirection:kGestureDirectionLeft duration:0.2f];
    }
}

- (void)hideLeft
{
    [self moveAnimationWithDirection:kGestureDirectionNone duration:0.2f];
}

- (void)setTabBarItem:(UIViewController *) contentController theIndex:(NSInteger) theIndex
{
    if (theIndex > [tabs count]) {
        return;
    }
    TabItem *tab = [tabs objectAtIndex:theIndex];
    tab.controllerParam = ^(UIViewController *controller) {
        return contentController;
    };

    [_cttabbar setTabBarItemController:contentController postXibName:tab.xibName];
    [_cttabbar forceDisplayController:theIndex];
}

- (void)enableGesture:(BOOL) enable
{
    enablePanGesture = enable;
}

- (void)responseMenus:(NSNotification *)notification
{
    [menuTableView reloadData];
}

- (void) responseOrderShowType:(NSNotification *)notification
{
    NSDictionary *dict = notification.userInfo;
    DataEngine *dataEngine = [DataEngine sharedDataEngine];
    dataEngine.orderBannerId = [[dict objectForKey:@"orderBannerId"] intValue];
    dataEngine.orderShowType = [[dict objectForKey:@"orderShowType"] intValue];
    dataEngine.orderSceneShowType = [[dict objectForKey:@"orderSceneShowType"] intValue];
    dataEngine.orderListShowType = [[dict objectForKey:@"orderListShowType"] intValue];
    
    [[NSUserDefaults standardUserDefaults] setInteger:dataEngine.orderBannerId forKey:@"orderBannerId"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSUserDefaults standardUserDefaults] setInteger:dataEngine.orderShowType forKey:@"orderShowType"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSUserDefaults standardUserDefaults] setInteger:dataEngine.orderSceneShowType forKey:@"orderSceneShowType"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSUserDefaults standardUserDefaults] setInteger:dataEngine.orderListShowType forKey:@"orderListShowType"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) responsePingCeShowType:(NSNotification *)notification
{
    NSDictionary *dict = notification.userInfo;
    DataEngine *dataEngine = [DataEngine sharedDataEngine];
    dataEngine.pingceBannerId = [[dict objectForKey:@"pingceBannerId"] intValue];
    dataEngine.pingceShowType = [[dict objectForKey:@"pingceShowType"] intValue];
    dataEngine.pingceListShowType = [[dict objectForKey:@"pingceListShowType"] intValue];
    dataEngine.pingceSceneShowType = [[dict objectForKey:@"pingceSceneShowType"] intValue];
    dataEngine.pingceHasNew = [[dict objectForKey:@"pingceHasNew"] boolValue];
    [[NSUserDefaults standardUserDefaults] setInteger:dataEngine.pingceBannerId forKey:@"pingceBannerId"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSUserDefaults standardUserDefaults] setInteger:dataEngine.pingceShowType forKey:@"pingceShowType"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSUserDefaults standardUserDefaults] setInteger:dataEngine.pingceListShowType forKey:@"pingceListShowType"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSUserDefaults standardUserDefaults] setInteger:dataEngine.pingceSceneShowType forKey:@"pingceSceneShowType"];
    [[NSUserDefaults standardUserDefaults] setBool:dataEngine.pingceHasNew forKey:@"pingceHasNew"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)reloadTableView
{
    [menuTableView reloadData];
}

- (void) responseHasNew:(NSNotification *)notification
{
    if ([selectedMenuBannerId longLongValue] == [[[NSUserDefaults standardUserDefaults] objectForKey:MENUBANNERIDVERSION] longLongValue]) {
        DataEngine *dataEngine = [DataEngine sharedDataEngine];
        for (int i=0; i<[dataEngine.hasNew count]; i++) {
            NSNumber *newBannerId = [dataEngine.hasNew objectAtIndex:i];
            if ([newBannerId longLongValue] == [selectedMenuBannerId longLongValue]) {
                [dataEngine.hasNew removeObjectAtIndex:i];
                [LocalSettings saveHasNew:dataEngine.hasNew];
                return;
            }
        }
    }
    [menuTableView reloadData];
    if ([DataEngine sharedDataEngine].pingceHasNew) {
        [self setBadgeNumber:1 index:2];
    } else {
        [self setBadgeNumber:0 index:2];
    }
}

- (void) resetMenuTableViewTransform
{
    float result = tabViewBody.frame.origin.x / 200;
    float scale = (0.05 * result);
    float resultScale = 0.95 + scale;
    if (resultScale >= 1) {
        resultScale = 1;
    }
    menuTableView.transform = CGAffineTransformMakeScale(resultScale, resultScale);
    if ((resultScale + 0.0f) <= 0.95f) {
        [menuTableView setUserInteractionEnabled:NO];
    } else if ((resultScale + 0.0f) >= 1) {
        [menuTableView setUserInteractionEnabled:YES];
    }
}

@end