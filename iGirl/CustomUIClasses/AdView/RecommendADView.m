//
//  RecommendADView.m
//  iAccessories
//
//  Created by zhang on 12-12-18.
//  Copyright (c) 2012年 MobileWoo. All rights reserved.
//

#import "RecommendADView.h"
#import "DataEngine.h"
#import "ImageCacheEngine.h"
#import "Constants+APIRequest.h"
#import "Constants+ErrorCodeDef.h"
#import "Constants+RetrunParamDef.h"

#define AD_IMAGE_TAG 10086

@interface RecommendADView (Private)

- (void)responseDownloadImage:(NSNotification*) notification;

- (void)openAD:(id) sender;
- (void)closeAD:(id) sender;

- (void)refreshADButtonImage;

- (void)startAutoScroll;

@end

@implementation RecommendADView
@synthesize delegate, source;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        needDownloadImage = [[NSMutableArray alloc] init];
        source = [NSString stringWithFormat:@"%p", self];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(responseDownloadImage:)
                                                     name:REQUEST_DOWNLOADFILE_NOTIFICATION_NAME
                                                   object:nil];
        // Initialization code
        if (!adScrollView) {
            adScrollView = [[UIScrollView alloc] initWithFrame:frame];
            [adScrollView setPagingEnabled:YES];
            [adScrollView setShowsHorizontalScrollIndicator:NO];
            [adScrollView setShowsVerticalScrollIndicator:NO];
            [adScrollView setDelegate:self];
            [adScrollView setScrollEnabled:NO];
        }
        [self addSubview:adScrollView];
        if (!closeButton) {
            closeButton = [[UIButton alloc] initWithFrame:CGRectMake(270, 0, 50, frame.size.height)];
            [closeButton setImage:[UIImage imageNamed:@"adViewClose"] forState:UIControlStateNormal];
            [closeButton addTarget:self action:@selector(closeAD:) forControlEvents:UIControlEventTouchUpInside];
            [closeButton setShowsTouchWhenHighlighted:YES];
        }
        [self addSubview:closeButton];
        if (!pageControl) {
            pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(250, 30, 50, 20)];
        }
        [pageControl setContentMode:UIViewContentModeRight];
        [pageControl setHidesForSinglePage:YES];
        [pageControl setUserInteractionEnabled:NO];
        [pageControl setBackgroundColor:[UIColor clearColor]];
        [pageControl setCurrentPage:1];
        [pageControl setNumberOfPages:5];
        [self addSubview:pageControl];
        nowIndex = 0;
    }
    return self;
}

- (void) setAD:(NSMutableArray *) array
{
    adArray = [NSMutableArray arrayWithArray:array];
    for (int i=0; i<[adArray count]; i++) {
        Advertise *ad = [adArray objectAtIndex:i];
        UIButton *adButton = [[UIButton alloc] initWithFrame:CGRectMake((i * 320), 0, 320, 50)];
        
        
        NSString *adImageUrl = [[DataEngine sharedDataEngine] getImageUrlByUUID:ad.uuid];
        NSString *localPath = [[ImageCacheEngine sharedInstance] getImagePathByUrl:adImageUrl];
        if (localPath) {
            [adButton setImage:[UIImage imageWithContentsOfFile:localPath] forState:UIControlStateNormal];
        } else {
            [[DataEngine sharedDataEngine] downloadFileByUrl:adImageUrl
                                                        type:kDownloadFileTypeImage
                                                        from:source];
            [needDownloadImage addObject:adImageUrl];
        }

//        [adButton setTitle:[NSString stringWithFormat:@"button:%d", i] forState:UIControlStateNormal];
        [adButton setTag:AD_IMAGE_TAG + i];
        [adButton addTarget:self action:@selector(openAD:) forControlEvents:UIControlEventTouchUpInside];
        [adScrollView addSubview:adButton];
    }
    [adScrollView setContentSize:CGSizeMake(320 * [adArray count], 50)];
    [self startAutoScroll];
    [pageControl setNumberOfPages:[adArray count]];
    if ([needDownloadImage count] == [adArray count] || [adArray count] == 0) {
        if (delegate) {
            [delegate showAD:NO];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger roundedValue = (NSInteger)round(scrollView.contentOffset.x / 320);
    pageControl.currentPage = roundedValue;
}

- (void)openAD:(id)sender
{
    UIButton *button = (UIButton *) sender;
    if (delegate) {
        Advertise *ad = [adArray objectAtIndex:button.tag - AD_IMAGE_TAG];
        [delegate openAD:ad];
    }
}

- (void)closeAD:(id) sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self removeFromSuperview];
    if (delegate) {
        [delegate closeRecommendADView];
    }
}

- (void)startAutoScroll
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if (adScrollView) {
        [adScrollView scrollRectToVisible:CGRectMake(0, 0, nowIndex * 320, 50) animated:YES];
        nowIndex += 1;
        if (nowIndex > [adArray count]) {
            nowIndex = 1;
        }
        [self performSelector:@selector(startAutoScroll)
                   withObject:nil
                   afterDelay:5];
    }
}

- (void)responseDownloadImage:(NSNotification*) notification
{
    NSDictionary *dictionary = (NSDictionary *)[notification userInfo];
    if (![[dictionary objectForKey:REQUEST_SOURCE_KEY] isEqualToString:source]) {
        return;
    }
//    NSLog(@"notification:%@", notification);
    NSString *imagePath = [dictionary objectForKey:TOUI_PARAM_DOWNLOADFILE_FILEPATH];
    if (imagePath) {
        [self refreshADButtonImage];
    }
}

- (void)refreshADButtonImage
{
    NSMutableArray *downloadedArray = [[NSMutableArray alloc] init];
    for (int i=0; i<[adArray count]; i++) {
        UIButton *button = (UIButton *)[self viewWithTag:AD_IMAGE_TAG + i];
        Advertise *ad = [adArray objectAtIndex:i];
        
        NSString *adImageUrl = [[DataEngine sharedDataEngine] getImageUrlByUUID:ad.uuid];
        NSString *localPath = [[ImageCacheEngine sharedInstance] getImagePathByUrl:adImageUrl];
        if (localPath) {
            [button setImage:[UIImage imageWithContentsOfFile:localPath] forState:UIControlStateNormal];
            [downloadedArray addObject:adImageUrl];
        } else {
            [[DataEngine sharedDataEngine] downloadFileByUrl:adImageUrl
                                                        type:kDownloadFileTypeImage
                                                        from:source];
        }
    }
    [needDownloadImage removeObjectsInArray:downloadedArray];
    if ([needDownloadImage count] != [adArray count]) {
        if (delegate) {
            [delegate showAD:YES];
        }
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}
@end
