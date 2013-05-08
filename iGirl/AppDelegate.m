//
//  AppDelegate.m
//  iAccessories
//
//  Created by 郭雪 on 12-10-16.
//  Copyright (c) 2012年 MobileWoo. All rights reserved.
//

#import "AppDelegate.h"
#import "NetworkMonitor.h"
#import "CLog.h"
#import "Constants.h"
#import "CustomNavigationBar.h"
#import "RecommendViewController.h"
#import "DataEngine.h"
#import "ItemDetailViewController.h"
#import "Treasure.h"
#import "GCPINViewController.h"
#import "TSBWebViewController.h"
#import "UIAlertView+Blocks.h"
#import "RIButtonItem.h"
#import "ShopWindowViewController.h"
#import "RecommendForDrawerViewController.h"
#import "ItemListViewController.h"
#import "Itemlist2ViewController.h"
#import "Menu.h"
#import "Banner.h"
#import "CategoryViewController.h"
#import "FavouriteViewController.h"
#import "MeController.h"
#import "SecurityViewController.h"
#import "CustomTabbarViewController.h"
#import "UserGuideViewController.h"
#import "DownloadManager.h"
#import "BookListViewController.h"

@interface AppDelegate (Private)

- (UIViewController *)homePageForId:(NSNumber *)barnnerId;
- (NSString *)homePageXibForId:(NSNumber *)barnnerId;
@end

@implementation AppDelegate

@synthesize window                  = _window;
@synthesize token                   = _token;
@synthesize tabBarController        = _tabBarController;
@synthesize appRootController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#ifdef TEST_SERVER
    [UBAnalysis startWithAppkey:APP_ID channelId:APP_USER_AGENT testServer:YES];
#else
    [UBAnalysis startWithAppkey:APP_ID channelId:APP_USER_AGENT testServer:NO];
#endif
    
    BOOL shutDownUmeng = [[NSUserDefaults standardUserDefaults] boolForKey:ShutDownUmeng];
    if (!shutDownUmeng) {
        [MobClick startWithAppkey:UM_AppKey reportPolicy:REALTIME channelId:APP_USER_AGENT];
    }
    [[NetworkMonitor sharedInstance] start];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor blackColor];
