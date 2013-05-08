//
//  MeController.m
//  iAccessories
//
//  Created by Tony Sun on 12-10-17.
//  Copyright (c) 2012年 MobileWoo. All rights reserved.
//

#import "MeController.h"
#import "CustomNavigationBar.h"
#import "AppDelegate.h"
#import "DataEngine.h"
#import "FeedbackViewController.h"
#import "AboutController.h"
#import "Constants.h"
#import "DataEngine.h"
#import "OAuth.h"
#import "RIButtonItem.h"
#import "UIAlertView+Blocks.h"
#import "FavouriteViewController.h"
#import "SecurityViewController.h"
#import "TSBWebViewController.h"
#import "UserGuideViewController.h"

# define TABLEVIEWCELL_HEIGHT   43

@interface MeController ()

- (void)removeAllImageCaches;

- (void)responseSinaUserInfo:(NSNotification *)notification;
- (void)responseUserLogin:(NSNotification *)notification;
- (void)responseUserLogout:(NSNotification *)notification;
- (void)moreButtonClick:(id)sender;
- (void)outerOpenApp;

@end

@interface MeController (notification)

- (void)responseSinaUserInfo:(NSNotification *)notification;
- (void)responseUserLogin:(NSNotification *)notification;
- (void)responseUserLogout:(NSNotification *)notification;

@end

@implementation MeController

@synthesize fromTab;
@synthesize tableView = _tableView;

- (void)moreButtonClick:(id)sender
{
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate showLeft];
}

