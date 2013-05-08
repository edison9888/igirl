//
//  CTTabbarControl.m
//  Tabbar
//
//  Created by 晋辉 卫 on 10/27/11.
//  Copyright (c) 2011 MobileWoo. All rights reserved.
//

#import "CTTabbarControl.h"
#import "AppDelegate.h"
#import "DataEngine.h"
#import "Constants.h"

@interface CTTabbarControl (Private)

- (void)initTabbar;
- (void)deselectItemExcept:(NSInteger)selectedIndex highlightIndex:(NSInteger)highlightIndex;
- (void)hideTitle:(NSNumber *)animation;
- (void)showTitle:(NSInteger)theIndex;
- (void)scrollArrowTo:(NSInteger)theIndex animation:(BOOL)animation;
- (void)scrollEnd;
- (void)resetViewRect:(UIViewController *)controller;
- (void)resetCurrentViewRect;

- (void)responseGetSellerTemplate:(NSNotification *)notification;

- (void)setTemplateShowNewTip;
- (void)setTaobaoGuideShowNewTip;

@end

@implementation CTTabbarControl
@synthesize controllers = _controllers;
@synthesize labels = _labels;
@synthesize buttons = _buttons;
@synthesize notShow = _notShow;
@synthesize bageButtons = _bageButtons;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithFrame:(CGRect)theFrame
       withDelegate:(id<CTTabbarControlDelegate>)theDelegate
          withCount:(NSInteger)theCount
{
    self = [super initWithFrame:theFrame];
    if (self) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];

        self.backgroundColor = [UIColor clearColor];
        _delegate = theDelegate;
        _count = theCount;
        _selected = -1;
        _bgImage = [_delegate tabbarBgImage:self];
        [self initTabbar];
        UIImage *arrow = [UIImage imageNamed:@"tabArrow.png"];
        _arrow = [[UIImageView alloc] initWithImage:arrow];
        _arrow.frame = CGRectMake(-100, kTabbarHeight - arrow.size.height, arrow.size.width, arrow.size.height);
        [self addSubview:_arrow];
        [[_delegate superView:self] addSubview:self];
        [self setBackgroundColor:[UIColor whiteColor]];
    }
    return self;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"notShow"];
    
    _delegate = nil;
}

