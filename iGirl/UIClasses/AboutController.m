//
//  AboutController.m
//  ThreeHundred
//
//  Created by 郭雪 on 11-12-30.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "AboutController.h"
#import "CustomNavigationBar.h"
#import "Constants.h"

@implementation AboutController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    //    [UBAnalysis event:@"About" label:@"Enter"];
    // Do any additional setup after loading the view from its nib.
    CustomNavigationBar* customNavigationBar = (CustomNavigationBar*)self.navigationController.navigationBar;
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setBackgroundImage:[[UIImage imageNamed:@"navigationBarBackButton.png"] stretchableImageWithLeftCapWidth:20.0 topCapHeight:16.0] forState:UIControlStateNormal];
    [cancelButton setBackgroundImage:[[UIImage imageNamed:@"navigationBarBackButton_selected.png"] stretchableImageWithLeftCapWidth:20.0 topCapHeight:16.0] forState:UIControlStateHighlighted];
    // Set the title to use the same font and shadow as the standard back button
    cancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
    cancelButton.titleLabel.textColor = [UIColor whiteColor];
    cancelButton.titleLabel.shadowOffset = CGSizeMake(0,-1);
    cancelButton.titleLabel.shadowColor = [UIColor darkGrayColor];
    // Set the break mode to truncate at the end like the standard back button
    cancelButton.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
    // Inset the title on the left and right
    //cancelButton.titleEdgeInsets = UIEdgeInsetsMake(0, 6.0, 0, 3.0);
    // Make the button as high as the passed in image
    cancelButton.frame = CGRectMake(0, 0, 48, 28);
    [customNavigationBar setText:[customNavigationBar onlyBackText] onBackButton:cancelButton leftCapWidth:20.0];
    [cancelButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:cancelButton];
    
    self.navigationItem.title = NSLocalizedString(@"关于我们", @"");
    // 设置view的背景图
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"mainBackground.png"]];
    
    //版本号
    [versionBg setImage:[UIImage imageNamed:@"about_icon.png"]];
    
    // 版本号
    NSDictionary *infoPlist = [[NSBundle mainBundle] localizedInfoDictionary];
    [versionWords setText:[[NSString alloc] initWithFormat:@"版本 V%@", [[[NSBundle mainBundle] infoDictionary]  objectForKey:@"CFBundleVersion"]]];
    [versionWords setTextColor:[UIColor colorWithRed:156.0 / 255.0 green:156.0  / 255.0 blue:156.0  / 255.0 alpha:1.0]];
    [versionWords setFont:[UIFont systemFontOfSize:12]];
    versionWords.textAlignment = UITextAlignmentCenter;
    
    // 应用名称
    [versionNumbers setText:[infoPlist objectForKey:NSLocalizedString(@"CFBundleDisplayName", @"")]];
    [versionNumbers setTextColor:[UIColor colorWithRed:60.0 / 255.0 green:60.0  / 255.0 blue:60.0  / 255.0 alpha:1.0]];
    [versionNumbers setFont:[UIFont systemFontOfSize:15]];
    versionNumbers.textAlignment = UITextAlignmentCenter;
    
    detailLabel.delegate = self;
    [detailLabel setFont:[UIFont systemFontOfSize:13]];
    [detailLabel setParagraphReplacement:@""];
    [detailLabel setTextColor:[UIColor darkGrayColor]];
    [detailLabel setText:NSLocalizedString(@"在网络信息过剩的时代，我们为你提供最有价值的原创时尚精品阅读！在这里，你能够第一时间获得时尚最新动态、简单实用的潮流指南、震撼人心的视觉享受。所有作品均由国内最优秀的时尚媒体编辑团队策划，并针对移动互联网用户阅读习惯来打造，为你带来时尚和视觉的双重盛宴。", @"")];

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
    //    [UBAnalysis event:@"About" label:@"Show"];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    //    [UBAnalysis event:@"About" label:@"Hidden"];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction) cancel:(id)sender
{
    //    [UBAnalysis event:@"About" label:@"Back"];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rtLabel:(id)rtLabel didSelectLinkWithURL:(NSURL*)url
{
    [[UIApplication sharedApplication] openURL:url];
}

@end