//    MoreViewController *moreViewController = [[MoreViewController alloc] initWithNibName:@"MoreViewController" bundle:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(downloadItemFinish:)
                                                 name:NOTIFICATION_DOWNLOAD_ITEM_FINISH
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(downloadItemStart:)
                                                 name:NOTIFICATION_DOWNLOAD_ITEM_START
                                               object:nil];
    tabs = [[NSMutableArray alloc] init];

    // 配置的首页
    NSNumber *menuBannerIdVersion = [[NSUserDefaults standardUserDefaults] objectForKey:MENUBANNERIDVERSION];
    UIViewController *homePage = [self homePageForId:menuBannerIdVersion];
    if (homePage == nil) {
        RecommendViewController *recommendViewController = [[RecommendViewController alloc] initWithNibName:@"RecommendViewController" bundle:nil];
        homePage = recommendViewController;
    }

    UIColor *tabSelectedColor = [UIColor colorWithRed:74.0f/255.0f green:187.0f/255.0f blue:251.0f/255.0f alpha:1.0f];
    UIColor *tabColor = [UIColor colorWithRed:217.0f/255.0f green:217.0f/255.0f blue:217.0f/255.0f alpha:1.0f];
    TabItem *item1 = [[TabItem alloc] init];
    item1.events = ^{
        [self.tabBarController enableGesture:YES];
        [self performSelector:@selector(delayClickHasNew) withObject:nil afterDelay:1.0f];
        [MobClick event:@"切换Tab" label:@"首页"];
        [UBAnalysis event:@"切换Tab" label:@"首页"];
    };
    item1.controllerParam = ^(UIViewController *controller) {
        return homePage;
    };
    [item1 setXibName:[self homePageXibForId:menuBannerIdVersion]];
    [item1 setItemIcon:@"tab1"];
    [item1 setItemIconHighlight:@"tab1_high"];
    [item1 setItemIconSelected:@"tab1_high"];
    [item1 setItemTitle:NSLocalizedString(@"首页", @"")];
    [item1 setItemTitleFont:[UIFont systemFontOfSize:11]];
    [item1 setItemTitleFontColor:tabColor];
    [item1 setItemTitleFontSelectedColor:tabSelectedColor];
    
    TabItem *item2 = [[TabItem alloc] init];
    item2.events = ^{
        [self.tabBarController enableGesture:NO];
        [MobClick event:@"切换Tab" label:@"到付"];
        [UBAnalysis event:@"切换Tab" label:@"到付"];
    };
    item2.controllerParam = ^(UIViewController *controller) {
        DataEngine *dataEngine = [DataEngine sharedDataEngine];
        
        switch (dataEngine.orderShowType) {
            case kMenuActionTypeList:
            case kMenuActionTypeListAuto:
            case kMenuActionTypeListDiscount:
            {
                switch (dataEngine.orderListShowType) {
                    case kTreasureListShowType222:
                    {
                        Itemlist2ViewController *itemList = [[Itemlist2ViewController alloc] initWithNibName:@"Itemlist2ViewController" bundle:nil];
                        itemList.listSource = kItemListFromBanner;
                        itemList.isFirstClass = YES;
                        itemList.bannerId = [NSNumber numberWithInt:dataEngine.orderBannerId];
                        itemList.title = NSLocalizedString(@"货到付款", @"");
                        itemList.fromTab = YES;
                        itemList.source = kItemDetailFromOrder;
                        itemList.dataType = kTileDataTypeDaofu;
                        controller = itemList;
                    }
                        
                        break;
                    case kTreasureListShowTypeList:
                    {
                        ItemListViewController *itemList = [[ItemListViewController alloc] initWithNibName:@"ItemListViewController" bundle:nil];
                        itemList.listSource = kItemListFromBanner;
                        itemList.isFirstClass = YES;
                        itemList.bannerId = [NSNumber numberWithInt:dataEngine.orderBannerId];
                        itemList.title = NSLocalizedString(@"货到付款", @"");
                        itemList.source = kItemDetailFromOrder;
                        itemList.dataType = kTileDataTypeDaofu;
                        itemList.fromTab = YES;
                        
                        controller = itemList;
                    }
                        break;
                    default:
                        break;
                }
            }
                break;
            case kMenuActionTypeTreasure:
            {
            }
                break;
            case kMenuActionTypeLink:
            {
            }
                break;
            case kMenuActionTypeSence:
            {
                switch (dataEngine.orderSceneShowType) {
                    case kTileShowType123:
                    {
                        RecommendForDrawerViewController *recommendViewController = [[RecommendForDrawerViewController alloc] initWithNibName:@"RecommendForDrawerViewController" bundle:nil];
                        recommendViewController.bannerId = [NSNumber numberWithInt:dataEngine.orderBannerId];
                        recommendViewController.isFirstClass = YES;
                        recommendViewController.fromTab = YES;
                        recommendViewController.source = kItemDetailFromOrder;
                        recommendViewController.dataType = kTileDataTypeDaofu;
                        controller = recommendViewController;
                    }
                        break;
                    case kTileShowTypeBigPicture:
                    {
                        ShopWindowViewController *shopWIndowViewController = [[ShopWindowViewController alloc] initWithNibName:@"ShopWindowViewController" bundle:nil];
                        shopWIndowViewController.isFirstClass = YES;
                        shopWIndowViewController.showTitle = NSLocalizedString(@"货到付款", @"");
                        shopWIndowViewController.bannerId = [NSNumber numberWithInt:dataEngine.orderBannerId];
                        shopWIndowViewController.source = kItemDetailFromOrder;
                        shopWIndowViewController.dataType = kTileDataTypeDaofu;
                        shopWIndowViewController.fromTab = YES;
                        controller = shopWIndowViewController;
                    }
                        break;
                    default:
                        break;
                }
            }
                break;
            case kMenuActionTypeCategory:
            {
            }
                break;
            case kMenuActionTypeFavorite:
            {
            }
                break;
            case kMenuActionTypeSettings:
            {
            }
                break;
            case kMenuActionTypeBackHomePage:
            {
            }
                break;
            case kMenuActionTypePin:
            {
            }
                break;
            default:
                break;
        }

        return controller;
    };
    [item2 setXibName:@"CategoryViewController"];
    [item2 setItemIcon:@"tab2"];
    [item2 setItemIconHighlight:@"tab2_high"];
    [item2 setItemIconSelected:@"tab2_high"];
    [item2 setItemTitle:NSLocalizedString(@"到付", @"")];
    [item2 setItemTitleFont:[UIFont systemFontOfSize:11]];
    [item2 setItemTitleFontColor:tabColor];
    [item2 setItemTitleFontSelectedColor:tabSelectedColor];

    TabItem *item3 = [[TabItem alloc] init];
    item3.events = ^{
        [self.tabBarController enableGesture:NO];
        // 删掉评测的new提示
        [DataEngine sharedDataEngine].pingceHasNew = NO;
        [[NSUserDefaults standardUserDefaults] setBool:[DataEngine sharedDataEngine].pingceHasNew forKey:@"pingceHasNew"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_HAS_NEW object:nil];

        [MobClick event:@"切换Tab" label:@"电子书"];
        [UBAnalysis event:@"切换Tab" label:@"电子书"];
    };
    item3.controllerParam = ^(UIViewController *controller) {
        
        BookListViewController *bookListViewController = [[BookListViewController alloc]initWithNibName:@"BookListViewController" bundle:nil];
        bookListViewController.isFirstClass = YES;
        bookListViewController.fromTab = YES;
        
        controller = bookListViewController;
    
        return controller;
    };
    [item3 setXibName:@"TSBWebViewController"];
    [item3 setItemIcon:@"tab3"];
    [item3 setItemIconHighlight:@"tab3_high"];
    [item3 setItemIconSelected:@"tab3_high"];
    [item3 setItemTitle:NSLocalizedString(@"电子书", @"")];
    [item3 setItemTitleFont:[UIFont systemFontOfSize:11]];
    [item3 setItemTitleFontColor:tabColor];
    [item3 setItemTitleFontSelectedColor:tabSelectedColor];

    TabItem *item4 = [[TabItem alloc] init];
    item4.events = ^{
        [self.tabBarController enableGesture:NO];
        [MobClick event:@"切换Tab" label:@"更多"];
        [UBAnalysis event:@"切换Tab" label:@"更多"];
    };
    item4.controllerParam = ^(UIViewController *controller) {
        ((MeController *) controller).fromTab = YES;
        return controller;
    };
    [item4 setXibName:@"MeController"];
    [item4 setItemIcon:@"tab4"];
    [item4 setItemIconHighlight:@"tab4_high"];
    [item4 setItemIconSelected:@"tab4_high"];
    [item4 setItemTitle:NSLocalizedString(@"更多", @"")];
    [item4 setItemTitleFont:[UIFont systemFontOfSize:11]];
    [item4 setItemTitleFontColor:tabColor];
    [item4 setItemTitleFontSelectedColor:tabSelectedColor];

    [tabs addObject:item1];
    [tabs addObject:item2];
    [tabs addObject:item3];
    [tabs addObject:item4];

    self.tabBarController = [[CustomTabbarViewController alloc] init];
    self.tabBarController.selectedMenuBannerId = [NSNumber numberWithLongLong:[menuBannerIdVersion longLongValue]];
    self.appRootController = [[UINavigationController alloc] init];
    self.appRootController.navigationBarHidden = YES;
    [self.appRootController pushViewController:_tabBarController animated:NO];
    self.window.rootViewController = appRootController;
    [self.window makeKeyAndVisible];
    
    [self.tabBarController setTabs:tabs];
    [self.tabBarController show];
    DataEngine *dataEngine = [DataEngine sharedDataEngine];
    if (dataEngine.pingceHasNew) {
        [self.tabBarController setBadgeNumber:1 index:2];
    }
    
    [self registerRemoteNotification];

    NSDictionary *apsInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    id actionType = [apsInfo objectForKey:@"t"];
    if (apsInfo && actionType && [actionType isKindOfClass:[NSNumber class]] && [actionType intValue] != kPushActionLanuch) {
        [self APSHandle:apsInfo];
    } else {
        // 为毛没开程序时,收到push后杀死程序,再打开launchOptions就是空啊?
        [self removeNotificationCenter];
    }
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"PassCode"]) {
        GCPINViewController *PIN = [[GCPINViewController alloc]
                                    initWithNibName:nil
                                    bundle:nil
                                    mode:GCPINViewControllerModeVerify];
        PIN.messageText = NSLocalizedString(@"请输入密码", @"");
        PIN.errorText = NSLocalizedString(@"密码错误", @"");
        PIN.title = NSLocalizedString(@"请输入密码", @"");
        PIN.verifyBlock = ^(NSString *code) {
            return [code isEqualToString:[[NSUserDefaults standardUserDefaults] valueForKey:@"PassCode"]];
        };
        [PIN presentFromViewController:self.tabBarController animated:NO];
    }
    
    // 检查引导
