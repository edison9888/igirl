//
//  ITSegmentedControl.h
//  ITSegmentedControl
//
//  Version: 1.0
//
//  Created by Cedric Vandendriessche on 10/11/10.
//  Copyright 2010 FreshCreations. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ITSEGMENTEDCONTROLIMAGE                 @"segmentedControlImage"
#define ITSEGMENTEDCONTROLSELECTEDIMAGE         @"segmentedControlSelectedImage"
#define ITSEGMENTEDCONTROLTITLE                 @"segmentedControlTitle"
#define ITSEGMENTEDCONTROLTITLENORMALCOLOR      @"segmentedControlTitleNormalColor"
#define ITSEGMENTEDCONTROLTITLESELECTEDCOLOR    @"segmentedControlTitleSelectedColor"



enum {
    ITSegmentedControlNoSegment = -1 // segment index for no selected segment
};

@interface ITSegmentedControl : UIControl {
	NSMutableArray *segments;
	UIImage *normalImageLeft;
	UIImage *normalImageMiddle;
	UIImage *normalImageRight;
	UIImage *selectedImageLeft;
	UIImage *selectedImageMiddle;
	UIImage *selectedImageRight;
	NSUInteger numberOfSegments;
	NSInteger selectedSegmentIndex;
	BOOL programmaticIndexChange;
	BOOL momentary;
    float fontSize;
}

- (id)initWithItems:(NSArray *)items; // items can be NSStrings or UIImages.

- (void)insertSegmentWithTitle:(NSString *)title atIndex:(NSUInteger)index; // insert before segment number
- (void)insertSegmentWithImage:(UIImage *)image atIndex:(NSUInteger)index;
- (void)removeSegmentAtIndex:(NSUInteger)index;
- (void)removeAllSegments;

- (void)setTitle:(NSString *)title forSegmentAtIndex:(NSUInteger)index;
- (NSString *)titleForSegmentAtIndex:(NSUInteger)index;

- (void)setImage:(UIImage *)image forSegmentAtIndex:(NSUInteger)index;
- (UIImage *)imageForSegmentAtIndex:(NSUInteger)index;

- (void)setImageAndTitle:(UIImage *)image 
           selectedImage:(UIImage *)selectedImage 
                   title:(NSString *)title 
        normalTitleColor:(UIColor *)normalTitleColor
      selectedTitleColor:(UIColor *)selectedTitleColor
       forSegmentAtIndex:(NSUInteger)index;

@property (nonatomic, retain) NSMutableArray *segments; // at least two (2) NSStrings are needed for a ITSegmentedControl to be displayed
@property (nonatomic, retain) UIImage *normalImageLeft;
@property (nonatomic, retain) UIImage *normalImageMiddle;
@property (nonatomic, retain) UIImage *normalImageRight;
@property (nonatomic, retain) UIImage *selectedImageLeft;
@property (nonatomic, retain) UIImage *selectedImageMiddle;
@property (nonatomic, retain) UIImage *selectedImageRight;
@property (nonatomic, readonly) NSUInteger numberOfSegments;
@property (nonatomic, getter=isMomentary) BOOL momentary; // if set, then we don't keep showing selected state after tracking ends. default is NO

// returns last segment pressed. default is ITSegmentedControlNoSegment until a segment is pressed. Becomes ITSegmentedControlNoSegment again when altering the amount of segments
// the UIControlEventValueChanged action is invoked when the segment changes via a user event. Set to UISegmentedControlNoSegment to turn off selection
@property (nonatomic, readwrite) NSInteger selectedSegmentIndex;

@property (assign) float fontSize;

@end
