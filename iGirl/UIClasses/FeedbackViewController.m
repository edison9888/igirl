//
//  FeedbackViewController.m
//  trover
//
//  Created by skye on 8/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FeedbackViewController.h"
#import "CustomPlaceholderTextview.h"
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"
#import "CustomNavigationBar.h"
#import "DataEngine.h"
#import "AppDelegate.h"
#import "ErrorCodeUtils.h"

@implementation FeedbackViewController

- (void)responseFeedback:(NSNotification *)notification
{
    NSDictionary *dictionary = (NSDictionary *)[notification userInfo];
    if (![[dictionary objectForKey:REQUEST_SOURCE_KEY] isEqualToString:_controllerId]) {
        return;
    }
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSNumber *returnCode = [dictionary objectForKey:RETURN_CODE];
    if (returnCode && [returnCode isKindOfClass:[NSNumber class]] && [returnCode intValue] == 0) {
        [delegate showFinishActivityView:NSLocalizedString(@"提交反馈成功！", @"") interval:1.5 inView:delegate.window];
        // 跳出此页
        [self performSelector:@selector(cancelWhenFeedBackFinished:) withObject:nil afterDelay:0.3];
    } else {
        [delegate showFailedActivityView:[dictionary objectForKey:TOUI_REQUEST_ERROR_MESSAGE] interval:ERROR_MESSAGE_SHOW_INTERVAL_LONG inView:delegate.window];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    //    [UBAnalysis event:@"FeedbackView" label:@"Enter"];
    // Do any additional setup after loading the view from its nib.
    if (_controllerId == nil || [_controllerId length] == 0) {
        _controllerId = [[NSString alloc] initWithFormat:@"%p", self];
    }
    
    [feedbackBg setImage:[UIImage imageNamed:@"feedback_bg.png"]];
    
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
    cancelButton.titleEdgeInsets = UIEdgeInsetsMake(0, 6.0, 0, 3.0);
    // Make the button as high as the passed in image
    cancelButton.frame = CGRectMake(0, 0, 48, 28);
    [customNavigationBar setText:[customNavigationBar onlyBackText] onBackButton:cancelButton leftCapWidth:20.0];
    [cancelButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:cancelButton];
    
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneButton setBackgroundImage:[[UIImage imageNamed:@"favouriteButton.png"] stretchableImageWithLeftCapWidth:14.0 topCapHeight:13.0] forState:UIControlStateNormal];
    [doneButton setBackgroundImage:[[UIImage imageNamed:@"favouriteButton_selected.png"] stretchableImageWithLeftCapWidth:14.0 topCapHeight:13.0] forState:UIControlStateHighlighted];
    
    [doneButton setTitleColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.3] forState:UIControlStateDisabled];
    // Set the title to use the same font and shadow as the standard back button
    doneButton.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
    doneButton.titleLabel.textColor = [UIColor whiteColor];
    doneButton.titleLabel.shadowOffset = CGSizeMake(0,-1);
    doneButton.titleLabel.shadowColor = [UIColor darkGrayColor];
    // Set the break mode to truncate at the end like the standard back button
    doneButton.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
    // Inset the title on the left and right
    doneButton.titleEdgeInsets = UIEdgeInsetsMake(0, 6.0, 0, 3.0);
    // Make the button as high as the passed in image
    doneButton.frame = CGRectMake(0, 0, 48, 28);
    [customNavigationBar setText:NSLocalizedString(@"发送", @"") onBackButton:doneButton leftCapWidth:20.0];
    [doneButton addTarget:self action:@selector(next:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:doneButton];
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    self.navigationItem.title = NSLocalizedString(@"意见反馈", @"");
    // 设置view的背景图
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"mainBackground.png"]];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(responseFeedback:)
                                                 name:REQUEST_FEEDBACK
                                               object:nil];
    
    [feedbackTextView setTextColor:[UIColor colorWithRed:90.f / 255.f green:90.f / 255.f blue:90.f / 255.f alpha:1]];
//    [feedbackTextView.layer setBackgroundColor: [[UIColor whiteColor] CGColor]];
//    [feedbackTextView.layer setBorderColor: [[UIColor grayColor] CGColor]];
//    [feedbackTextView.layer setBorderWidth: 1.0];
//    [feedbackTextView.layer setCornerRadius:8.0f];
//    [feedbackTextView.layer setMasksToBounds:YES];
//    [feedbackTextView setClipsToBounds:YES];
    feedbackTextView.delegate = self;
    feedbackTextView.placeholder = NSLocalizedString(@"亲,欢迎您留下宝贵的建议。", @"");
    
    _contactField.delegate = self;
    [_contactBg setImage:[UIImage imageNamed:@"feedback_email.png"]];
    _contactField.placeholder = NSLocalizedString(@"联系方式(手机/QQ/邮箱)", @"");
    [_contactField becomeFirstResponder];
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
    //    [UBAnalysis event:@"FeedbackView" label:@"Show"];
    
//    AppDelegate *delegate= (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    delegate.viewDeckController.panningGestureDelegate = self;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    //    [UBAnalysis event:@"FeedbackView" label:@"Hidden"];
    
//    AppDelegate *delegate= (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    delegate.viewDeckController.panningGestureDelegate = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(canDoNextDetect) object:nil];
    [self performSelector:@selector(canDoNextDetect) withObject:nil afterDelay:0.1];
    
    return TRUE;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    [_contactField resignFirstResponder];
    [feedbackTextView resignFirstResponder];
    return YES;
}

- (BOOL)canDoNextDetect
{
    if ([feedbackTextView.text length] > 0) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
        return TRUE;
    }
    else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
        return FALSE;
    }
}

- (IBAction)next:(id)sender
{
    [_contactField resignFirstResponder];
    [feedbackTextView resignFirstResponder];
    AppDelegate *delegate= (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate showActivityView:NSLocalizedString(@"正在提交反馈...", @"") inView:delegate.window];
    DataEngine *dataEngine = [DataEngine sharedDataEngine];
    [dataEngine feedback:feedbackTextView.text
                   email:_contactField.text
                    from:_controllerId];
}

- (IBAction)cancel:(id)sender
{
    //    [UBAnalysis event:@"FeedbackView" label:@"Back"];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) cancelWhenFeedBackFinished:(id)sender
{
    //    [UBAnalysis event:@"FeedbackView" label:@"FeedbackSuccess"];
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [feedbackTextView performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.01];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(canDoNextDetect) object:nil];
    [self performSelector:@selector(canDoNextDetect) withObject:nil afterDelay:0.1];
    
    return TRUE;
}

@end