//    BOOL userGuide = [[NSUserDefaults standardUserDefaults] boolForKey:USERGUIDE_VERSION];
//    if (!userGuide) {
//        UserGuideViewController *userGuide = [[UserGuideViewController alloc] initWithNibName:@"UserGuideViewController" bundle:nil];
//        [self.tabBarController presentModalViewController:userGuide animated:NO];
//    }
    [self performSelector:@selector(delayClickHasNew) withObject:nil afterDelay:1.0f];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    //[[DataEngine sharedDataEngine] saveData];
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"PassCode"]) {
        GCPINViewController *PIN = [[GCPINViewController alloc]
                                    initWithNibName:nil
                                    bundle:nil
                                    mode:GCPINViewControllerModeVerify];
        PIN.messageText = NSLocalizedString(@"请输入密码", @"");
        PIN.errorText = NSLocalizedString(@"密码错误", @"");
        PIN.title = NSLocalizedString(@"请输入密码", @"");
        PIN.verifyBlock = ^(NSString *code) {
            return [code isEqualToString:[[NSUserDefaults standardUserDefaults] valueForKey:@"PassCode"]];
        };
        [PIN presentFromViewController:self.tabBarController animated:NO];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval last = [[NSUserDefaults standardUserDefaults] doubleForKey:LASTINTOFOREGROUND];
    NSTimeInterval timePass = now - last;
    [self removeNotificationCenter];

    if (timePass > UPDATERELOADDATATIMEINTERVAL || TEST_ENTERFORGOUND) {
        [[DataEngine sharedDataEngine] doSomeThingAfterDataEngineCreate];
        
        // 启动程序时选择默认主页
        NSNumber *barnnerId = [[NSUserDefaults standardUserDefaults] objectForKey:MENUBANNERIDVERSION];
        if (barnnerId && [barnnerId isKindOfClass:[NSNumber class]]) {
            [self variableHomePage:barnnerId];
        } else {
            RecommendViewController *recommendViewController = [[RecommendViewController alloc] initWithNibName:@"RecommendViewController" bundle:nil];
            UINavigationController* navRec = [[UINavigationController alloc] initWithRootViewController:recommendViewController];
            [navRec setValue:[[CustomNavigationBar alloc] init] forKeyPath:@"navigationBar"];
            [self.tabBarController setTabBarItem:navRec theIndex:0];
            [self.tabBarController hideLeft];
        }
    }
}

