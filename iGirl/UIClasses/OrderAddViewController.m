//
//  OrderAddViewController.m
//  iAccessories
//
//  Created by sunxq on 13-3-29.
//  Copyright (c) 2013年 MobileWoo. All rights reserved.
//

#import "OrderAddViewController.h"
#import "CustomNavigationBar.h"
#import "AppDelegate.h"
#import "DataEngine.h"
#import "Constants.h"

#define BASIC_TAG       7568

#define ORDER_NUM               @"order_num"
#define ORDER_NAME              @"order_name"
#define ORDER_MOBILE            @"order_mobile"
#define ORDER_ADDRESS           @"order_address"
#define ORDER_REMARK            @"order_remark"

@interface OrderAddViewController ()

@end

@implementation OrderAddViewController

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
	// Do any additional setup after loading the view.
    _controllerId = [[NSString alloc] initWithFormat:@"%p", self];
    
    self.navigationItem.title = NSLocalizedString(@"确认订单", @"");
    
    CustomNavigationBar *customNavigationBar = (CustomNavigationBar *)self.navigationController.navigationBar;
    
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
    [cancelButton setBackgroundImage:[[UIImage imageNamed:@"navigationBarBackButton.png"] stretchableImageWithLeftCapWidth:20.0 topCapHeight:16.0] forState:UIControlStateNormal];
    [cancelButton setBackgroundImage:[[UIImage imageNamed:@"navigationBarBackButton_selected.png"] stretchableImageWithLeftCapWidth:20.0 topCapHeight:16.0] forState:UIControlStateHighlighted];
    [customNavigationBar setText:[customNavigationBar onlyBackText] onBackButton:cancelButton leftCapWidth:20];
    [cancelButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:cancelButton];
    
    UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
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
    [submitButton setBackgroundImage:[[UIImage imageNamed:@"navigationBarButton.png"] stretchableImageWithLeftCapWidth:20.0 topCapHeight:16.0] forState:UIControlStateNormal];
    [submitButton setBackgroundImage:[[UIImage imageNamed:@"navigationBarButton_selected.png"] stretchableImageWithLeftCapWidth:20.0 topCapHeight:16.0] forState:UIControlStateHighlighted];

    [customNavigationBar setText:NSLocalizedString(@"提交订单", @"") onBackButton:submitButton leftCapWidth:20];
    [submitButton addTarget:self action:@selector(post:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:submitButton];
    
    
    _cells = [[NSMutableDictionary alloc] initWithCapacity:7];
    
    [self.view setBackgroundColor:[UIColor colorWithRed:241.f / 255.f green:241.f / 255.f blue:241.f / 255.f alpha:1]];
    
    self.tableView.separatorStyle = NO;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(responseAddOrder:)
                                                 name:REQUEST_ADDORDER
                                               object:nil];
    
    
//    AppDelegate *delegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
//    _bottomView.frame = CGRectMake(0, delegate.window.bounds.size.height - _bottomView.bounds.size.height, _bottomView.bounds.size.width, _bottomView.bounds.size.height);
    
//    [delegate.window addSubview:_bottomView];
//    [_orderButton addTarget:self action:@selector(post:) forControlEvents:UIControlEventTouchUpInside];
    [self performSelector:@selector(canSubmitDetect) withObject:nil afterDelay:0.1];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(canSubmitDetect) object:nil];
    [self performSelector:@selector(canSubmitDetect) withObject:nil afterDelay:0.1];
    
    [textField resignFirstResponder];
    if (textField.tag - BASIC_TAG <= 3) {
        int nextTag = (textField.tag + 1);
        int nextTagTemp = nextTag - BASIC_TAG;
        UITableViewCell *cell = [_cells objectForKey:[NSString stringWithFormat:@"1,%d", nextTagTemp]];
        UITextField *field = (UITextField *) [cell.contentView viewWithTag:nextTag];
        [field becomeFirstResponder];
    }
    return YES;
}

