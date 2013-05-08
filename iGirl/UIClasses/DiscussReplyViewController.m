//
//  DiscussReplyViewController.m
//  iAccessories
//
//  Created by zhang on 13-3-29.
//  Copyright (c) 2013年 MobileWoo. All rights reserved.
//

#import "DiscussReplyViewController.h"
#import "CustomNavigationBar.h"
#import "Constants.h"
#import "Constants+APIRequest.h"
#import "Constants+ErrorCodeDef.h"
#import "DataEngine.h"
#import "AppDelegate.h"

#define CONTENTVIEW_TEXT @"发表一下你的意见"
#define REPLY_NICK_NAME @"discuss_reply_nick_name"

@interface DiscussReplyViewController ()
- (void)canSubmitDetect;
- (void)back:(id)sender;
- (void)submit:(id)sender;

- (void)responseReplyDiscuss:(NSNotification *)notification;
@end

@implementation DiscussReplyViewController
@synthesize discussId;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        discussId = [NSNumber numberWithInt:0];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _controllerId = [NSString stringWithFormat:@"%p", self];
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(responseReplyDiscuss:)
                                                 name:REQUEST_REPLYDISCUSS
                                               object:nil];

    CustomNavigationBar* customNavigationBar = (CustomNavigationBar*)self.navigationController.navigationBar;
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setBackgroundImage:[[UIImage imageNamed:@"navigationBarBackButton.png"] stretchableImageWithLeftCapWidth:20.0 topCapHeight:16.0] forState:UIControlStateNormal];
    [backButton setBackgroundImage:[[UIImage imageNamed:@"navigationBarBackButton_selected.png"] stretchableImageWithLeftCapWidth:20.0 topCapHeight:16.0] forState:UIControlStateHighlighted];
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
    [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [customNavigationBar setText:[customNavigationBar onlyBackText] onBackButton:backButton leftCapWidth:20.0];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:backButton];

    UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [submitButton setBackgroundImage:[[UIImage imageNamed:@"navigationBarButton.png"] stretchableImageWithLeftCapWidth:20.0 topCapHeight:16.0] forState:UIControlStateNormal];
    [submitButton setBackgroundImage:[[UIImage imageNamed:@"navigationBarButton_selected.png"] stretchableImageWithLeftCapWidth:20.0 topCapHeight:16.0] forState:UIControlStateHighlighted];
    // Set the title to use the same font and shadow as the standard back button
    submitButton.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
    submitButton.titleLabel.textColor = [UIColor whiteColor];
    submitButton.titleLabel.shadowOffset = CGSizeMake(0,-1);
    submitButton.titleLabel.shadowColor = [UIColor darkGrayColor];
    // Set the break mode to truncate at the end like the standard back button
    submitButton.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
    // Inset the title on the left and right
    submitButton.titleEdgeInsets = UIEdgeInsetsMake(0, 6.0, 0, 3.0);
    // Make the button as high as the passed in image
    submitButton.frame = CGRectMake(0, 0, 48, 28);
    [submitButton addTarget:self action:@selector(submit:) forControlEvents:UIControlEventTouchUpInside];
    [customNavigationBar setText:[NSString stringWithFormat:NSLocalizedString(@"提交", @"")] onBackButton:submitButton leftCapWidth:20.0];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:submitButton];

    self.navigationItem.title = NSLocalizedString(@"回复主题", @"");
    [contentTextView becomeFirstResponder];
    [self canSubmitDetect];
    nickNameTextField.returnKeyType = UIReturnKeyNext;
    contentTextView.returnKeyType = UIReturnKeyDone;
    nickNameTextField.text = [[NSUserDefaults standardUserDefaults] objectForKey:REPLY_NICK_NAME];
}

- (void)back:(id)sender
{
    [nickNameTextField resignFirstResponder];
    [contentTextView resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)submit:(id)sender
{
    [nickNameTextField resignFirstResponder];
    [contentTextView resignFirstResponder];
    [[NSUserDefaults standardUserDefaults] setObject:(nickNameTextField.text ? nickNameTextField.text : @"") forKey:REPLY_NICK_NAME];
    [[NSUserDefaults standardUserDefaults] synchronize];
    DataEngine *dataEngine = [DataEngine sharedDataEngine];
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate showActivityView:NSLocalizedString(@"正在提交", @"") inView:delegate.window];
    [dataEngine replyDiscuss:discussId
                        nick:nickNameTextField.text
                     content:contentTextView.text
                        from:_controllerId];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"]) {
        [nickNameTextField resignFirstResponder];
        [contentTextView becomeFirstResponder];
        return NO;
    }
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([contentTextView.text isEqualToString:CONTENTVIEW_TEXT]) {
        contentTextView.text = @"";
        [contentTextView setTextColor:[UIColor blackColor]];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [contentTextView resignFirstResponder];
        return NO;
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(canSubmitDetect) object:nil];
    [self performSelector:@selector(canSubmitDetect) withObject:nil afterDelay:0.1];
    
    return YES;
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    if ([contentTextView.text isEqualToString:@""]) {
        contentTextView.text = CONTENTVIEW_TEXT;
        [contentTextView setTextColor:[UIColor grayColor]];
    }
}

- (void)canSubmitDetect
{
    if ([contentTextView.text length] > 0) {
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
    } else {
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
    }
}

- (void)responseReplyDiscuss:(NSNotification *)notification
{
    NSDictionary *dictionary = (NSDictionary *)[notification userInfo];
    if (![[dictionary objectForKey:REQUEST_SOURCE_KEY] isEqualToString:_controllerId]) {
        return;
    }

    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSNumber *returnCode = [dictionary objectForKey:RETURN_CODE];
    if (returnCode && [returnCode isKindOfClass:[NSNumber class]] && [returnCode intValue] == NO_ERROR) {
        [delegate showFinishActivityView:NSLocalizedString(@"回复成功!", @"") interval:ERROR_MESSAGE_SHOW_INTERVAL_NORMAL inView:delegate.window];
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        NSString *errorText = [dictionary objectForKey:TOUI_REQUEST_ERROR_MESSAGE];
        [delegate showFailedActivityView:errorText interval:ERROR_MESSAGE_SHOW_INTERVAL_LONG inView:delegate.window];
        [contentTextView becomeFirstResponder];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}
@end