- (void)delayClickHasNew
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayClickHasNew) object:nil];
    [[DataEngine sharedDataEngine] clickMenu:[[NSUserDefaults standardUserDefaults] objectForKey:MENUBANNERIDVERSION]];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[[DataEngine sharedDataEngine] weiboEngine] applicationDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
//	return [[[DataEngine sharedDataEngine] weiboEngine] handleOpenURL:url];
#ifdef DEBUG
    NSLog(@"openURL : %@", url);
#endif
    if (sourceApplication && [sourceApplication isEqualToString:@"com.sina.weibo"]) {
        return [[[DataEngine sharedDataEngine] weiboEngine] handleOpenURL:url];
    } else {
        return [self application:application handleOpenURL:url];
    }
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    if ([url.scheme isEqualToString:@"ipeijian"]) {
        NSString *param = url.host;
        NSArray *array = [param componentsSeparatedByString:@"&"];
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:4];
        // 存每一个参数
        for (NSString *string in array) {
            NSArray *component = [string componentsSeparatedByString:@"="];
            if (component && [component isKindOfClass:[NSArray class]]) {
                if ([component count] == 2) {
                    [dict setObject:[component objectAtIndex:1] forKey:[component objectAtIndex:0]];
                }
            }
        }
        NSNumber *item_id = [NSNumber numberWithLongLong:[[dict objectForKey:@"item_id"] longLongValue]];
        if (item_id && [item_id longLongValue] > 0) {
            [MobClick event:@"商品详情页面" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@"链接", @"进入来源", nil]];
            [UBAnalysis event:@"商品详情页面" labels:2, @"进入来源", @"链接"];

            ItemDetailViewController *itemDetail = [[ItemDetailViewController alloc] initWithNibName:@"ItemDetailViewController" bundle:nil];
            itemDetail.preViewName = NSLocalizedString(@"链接", @"");
            itemDetail.isJumpIndex = YES;
            itemDetail.isFirstClass = YES;
            itemDetail.treasureId = item_id;
            itemDetail.treasuresArray = nil;
            UINavigationController *navDetail = [[UINavigationController alloc] initWithRootViewController:itemDetail];
            [navDetail setValue:[[CustomNavigationBar alloc] init] forKeyPath:@"navigationBar"];
            [self presentModalViewController:itemDetail animated:YES];
//            [self.tabBarController setTabBarItem:navDetail theIndex:0];
            [self.tabBarController hideLeft];
        }
    }
    return YES;
}

#pragma mark - HUD

- (void)showActivityView:(NSString *)text inView:(UIView*)view
{
    UIView *viewExist = nil;
	for (UIView *v in [view subviews]) {
		if ([v isKindOfClass:[MBProgressHUD class]]) {
			viewExist = v;
            break;
		}
	}
    
    if (viewExist) {
        ((MBProgressHUD *)viewExist).labelText = @"";
        ((MBProgressHUD *)viewExist).detailsLabelText = text;
    }
    else {
        MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:view animated:YES];
        HUD.delegate = self;
        HUD.labelText = @"";
        HUD.detailsLabelText = text;
    }
}

- (void)hideActivityView:(UIView *)view {
    [MBProgressHUD hideHUDForView:view animated:YES];
}

- (void)showFinishActivityView:(NSString*)text interval:(NSTimeInterval)time inView:(UIView*)view
{
    UIView *viewExist = nil;
	for (UIView *v in [view subviews]) {
		if ([v isKindOfClass:[MBProgressHUD class]]) {
			viewExist = v;
            break;
		}
	}
    
    if (viewExist) {
        MBProgressHUD *HUD = (MBProgressHUD *)viewExist;
        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"activitycheckmark.png"]];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.labelText = @"";
        HUD.detailsLabelText = text;
        [HUD hide:YES afterDelay:time];
    }
    else {
        MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:view animated:YES];
        HUD.delegate = self;
        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"activitycheckmark.png"]];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.labelText = @"";
        HUD.detailsLabelText = text;
        [HUD hide:YES afterDelay:time];
    }
}

- (void)showFailedActivityView:(NSString*)text interval:(NSTimeInterval)time inView:(UIView*)view
{
    UIView *viewExist = nil;
	for (UIView *v in [view subviews]) {
		if ([v isKindOfClass:[MBProgressHUD class]]) {
			viewExist = v;
            break;
		}
	}
    
    if (viewExist) {
        MBProgressHUD *HUD = (MBProgressHUD *)viewExist;
        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"activitycross.png"]];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.labelText = @"";
        HUD.detailsLabelText = text;
        [HUD hide:YES afterDelay:time];
    }
    else {
        MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:view animated:YES];
        HUD.delegate = self;
        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"activitycross.png"]];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.labelText = @"";
        HUD.detailsLabelText = text;
        [HUD hide:YES afterDelay:time];
    }
}