- (IBAction)changeBuyCount:(id)sender
{
    UIButton *button = (UIButton *)sender;
    UITableViewCell *cell = [_cells objectForKey:@"1,0"];
    UITextField *field = (UITextField *) [cell.contentView viewWithTag:(BASIC_TAG + 0)];
    if (field.text && [field.text length] > 0) {
        if (button.tag == 6001) {
            field.text = [NSString stringWithFormat:@"%d", ([field.text intValue] - 1) > 0 ? [field.text intValue] - 1 : 1];
        }
        else if(button.tag == 6002) {
            field.text = [NSString stringWithFormat:@"%d", [field.text intValue] + 1];
        }
    } else {
        field.text = @"1";
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(canSubmitDetect) object:nil];
    [self performSelector:@selector(canSubmitDetect) withObject:nil afterDelay:0.1];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(canSubmitDetect) object:nil];
    [self performSelector:@selector(canSubmitDetect) withObject:nil afterDelay:0.1];
}

- (void)canSubmitDetect
{
    UITableViewCell *cell1 = [_cells objectForKey:@"1,0"];
    UITextField *field1 = (UITextField *) [cell1.contentView viewWithTag:(BASIC_TAG + 0)];
    
    UITableViewCell *cell2 = [_cells objectForKey:@"1,1"];
    UITextField *field2 = (UITextField *) [cell2.contentView viewWithTag:(BASIC_TAG + 1)];
    
    UITableViewCell *cell3 = [_cells objectForKey:@"1,2"];
    UITextField *field3 = (UITextField *) [cell3.contentView viewWithTag:(BASIC_TAG + 2)];
    
    UITableViewCell *cell4 = [_cells objectForKey:@"1,3"];
    UITextField *field4 = (UITextField *) [cell4.contentView viewWithTag:(BASIC_TAG + 3)];

    if ([field1.text isEqualToString:@""] ||
        [field2.text isEqualToString:@""] ||
        [field3.text isEqualToString:@""] ||
        [field4.text isEqualToString:@""]) {
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
    } else {
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
    }
}

- (IBAction)post:(id)sender
{
    UITableViewCell *cell1 = [_cells objectForKey:@"1,0"];
    UITextField *field1 = (UITextField *) [cell1.contentView viewWithTag:(BASIC_TAG + 0)];

    UITableViewCell *cell2 = [_cells objectForKey:@"1,1"];
    UITextField *field2 = (UITextField *) [cell2.contentView viewWithTag:(BASIC_TAG + 1)];
    
    UITableViewCell *cell3 = [_cells objectForKey:@"1,2"];
    UITextField *field3 = (UITextField *) [cell3.contentView viewWithTag:(BASIC_TAG + 2)];
    
    UITableViewCell *cell4 = [_cells objectForKey:@"1,3"];
    UITextField *field4 = (UITextField *) [cell4.contentView viewWithTag:(BASIC_TAG + 3)];
    
    UITableViewCell *cell5 = [_cells objectForKey:@"1,4"];
    UITextField *field5 = (UITextField *) [cell5.contentView viewWithTag:(BASIC_TAG + 4)];
    
//    [[NSUserDefaults standardUserDefaults] setObject:field1.text forKey:ORDER_NUM];
//    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSUserDefaults standardUserDefaults] setObject:field2.text forKey:ORDER_NAME];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSUserDefaults standardUserDefaults] setObject:field3.text forKey:ORDER_MOBILE];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSUserDefaults standardUserDefaults] setObject:field4.text forKey:ORDER_ADDRESS];
    [[NSUserDefaults standardUserDefaults] synchronize];
//    [[NSUserDefaults standardUserDefaults] setObject:field5.text forKey:ORDER_REMARK];
//    [[NSUserDefaults standardUserDefaults] synchronize];
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate showActivityView:@"正在提交..." inView:delegate.window];
    
    [[DataEngine sharedDataEngine] addOrder:self.itemId
                                       name:field2.text
                                     remark:field5.text
                                   buyCount:[NSNumber numberWithInt:[field1.text intValue]]
                                      phone:field3.text
                                    address:field4.text
                                       from:_controllerId];
}

