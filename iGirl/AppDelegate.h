//
//  AppDelegate.h
//  iAccessories
//
//  Created by 郭雪 on 12-10-16.
//  Copyright (c) 2012年 MobileWoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "CustomTabbarViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, MBProgressHUDDelegate> {
    NSMutableArray *tabs;
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UINavigationController *appRootController;
@property (nonatomic, retain) CustomTabbarViewController *tabBarController;
@property (nonatomic, readonly) NSString *token;

- (NSString *)networkStatus;

//first show hud with text in view
- (void)showActivityView:(NSString *)text inView:(UIView *)view;
//hide prevoiusly showed hud
- (void)hideActivityView:(UIView *)view;
//first showe hud with succeed text and image for time seconds in view
- (void)showFinishActivityView:(NSString *)text interval:(NSTimeInterval)time inView:(UIView *)view;
//first showe hud with failed text and image for time seconds in view
- (void)showFailedActivityView:(NSString *)text interval:(NSTimeInterval)time inView:(UIView *)view;

- (void)presentModalViewController:(UIViewController*)rootViewController animated:(BOOL)animated;

- (void)variableHomePage:(NSNumber *)barnnerId;

- (void)removeNotificationCenter;

// 显示/隐藏左侧菜单
- (void)showLeft;

// 设置tab显示controller
- (void)setTabBarItem:(UIViewController *) contentController theIndex:(NSInteger) theIndex;

// 消掉首页的new
- (void)delayClickHasNew;
@end