- (void)hudWasHidden:(MBProgressHUD *)hud
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ProgressDisappeared" object:nil];
}

- (void)presentModalViewController:(UIViewController*)rootViewController animated:(BOOL)animated
{
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:rootViewController];
    CustomNavigationBar* customNavigationBar = [[CustomNavigationBar alloc] init];
    [nav setValue:customNavigationBar forKeyPath:@"navigationBar"];
    [self.window.rootViewController presentModalViewController:nav animated:animated];
}

- (NSString *)networkStatus
{
    NSString *result = nil;
    switch ([[NetworkMonitor sharedInstance] networkStatus]) {
        case ReachableViaWWAN: {
            result = @"wlan";
            break;
        }
        case ReachableViaWiFi: {
            result = @"wifi";
            break;
        }
        default:
            break;
    }
    return result;
}

#pragma mark - Notification management

- (void)registerRemoteNotification
{
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // Get a hex string from the device token with no spaces or < >
    NSMutableString *token = [[NSMutableString alloc] initWithFormat:@"%@",deviceToken];
    [token replaceOccurrencesOfString:@"<" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [token length])];
    [token replaceOccurrencesOfString:@">" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [token length])];
    _token = token;
    [[DataEngine sharedDataEngine] apns:_token from:nil];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    [[DataEngine sharedDataEngine] apns:nil from:nil];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    application.applicationIconBadgeNumber = [[[userInfo objectForKey:@"aps"] objectForKey:@"badge"] intValue];
    id alert = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
    NSString *lockey = nil;
    NSString *actionLocKey = nil;
    if (alert) {
        if ([alert isKindOfClass:[NSDictionary class]]) {
            lockey = [alert objectForKey:@"loc-key"];
            actionLocKey = [alert objectForKey:@"action-loc-key"];
        } else if ([alert isKindOfClass:[NSString class]]) {
            lockey = alert;
        }
    }
    [self removeNotificationCenter];

    if (actionLocKey) {

        if (application.applicationState == UIApplicationStateActive) {
            // 运行状态弹对话框
            RIButtonItem *cancelItem = [RIButtonItem item];
            cancelItem.label = NSLocalizedString(@"我知道了", @"");
            cancelItem.action = ^{
                [self removeNotificationCenter];
            };
            
            RIButtonItem *okItem = [RIButtonItem item];
            okItem.label = actionLocKey;
            okItem.action = ^{
                [self APSHandle:userInfo];
            };
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                message:lockey
                                                       cancelButtonItem:cancelItem
                                                       otherButtonItems:okItem, nil];
            [alertView show];
        } else {
            [self APSHandle:userInfo];
        }
    }
}