- (id)init
{
    if (self = [super init]) {
        fromTab = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [MobClick event:@"更多页面" label:@"进入页面"];
    [UBAnalysis event:@"更多页面" label:@"进入页面"];
    [super viewDidLoad];
    
    if (_controllerId || [_controllerId length] == 0) {
        _controllerId = [[NSString alloc] initWithFormat:@"%p", self];
    }
    
    // app是否在审核中
    _appInreview = [DataEngine sharedDataEngine].appInReview;
    
    self.navigationItem.title = NSLocalizedString(@"更多", @"");
    [self.tableView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mainBackground.png"]]];
    if (!fromTab) {
        UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [moreButton setImage:[UIImage imageNamed:@"recommendMoreButton.png"] forState:UIControlStateNormal];
        [moreButton setImage:[UIImage imageNamed:@"recommendMoreButton_highlight.png"] forState:UIControlStateHighlighted];
        moreButton.frame = CGRectMake(0, 0, 47, 44);
        [moreButton addTarget:self action:@selector(moreButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:moreButton];
        
    }
    
    // 绑定微博按钮    
    _bindSinaButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_bindSinaButton addTarget:self action:@selector(clickBindButton:) forControlEvents:UIControlEventTouchUpInside];
    
//    _bindSina = [DataEngine sharedDataEngine].isLogin;
    [self showBind:[DataEngine sharedDataEngine].isLogin];
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(responseRemoveAllImageCaches:)
                                                 name:REMOVE_ALL_IMAGE_CACHES
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(responseSinaUserInfo:)
                                                 name:REQUEST_SINAWEIBOUSERINFO
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(responseUserLogin:)
                                                 name:REQUEST_OAUTHLOGIN
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(responseUserLogout:)
                                                 name:REQUEST_USERLOGOUT
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [MobClick beginLogPageView:@"更多页面"];
    [MobClick event:@"更多页面" label:@"页面显示"];
    [UBAnalysis event:@"更多页面" label:@"页面显示"];
    [UBAnalysis startTracPage:@"更多页面" labels:0];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [MobClick endLogPageView:@"更多页面"];
    [MobClick event:@"更多页面" label:@"页面隐藏"];
    [UBAnalysis event:@"更多页面" label:@"页面隐藏"];
    [UBAnalysis endTracPage:@"更多页面" labels:0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        DataEngine *dataEngine = [DataEngine sharedDataEngine];
        if (dataEngine.appInReview) {
            return 4;
        }
        return 5;
    } else if (section == 2) {
        return 1;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MeControllerCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        for (UIView *subView in cell.contentView.subviews) {
            [subView removeFromSuperview];
        }
    }
    
    UIImageView *cellBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellbg.png"]];
    UIImageView *cellBackgroundHighlight = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellbg_selected.png"]];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(6, (cell.frame.size.height - 25) / 2, 25, 25)];
    [imageView setAlpha:1.0];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(34, (cell.frame.size.height - 30) / 2, 240, 30)];
    label.font = [UIFont systemFontOfSize:14];
    [label setTextColor:[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0]];
    [label setShadowColor:[UIColor whiteColor]];
    [label setShadowOffset:CGSizeMake(0.0f, 1.0f)];
    label.backgroundColor = [UIColor clearColor];

    UIImageView *leftImage = [[UIImageView alloc] init];
    leftImage.frame = CGRectMake(270, (cell.frame.size.height - 20) / 2, 20, 20);
    leftImage.image = [UIImage imageNamed:@"arrow_icon_bg.png"];
    [cell.contentView addSubview:leftImage];
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        imageView.image = [UIImage imageNamed:@"sina_icon_bg"];
        [leftImage removeFromSuperview];
        label.text = NSLocalizedString(@"新浪微博", @"");
        _bindSinaButton.frame = CGRectMake(230, (cell.frame.size.height - 28) / 2, 56, 28);
        [cell.contentView addSubview:_bindSinaButton];
    }
    if (indexPath.section == 1) {
        if ([DataEngine sharedDataEngine].appInReview) {
            // 在审核 隐藏评分
            switch (indexPath.row) {
                case 0:
                {
                    // 我的收藏
                    cellBackground.image = [UIImage imageNamed:@"up_cellbg.png"];
                    cellBackgroundHighlight.image = [UIImage imageNamed:@"up_cellbg_selected.png"];
                    imageView.image = [UIImage imageNamed:@"favourite_icon_bg"];
                    label.text = NSLocalizedString(@"我的收藏", @"");
                }
                    break;
                case 1:
                {
                    // 清除缓存
                    cellBackground.image = [UIImage imageNamed:@"center_cellbg.png"];
                    cellBackgroundHighlight.image = [UIImage imageNamed:@"center_cellbg_selected.png"];
                    imageView.image = [UIImage imageNamed:@"clear_icon_bg"];
                    label.text = NSLocalizedString(@"清除缓存", @"");
                }
                    break;
                case 2:
                {
                    // 意见反馈
                    cellBackground.image = [UIImage imageNamed:@"center_cellbg.png"];
                    cellBackgroundHighlight.image = [UIImage imageNamed:@"center_cellbg_selected.png"];
                    imageView.image = [UIImage imageNamed:@"feedback_icon_bg"];
                    label.text = NSLocalizedString(@"意见反馈", @"");
                }
                    break;
                case 3:
                {
                    // 关于我们
                    cellBackground.image = [UIImage imageNamed:@"down_cellbg.png"];
                    cellBackgroundHighlight.image = [UIImage imageNamed:@"down_cellbg_selected.png"];
                    imageView.image = [UIImage imageNamed:@"about_icon_bg"];
                    label.text = NSLocalizedString(@"关于我们", @"");
                }
                    break;
                default:
                    break;
            }
        } else {
            switch (indexPath.row) {
                case 0:
                {
                    // 我的收藏
                    cellBackground.image = [UIImage imageNamed:@"up_cellbg.png"];
                    cellBackgroundHighlight.image = [UIImage imageNamed:@"up_cellbg_selected.png"];
                    imageView.image = [UIImage imageNamed:@"favourite_icon_bg"];
                    label.text = NSLocalizedString(@"我的收藏", @"");
                }
                    break;
                case 1:
                {
                    // 清除缓存
                    cellBackground.image = [UIImage imageNamed:@"center_cellbg.png"];
                    cellBackgroundHighlight.image = [UIImage imageNamed:@"center_cellbg_selected.png"];
                    imageView.image = [UIImage imageNamed:@"clear_icon_bg"];
                    label.text = NSLocalizedString(@"清除缓存", @"");
                }
                    break;
                case 2:
                {
                    // 给我评价
                    cellBackground.image = [UIImage imageNamed:@"center_cellbg.png"];
                    cellBackgroundHighlight.image = [UIImage imageNamed:@"center_cellbg_selected.png"];
                    imageView.image = [UIImage imageNamed:@"evaluate_icon_bg"];
                    label.text = NSLocalizedString(@"给我评价", @"");
                }
                    break;
                case 3:
                {
                    // 意见反馈
                    cellBackground.image = [UIImage imageNamed:@"center_cellbg.png"];
                    cellBackgroundHighlight.image = [UIImage imageNamed:@"center_cellbg_selected.png"];
                    imageView.image = [UIImage imageNamed:@"feedback_icon_bg"];
                    label.text = NSLocalizedString(@"意见反馈", @"");
                }
                    break;
                case 4:
                {
                    // 关于我们
                    cellBackground.image = [UIImage imageNamed:@"down_cellbg.png"];
                    cellBackgroundHighlight.image = [UIImage imageNamed:@"down_cellbg_selected.png"];
                    imageView.image = [UIImage imageNamed:@"about_icon_bg"];
                    label.text = NSLocalizedString(@"关于我们", @"");
                }
                    break;
                default:
                    break;
            }
        }
    }
    if (indexPath.section == 2 && indexPath.row == 0) {
        imageView.image = [UIImage imageNamed:@"weichat_icon_bg"];
        label.text = NSLocalizedString(@"微信客服", @"");
    }
    // add imageview & label to cell
    [cell.contentView addSubview:imageView];
    [cell.contentView addSubview:label];
    
    cell.backgroundView = cellBackground;
    cell.selectedBackgroundView = cellBackgroundHighlight;

    return cell;
}


