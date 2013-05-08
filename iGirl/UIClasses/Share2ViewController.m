//
//  Share2ViewController.m
//  iAccessories
//
//  Created by zhang on 13-4-19.
//  Copyright (c) 2013年 MobileWoo. All rights reserved.
//

#import "Share2ViewController.h"
#import "CustomNavigationBar.h"
#import "DataEngine.h"
#import "Constants+APIRequest.h"
#import "Constants+ErrorCodeDef.h"
#import "Constants.h"
#import "OAuth.h"
#import "User.h"
#import "UIAlertView+Blocks.h"
#import "AppDelegate.h"
#import "LocalSettings.h"
#import "ShareTemplate.h"
#import "ImageCacheEngine.h"
#import "UBAnalysis.h"



#define DESCRIPTION_MAX_LENGTH          100
#define DESCRIPTION_TIP_LENGTH          3
#define SHARE_TEMPLATE_TAG 20000
#define ITEM_TEXT_HEIGHT 120
#define ITEM_TEXT_HEIGHT_TOP 82
#define ITEM_SHARE_Y 154
#define ITEM_SHARE_Y_TOP 122

@interface Share2ViewController ()
- (void)responseShare:(NSNotification*) notification;
- (void)submit:(id) sender;
- (IBAction)clearShareText:(id)sender;

@end

@implementation Share2ViewController
@synthesize shareText, shareLink;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
                self.navigationItem.title = NSLocalizedString(@"分享到新浪微博", @"");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [MobClick event:@"分享页面" label:@"进入页面"];
    [UBAnalysis event:@"分享页面" label:@"进入页面"];

    // Do any additional setup after loading the view from its nib.
    _controllerId = [[NSString alloc] initWithFormat:@"%p", self];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(responseShare:)
                                                 name:REQUEST_SHARETOWEB
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(responseSinaUserInfo:)
                                                 name:REQUEST_SINAWEIBOUSERINFO
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(responseUserLogin:)
                                                 name:REQUEST_OAUTHLOGIN
                                               object:nil];
    CustomNavigationBar* customNavigationBar = (CustomNavigationBar*)self.navigationController.navigationBar;
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setBackgroundImage:[[UIImage imageNamed:@"navigationBarBackButton.png"] stretchableImageWithLeftCapWidth:20.0 topCapHeight:16.0] forState:UIControlStateNormal];
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
    [customNavigationBar setText:NSLocalizedString(@"提交", @"") onBackButton:submitButton leftCapWidth:20.0];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:submitButton];
    shareTextView.text = shareText;
    [self textViewDidChange:shareTextView];
    [shareTextView becomeFirstResponder];
    [DataEngine sharedDataEngine].isInShareViewController = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clearShareText:(id)sender
{
    [shareTextView setText:@""];
    [self textViewDidChange:shareTextView];
}

# pragma mark - response notification

- (void)responseSinaUserInfo:(NSNotification *)notification
{
    NSDictionary *dict = [notification userInfo];
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSNumber *returnCode = [dict objectForKey:RETURN_CODE];
    if (returnCode && [returnCode isKindOfClass:[NSNumber class]] && [returnCode intValue] == 0) {
        [delegate hideActivityView:delegate.window];
        SinaOAuth *sinaOauth = [dict objectForKey:TOUI_PARAM_SINA_USERINFO_OAUTHINFO];
        RIButtonItem *cancelButton = [[RIButtonItem alloc] init];
        [cancelButton setLabel:NSLocalizedString(@"取消", @"")];
        [cancelButton setAction:^{
            [[DataEngine sharedDataEngine] oauthLogin:sinaOauth followZb:0 isAutoLogin:NO from:_controllerId];
            [delegate showActivityView:@"正在登录，请稍侯..." inView:delegate.window];
        }];
        RIButtonItem *okButton = [[RIButtonItem alloc] init];
        [okButton setLabel:NSLocalizedString(@"关注", @"")];
        [okButton setAction:^{
            [[DataEngine sharedDataEngine] oauthLogin:sinaOauth followZb:1 isAutoLogin:NO from:_controllerId];
            [delegate showActivityView:@"正在登录，请稍侯..." inView:delegate.window];
        }];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"您是否要关注爱配件官方微博?", @"")
                                                        message:@""
                                               cancelButtonItem:cancelButton
                                               otherButtonItems:okButton, nil];
        [alert show];
    } else {
        [delegate showFailedActivityView:[dict objectForKey:TOUI_REQUEST_ERROR_MESSAGE] interval:ERROR_MESSAGE_SHOW_INTERVAL_NORMAL inView:delegate.window];
    }
}

- (void)responseUserLogin:(NSNotification *)notification
{
    NSDictionary *dict = [notification userInfo];
    if ([dict objectForKey:REQUEST_SOURCE_KEY] != _controllerId) {
        return;
    }
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSNumber *returnCode = [dict objectForKey:RETURN_CODE];
    if (returnCode && [returnCode isKindOfClass:[NSNumber class]] && [returnCode intValue] == 0) {
        [MobClick event:@"分享页面" attributes:[NSDictionary dictionaryWithObjectsAndKeys:shareText ? shareText : KPlaceholder, @"点击分享", nil]];
        [UBAnalysis event:@"分享页面" labels:2, @"点击分享", shareText ? shareText : KPlaceholder];
        [[DataEngine sharedDataEngine] share:kOAuthTypeSinaWeibo
                                  treasureId:nil
                                 description:shareTextView.text
                                        link:shareLink
                                        from:_controllerId];
        [delegate showActivityView:@"正在分享..." inView:delegate.window];
    } else {
        [delegate showFailedActivityView:[dict objectForKey:TOUI_REQUEST_ERROR_MESSAGE] interval:ERROR_MESSAGE_SHOW_INTERVAL_NORMAL inView:delegate.window];
    }
}

