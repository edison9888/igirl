
#import <UIKit/UIKit.h>

@interface WebViewToolBar : UIToolbar
{
    __unsafe_unretained UIWebView *_webView;
}

@property (nonatomic, assign) UIWebView *webView;

-(void) setLoadingRequest;
-(void) setIdle;

@end