#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TABLEVIEWCELL_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0 && indexPath.row == 0) {
        // 注销、登录
        [self clickBindButton:_bindSinaButton];
    }
    if (indexPath.section == 1) {
        if ([DataEngine sharedDataEngine].appInReview) {
            // 在审核 隐藏评分
            switch (indexPath.row) {
                case 0:
                {
                    // 收藏夹
                    FavouriteViewController *favourite = [[FavouriteViewController alloc] initWithNibName:@"FavouriteViewController" bundle:nil];
                    [favourite setFromTab:YES];
                    [self.navigationController pushViewController:favourite animated:YES];
                }
                    break;
                case 1:
                {
                    // 清除缓存
                    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                    [delegate showActivityView:NSLocalizedString(@"正在释放磁盘空间", @"") inView:delegate.window];
                    [self performSelector:@selector(removeAllImageCaches) withObject:nil afterDelay:0.1f];
                }
                    break;
                case 2:
                {
                    // 意见反馈
                    FeedbackViewController *feedbackViewController = [[FeedbackViewController alloc] initWithNibName:@"FeedbackViewController" bundle:nil];
                    [self.navigationController pushViewController:feedbackViewController animated:YES];
                }
                    break;
                case 3:
                {
                    // 关于我们
                    AboutController *about = [[AboutController alloc] initWithNibName:@"AboutController" bundle:nil];
                    [self.navigationController pushViewController:about animated:YES];
                }
                    break;
                default:
                    break;
            }
        } else {
            switch (indexPath.row) {
                case 0:
                {
                    // 收藏夹
                    FavouriteViewController *favourite = [[FavouriteViewController alloc] initWithNibName:@"FavouriteViewController" bundle:nil];
                    [favourite setFromTab:YES];
                    [self.navigationController pushViewController:favourite animated:YES];
                }
                    break;
                case 1:
                {
                    // 清除缓存
                    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                    [delegate showActivityView:NSLocalizedString(@"正在释放磁盘空间", @"") inView:delegate.window];
                    [self performSelector:@selector(removeAllImageCaches) withObject:nil afterDelay:0.1f];
                }
                    break;
                case 2:
                {
                    // 给我评价
                    [self outerOpenApp];
                }
                    break;
                case 3:
                {
                    // 意见反馈
                    FeedbackViewController *feedbackViewController = [[FeedbackViewController alloc] initWithNibName:@"FeedbackViewController" bundle:nil];
                    [self.navigationController pushViewController:feedbackViewController animated:YES];
                }
                    break;
                case 4:
                {
                    // 关于我们
                    AboutController *about = [[AboutController alloc] initWithNibName:@"AboutController" bundle:nil];
                    [self.navigationController pushViewController:about animated:YES];
                }
                    break;
                default:
                    break;
            }
        }
    }
    if (indexPath.section == 2 && indexPath.row == 0) {
        // 微信
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:WEIXIN_URL]];
        TSBWebViewController *tradeView = [[TSBWebViewController alloc] initWithNibName:@"TSBWebViewController" bundle:nil];
        tradeView.url = WEIXIN_URL;
        tradeView.showTitle = @"微信客服";

        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [delegate presentModalViewController:tradeView animated:YES];
    }
}

