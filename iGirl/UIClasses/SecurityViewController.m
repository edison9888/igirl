//
//  SecurityViewController.m
//  iTBK
//
//  Created by 郭雪 on 12-9-28.
//
//

#import "SecurityViewController.h"
#import "CustomNavigationBar.h"
#import "GCPINViewController.h"
#import "AppDelegate.h"
#import "DataEngine.h"

@interface SecurityViewController ()

- (void)back:(id)sender;
- (void)moreButtonClick:(id)sender;

@end

@implementation SecurityViewController
@synthesize fromTab;

- (id)init
{
    if (self = [super init]) {
        fromTab = NO;
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization

    }
    return self;
}

- (void)viewDidLoad
{
    [MobClick event:@"密码页面" label:@"进入页面"];
    [UBAnalysis event:@"密码页面" label:@"进入页面"];
    
    [super viewDidLoad];
    if (!fromTab) {
        UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [moreButton setImage:[UIImage imageNamed:@"recommendMoreButton.png"] forState:UIControlStateNormal];
        [moreButton setImage:[UIImage imageNamed:@"recommendMoreButton_highlight.png"] forState:UIControlStateHighlighted];
        moreButton.frame = CGRectMake(0, 0, 47, 44);
        [moreButton addTarget:self action:@selector(moreButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:moreButton];
    } else {
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
    }

    self.navigationItem.title = NSLocalizedString(@"密码锁", @"");
    
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"mainBackground.png"]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [MobClick beginLogPageView:@"首页"];
    [MobClick event:@"密码页面" label:@"页面显示"];
    [UBAnalysis event:@"密码页面" label:@"页面显示"];
    [UBAnalysis startTracPage:@"密码页面" labels:0];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [MobClick endLogPageView:@"密码页面"];
    [MobClick event:@"密码页面" label:@"页面隐藏"];
    [UBAnalysis event:@"密码页面" label:@"页面隐藏"];
    [UBAnalysis endTracPage:@"密码页面" labels:0];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.textAlignment = UITextAlignmentCenter;
    }
    
    cell.textLabel.textColor = [UIColor blackColor];
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    
    switch (indexPath.section) {
        case 0:
            if ([[NSUserDefaults standardUserDefaults] valueForKey:@"PassCode"]) {
                cell.textLabel.text = NSLocalizedString(@"取消密码", @"");
            }
            else {
                cell.textLabel.text = NSLocalizedString(@"设置密码", @"");
            }
            break;
        case 1:
            cell.textLabel.text = NSLocalizedString(@"修改密码", @"");
            if ([[NSUserDefaults standardUserDefaults] valueForKey:@"PassCode"]) {
                cell.textLabel.textColor = [UIColor blackColor];
            }
            else {
                cell.textLabel.textColor = [UIColor lightGrayColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            break;
        default:
            break;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section) {
        case 0:
        {
            if ([[NSUserDefaults standardUserDefaults] valueForKey:@"PassCode"]) {
                [MobClick event:@"密码页面" label:@"密码锁关闭"];
                [UBAnalysis event:@"密码页面" label:@"密码锁关闭"];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"PassCode"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [tableView reloadData];
            }
            else {
                [MobClick event:@"密码页面" label:@"密码锁开启"];
                [UBAnalysis event:@"密码页面" label:@"密码锁开启"];
                GCPINViewController *PIN = [[GCPINViewController alloc]
                                            initWithNibName:nil
                                            bundle:nil
                                            mode:GCPINViewControllerModeCreate];
                PIN.messageText = NSLocalizedString(@"请输入密码", @"");
                PIN.messageText2 = NSLocalizedString(@"请再次输入密码", @"");
                PIN.errorText = NSLocalizedString(@"两次密码不一致", @"");
                PIN.title = NSLocalizedString(@"设置密码", @"");
                PIN.verifyBlock = ^(NSString *code) {
                    [[NSUserDefaults standardUserDefaults] setValue:code forKey:@"PassCode"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [tableView reloadData];
                    return YES;
                };
                
                AppDelegate *delegate= (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [PIN presentFromViewController:delegate.tabBarController animated:YES];
            }
        }
            break;
        case 1:
        {
            if ([[NSUserDefaults standardUserDefaults] valueForKey:@"PassCode"] == nil) {
                return;
            }
            
            GCPINViewController *PIN = [[GCPINViewController alloc]
                                        initWithNibName:nil
                                        bundle:nil
                                        mode:GCPINViewControllerModeCreate];
            PIN.messageText = NSLocalizedString(@"请输入密码", @"");
            PIN.messageText2 = NSLocalizedString(@"请再次输入密码", @"");
            PIN.errorText = NSLocalizedString(@"两次密码不一致", @"");
            PIN.title = NSLocalizedString(@"修改密码", @"");
            PIN.verifyBlock = ^(NSString *code) {
                [[NSUserDefaults standardUserDefaults] setValue:code forKey:@"PassCode"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [tableView reloadData];
                return YES;
            };
            
            AppDelegate *delegate= (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [PIN presentFromViewController:delegate.tabBarController animated:YES];
        }
            break;
        default:
            break;
    }
}

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)moreButtonClick:(id)sender
{
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate showLeft];
}

@end