- (void)responseAddOrder:(NSNotification *)notification
{
    NSDictionary *dict = (NSDictionary *)[notification userInfo];
    if (![[dict objectForKey:REQUEST_SOURCE_KEY] isEqualToString:_controllerId]) {
        return;
    }
    NSNumber *returnCode = [dict objectForKey:RETURN_CODE];
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (returnCode && [returnCode isKindOfClass:[NSNumber class]] && [returnCode intValue] == 0) {
        [delegate showFinishActivityView:@"订单提交成功~" interval:2.0F inView:delegate.window];
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [delegate showFailedActivityView:[NSString stringWithFormat:@"订单提交失败..code:%@", returnCode] interval:2.0F inView:delegate.window];
    }
}

#pragma mark - TableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1) {
        return 5;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *itemKey = [NSString stringWithFormat:@"%d,%d", indexPath.section, indexPath.row];
    UITableViewCell *cell = nil;
    if (![_cells objectForKey:itemKey]) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        [_cells setObject:cell forKey:itemKey];
    } else {
        return [_cells objectForKey:itemKey];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.section == 0) {
        UILabel *itemLabel = [[UILabel alloc] initWithFrame:CGRectMake(13, 10, 285, 35)];
        itemLabel.text = self.itemName;
        itemLabel.textColor = [UIColor colorWithRed:60.0f / 255.0f green:60.0f / 255.0f blue:60.0f / 255.0f alpha:1];
        itemLabel.font = [UIFont systemFontOfSize:15.0f];
        [itemLabel setBackgroundColor:[UIColor clearColor]];
        itemLabel.numberOfLines = 2;
        [cell.contentView addSubview:itemLabel];
    } else if (indexPath.section == 1 && indexPath.row < 5) {
        UIImageView *leftBg = [[UIImageView alloc] initWithFrame:CGRectMake(12, 0, 82, 33)];
        [leftBg setImage:[[UIImage imageNamed:@"order_leftbg.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
        [cell.contentView addSubview:leftBg];
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(leftBg.frame.origin.x, leftBg.frame.origin.y, leftBg.frame.size.width, leftBg.frame.size.height)];
        nameLabel.textAlignment = UITextAlignmentCenter;
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.textColor = [UIColor colorWithRed:80.0f / 255.0f green:80.0f / 255.0f blue:80.0f / 255.0f alpha:1];
        nameLabel.font = [UIFont systemFontOfSize:13.0f];
        [cell.contentView addSubview:nameLabel];
        
        UIImageView *rightBg = [[UIImageView alloc] initWithFrame:CGRectMake(leftBg.frame.origin.x + leftBg.frame.size.width - 1, leftBg.frame.origin.y, 211, leftBg.frame.size.height)];
        [rightBg setImage:[[UIImage imageNamed:@"order_rightbg.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
        [cell.contentView addSubview:rightBg];
        
        UITextField *textField = [[UITextField alloc] init];
        textField.tag = BASIC_TAG + indexPath.row;
        [textField setBackgroundColor:[UIColor clearColor]];
        textField.frame = CGRectMake(rightBg.frame.origin.x + 15, rightBg.frame.origin.y + (rightBg.bounds.size.height - 15) / 2, rightBg.bounds.size.width - 15, 15);
        textField.textColor = [UIColor colorWithRed:60.0f / 255.0f green:60.0f / 255.0f blue:60.0f / 255.0f alpha:1];
        textField.font = [UIFont systemFontOfSize:13.0f];
        textField.delegate = self;
        textField.returnKeyType = UIReturnKeyNext;
        [cell.contentView addSubview:textField];
        
        if (indexPath.row == 0) {
            UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
            leftButton.frame = CGRectMake(rightBg.frame.origin.x + 15, (rightBg.bounds.size.height - 27) / 2, 27, 27);
            [leftButton setBackgroundImage:[UIImage imageNamed:@"order_jian.png"] forState:UIControlStateNormal];
            [leftButton setBackgroundImage:[UIImage imageNamed:@"order_jian_pressed.png"] forState:UIControlStateHighlighted];
            leftButton.tag = 6001;
            [leftButton addTarget:self
                           action:@selector(changeBuyCount:)
                 forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:leftButton];
            
            UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
            rightButton.frame = CGRectMake(rightBg.frame.origin.x + 112, leftButton.frame.origin.y, 27, 27);
            [rightButton setBackgroundImage:[UIImage imageNamed:@"order_jia.png"] forState:UIControlStateNormal];
            [rightButton setBackgroundImage:[UIImage imageNamed:@"order_jia_pressed.png"] forState:UIControlStateHighlighted];
            rightButton.tag = 6002;
            [rightButton addTarget:self
                           action:@selector(changeBuyCount:)
                 forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:rightButton];
        }
        
        switch (indexPath.row) {
            case 0:
            {
                rightBg.frame = CGRectMake(leftBg.frame.origin.x + leftBg.frame.size.width + 49, leftBg.frame.origin.y, 55, leftBg.frame.size.height);
                nameLabel.text = NSLocalizedString(@"数量*", @"");
                textField.text = NSLocalizedString(@"1", @"");
                [textField setEnabled:NO];
                textField.frame = CGRectMake(rightBg.frame.origin.x, rightBg.frame.origin.y + (rightBg.bounds.size.height - 15) / 2, rightBg.bounds.size.width, 15);
                textField.textAlignment = UITextAlignmentCenter;
                textField.textColor = [UIColor colorWithRed:220.0f / 255.0f green:50.0f / 255.0f blue:120.0f / 255.0f alpha:1];
                textField.keyboardType = UIKeyboardTypeNumberPad;
//                if ([[NSUserDefaults standardUserDefaults] objectForKey:ORDER_NUM]) {
//                    textField.text = [[NSUserDefaults standardUserDefaults] objectForKey:ORDER_NUM];
//                }
                break;
            }
            case 1:
            {
                nameLabel.text = NSLocalizedString(@"姓名*", @"");
                textField.placeholder = NSLocalizedString(@"输入您的姓名", @"");
                textField.text = [[NSUserDefaults standardUserDefaults] objectForKey:ORDER_NAME];
            }
                break;
            case 2:
            {
                nameLabel.text = NSLocalizedString(@"手机*", @"");
                textField.placeholder = NSLocalizedString(@"输入您的手机号", @"");
                textField.keyboardType = UIKeyboardTypePhonePad;
                textField.text = [[NSUserDefaults standardUserDefaults] objectForKey:ORDER_MOBILE];
            }
                break;
            case 3:
            {
                nameLabel.text = NSLocalizedString(@"地址*", @"");
                textField.placeholder = NSLocalizedString(@"输入您的收货地址", @"");
                textField.text = [[NSUserDefaults standardUserDefaults] objectForKey:ORDER_ADDRESS];
            }
                break;
            case 4:
            {
                nameLabel.text = NSLocalizedString(@"备注", @"");
//                textField.text = [[NSUserDefaults standardUserDefaults] objectForKey:ORDER_REMARK];
                textField.returnKeyType = UIReturnKeyDone;
                textField.placeholder = NSLocalizedString(@"(选填)", @"");
            }
                break;
            default:
                break;
        }
    }
    
    // 提交订单按钮
//    if (indexPath.row == 5) {
//        UIButton *postButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        postButton.frame = CGRectMake(27, 0, 267, 41);
//        [postButton setTitle:NSLocalizedString(@"提交订单", @"") forState:UIControlStateNormal];
//        [postButton setBackgroundImage:[UIImage imageNamed:@"order_post.png"] forState:UIControlStateNormal];
//        [postButton setBackgroundImage:[UIImage imageNamed:@"order_post_pressed.png"] forState:UIControlStateHighlighted];
//        [postButton addTarget:self action:@selector(post:) forControlEvents:UIControlEventTouchUpInside];
//        [cell addSubview:postButton];
//    }
    
    return cell;
}

#pragma mark - TableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 60;
    }
    return 42;
}

@end