- (void)removeAllImageCaches
{
    [[DataEngine sharedDataEngine] removeAllImageCaches];
}

# pragma mark - Click Bind Button

- (void)clickBindButton:(id)sender
{
    // 退出登录
    if ([DataEngine sharedDataEngine].isLogin) {
        [MobClick event:@"更多页面" label:@"注销"];
        [UBAnalysis event:@"更多页面" label:@"注销"];
        
        RIButtonItem *cancelItem = [RIButtonItem item];
        cancelItem.label = NSLocalizedString(@"取消", @"");
        cancelItem.action = ^{
            
        };
        
        RIButtonItem *okItem = [RIButtonItem item];
        okItem.label = NSLocalizedString(@"注销", @"");
        okItem.action = ^{
            AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [delegate showActivityView:NSLocalizedString(@"正在注销...", @"") inView:delegate.window];
            [[DataEngine sharedDataEngine] userLogout:_controllerId];
        };
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:NSLocalizedString(@"确定注销?", @"")
                                               cancelButtonItem:cancelItem
                                               otherButtonItems:okItem, nil];
        [alert show];

    } else {
        // 此处登录
        [MobClick event:@"更多页面" label:@"登录"];
        [UBAnalysis event:@"更多页面" label:@"登录"];
        [[DataEngine sharedDataEngine] sinaWeiboLogin];
    }
}

- (void)showBind:(BOOL)bind
{
    if (bind) {
        [_bindSinaButton setBackgroundImage:[UIImage imageNamed:@"loginout.png"] forState:UIControlStateNormal];
        [_bindSinaButton setBackgroundImage:[UIImage imageNamed:@"loginout_selected.png"] forState:UIControlStateHighlighted];
        [_bindSinaButton setTitle:NSLocalizedString(@"退出", @"") forState:UIControlStateNormal];
        
    } else {
        [_bindSinaButton setBackgroundImage:[UIImage imageNamed:@"bindsina.png"] forState:UIControlStateNormal];
        [_bindSinaButton setBackgroundImage:[UIImage imageNamed:@"bindsina_selected.png"] forState:UIControlStateHighlighted];
        [_bindSinaButton setTitle:NSLocalizedString(@"绑定", @"") forState:UIControlStateNormal];
    }
    
    _bindSinaButton.titleLabel.textColor = [UIColor whiteColor];
    _bindSinaButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
}

