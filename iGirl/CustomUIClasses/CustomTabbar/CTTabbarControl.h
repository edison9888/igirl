//
//  CTTabbarControl.h
//  Tabbar
//
//  Created by 晋辉 卫 on 10/27/11.
//  Copyright (c) 2011 MobileWoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kTabbarHeight 50
#define kTabbarRealHeight 50
#define kTabbarCount 5
#define kShanGuangAnimationDuration 1.4f
#define kShanGuangSleepTime 5.0f

@protocol CTTabbarControlDelegate;

@interface CTTabbarControl : UIView
{
    __unsafe_unretained id<CTTabbarControlDelegate> _delegate;
    NSInteger _count;
    NSInteger _selected;
    UIImage *_bgImage;
    UIImageView *_arrow;
}

- (id)initWithFrame:(CGRect)theFrame
       withDelegate:(id<CTTabbarControlDelegate>)theDelegate
          withCount:(NSInteger)theCount;
@property (strong, nonatomic) NSMutableDictionary *controllers;
@property (strong, nonatomic) NSMutableArray *labels;
@property (strong, nonatomic) NSMutableArray *buttons;
@property (strong, nonatomic) NSMutableArray *bageButtons;
@property (nonatomic, assign) BOOL notShow;

- (void)buttonHighlighted:(id)sender;
- (void)buttonSelected:(id)sender;
- (void)setSelectedIndex:(NSInteger)theIndex; //set the selected index from 0 on
- (void)buttonOutside:(id)sender;
- (UIViewController *)selectedController;
- (UIViewController *)targetController:(int) theIndex;
- (NSInteger)selectedIndex;
- (void)resetTab:(NSInteger)index;
// 设置tab位置的controller
- (void)setTabBarItemController:(UIViewController *) contentController postXibName:(NSString *) postXibName;
// 强制重新显示tab内容
- (void)forceDisplayController:(NSInteger) theIndex;
@end

@protocol CTTabbarControlDelegate <NSObject>

- (UIView *)superView:(CTTabbarControl *)tabbar; //the tabbar's super view.
- (NSString *)xibName:(CTTabbarControl *)tabbar atIndex:(NSInteger)theIndex;//the controllers' names
- (BOOL)isNavigation:(CTTabbarControl *)tabbar atIndex:(NSInteger)theIndex;
- (UIImage *)tabbarBgImage:(CTTabbarControl *)tabbar;//tabbar's background image
- (CGRect)tabbarButtonRect:(CTTabbarControl *)tabbar atIndex:(NSInteger)theIndex;//items' rects. you can set the rect by your self. not average
- (NSString *)tabbarItemTitle:(CTTabbarControl *)tabbar
                      atIndex:(NSInteger)theIndex;
- (UIColor *)tabbarItemTitleColorNormal:(CTTabbarControl *)tabbar
                                atIndex:(NSInteger)theIndex;
- (UIColor *)tabbarItemTitleColorSelected:(CTTabbarControl *)tabbar
                                  atIndex:(NSInteger)theIndex;
- (UIFont *)tabbarItemTitleFont:(CTTabbarControl *)tabbar
                       atIndex:(NSInteger)theIndex;

- (UIImage *)tabbarItemIcon:(CTTabbarControl *)tabbar
                    atIndex:(NSInteger)theIndex;//normal icon
- (UIImage *)tabbarItemIconHighlight:(CTTabbarControl *)tabbar
                             atIndex:(NSInteger)theIndex; //highlight icon, when you touch down the item
- (UIImage *)tabbarItemIconSelected:(CTTabbarControl *)tabbar
                             atIndex:(NSInteger)theIndex;//selected icon, then the item is selected
- (BOOL)canselect:(CTTabbarControl *)tabbar atIndex:(NSInteger)theIndex;

- (void)willSelect:(CTTabbarControl *)tabbar atIndex:(NSInteger)theIndex;

- (UIViewController *)getControllerParam:(UIViewController *)controller atIndex:(NSInteger) theIndex;
@end