- (void)setSelectedIndex:(NSInteger)theIndex
{
    if (theIndex != _selected) {
        [_delegate willSelect:self atIndex:theIndex];
    }
    
    if (![_delegate canselect:self atIndex:theIndex]) {
        [self scrollEnd];
        return;
    }
    AppDelegate *delegate= (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString *preXibName = [_delegate xibName:self atIndex:_selected];
    NSString *postXibName = [_delegate xibName:self atIndex:theIndex];
    if ([_delegate isNavigation:self atIndex:theIndex]) {
        if (_selected >= 0 && _selected < _count && _selected != theIndex) {
            [self scrollArrowTo:theIndex animation:YES];
        } else {
            [self scrollArrowTo:theIndex animation:NO];
        }
        [self showTitle:theIndex];
        [self deselectItemExcept:theIndex highlightIndex:theIndex];
        UIViewController *preController = [_controllers objectForKey:preXibName];
        if (theIndex == _selected) {
            if (preController != nil && preController != (UIViewController *)[NSNull null] && [preController isKindOfClass:[UINavigationController class]]) {
                [(UINavigationController *)preController popToRootViewControllerAnimated:YES];
            }
            return;
        }
        if (preController != (UIViewController *)[NSNull null] && preController != nil) {
            [preController.view removeFromSuperview];
            if (SYSTEM_VERSION_LESS_THAN(@"5.0")) {
                [preController viewWillDisappear:NO];
                [preController viewDidDisappear:NO];
            }
        }
        _selected = theIndex;
        UIViewController *postController = [_controllers objectForKey:postXibName];
        if (postController == nil || postController == (UIViewController *)[NSNull null]) {
            postController = [[[NSBundle mainBundle] loadNibNamed:@"CustomNavigationController" owner:self options:nil] objectAtIndex:0];
            UIViewController *first = nil;
            Class controllerClass = NSClassFromString(postXibName);
            if([[NSBundle mainBundle] pathForResource:postXibName ofType:@"nib"]) {
                first = [[controllerClass alloc] initWithNibName:postXibName bundle:nil];
            } else {
                first = [[controllerClass alloc] init];
            }
            first = [_delegate getControllerParam:first atIndex:_selected];

            [(UINavigationController *)postController pushViewController:first animated:NO];
            [_controllers setObject:postController forKey:postXibName];
        }
        [self resetViewRect:postController];
        [[_delegate superView:self] insertSubview:postController.view belowSubview:self];
        if (SYSTEM_VERSION_LESS_THAN(@"5.0")) {
            [postController viewWillAppear:NO];
            [postController viewDidAppear:NO];
        }
    } else {
        [self deselectItemExcept:_selected highlightIndex:-1];
        if (_selected == theIndex) {
            return;
        }

        Class controllerClass = NSClassFromString(postXibName);
        UIViewController *first = nil;
        if([[NSBundle mainBundle] pathForResource:postXibName ofType:@"nib"]) {
            first = [[controllerClass alloc] initWithNibName:postXibName bundle:nil];
        } else {
            first = [[controllerClass alloc] init];
        }
        [delegate presentModalViewController:first animated:YES];
    }
//    [[_delegate superView:self] bringSubviewToFront:self];
}

- (UIViewController *)selectedController
{
    return [_controllers objectForKey:[_delegate xibName:self atIndex:_selected]];
}

- (UIViewController *)targetController:(int) theIndex
{
    return [_controllers objectForKey:[_delegate xibName:self atIndex:theIndex]];
}

- (NSInteger)selectedIndex
{
    return _selected;
}

- (void)resetTab:(NSInteger)index
{
    if (![_delegate isNavigation:self atIndex:index]) {
        return;
    }
    UIViewController *controller = [_controllers objectForKey:[_delegate xibName:self atIndex:index]];
    if (controller != (UIViewController *)[NSNull null] && controller != nil && [controller isKindOfClass:[UINavigationController class]]) {
        [(UINavigationController *)controller popToRootViewControllerAnimated:YES];
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    CGRect middleFrame = [_delegate tabbarButtonRect:self atIndex:2];
    if (point.y >= 0 && point.y < kTabbarHeight - kTabbarRealHeight && ((point.x >= 0 && point.x < middleFrame.origin.x) || (point.x >= middleFrame.origin.x + middleFrame.size.width && point.x < self.frame.size.width))) {
        return nil;
    }
    return [super hitTest:point withEvent:event];
}

- (void)initTabbar
{
    if (_controllers) {
        NSEnumerator *enumerator = [_controllers objectEnumerator];
        UIViewController *controller;
        while (controller = [enumerator nextObject]) {
            if (controller != (UIViewController *)[NSNull null]) {
                [controller.view removeFromSuperview];
            }
        }
        self.controllers = nil;
    }
    _controllers = [[NSMutableDictionary alloc] initWithCapacity:_count];
    if (_labels) {
        self.labels = nil;
    }
    _labels = [[NSMutableArray alloc] initWithCapacity:_count];
    
    if (_bageButtons) {
        self.bageButtons = nil;
    }
    _bageButtons = [[NSMutableArray alloc] initWithCapacity:_count];
    
    if (_buttons) {
        for (int ii = 0; ii < _buttons.count; ii++) {
            [(UIButton *)[_buttons objectAtIndex:ii] removeFromSuperview];
        }
        self.buttons = nil;
    }
    
    _buttons = [[NSMutableArray alloc] initWithCapacity:_count];
    for (int ii = 0; ii < _count; ii++) {
        [_controllers setObject:[NSNull null] forKey:[_delegate xibName:self atIndex:ii]];
        NSString *title = [_delegate tabbarItemTitle:self atIndex:ii];
        if (title) {
            [_labels addObject:[_delegate tabbarItemTitle:self atIndex:ii]];
        } else {
            [_labels addObject:[NSNull null]];
        }
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [_buttons addObject:button];
        UIImage *icon = [_delegate tabbarItemIcon:self atIndex:ii];
        CGRect rect = [_delegate tabbarButtonRect:self atIndex:ii];
        button.frame = CGRectMake(rect.origin.x + (rect.size.width - icon.size.width) / 2, rect.origin.y + (rect.size.height - icon.size.height) / 2, icon.size.width, icon.size.height);
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitle:title forState:UIControlStateHighlighted];
        [button setTitle:title forState:UIControlStateSelected];
        [button setBackgroundImage:[_delegate tabbarItemIcon:self atIndex:ii] forState:UIControlStateNormal];
        [button setBackgroundImage:[_delegate tabbarItemIconHighlight:self atIndex:ii] forState:UIControlStateHighlighted];
        [button setBackgroundImage:[_delegate tabbarItemIconSelected:self atIndex:ii] forState:UIControlStateSelected];
        [button setTitleColor:[_delegate tabbarItemTitleColorNormal:self atIndex:ii] forState:UIControlStateNormal];
        [button setTitleColor:[_delegate tabbarItemTitleColorSelected:self atIndex:ii] forState:UIControlStateHighlighted];
        [button setTitleColor:[_delegate tabbarItemTitleColorSelected:self atIndex:ii] forState:UIControlStateSelected];
        button.titleLabel.font = [_delegate tabbarItemTitleFont:self atIndex:ii];
        button.titleLabel.textAlignment = UITextAlignmentCenter;
        
        [button addTarget:self action:@selector(buttonSelected:) forControlEvents:UIControlEventTouchUpInside];
        [button addTarget:self action:@selector(buttonHighlighted:) forControlEvents:UIControlEventTouchDown];
        [button addTarget:self action:@selector(buttonHighlighted:) forControlEvents:UIControlEventTouchDragInside];
        [button addTarget:self action:@selector(buttonOutside:) forControlEvents:UIControlEventTouchCancel];
        [button addTarget:self action:@selector(buttonOutside:) forControlEvents:UIControlEventTouchUpOutside];
        button.titleEdgeInsets = UIEdgeInsetsMake(32, 1, 0, 0);
        [self addSubview:button];
        
        UIImageView *hasNewImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"new"]];
        [self addSubview:hasNewImageView];
        hasNewImageView.frame = CGRectMake(rect.origin.x + rect.size.width / 2 + 10, rect.origin.y + rect.size.height / 6 - 6, 23, 17);
        hasNewImageView.hidden = YES;
        [_bageButtons addObject:hasNewImageView];
    }
}

