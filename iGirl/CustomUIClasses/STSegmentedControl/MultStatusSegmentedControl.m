//
//  MultStatusSegmentedControl.m
//  Pocket flea market
//
//  Created by 晋辉 卫 on 2/24/12.
//  Copyright (c) 2012 MobileWoo. All rights reserved.
//

#import "MultStatusSegmentedControl.h"

#define kLowlightColor [UIColor colorWithRed:100 / 255.0 green:100 / 255.0 blue:100 / 255.0 alpha:1.0]
#define kObjectName @"Title"
#define kObjectStatus @"Status"
#define kObjectStatusKeys @"keys"
#define kStatusTag 10000

@interface MultStatusSegmentedControl (Private)
- (void)updateUI;
- (void)deselectAllSegments;
- (void)insertSegmentWithObject:(NSObject *)object atIndex:(NSUInteger)index;
- (void)setObject:(NSObject *)object forSegmentAtIndex:(NSUInteger)index;
- (void)resetSegments;
- (void)sendActionsForControlEvents:(UIControlEvents) events;
@end

@implementation MultStatusSegmentedControl
@synthesize numberOfSegments = _numberOfSegments;
@synthesize selectedSegmentIndex = _selectedSegmentIndex;
@synthesize currentStatus = _currentStatus;
@synthesize momentary = _momentary;

#pragma mark -
#pragma mark Initializer

- (id)initWithFrame:(CGRect)frame {
    if((self = [super initWithFrame:frame])) {
        self.backgroundColor = [UIColor clearColor];
        
        _selectedSegmentIndex = MultStatusSegmentedControlNoSegment;
        _momentary = NO;
        UIImage *arrow = [UIImage imageNamed:@"segmented_arrow.png"];
        _arrow = [[UIImageView alloc] initWithImage:arrow];
        _arrow.frame = CGRectMake(-100, self.frame.origin.y + self.frame.size.height - arrow.size.height, arrow.size.width, arrow.size.height);
        [self addSubview:_arrow];
    }
    return self;
}

- (id)initWithItems:(NSArray *)items {
    if((self = [super init])) {
        self.backgroundColor = [UIColor clearColor];
        
        _selectedSegmentIndex = MultStatusSegmentedControlNoSegment;
        _momentary = NO;
        /*
         Set items
         */
        _segments = [NSMutableArray arrayWithCapacity:3];
        for (NSObject *object in items) {
            NSMutableDictionary *item = [NSMutableDictionary dictionaryWithObjectsAndKeys:object, kObjectName, [NSMutableDictionary dictionaryWithCapacity:2], kObjectStatus, [NSMutableArray arrayWithCapacity:2], kObjectStatusKeys, nil];
            [_segments addObject:item];
        }
        UIImage *arrow = [UIImage imageNamed:@"segmented_arrow.png"];
        _arrow = [[UIImageView alloc] initWithImage:arrow];
        _arrow.frame = CGRectMake(-100, self.frame.origin.y + self.frame.size.height - arrow.size.height, arrow.size.width, arrow.size.height);
//        [self addSubview:_arrow];
        [self resetSegments];
    }
    return self;
}

#pragma mark -
#pragma mark initWithCoder for IB support

- (id)initWithCoder:(NSCoder *)decoder {
    if(self == [super initWithCoder:decoder]) {
		self.backgroundColor = [UIColor clearColor];
		self.frame = self.frame;
		
		_selectedSegmentIndex = MultStatusSegmentedControlNoSegment;
		_momentary = NO;
        
        UIImage *arrow = [UIImage imageNamed:@"segmented_arrow.png"];
        _arrow = [[UIImageView alloc] initWithImage:arrow];
        _arrow.frame = CGRectMake(-100, self.frame.origin.y + self.frame.size.height - arrow.size.height, arrow.size.width, arrow.size.height);
        [self addSubview:_arrow];
	}
    return self;
}

#pragma mark -
- (NSUInteger)numberOfSegments
{
    return _segments.count;
}