- (void)responseRemoveAllImageCaches:(NSNotification *)notification
{
    AppDelegate *delegate= (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSDictionary *dictionary = (NSDictionary *)[notification object];
    NSString *allFileSize = [dictionary objectForKey:@"allFileSize"];
    float fileSize = ([allFileSize longLongValue] / 1024.0f) / 1024.0f;
    NSString *cleanedString = NSLocalizedString(@"缓存清理完成", @"");
    NSString *fileSizeString = @"";
    if ((int) fileSize == fileSize) {
        if (fileSize == 0) {
            // 如果是0,保留两位小数,显示0.00M
            fileSizeString = [NSString stringWithFormat:@"%.2f", fileSize];
        } else {
            fileSizeString = [NSString stringWithFormat:@"%f", fileSize];
        }
        cleanedString = [NSString stringWithFormat:NSLocalizedString(@"缓存清理完成，共释放%@M空间", @""), fileSizeString];
    } else {
        fileSizeString = [NSString stringWithFormat:@"%.2f", fileSize];
        cleanedString = [NSString stringWithFormat:NSLocalizedString(@"缓存清理完成，共释放%@M空间", @""), fileSizeString];
    }
    [delegate showFinishActivityView:cleanedString interval:1.5f inView:delegate.window];
}

# pragma mark - response notification

- (void)responseSinaUserInfo:(NSNotification *)notification
{
    NSDictionary *dict = [notification userInfo];
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSNumber *returnCode = [dict objectForKey:RETURN_CODE];
    if (returnCode && [returnCode isKindOfClass:[NSNumber class]] && [returnCode intValue] == 0) {
        if ([DataEngine sharedDataEngine].isInShareViewController) {
            return;
        }
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
        [self showBind:YES];
        return;
    }
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSNumber *returnCode = [dict objectForKey:RETURN_CODE];
    if (returnCode && [returnCode isKindOfClass:[NSNumber class]] && [returnCode intValue] == 0) {
        [delegate hideActivityView:delegate.window];
        [self showBind:YES];
    } else {
        [delegate showFailedActivityView:[dict objectForKey:TOUI_REQUEST_ERROR_MESSAGE] interval:ERROR_MESSAGE_SHOW_INTERVAL_NORMAL inView:delegate.window];
    }
}

- (void)responseUserLogout:(NSNotification *)notification
{
    NSDictionary *dict = [notification userInfo];
    if ([dict objectForKey:REQUEST_SOURCE_KEY] != _controllerId) {
        return;
    }
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSNumber *returnCode = [dict objectForKey:RETURN_CODE];
    if (returnCode && [returnCode isKindOfClass:[NSNumber class]] && [returnCode intValue] == 0) {
        [delegate hideActivityView:delegate.window];
        [self showBind:NO];
    } else {
        [delegate showFailedActivityView:[dict objectForKey:TOUI_REQUEST_ERROR_MESSAGE] interval:ERROR_MESSAGE_SHOW_INTERVAL_NORMAL inView:delegate.window];
    }
}

- (void)outerOpenApp {
    if (SYSTEM_VERSION_LESS_THAN(@"6.0")) {
        NSString *urlStr = [NSString stringWithFormat:APP_RATING_URL];
        NSURL *url = [NSURL URLWithString:urlStr];
        [[UIApplication sharedApplication] openURL:url];
    } else {
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [delegate showActivityView:NSLocalizedString(@"请稍候...", @"") inView:delegate.window];

        SKStoreProductViewController *storeProductVC = [[SKStoreProductViewController alloc] init];
        storeProductVC.delegate = self;
        NSDictionary *dict = [NSDictionary dictionaryWithObject:APP_ITUNES_ID
                                                         forKey:SKStoreProductParameterITunesItemIdentifier];
        [storeProductVC loadProductWithParameters:dict
                                  completionBlock:^(BOOL result, NSError *error) {
                                      AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                                      if (result) {
                                          [delegate hideActivityView:delegate.window];
                                          [delegate.tabBarController  presentModalViewController:storeProductVC animated:YES];
                                      } else {
                                          [delegate showFailedActivityView:NSLocalizedString(@"网络错误，请重试", @"") interval:ERROR_MESSAGE_SHOW_INTERVAL_LONG inView:delegate.window];
                                      }
                                  }];
    }
}

#pragma mark - SKStoreProductViewControllerDelegate
- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES completion:^{
    }];
}

@end