- (void)deselectItemExcept:(NSInteger)selectedIndex highlightIndex:(NSInteger)highlightIndex
{
    for (int ii = 0; ii < _count; ii++) {
        UIButton *button = [_buttons objectAtIndex:ii];
        if (ii == selectedIndex) {
            if (button) {
                button.selected = YES;
                button.highlighted = NO;
            }
        } else if (ii == highlightIndex) {
            if (button) {
                button.selected = NO;
                button.highlighted = YES;
            }
        } else {
            if (button) {
                button.selected = NO;
                button.highlighted = NO;
            }
        }
    }
}

- (void)showTitle:(NSInteger)theIndex
{
    for (int ii = 0; ii < _count; ii++) {
        if ([_delegate isNavigation:self atIndex:ii]) {
//            UIButton *button= [_buttons objectAtIndex:ii];
//            button.titleLabel.alpha = (ii == theIndex) ? 1.0 : 0.0;
        }
    }
}

- (void)scrollArrowTo:(NSInteger)theIndex animation:(BOOL)animation
{
    if (animation) {
        [UIView beginAnimations:@"arrow" context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(scrollEnd)];
    }
    UIButton *button = [_buttons objectAtIndex:theIndex];
    _arrow.frame = CGRectMake(button.frame.origin.x + (button.frame.size.width - _arrow.frame.size.width) / 2, _arrow.frame.origin.y, _arrow.frame.size.width, _arrow.frame.size.height);
    if (animation) {
        [UIView commitAnimations];
    }
}

- (void)scrollEnd
{
    //[self performSelector:@selector(hideTitle:) withObject:[NSNumber numberWithBool:YES] afterDelay:0.3];
}

- (void)resetViewRect:(UIViewController *)controller
{
    if (_notShow) {
        controller.view.frame = [_delegate superView:self].bounds;
    } else {
        controller.view.frame = CGRectMake(0, 0, 320, [_delegate superView:self].frame.size.height - kTabbarRealHeight);
    }
}