- (void)APSHandle:(NSDictionary *)apsInfo
{
    id actionType = [apsInfo objectForKey:@"t"];
    id actionParam = [apsInfo objectForKey:@"i"];
    NSString *fromText = @"推送";

    [self removeNotificationCenter];
    if (actionType && [actionType isKindOfClass:[NSNumber class]]) {
        UIViewController *controller = nil;
        switch ([actionType intValue]) {
            case kPushActionLanuch:
                break;
            case kPushActionUrl:
            {
                if (actionParam && [actionParam isKindOfClass:[NSString class]] && [actionParam length] > 0) {
                    controller = [[TSBWebViewController alloc] initWithNibName:@"TSBWebViewController" bundle:nil];
                    ((TSBWebViewController *) controller).isFirstClass = YES;
                    ((TSBWebViewController *) controller).url = actionParam;
                    ((TSBWebViewController *) controller).showTitle = nil;
                }
            }
                break;
            case kPushActionTreasure:
            {
                if (actionParam && [actionParam isKindOfClass:[NSString class]] && [actionParam length]) {
                    [MobClick event:@"商品详情页面" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@"推送", @"进入来源", nil]];
                    [UBAnalysis event:@"商品详情页面" labels:2, @"进入来源", @"推送"];

                    controller = [[ItemDetailViewController alloc] initWithNibName:@"ItemDetailViewController" bundle:nil];
//                    ((ItemDetailViewController *) controller).isFirstClass = YES;
                    ((ItemDetailViewController *) controller).treasureId = [NSNumber numberWithLongLong:[actionParam longLongValue]];
                    ((ItemDetailViewController *) controller).treasuresArray = nil;
                    ((ItemDetailViewController *) controller).preViewName = @"APS";
                }
            }
                break;
            case kPushActionSence:
            {
                if (actionParam && [actionParam isKindOfClass:[NSString class]] && [actionParam length] > 0) {
                    NSArray *params = [actionParam componentsSeparatedByString:@","];
                    if (params && [params isKindOfClass:[NSArray class]] && [params count] >= 2) {
                        NSNumber *bannerId = [NSNumber numberWithInt:[[params objectAtIndex:0] intValue]];
                        NSNumber *showType = [NSNumber numberWithInt:[[params objectAtIndex:1] intValue]];
                        if (bannerId && showType) {
                            self.tabBarController.selectedMenuBannerId = bannerId;
                            [self.tabBarController reloadTableView];

                            switch ([showType intValue]) {
                                case kTileShowType123:
                                {
                                    controller = [[RecommendForDrawerViewController alloc] initWithNibName:@"RecommendForDrawerViewController" bundle:nil];
                                    ((RecommendForDrawerViewController *) controller).forAnalysisPath = fromText;
                                    ((RecommendForDrawerViewController *) controller).isFirstClass = YES;
                                    ((RecommendForDrawerViewController *) controller).bannerId = bannerId;
                                }
                                    break;
                                case kTileShowTypeBigPicture:
                                {
                                    controller = [[ShopWindowViewController alloc] initWithNibName:@"ShopWindowViewController" bundle:nil];
                                    ((ShopWindowViewController *) controller).forAnalysisPath = fromText;
                                    ((ShopWindowViewController *) controller).isFirstClass = YES;
                                    ((ShopWindowViewController *) controller).bannerId = bannerId;
                                }
                                    break;
                                default:
                                    break;
                            }
                        }
                    }
                }
            }
                break;
            case kPushActionList:
            {
                if (actionParam && [actionParam isKindOfClass:[NSString class]] && [actionParam length] > 0) {
                    NSArray *params = [actionParam componentsSeparatedByString:@","];
                    if (params && [params isKindOfClass:[NSArray class]] && [params count] >= 3) {
                        NSNumber *bannerId = [NSNumber numberWithInt:[[params objectAtIndex:0] intValue]];
                        NSNumber *showType = [NSNumber numberWithInt:[[params objectAtIndex:1] intValue]];
                        NSNumber *tileType = [NSNumber numberWithInt:[[params objectAtIndex:2] intValue]];
                        NSString *titleName = [params objectAtIndex:3];

                        if (bannerId && showType && tileType) {
                            self.tabBarController.selectedMenuBannerId = bannerId;
                            [self.tabBarController reloadTableView];
                            switch ([showType intValue]) {
                                case kTreasureListShowTypeList:
                                {
                                    controller = [[ItemListViewController alloc] initWithNibName:@"ItemListViewController" bundle:nil];
                                    ((ItemListViewController *) controller).forAnalysisPath = fromText;
                                    ((ItemListViewController *) controller).listSource = kItemListFromBanner;
                                    ((ItemListViewController *) controller).isFirstClass = YES;
                                    ((ItemListViewController *) controller).bannerId = bannerId;
                                    ((ItemListViewController *) controller).tileType = [tileType intValue];
                                    ((ItemListViewController *) controller).title = titleName;
                                }
                                    break;
                                case kTreasureListShowType222:
                                {
                                    controller = [[Itemlist2ViewController alloc] initWithNibName:@"Itemlist2ViewController" bundle:nil];
                                    ((Itemlist2ViewController *) controller).forAnalysisPath = fromText;
                                    ((Itemlist2ViewController *) controller).listSource = kItemListFromBanner;
                                    ((Itemlist2ViewController *) controller).isFirstClass = YES;
                                    ((Itemlist2ViewController *) controller).bannerId = bannerId;
                                    ((Itemlist2ViewController *) controller).tileType = [tileType intValue];
                                    ((Itemlist2ViewController *) controller).title = titleName;
                                }
                                    break;
                                default:
                                    break;
                            }
                        }
                    }
                }
            }
                break;
            default:
            {
                RIButtonItem *cancelItem = [RIButtonItem item];
                cancelItem.label = NSLocalizedString(@"暂不升级", @"");
                cancelItem.action = ^{
                };
                
                RIButtonItem *okItem = [RIButtonItem item];
                okItem.label = NSLocalizedString(@"升级", @"");
                okItem.action = ^{
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:APP_DOWNLOAD_URL]];
                };
                UIAlertView *updateAlert = [[UIAlertView alloc] initWithTitle:nil
                                                                      message:NSLocalizedString(@"您当前的版本不支持这种类型的通知，是否升级？", @"")
                                                             cancelButtonItem:cancelItem
                                                             otherButtonItems:okItem, nil];
                [updateAlert show];
                return;
            }
                break;
        }
        if (controller) {
            if ([controller isKindOfClass:[ItemDetailViewController class]] || [controller isKindOfClass:[TSBWebViewController class]]) {
                // 详情、网页直接弹出新窗口
                [self presentModalViewController:controller animated:YES];
            } else {
                UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
                [navController setValue:[[CustomNavigationBar alloc] init] forKeyPath:@"navigationBar"];
                [self.tabBarController setTabBarItem:navController theIndex:0];
                [self.tabBarController hideLeft];
            }
        }
    }
}

