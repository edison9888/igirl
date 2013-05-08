//
//  RecommendScrollController.h
//  iTBK
//
//  Created by 王 兆琦 on 12-9-28.
//
//

#import <UIKit/UIKit.h>
#import "DiscountView.h"

@class DiscountScrollController;

@interface DiscountScrollController : UIViewController <UIScrollViewDelegate, DiscountViewDelegate>
{
    IBOutlet UIImageView            *_discountViewBg;
    //页面id
    NSString                        *_controllerId;
    //页面title
    NSString                        *_showTitle;
    //推广数据
    NSArray                         *_currentArray;
    //主显示页面
    IBOutlet UIScrollView           *_scrollView;
    //scroll view 滚动时记录的点
    CGPoint                         _point;
    
    NSTimer                         *_timer;
}

@property (nonatomic, copy) NSString *showTitle;

@end