- (void)resetCurrentViewRect
{
    if (_selected >= 0 && _selected < _count) {
        UIViewController *postController = [_controllers objectForKey:[_delegate xibName:self atIndex:_selected]];
        if (postController != nil && postController != (UIViewController *)[NSNull null]) {
            [self resetViewRect:postController];
        }
    }
}

- (void)hideTitle:(NSNumber *)animation
{
    if ([animation boolValue]) {
        [UIView beginAnimations:@"title" context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    }
    for (UIButton *button in _buttons) {
//        button.titleLabel.alpha = 0.0;
    }
    if ([animation boolValue]) {
        [UIView commitAnimations];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
 */
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [_bgImage drawInRect:self.bounds];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"notShow"]) {
        if (_selected >= 0 && _selected < _count) {
            UIViewController *postController = [_controllers objectForKey:[_delegate xibName:self atIndex:_selected]];
            if (postController != nil && postController != (UIViewController *)[NSNull null]) {
                [self resetViewRect:postController];
            }
        }
    }
}

- (void)buttonHighlighted:(id)sender
{
    NSInteger index = [_buttons indexOfObject:sender];
    if (index >= 0 && index < _count) {
        //[self showTitle:index];
        [self deselectItemExcept:_selected highlightIndex:index];
    }
}

- (void)buttonSelected:(id)sender
{
    NSInteger index = [_buttons indexOfObject:sender];
    if (index >= 0 && index < _count) {
        [self setSelectedIndex:index];
    }
}

- (void)buttonOutside:(id)sender
{
    [self hideTitle:[NSNumber numberWithBool:YES]];
}

- (void)setTabBarItemController:(UIViewController *) contentController postXibName:(NSString *) postXibName
{
    [_controllers setObject:contentController forKey:postXibName];
}

- (void)forceDisplayController:(NSInteger) theIndex;
{
    if (theIndex != _selected) {
        [_delegate willSelect:self atIndex:theIndex];
    }
    
    if (![_delegate canselect:self atIndex:theIndex]) {
        [self scrollEnd];
        return;
    }

    NSString *preXibName = [_delegate xibName:self atIndex:_selected];
    NSString *postXibName = [_delegate xibName:self atIndex:theIndex];
    if (_selected >= 0 && _selected < _count && _selected != theIndex) {
        [self scrollArrowTo:theIndex animation:YES];
    } else {
        [self scrollArrowTo:theIndex animation:NO];
    }
    [self showTitle:theIndex];
    [self deselectItemExcept:theIndex highlightIndex:theIndex];
    UIViewController *preController = [_controllers objectForKey:preXibName];
    if (preController != (UIViewController *)[NSNull null] && preController != nil) {
        [preController.view removeFromSuperview];
        if (SYSTEM_VERSION_LESS_THAN(@"5.0")) {
            [preController viewWillDisappear:NO];
            [preController viewDidDisappear:NO];
        }
    }
    _selected = theIndex;
    UIViewController *postController = [_controllers objectForKey:postXibName];
    if (postController == nil || postController == (UIViewController *)[NSNull null]) {
        postController = [[[NSBundle mainBundle] loadNibNamed:@"CustomNavigationController" owner:self options:nil] objectAtIndex:0];
        UIViewController *first = nil;
        Class controllerClass = NSClassFromString(postXibName);
        if([[NSBundle mainBundle] pathForResource:postXibName ofType:@"nib"]) {
            first = [[controllerClass alloc] initWithNibName:postXibName bundle:nil];
        } else {
            first = [[controllerClass alloc] init];
        }
        first = [_delegate getControllerParam:first atIndex:_selected];
        
        [(UINavigationController *)postController pushViewController:first animated:NO];
        [_controllers setObject:postController forKey:postXibName];
    }
    [self resetViewRect:postController];
    [[_delegate superView:self] insertSubview:postController.view belowSubview:self];
    if (SYSTEM_VERSION_LESS_THAN(@"5.0")) {
        [postController viewWillAppear:NO];
        [postController viewDidAppear:NO];
    }

}
@end