- (void)variableHomePage:(NSNumber *)barnnerId
{
    UIViewController *controller = [self homePageForId:barnnerId];
        if (controller) {
//            UINavigationController *old = (UINavigationController *)self.viewDeckController.centerController;
//            if ([old class] == [UINavigationController class] && old.viewControllers && [old.viewControllers count] > 0) {
//                if ([controller class] == [[old.viewControllers objectAtIndex:0] class]) {
//                    // 这个页面已经是首页了~~~~~
//                    return ;
//                }
//            }

            // 如果是详情,弹出新窗口,默认设置页
            
            self.tabBarController.selectedMenuBannerId = barnnerId;
            if ([controller isKindOfClass:[ItemDetailViewController class]]) {
                MeController *meController = [[MeController alloc] initWithNibName:@"MeController" bundle:nil];
                UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:meController];
                [navController setValue:[[CustomNavigationBar alloc] init] forKeyPath:@"navigationBar"];

                [self presentModalViewController:navController animated:YES];
                [self.tabBarController setTabBarItem:navController theIndex:0];
                [self.tabBarController hideLeft];
            } else {
                UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
                [navController setValue:[[CustomNavigationBar alloc] init] forKeyPath:@"navigationBar"];
                [self.tabBarController setTabBarItem:navController theIndex:0];
                [self.tabBarController hideLeft];
            }
        }
}

- (UIViewController *)homePageForId:(NSNumber *)barnnerId
{
    UIViewController *controller = nil;
    
    if (barnnerId == nil) {
        RecommendViewController *recommendViewController = [[RecommendViewController alloc] initWithNibName:@"RecommendViewController" bundle:nil];
        controller = recommendViewController;
        return controller;
    }
    MenuItem *item = [[DataEngine sharedDataEngine] getMenuItemByBarnnerId:barnnerId];
    if (item) {
        switch ([item.menuType intValue]) {
            case kMenuActionTypeList:
            case kMenuActionTypeListAuto:
            case kMenuActionTypeListDiscount:
            {
                switch (((MenuItemTreasureList *)item).treasureShowType) {
                    case kTreasureListShowType222:
                    {
                        Itemlist2ViewController *itemList = [[Itemlist2ViewController alloc] initWithNibName:@"Itemlist2ViewController" bundle:nil];
                        itemList.listSource = kItemListFromBanner;
                        itemList.isFirstClass = YES;
                        itemList.bannerId = ((MenuItemTreasureList *)item).bannerId;
                        itemList.tileType = [item.menuType intValue];
                        itemList.title = item.menuName;
                        
                        controller = itemList;
                    }
                        
                        break;
                    case kTreasureListShowTypeList:
                    {
                        ItemListViewController *itemList = [[ItemListViewController alloc] initWithNibName:@"ItemListViewController" bundle:nil];
                        itemList.listSource = kItemListFromBanner;
                        itemList.isFirstClass = YES;
                        itemList.bannerId = ((MenuItemTreasureList *)item).bannerId;
                        itemList.tileType = [item.menuType intValue];
                        itemList.title = item.menuName;
                        
                        controller = itemList;
                    }
                        break;
                    default:
                        break;
                }
            }
                break;
            case kMenuActionTypeTreasure:
            {
                {
                    [MobClick event:@"商品详情页面" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@"左侧菜单", @"进入来源", nil]];
                    [UBAnalysis event:@"商品详情页面" labels:2, @"进入来源", @"左侧菜单"];

                    ItemDetailViewController *itemDetail = [[ItemDetailViewController alloc] initWithNibName:@"ItemDetailViewController" bundle:nil];
                    itemDetail.isFirstClass = YES;
                    itemDetail.treasureId = ((MenuItemTreasureDetail *)item).tid;
                    itemDetail.treasuresArray = nil;
                    itemDetail.preViewName = item.menuName;
                    
                    controller = itemDetail;
                }
            }
                break;
            case kMenuActionTypeLink:
            {
                {
                    TSBWebViewController *tradeView = [[TSBWebViewController alloc] initWithNibName:@"TSBWebViewController" bundle:nil];
                    tradeView.isFirstClass = YES;
                    tradeView.url = ((MenuItemLink *)item).url;
                    tradeView.showTitle = item.menuName;
                    
                    controller = tradeView;
                }
            }
                break;
            case kMenuActionTypeSence:
            {
                switch (((MenuItemSence *)item).tileShowType) {
                    case kTileShowType123:
                    {
                        Banner *banner = [[Banner alloc] init];
                        banner.bannerId = ((MenuItemSence *)item).bannerId;
                        banner.title = ((MenuItemSence *)item).menuName;
                        [[DataEngine sharedDataEngine] addbanner:banner];
                        RecommendForDrawerViewController *recommendViewController = [[RecommendForDrawerViewController alloc] initWithNibName:@"RecommendForDrawerViewController" bundle:nil];
                        recommendViewController.isFirstClass = YES;
                        recommendViewController.bannerId = banner.bannerId;
                        
                        controller = recommendViewController;
                    }
                        break;
                    case kTileShowTypeBigPicture:
                    {
                        Banner *banner = [[Banner alloc] init];
                        banner.bannerId = ((MenuItemSence *)item).bannerId;
                        banner.title = ((MenuItemSence *)item).menuName;
                        [[DataEngine sharedDataEngine] addbanner:banner];
                        ShopWindowViewController *shopWIndowViewController = [[ShopWindowViewController alloc] initWithNibName:@"ShopWindowViewController" bundle:nil];
                        shopWIndowViewController.isFirstClass = YES;
                        shopWIndowViewController.bannerId = banner.bannerId;
                        shopWIndowViewController.showTitle = banner.title;
                        
                        controller = shopWIndowViewController;
                    }
                        break;
                    default:
                        break;
                }
            }
                break;
            case kMenuActionTypeCategory:
            {
                {
                    CategoryViewController *categoryViewController = [[CategoryViewController alloc] initWithNibName:@"CategoryViewController" bundle:nil];
                    
                    controller = categoryViewController;
                }
            }
                break;
            case kMenuActionTypeFavorite:
            {
                {
                    FavouriteViewController *favouriteController = [[FavouriteViewController alloc] init];
                    
                    controller = favouriteController;
                }
            }
                break;
            case kMenuActionTypeSettings:
            {
                {
                    MeController *meController = [[MeController alloc] initWithNibName:@"MeController" bundle:nil];
                    
                    controller = meController;
                }
            }
                break;
            case kMenuActionTypeBackHomePage:
            {
                {
                    RecommendViewController *recommendViewController = [[RecommendViewController alloc] initWithNibName:@"RecommendViewController" bundle:nil];
                    
                    controller = recommendViewController;
                }
            }
                break;
            case kMenuActionTypePin:
            {
                {
                    SecurityViewController *securityViewController = [[SecurityViewController alloc] initWithNibName:@"SecurityViewController" bundle:nil];
                    
                    controller = securityViewController;
                }
            }
                break;
            default:
                break;
        }
    }
    
    return controller;
}

