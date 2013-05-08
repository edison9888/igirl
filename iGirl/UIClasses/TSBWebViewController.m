//
//  TSBWebViewController.m
//  Pocket flea market
//
//  Created by 晋辉 卫 on 2/24/12.
//  Copyright (c) 2012 MobileWoo. All rights reserved.
//

#import "TSBWebViewController.h"
#import "CustomNavigationBar.h"
#import "WebViewToolBar.h"
#import "CLog.h"
#import "AppDelegate.h"
#import "Share2ViewController.h"

@interface TSBWebViewController()

- (void)moreButtonClick:(id)sender;
- (void)refresh:(id)sender;
- (void)shareClick:(id)sender;
@end

@implementation TSBWebViewController
@synthesize url = _url;
@synthesize showTitle = _showTitle;
@synthesize isFirstClass = _isFirstClass;
@synthesize fromTab;
@synthesize showShare;

- (IBAction)back:(id)sender
{
    if ([self.navigationController.viewControllers objectAtIndex:0] == self) {
        [self dismissModalViewControllerAnimated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)moreButtonClick:(id)sender
{
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate showLeft];
}

- (void)refresh:(id)sender
{
    [_webView reload];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _isFirstClass = NO;
        fromTab = NO;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    CustomNavigationBar *customNavigationBar = (CustomNavigationBar *)self.navigationController.navigationBar;
    
    if (_isFirstClass) {
        UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [moreButton setImage:[UIImage imageNamed:@"recommendMoreButton.png"] forState:UIControlStateNormal];
        [moreButton setImage:[UIImage imageNamed:@"recommendMoreButton_highlight.png"] forState:UIControlStateHighlighted];
        moreButton.frame = CGRectMake(0, 0, 47, 44);
        [moreButton addTarget:self action:@selector(moreButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:moreButton];
    }
    else {
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        // Set the title to use the same font and shadow as the standard back button
        cancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
        cancelButton.titleLabel.textColor = [UIColor whiteColor];
        cancelButton.titleLabel.shadowOffset = CGSizeMake(0,-1);
        cancelButton.titleLabel.shadowColor = [UIColor darkGrayColor];
        // Set the break mode to truncate at the end like the standard back button
        cancelButton.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
        // Inset the title on the left and right
        cancelButton.titleEdgeInsets = UIEdgeInsetsMake(0, 6.0, 0, 3.0);
        // Make the button as high as the passed in image
        cancelButton.frame = CGRectMake(0, 0, 48, 28);
        
        if ([self.navigationController.viewControllers objectAtIndex:0] == self) {
            [cancelButton setBackgroundImage:[[UIImage imageNamed:@"navigationBarButton.png"] stretchableImageWithLeftCapWidth:20.0 topCapHeight:16.0] forState:UIControlStateNormal];
            [cancelButton setBackgroundImage:[[UIImage imageNamed:@"navigationBarButton_selected.png"] stretchableImageWithLeftCapWidth:20.0 topCapHeight:16.0] forState:UIControlStateHighlighted];
            [customNavigationBar setText:[customNavigationBar closeText] onBackButton:cancelButton leftCapWidth:20.0];
        } else {
            [cancelButton setBackgroundImage:[[UIImage imageNamed:@"navigationBarBackButton.png"] stretchableImageWithLeftCapWidth:20.0 topCapHeight:16.0] forState:UIControlStateNormal];
            [cancelButton setBackgroundImage:[[UIImage imageNamed:@"navigationBarBackButton_selected.png"] stretchableImageWithLeftCapWidth:20.0 topCapHeight:16.0] forState:UIControlStateHighlighted];
            [customNavigationBar setText:[customNavigationBar onlyBackText] onBackButton:cancelButton leftCapWidth:20];
        }

        [cancelButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:cancelButton];
    }
    if (fromTab) {
        self.navigationItem.leftBarButtonItem = NO;
        [_toolbar removeFromSuperview];
        _webView.frame = self.view.bounds;
        
        // 刷新按钮
        UIButton *refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        // Set the title to use the same font and shadow as the standard back button
        refreshButton.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
        refreshButton.titleLabel.textColor = [UIColor whiteColor];
        refreshButton.titleLabel.shadowOffset = CGSizeMake(0,-1);
        refreshButton.titleLabel.shadowColor = [UIColor darkGrayColor];
        // Set the break mode to truncate at the end like the standard back button
        refreshButton.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
        // Inset the title on the left and right
        refreshButton.titleEdgeInsets = UIEdgeInsetsMake(0, 6.0, 0, 3.0);
        // Make the button as high as the passed in image
        refreshButton.frame = CGRectMake(0, 0, 48, 28);
        [refreshButton setBackgroundImage:[[UIImage imageNamed:@"navigationBarButton.png"] stretchableImageWithLeftCapWidth:20.0 topCapHeight:16.0] forState:UIControlStateNormal];
        [refreshButton setBackgroundImage:[[UIImage imageNamed:@"navigationBarButton_selected.png"] stretchableImageWithLeftCapWidth:20.0 topCapHeight:16.0] forState:UIControlStateHighlighted];
        [customNavigationBar setText:NSLocalizedString(@"刷新", @"") onBackButton:refreshButton leftCapWidth:20.0];
        [refreshButton addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:refreshButton];
    } else {
        _toolbar.webView = _webView;
        if (showShare) {
            UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [shareButton setBackgroundImage:[[UIImage imageNamed:@"favouriteButton.png"] stretchableImageWithLeftCapWidth:20.0 topCapHeight:16.0] forState:UIControlStateNormal];
            [shareButton setBackgroundImage:[[UIImage imageNamed:@"favouriteButton_selected.png"] stretchableImageWithLeftCapWidth:20.0 topCapHeight:16.0] forState:UIControlStateHighlighted];
            // Set the title to use the same font and shadow as the standard back button
            shareButton.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
            shareButton.titleLabel.textColor = [UIColor whiteColor];
            shareButton.titleLabel.shadowOffset = CGSizeMake(0,-1);
            shareButton.titleLabel.shadowColor = [UIColor darkGrayColor];
            // Set the break mode to truncate at the end like the standard back button
            shareButton.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
            // Inset the title on the left and right
            shareButton.titleEdgeInsets = UIEdgeInsetsMake(0, 6.0, 0, 3.0);
            // Make the button as high as the passed in image
            shareButton.frame = CGRectMake(0, 0, 48, 28);
            [customNavigationBar setText:NSLocalizedString(@"分享", @"") onBackButton:shareButton leftCapWidth:20.0];
            [shareButton addTarget:self action:@selector(shareClick:) forControlEvents:UIControlEventTouchUpInside];
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:shareButton];
        }
    }
    
    self.navigationItem.title = _showTitle;
    
    
    _webView.clipsToBounds = NO;
    for (UIView *subview in _webView.subviews) {
        if ([subview isKindOfClass:[UIScrollView class]]) {
            subview.clipsToBounds = NO;
        }
    }
    
    NSURL *url = nil;
    NSString *lower = [_url lowercaseString];
    if ([lower hasPrefix:@"http://"] || [lower hasPrefix:@"https://"]) {
        url = [NSURL URLWithString:_url];
    } else if ([lower rangeOfString:@"://"].length > 0) {
        url = [NSURL URLWithString:_url];
    }
    else {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", _url]];
    }
    
    NSMutableURLRequest *theRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [_webView loadRequest:theRequest];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *url = [request.URL.absoluteString lowercaseString];
    if ([url hasPrefix:@"http"] || [url hasPrefix:@"https"]) {
        if ([url hasPrefix:@"http://itunes.apple.com"] || [url hasPrefix:@"https://itunes.apple.com"]) {
            [[UIApplication sharedApplication] openURL:request.URL];
            return NO;
        }
        else {
            return YES;
        }
    }
    else {
        if ([[UIApplication sharedApplication] canOpenURL:request.URL]) {
            [[UIApplication sharedApplication] openURL:request.URL];
        }
        return NO;
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webViewParam
{
    NSString *requestUrl = [NSString stringWithFormat:@"%@", webViewParam.request.URL];
    NSString *strCharacter = @"?";
    NSRange range = [requestUrl rangeOfString:strCharacter];
    if (range.location != NSNotFound) {
        NSString *realUrl = [requestUrl substringToIndex:range.location];
        [MobClick event:@"WebView" label:realUrl];
        [UBAnalysis event:@"WebView" label:realUrl];
    } else if (requestUrl && [requestUrl length] > 0 && ![requestUrl isEqualToString:@""]) {
        [MobClick event:@"WebView" label:requestUrl];
        [UBAnalysis event:@"WebView" label:requestUrl];
    }

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	[_toolbar setLoadingRequest];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    // 消除缓冲标志
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [_toolbar setIdle];
    NSString *webViewTitle = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    if (!self.showTitle || [self.showTitle isEqualToString:@""]) {
        // 如果标题是空，显示网页的标题
        self.showTitle = webViewTitle;
        self.navigationItem.title = self.showTitle;
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [_toolbar setIdle];
}

- (void)shareClick:(id)sender
{
    [MobClick event:@"WebView" label:@"点击分享"];
    [UBAnalysis event:@"WebView" label:@"点击分享"];
    
    Share2ViewController *share = [[Share2ViewController alloc] initWithNibName:@"Share2ViewController" bundle:nil];
    share.shareText = self.showTitle;
    share.shareLink = _url;
    [self.navigationController pushViewController:share animated:YES];
}

@end