- (void)updateUI {
	/*
	 Remove every UIButton from screen
	 */
	[[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
	
	/*
	 We're only displaying this element if there are at least two buttons
	 */
	if (_segments.count > 1) {
		int indexOfObject = 0;
		
		float segmentWidth = (float)self.frame.size.width / self.numberOfSegments;
		float lastX = 0.0;
		
		for (NSDictionary *object in _segments) {
            NSObject *title = [object objectForKey:kObjectName];
			/*
			 Calculate the frame for the current segment
			 */
			int currentSegmentWidth = round(lastX + segmentWidth) - round(lastX);
			
			CGRect segmentFrame = CGRectMake(round(lastX), 0, currentSegmentWidth, self.frame.size.height);
			lastX += segmentWidth;
			
			/*
			 Give every button the background image it needs for its current state
			 */
			UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
			
			if (indexOfObject == 0) {
                [button setBackgroundImage:[[UIImage imageNamed:@"segmented_button_left.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:15] forState:UIControlStateNormal];
                [button setBackgroundImage:[[UIImage imageNamed:@"segmented_button_left_high.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:15] forState:UIControlStateHighlighted];
                [button setBackgroundImage:[[UIImage imageNamed:@"segmented_button_left_selected.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:15] forState:UIControlStateSelected];
			} else if(indexOfObject == self.numberOfSegments - 1) {
                [button setBackgroundImage:[[UIImage imageNamed:@"segmented_button_right.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:15] forState:UIControlStateNormal];
                [button setBackgroundImage:[[UIImage imageNamed:@"segmented_button_right_high.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:15] forState:UIControlStateHighlighted];
                [button setBackgroundImage:[[UIImage imageNamed:@"segmented_button_right_selected.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:15] forState:UIControlStateSelected];
				
			} else {
                [button setBackgroundImage:[[UIImage imageNamed:@"segmented_button_center.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:15] forState:UIControlStateNormal];
                [button setBackgroundImage:[[UIImage imageNamed:@"segmented_button_center_high.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:15] forState:UIControlStateHighlighted];
                [button setBackgroundImage:[[UIImage imageNamed:@"segmented_button_center_selected.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:15] forState:UIControlStateSelected];
            }
            [button setTitleColor:kLowlightColor forState:UIControlStateNormal];
            [button setTitleColor:[UIColor colorWithRed:100 / 255.0 green:100 / 255.0 blue:100 / 255.0 alpha:1.0] forState:UIControlStateHighlighted];
            [button setTitleColor:[UIColor colorWithRed:100 / 255.0 green:100 / 255.0 blue:100 / 255.0 alpha:1.0] forState:UIControlStateSelected];
			
			button.frame = segmentFrame;
			button.titleLabel.font = [UIFont systemFontOfSize:12];
            [button.titleLabel setShadowOffset:CGSizeMake(0, 1)];
            [button setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
			button.tag = indexOfObject + 1;
			button.adjustsImageWhenHighlighted = NO;
			
			/*
			 Check if we're dealing with a string or an image
			 */
			if ([title isKindOfClass:[NSString class]]) {
				[button setTitle:(NSString *)title forState:UIControlStateNormal];
                button.titleLabel.text = (NSString *)title;
			} else if([title isKindOfClass:[UIImage class]]) {
				[button setImage:(UIImage *)title forState:UIControlStateNormal];
			}
			
			[button addTarget:self action:@selector(segmentTapped:) forControlEvents:UIControlEventTouchDown];
            [button addTarget:self action:@selector(segmentDrag:) forControlEvents:UIControlEventTouchDragInside];
            [button addTarget:self action:@selector(segmentSelected:) forControlEvents:UIControlEventTouchUpInside];
            [button addTarget:self action:@selector(buttonCancel:) forControlEvents:UIControlEventTouchCancel];
            [button addTarget:self action:@selector(buttonCancel:) forControlEvents:UIControlEventTouchDragOutside];
            [button addTarget:self action:@selector(buttonCancel:) forControlEvents:UIControlEventTouchUpOutside];
			[self addSubview:button];
            
            if (_selectedSegmentIndex == indexOfObject) {                
                _arrow.frame = CGRectMake(segmentFrame.origin.x + (segmentFrame.size.width - _arrow.frame.size.width) / 2, segmentFrame.origin.y + segmentFrame.size.height - _arrow.frame.size.height, _arrow.frame.size.width, _arrow.frame.size.height);
            }
			
			++indexOfObject;
		}
		/*
		 Make sure the selected segment shows both its separators
		 */
		[self bringSubviewToFront:[self viewWithTag:_selectedSegmentIndex + 1]];
        [_arrow removeFromSuperview];
        //            [self addSubview:_arrow];
	}
}

- (void)deselectAllSegments {
	/*
	 Deselects all segments
	 */
	for (UIButton *button in self.subviews) {
        if ([button isKindOfClass:[UIButton class]]) {
            button.highlighted = NO;
            button.selected = NO;
        }		
	}
}

- (void)resetSegments {
	/*
	 Reset the index and send the action
	 */
	_selectedSegmentIndex = MultStatusSegmentedControlNoSegment;
    _currentStatus = nil;
	[self updateUI];
}

- (void)insertSegmentWithObject:(NSObject *)object atIndex:(NSUInteger)index {
	/*
	 Making sure we don't call out of bounds
	 */
	if (index <= self.numberOfSegments) {
		[_segments insertObject:object atIndex:index];
		[self resetSegments];
	}
}

- (void)setObject:(NSObject *)object forSegmentAtIndex:(NSUInteger)index {
	/*
	 Making sure we don't call out of bounds
	 */
	if (index < self.numberOfSegments) {
		[_segments replaceObjectAtIndex:index withObject:object];
		[self resetSegments];
	}
}

- (void)segmentTapped:(id)sender {
	[self deselectAllSegments];
    for (UIButton *button in self.subviews) {
        if ([button isKindOfClass:[UIButton class]]) {
            UIView *statusView = [button viewWithTag:kStatusTag];
            if (statusView) {
                statusView.hidden = YES;
            }
        }
	}
	/*
	 Send the action
	 */
	UIButton *button = sender;
	[self bringSubviewToFront:button];
    NSDictionary *status = nil;
    NSArray *keys = nil;
    if (button.tag > 0 && button.tag <= self.numberOfSegments) {
        status = [[_segments objectAtIndex:button.tag - 1] objectForKey:kObjectStatus];
        keys = [[_segments objectAtIndex:button.tag - 1] objectForKey:kObjectStatusKeys];
    }
    UIImage *statusImage = nil;
    if (_selectedSegmentIndex != button.tag - 1 || _programmaticIndexChange) {
        if (_selectedSegmentIndex != button.tag - 1 || _currentStatus == nil) {
            if (keys.count > 0) {
                _currentStatus = [keys objectAtIndex:0];
            } else {
                _currentStatus = nil;
            }
        }
        _selectedSegmentIndex = button.tag - 1;
        _programmaticIndexChange = NO;
        [self sendActionsForControlEvents:UIControlEventValueChanged];
        button.selected = YES;
        _isSwitch = YES;
    } else {
        if (_currentStatus == nil) {
            if (keys.count > 0) {
                _currentStatus = [keys objectAtIndex:0];
            }
        } else {
            if (![keys containsObject:_currentStatus]) {
                _currentStatus = nil;
            }
        }
        if (_currentStatus) {
            button.highlighted = YES;
        } else {
            button.selected = YES;
        }
        _isSwitch = NO;
    }
	if (_currentStatus) {
        UIImage *image = [status objectForKey:_currentStatus];
        if (image && [image isKindOfClass:[UIImage class]]) {
            statusImage = image;
        }
    }
    if (statusImage) {
        UIImageView *statusView = (UIImageView *)[button viewWithTag:kStatusTag];
        if (statusView == nil) {
            statusView = [[UIImageView alloc] init];
            statusView.tag = kStatusTag;
            [button addSubview:statusView];
        }
        statusView.hidden = NO;
        statusView.image = statusImage;
        CGRect contentRect;
        if ([[[_segments objectAtIndex:button.tag - 1] objectForKey:kObjectName] isKindOfClass:[NSString class]]) {
            contentRect = [button titleRectForContentRect:button.bounds];
        } else {
            contentRect = [button imageRectForContentRect:button.bounds];
        }
        // 原先的x:
        // (contentRect.origin.x - statusImage.size.width)/ 2
        statusView.frame = CGRectMake(44, (button.frame.size.height - statusImage.size.height)/ 2, statusImage.size.width, statusImage.size.height);
    }
	/*
	 Give the tapped segment the selected look
	 */
//    [UIView beginAnimations:@"arrow" context:nil];
//    [UIView setAnimationDuration:0.3];
//    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
//    [UIView setAnimationDelegate:self];
//    CGRect frame = CGRectMake(button.frame.origin.x + (button.frame.size.width - _arrow.frame.size.width) / 2, button.frame.origin.y + button.frame.size.height - _arrow.frame.size.height, _arrow.frame.size.width, _arrow.frame.size.height);
//    _arrow.frame = frame;
//    [UIView commitAnimations];
}

- (void)segmentDrag:(id)sender {
	[self deselectAllSegments];
	/*
	 Send the action
	 */
	UIButton *button = sender;
    [self bringSubviewToFront:button];
	if (_currentStatus && !_isSwitch) {
        button.highlighted = YES;
    } else {
        button.selected = YES;
    }
}

- (void)segmentSelected:(id)sender {
	[self deselectAllSegments];
	/*
	 Send the action
	 */
	UIButton *button = sender;
	[self bringSubviewToFront:button];
    NSDictionary *status = nil;
    NSMutableArray *keys = nil;
    if (button.tag > 0 && button.tag <= self.numberOfSegments) {
        status = [[_segments objectAtIndex:button.tag - 1] objectForKey:kObjectStatus];
        keys = [NSMutableArray arrayWithArray:[[_segments objectAtIndex:button.tag - 1] objectForKey:kObjectStatusKeys]];
    }
    UIImage *statusImage = nil;
    if (_currentStatus && !_isSwitch) {
        [keys removeObject:_currentStatus];
        if (keys.count > 0) {
            _currentStatus = [keys objectAtIndex:0];
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        }
    }
    button.selected = YES;
	if (_currentStatus && !_isSwitch) {
        UIImage *image = [status objectForKey:_currentStatus];
        if (image && [image isKindOfClass:[UIImage class]]) {
            statusImage = image;
        }
    }
    if (statusImage) {
        UIImageView *statusView = (UIImageView *)[button viewWithTag:kStatusTag];
        if (statusView == nil) {
            statusView = [[UIImageView alloc] init];
            statusView.tag = kStatusTag;
            [button addSubview:statusView];
        }
        statusView.hidden = NO;
        statusView.image = statusImage;
        CGRect contentRect;
        if ([[[_segments objectAtIndex:button.tag - 1] objectForKey:kObjectName] isKindOfClass:[NSString class]]) {
            contentRect = [button titleRectForContentRect:button.bounds];
        } else {
            contentRect = [button imageRectForContentRect:button.bounds];
        }
        // 原先的x:
        // (contentRect.origin.x - statusImage.size.width)/ 2
        statusView.frame = CGRectMake(44, (button.frame.size.height - statusImage.size.height)/ 2, statusImage.size.width, statusImage.size.height);
    }
    
	if (_momentary) {
        [self performSelector:@selector(deselectAllSegments) withObject:nil afterDelay:0.2];
    }
}

- (void)buttonCancel:(id)sender
{
    [self deselectAllSegments];
	/*
	 Send the action
	 */
	UIButton *button = sender;
    [self bringSubviewToFront:button];
	button.selected = YES;
}

#pragma mark -

- (void)insertSegmentWithTitle:(NSString *)title atIndex:(NSUInteger)index {
    NSMutableDictionary *item = [NSMutableDictionary dictionaryWithObjectsAndKeys:title, kObjectName, [NSMutableDictionary dictionaryWithCapacity:2], kObjectStatus, [NSMutableArray arrayWithCapacity:2], kObjectStatusKeys, nil];
	[self insertSegmentWithObject:item atIndex:index];
}

- (void)insertSegmentWithImage:(UIImage *)image atIndex:(NSUInteger)index {
    NSMutableDictionary *item = [NSMutableDictionary dictionaryWithObjectsAndKeys:image, kObjectName, [NSMutableDictionary dictionaryWithCapacity:2], kObjectStatus, [NSMutableArray arrayWithCapacity:2], kObjectStatusKeys, nil];
	[self insertSegmentWithObject:item atIndex:index];
}

- (void)removeSegmentAtIndex:(NSUInteger)index {
	/*
	 Making sure we don't call out of bounds
	 If you delete a segment when only having two segments, the control won't be shown anymore
	 */
	if (index < self.numberOfSegments) {
		[_segments removeObjectAtIndex:index];
		[self resetSegments];
	}
}

- (void)removeAllSegments {
	[_segments removeAllObjects];
	_selectedSegmentIndex = MultStatusSegmentedControlNoSegment;
	[self updateUI];
}

- (void)setTitle:(NSString *)title forSegmentAtIndex:(NSUInteger)index {
    if (index < self.numberOfSegments) {
        NSMutableDictionary *dictionary = [_segments objectAtIndex:index];
        [dictionary setObject:title forKey:kObjectName];
		[self resetSegments];
    }
}

- (void)setImage:(UIImage *)image forSegmentAtIndex:(NSUInteger)index {
    if (index < self.numberOfSegments) {
        NSMutableDictionary *dictionary = [_segments objectAtIndex:index];
        [dictionary setObject:image forKey:kObjectName];
		[self resetSegments];
    }
}

#pragma mark -
#pragma mark Getters

- (NSString *)titleForSegmentAtIndex:(NSUInteger)index {
	if (index < self.numberOfSegments) {
        id title = [[_segments objectAtIndex:index] objectForKey:kObjectName];
        if (title && [title isKindOfClass:[NSString class]]) {
            return title;
        }
	}
    return nil;
}

- (UIImage *)imageForSegmentAtIndex:(NSUInteger)index {
	if (index < self.numberOfSegments) {
        id image = [[_segments objectAtIndex:index] objectForKey:kObjectName];
		if([image isKindOfClass:[UIImage class]]) {
			return image;
		}
	}
	return nil;
}

- (void)addStatusWithImage:(UIImage *)image withStatus:(NSString *)status forSegmentAtIndex:(NSUInteger)index
{
    if (index < self.numberOfSegments && image && status) {
        NSMutableDictionary *object = [_segments objectAtIndex:index];
        NSMutableDictionary *statusDic = [object objectForKey:kObjectStatus];
        [statusDic setObject:image forKey:status];
        NSMutableArray *keys = [object objectForKey:kObjectStatusKeys];
        [keys removeObject:status];
        [keys addObject:status];
        [self resetSegments];
    }
}

- (void)removeStatus:(NSString *)status forSegmentAtIndex:(NSUInteger)index
{
    if (index < self.numberOfSegments && status) {
        NSMutableDictionary *object = [_segments objectAtIndex:index];
        NSMutableDictionary *statusDic = [object objectForKey:kObjectStatus];
        [statusDic removeObjectForKey:status];
        NSMutableArray *keys = [object objectForKey:kObjectStatusKeys];
        [keys removeObject:status];
        [self resetSegments];
    }
}

#pragma -
#pragma mark Setters
- (void)setSelectedSegmentIndex:(NSInteger)index {
	if (index != _selectedSegmentIndex) {
		_selectedSegmentIndex = index;
        _currentStatus = nil;
        _programmaticIndexChange = YES;
		if (index >= 0 && index < self.numberOfSegments) {
			UIButton *button = (UIButton *)[self viewWithTag:index + 1];
			[self segmentTapped:button];
		}
	}
}

- (void)setSelectedStatus:(NSInteger)index status:(NSString *)theStatus
{
    if (theStatus == nil) {
        self.selectedSegmentIndex = index;
        return;
    }
    if (_selectedSegmentIndex != index || ![theStatus isEqualToString:_currentStatus]) {
        _selectedSegmentIndex = index;
        _currentStatus = [NSString stringWithString:theStatus];
        _programmaticIndexChange = YES;
        if (index >= 0 && index < self.numberOfSegments) {
			UIButton *button = (UIButton *)[self viewWithTag:index + 1];
			[self segmentTapped:button];
		}
    }
}

- (void)setFrame:(CGRect)rect {
	[super setFrame:rect];
	[self updateUI];
}

- (void)sendActionsForControlEvents:(UIControlEvents) events
{
    // nothing to do...
}
@end
