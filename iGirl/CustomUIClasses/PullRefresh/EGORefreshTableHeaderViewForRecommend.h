#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

typedef enum{
	EGOOPullRefreshPullingForRecommend = 0,
	EGOOPullRefreshNormalForRecommend,
	EGOOPullRefreshLoadingForRecommend,	
    EGOOPullRefreshIdleForRecommend,
} EGOPullRefreshStateForRecommend;

@protocol EGORefreshTableHeaderViewForRecommendDelegate;
@interface EGORefreshTableHeaderViewForRecommend : UIView {
	
	id __unsafe_unretained _delegate;
	EGOPullRefreshStateForRecommend _state;

	UILabel *_lastUpdatedLabel;
	UILabel *_statusLabel;
	CALayer *_arrowImage;
	UIActivityIndicatorView *_activityView;
	

}

@property(nonatomic,assign) id <EGORefreshTableHeaderViewForRecommendDelegate> delegate;

- (id)initWithFrame:(CGRect)frame arrowImageName:(NSString *)arrow textColor:(UIColor *)textColor;

- (void)refreshLastUpdatedDate;
- (void)egoRefreshScrollViewDidScroll:(UIScrollView *)scrollView;
- (void)egoRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView;
- (void)egoRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView;
- (void)egoRefreshScrollViewDidEndDecelerating:(UIScrollView *)scrollView;

@end
@protocol EGORefreshTableHeaderViewForRecommendDelegate
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderViewForRecommend*)view;
- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderViewForRecommend*)view;
@optional
- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderViewForRecommend*)view;
@end
