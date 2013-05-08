//
//  DiscussDetailViewController.m
//  iAccessories
//
//  Created by zhang on 13-3-29.
//  Copyright (c) 2013年 MobileWoo. All rights reserved.
//

#import "DiscussDetailViewController.h"
#import "DiscussReplyViewController.h"
#import "CustomNavigationBar.h"
#import "Constants.h"

@interface DiscussDetailViewController ()
- (void)close:(id)sender;
- (void)responseReplyDiscuss:(NSNotification *)notification;
@end

@implementation DiscussDetailViewController

@synthesize discussId, discussDetailUrl;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [MobClick event:@"讨论区详情页" label:@"进入页面"];
    [UBAnalysis event:@"讨论区详情页" label:@"进入页面"];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(responseReplyDiscuss:)
                                                 name:REQUEST_REPLYDISCUSS
                                               object:nil];
    CustomNavigationBar* customNavigationBar = (CustomNavigationBar*)self.navigationController.navigationBar;
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setBackgroundImage:[[UIImage imageNamed:@"navigationBarButton.png"] stretchableImageWithLeftCapWidth:20.0 topCapHeight:16.0] forState:UIControlStateNormal];
    [backButton setBackgroundImage:[[UIImage imageNamed:@"navigationBarButton_selected.png"] stretchableImageWithLeftCapWidth:20.0 topCapHeight:16.0] forState:UIControlStateHighlighted];
    // Set the title to use the same font and shadow as the standard back button
    backButton.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
    backButton.titleLabel.textColor = [UIColor whiteColor];
    backButton.titleLabel.shadowOffset = CGSizeMake(0,-1);
    backButton.titleLabel.shadowColor = [UIColor darkGrayColor];
    // Set the break mode to truncate at the end like the standard back button
    backButton.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
    // Inset the title on the left and right
    backButton.titleEdgeInsets = UIEdgeInsetsMake(0, 6.0, 0, 3.0);
    // Make the button as high as the passed in image
    backButton.frame = CGRectMake(0, 0, 48, 28);
    [backButton addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
    [customNavigationBar setText:[customNavigationBar closeText] onBackButton:backButton leftCapWidth:20.0];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:backButton];
    
    self.navigationItem.title = NSLocalizedString(@"讨论详情", @"");
    if (discussDetailUrl && [discussDetailUrl isKindOfClass:[NSString class]] && ![discussDetailUrl isEqualToString:@""]) {
        NSURL *url = [[NSURL alloc] initWithString:discussDetailUrl];
        [discussDetailWebView loadRequest:[[NSURLRequest alloc] initWithURL:url]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)replyButtonClick:(id)sender
{
    [MobClick event:@"讨论区详情页" label:@"点击回复"];
    [UBAnalysis event:@"讨论区详情页" label:@"点击回复"];

    DiscussReplyViewController *reply = [[DiscussReplyViewController alloc] initWithNibName:@"DiscussReplyViewController" bundle:nil];
    reply.discussId = discussId;
    [self.navigationController pushViewController:reply animated:YES];
}

- (void)close:(id)sender
{
    [[self parentViewController] dismissModalViewControllerAnimated:true];
}

- (void)responseReplyDiscuss:(NSNotification *)notification
{
    [discussDetailWebView reload];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [MobClick beginLogPageView:@"讨论区详情页"];
    [MobClick event:@"讨论区详情页" label:@"页面显示"];
    [UBAnalysis event:@"讨论区详情页" label:@"页面显示"];
    [UBAnalysis startTracPage:@"讨论区详情页" labels:0];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [MobClick endLogPageView:@"讨论区详情页"];
    [MobClick event:@"讨论区详情页" label:@"页面隐藏"];
    [UBAnalysis event:@"讨论区详情页" label:@"页面隐藏"];
    [UBAnalysis endTracPage:@"讨论区详情页" labels:0];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}
@end