- (void)submit:(id) sender
{
    if ([shareTextView isFirstResponder]) {
        [shareTextView resignFirstResponder];
    }
    if (![DataEngine sharedDataEngine].isLogin) {
        // 此处登录
        [[DataEngine sharedDataEngine] sinaWeiboLogin];
        return;
    } else {
        Me *me = [[DataEngine sharedDataEngine] me];
        SinaOAuth *oauth = [me.oauthes objectForKey:[NSNumber numberWithInt:kOAuthTypeSinaWeibo]];
        if (oauth.expiredIn == nil || [oauth.expiredIn timeIntervalSince1970] <= [[NSDate date] timeIntervalSince1970] || TEST_WEIBOEXPIREDIN) {
            RIButtonItem *cancelItem = [RIButtonItem item];
            cancelItem.label = NSLocalizedString(@"取消", @"");
            cancelItem.action = ^{
                
            };
            
            RIButtonItem *okItem = [RIButtonItem item];
            okItem.label = NSLocalizedString(@"重新授权", @"");
            okItem.action = ^{
                [[DataEngine sharedDataEngine] sinaWeiboLogin];
            };
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:NSLocalizedString(@"您的授权已经过期需要重新授权", @"")
                                                   cancelButtonItem:cancelItem
                                                   otherButtonItems:okItem, nil];
            [alert show];
            return;
        }
    }
    
    if ([self wordsCount:shareTextView.text] > DESCRIPTION_MAX_LENGTH) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"字太多了~最多%d字", DESCRIPTION_MAX_LENGTH]                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"知道了", @"")
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    if ([self wordsCount:shareTextView.text] < DESCRIPTION_TIP_LENGTH) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"字太少了~最少%d字", DESCRIPTION_TIP_LENGTH]
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"知道了", @"")
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    [MobClick event:@"分享页面" attributes:[NSDictionary dictionaryWithObjectsAndKeys:shareText ? shareText : KPlaceholder, @"点击分享", nil]];
    [UBAnalysis event:@"分享页面" labels:2, @"点击分享", shareText ? shareText : KPlaceholder];

    [[DataEngine sharedDataEngine] share:kOAuthTypeSinaWeibo
                              treasureId:nil
                             description:shareTextView.text
                                    link:shareLink
                                    from:_controllerId];
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate showActivityView:@"正在分享..." inView:delegate.window];
}

- (void)responseShare:(NSNotification*) notification
{
    NSDictionary *dict = (NSDictionary *)[notification userInfo];
    if (![[dict objectForKey:REQUEST_SOURCE_KEY] isEqualToString:_controllerId]) {
        return;
    }
    NSNumber *returnCode = [dict objectForKey:RETURN_CODE];
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (returnCode && [returnCode isKindOfClass:[NSNumber class]] && [returnCode intValue] == 0) {
        [delegate showFinishActivityView:@"分享成功啦~" interval:2.0F inView:delegate.window];
        [DataEngine sharedDataEngine].isInShareViewController = NO;
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [delegate showFinishActivityView:[NSString stringWithFormat:@"分享失败..code:%@", returnCode] interval:2.0F inView:delegate.window];
    }
}

// 计算已经输入的字数
- (int)wordsCount:(NSString *)content
{
    // 匹配双字节字符
    NSString *pattern = @"[^x00-xff]";
    NSError *error = [NSError new];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    
    //匹配到的次数
    NSUInteger chineseCount =[regex numberOfMatchesInString:content options:NSRegularExpressionCaseInsensitive range:NSMakeRange(0, [content length])];
    
    int charCount = [content length] - chineseCount;
    return charCount % 2 == 0 ? charCount / 2 + chineseCount: charCount / 2 + 1 + chineseCount;
}

# pragma mark - UITextViewDegate

- (void)textViewDidChange:(UITextView *)textView
{
    //超出字数范围，显示红色字样
    if([self wordsCount:textView.text] > DESCRIPTION_MAX_LENGTH - DESCRIPTION_TIP_LENGTH)
    {
        [textLabel setTextColor:[UIColor redColor]];
    }
    else
    {
        [textLabel setTextColor:[UIColor colorWithRed:160.f / 255.f green:160.f / 255.f blue:160.f / 255.f alpha:1]];
    }
    
    [self.navigationItem.rightBarButtonItem setEnabled:!([self wordsCount:textView.text] > DESCRIPTION_MAX_LENGTH || [self wordsCount:textView.text] == 0)];

    [textLabel setText:[NSString stringWithFormat:NSLocalizedString(@"%d/%d", @""), DESCRIPTION_MAX_LENGTH - [self wordsCount:textView.text], DESCRIPTION_MAX_LENGTH]];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        return NO;
    }
    return YES;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    [DataEngine sharedDataEngine].isInShareViewController = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [MobClick beginLogPageView:@"分享页面"];
    [MobClick event:@"分享页面" label:@"页面显示"];
    [UBAnalysis event:@"分享页面" label:@"页面显示"];
    [UBAnalysis startTracPage:@"分享页面" labels:0];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [MobClick endLogPageView:@"分享页面"];
    [MobClick event:@"分享页面" label:@"页面隐藏"];
    [UBAnalysis event:@"分享页面" label:@"页面隐藏"];
    [UBAnalysis endTracPage:@"分享页面" labels:0];
}

@end