- (NSString *)homePageXibForId:(NSNumber *)barnnerId
{
    NSString *xibName = @"CustomNavigationController";
    
    if (barnnerId == nil) {
        xibName = @"RecommendViewController";
        return xibName;
    }
    
    MenuItem *item = [[DataEngine sharedDataEngine] getMenuItemByBarnnerId:barnnerId];
    if (item) {
        switch ([item.menuType intValue]) {
            case kMenuActionTypeList:
            case kMenuActionTypeListAuto:
            case kMenuActionTypeListDiscount:
            {
                switch (((MenuItemTreasureList *)item).treasureShowType) {
                    case kTreasureListShowType222:
                    {
                        xibName = @"Itemlist2ViewController";
                    }
                        break;
                    case kTreasureListShowTypeList:
                    {
                        xibName = @"ItemListViewController";
                    }
                        break;
                    default:
                        break;
                }
            }
                break;
            case kMenuActionTypeTreasure:
            {
                {                    
                    xibName = @"ItemDetailViewController";
                }
            }
                break;
            case kMenuActionTypeLink:
            {
                {
                    xibName = @"TSBWebViewController";
                }
            }
                break;
            case kMenuActionTypeSence:
            {
                switch (((MenuItemSence *)item).tileShowType) {
                    case kTileShowType123:
                    {
                        xibName = @"RecommendForDrawerViewController";
                    }
                        break;
                    case kTileShowTypeBigPicture:
                    {
                        xibName = @"ShopWindowViewController";
                    }
                        break;
                    default:
                        break;
                }
            }
                break;
            case kMenuActionTypeCategory:
            {
                {
                    xibName = @"CategoryViewController";
                }
            }
                break;
            case kMenuActionTypeFavorite:
            {
                {
                    
                }
            }
                break;
            case kMenuActionTypeSettings:
            {
                {
                    xibName = @"MeController";
                }
            }
                break;
            case kMenuActionTypeBackHomePage:
            {
                {
                    xibName = @"RecommendViewController";
                }
            }
                break;
            case kMenuActionTypePin:
            {
                {
                    xibName = @"SecurityViewController";;
                }
            }
                break;
            default:
                break;
        }
    }
    return xibName;
}

// 消除通知栏
- (void)removeNotificationCenter
{
    UIApplication *app = [UIApplication sharedApplication];
    // iOS bug
    // 如果通知数字是0 那么会消不掉顶部通知中心的提示
    app.applicationIconBadgeNumber = 1;
    app.applicationIconBadgeNumber = 0;
    [app cancelAllLocalNotifications];
}

- (void)showLeft
{
    [self.tabBarController showLeft];
}

- (void)setTabBarItem:(UIViewController *) contentController theIndex:(NSInteger) theIndex
{
    [self.tabBarController setTabBarItem:contentController theIndex:theIndex];
}

- (void)downloadItemFinish:(NSNotification *) notification
{
    // 下载完成
    int downloadingCount = [[DataEngine sharedDataEngine].downloadings count];
    if (downloadingCount == 0) {
        [UIApplication sharedApplication].idleTimerDisabled = NO;
    } else {
        // 下载状态屏幕常亮
        [UIApplication sharedApplication].idleTimerDisabled = YES;
    }
}

- (void)downloadItemStart:(NSNotification *) notification
{
    // 开始下载
    int downloadingCount = [[DataEngine sharedDataEngine].downloadings count];
    NSLog(@"downloadingCount:%d", downloadingCount);
}
@end
