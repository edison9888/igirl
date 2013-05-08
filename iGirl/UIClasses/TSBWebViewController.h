//
//  TSBWebViewController.h
//  Pocket flea market
//
//  Created by 晋辉 卫 on 2/24/12.
//  Copyright (c) 2012 MobileWoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WebViewToolBar;

@interface TSBWebViewController : UIViewController <UIWebViewDelegate>
{
    IBOutlet UIWebView *_webView;
    
    IBOutlet WebViewToolBar *_toolbar;
    
    BOOL _isFirstClass;
    BOOL fromTab;
    BOOL showShare;
}

@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *showTitle;
@property (assign) BOOL isFirstClass;
@property (assign) BOOL fromTab;
@property (assign) BOOL showShare;
@end
