//
//  CustomTabbarViewController.h
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
#import "CTTabbarControl.h"

typedef void (^CTTabItemEvents)();
typedef UIViewController* (^CTTabItemControllerParam)(UIViewController *);

@interface TabItem : NSObject {
    CTTabItemEvents events;
    CTTabItemControllerParam controllerParam;
    NSString *xibName;
    NSString *itemIcon;
    NSString *itemIconHighlight;
    NSString *itemIconSelected;
    NSString *itemTitle;
    UIFont *itemTitleFont;
    UIColor *itemTitleFontColor;
    UIColor *itemTitleFontSelectedColor;
}
@property (nonatomic, retain) NSString *xibName;
@property (nonatomic, retain) NSString *itemIcon;
@property (nonatomic, retain) NSString *itemIconHighlight;
@property (nonatomic, retain) NSString *itemIconSelected;
@property (nonatomic, retain) NSString *itemTitle;
@property (nonatomic, retain) UIFont *itemTitleFont;
@property (nonatomic, retain) UIColor *itemTitleFontColor;
@property (nonatomic, retain) UIColor *itemTitleFontSelectedColor;
@property (copy, nonatomic) CTTabItemEvents events;
@property (copy, nonatomic) CTTabItemControllerParam controllerParam;

@end

@interface MenuListCell : UITableViewCell

@end

@interface CustomTabbarViewController : UIViewController <CTTabbarControlDelegate, UITableViewDataSource, UITableViewDelegate>
{
    CTTabbarControl *_cttabbar;
    NSString *_controllerId;
    
    NSMutableArray *tabs;

    UIView *tabViewBody;
    
    CGFloat currentTranslate;
    // 用于滑动
    UIPanGestureRecognizer *panGestureReconginzer;
    BOOL enablePanGesture;
    // 用于点击
    UITapGestureRecognizer *tapGestureGeconginzer;
    BOOL enableTapGesture;
    // 记录哪个选择了
    NSNumber *selectedMenuBannerId;

    UITableView *menuTableView;
}

@property (nonatomic, readonly) BOOL tabbarHidden;
@property (nonatomic, retain) NSMutableArray *tabs;
@property (nonatomic, retain) NSNumber *selectedMenuBannerId;

- (void) show;

- (void)setBadgeNumber:(int)number index:(int)index;
- (UIViewController *)selectedViewController;
- (UIViewController *)targetController:(int) theIndex;
- (NSInteger)selectedIndex;
- (void)setSelectedIndex:(NSInteger)theIndex;
- (void)hideTabbar:(BOOL)rightToLeft;
- (void)showTabbar:(BOOL)leftToRight;

//重置tabbar
- (void)resetTabbar;
// 显示左侧菜单
- (void)showLeft;
// 显示指定位置的controller
- (void)setTabBarItem:(UIViewController *) contentController theIndex:(NSInteger) theIndex;
// 只隐藏左侧菜单
- (void)hideLeft;
// 启用禁用滑动手势
- (void)enableGesture:(BOOL) enable;
// 重新载入tableview
- (void)reloadTableView;
@end
