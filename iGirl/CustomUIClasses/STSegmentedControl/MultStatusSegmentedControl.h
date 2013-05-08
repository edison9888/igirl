//
//  MultStatusSegmentedControl.h
//  Pocket flea market
//
//  Created by 晋辉 卫 on 2/24/12.
//  Copyright (c) 2012 MobileWoo. All rights reserved.
//

#import <UIKit/UIKit.h>

enum {
    MultStatusSegmentedControlNoSegment = -1 // segment index for no selected segment
};

@interface MultStatusSegmentedControl : UIControl
{
    NSMutableArray *_segments;
    UIImageView *_arrow;
    
    BOOL _programmaticIndexChange;
    BOOL _isSwitch;
}

- (id)initWithItems:(NSArray *)items;

- (void)insertSegmentWithTitle:(NSString *)title atIndex:(NSUInteger)index; // insert before segment number
- (void)insertSegmentWithImage:(UIImage *)image atIndex:(NSUInteger)index;

- (void)removeSegmentAtIndex:(NSUInteger)index;
- (void)removeAllSegments;

- (void)setTitle:(NSString *)title forSegmentAtIndex:(NSUInteger)index;
- (NSString *)titleForSegmentAtIndex:(NSUInteger)index;

- (void)setImage:(UIImage *)image forSegmentAtIndex:(NSUInteger)index;
- (UIImage *)imageForSegmentAtIndex:(NSUInteger)index;

- (void)addStatusWithImage:(UIImage *)image withStatus:(NSString *)status forSegmentAtIndex:(NSUInteger)index;
- (void)removeStatus:(NSString *)status forSegmentAtIndex:(NSUInteger)index;
- (void)setSelectedStatus:(NSInteger)index status:(NSString *)theStatus;
@property (nonatomic, readonly, getter = numberOfSegments) NSUInteger numberOfSegments;

@property (nonatomic, getter=isMomentary) BOOL momentary; // if set, then we don't keep showing selected state after tracking ends. default is NO


// returns last segment pressed. default is STSegmentedControlNoSegment until a segment is pressed. Becomes STSegmentedControlNoSegment again when altering the amount of segments
// the UIControlEventValueChanged action is invoked when the segment changes via a user event. Set to UISegmentedControlNoSegment to turn off selection
@property (nonatomic, readwrite) NSInteger selectedSegmentIndex;
@property (nonatomic, strong, readonly) NSString *currentStatus;
@end
