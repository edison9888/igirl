//
//  CategoryViewController.m
//  iAccessories
//
//  Created by zhang on 12-10-16.
//  Copyright (c) 2012年 MobileWoo. All rights reserved.
//

#import "CategoryViewController.h"
#import "CustomNavigationBar.h"
#import "DataEngine.h"
#import "Category.h"
#import "ImageCacheEngine.h"
#import "Constants+APIRequest.h"
#import "Constants+RetrunParamDef.h"
#import "ItemListViewController.h"
#import "UBAnalysis.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "RIButtonItem.h"
#import "UIAlertView+Blocks.h"
#import "UISearchBar+CustomBackground.h"

#define ROW_ITEM_COUNT 3
#define ROW_HEIGHT 106
#define CATE_ITEM_TAG 95105

#define SEARCH_BAR_NORMAL_RECT CGRectMake(5,0,310,44)
#define SEARCH_BAR_FULL_RECT CGRectMake(5,0,310,44)


@interface CategoryViewController (Private)

- (void)responseDownloadImage:(NSNotification*) notification;
- (void)moreButtonClick:(id)sender;
- (void)responseSearchHistoryChange:(NSNotification*) notification;
- (void)openCate:(id)sender;
- (void)clearHistory:(id)sender;
- (void)searchRightButtonClick:(id)sender;
@end

@implementation CategoryViewController
@synthesize forAnalysisPath = forAnalysisPath;
@synthesize tableView = _tableView;
@synthesize fromTab;

- (void)viewDidLoad
{
    [MobClick event:@"分类列表" label:@"进入页面"];
    [UBAnalysis event:@"分类列表" label:@"进入页面"];
    
    [super viewDidLoad];
    forAnalysisPath = @"";
    _controllerId = [[NSString alloc] initWithFormat:@"%p", self];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(responseDownloadImage:)
                                                 name:REQUEST_DOWNLOADFILE_NOTIFICATION_NAME
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(responseSearchHistoryChange:)
                                                 name:NOTIFICATION_SEARCH_HISTORY_CHANGE
                                               object:nil];

    if (!fromTab) {
        UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [moreButton setImage:[UIImage imageNamed:@"recommendMoreButton.png"] forState:UIControlStateNormal];
        [moreButton setImage:[UIImage imageNamed:@"recommendMoreButton_highlight.png"] forState:UIControlStateHighlighted];
        moreButton.frame = CGRectMake(0, 0, 47, 44);
        [moreButton addTarget:self action:@selector(moreButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:moreButton];
    }

    self.navigationItem.title = NSLocalizedString(@"分类", nil);
    [_tableView setSeparatorStyle:NO];
    [self.tableView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mainBackground"]]];
    [_searchHistoryTableView setSeparatorStyle:NO];

//    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [rightButton setImage:[UIImage imageNamed:@"navigationBarButton.png"] forState:UIControlStateNormal];
//    [rightButton setImage:[UIImage imageNamed:@"navigationBarButton_selected"] forState:UIControlStateHighlighted];
//    rightButton.frame = CGRectMake(0, 0, 47, 44);
//    [rightButton addTarget:self action:@selector(searchRightButtonClick:) forControlEvents:UIControlEventTouchUpInside];
//    [rightButton setTitle:NSLocalizedString(@"搜索", @"") forState:UIControlStateNormal];
    self.navigationItem.titleView = _searchBar;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [MobClick beginLogPageView:@"分类列表"];
    [MobClick event:@"分类列表" label:@"页面显示"];
    [UBAnalysis event:@"分类列表" label:@"页面显示"];
    [UBAnalysis startTracPage:@"分类列表" labels:0];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [MobClick endLogPageView:@"分类列表"];
    [MobClick event:@"分类列表" label:@"页面隐藏"];
    [UBAnalysis event:@"分类列表" label:@"页面隐藏"];
    [UBAnalysis endTracPage:@"分类列表" labels:0];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (tableView == _tableView) {
        int count = [[DataEngine sharedDataEngine].categories count] - 3;
        if (count > 3) {
            count = count / ROW_ITEM_COUNT + (count % ROW_ITEM_COUNT == 0 ? 0 : 1);
            return count;
        } else {
            return 1;
        }
    }
    if (tableView == _searchHistoryTableView) {
        if ([[DataEngine sharedDataEngine].searchHistory count] > 0) {
            return [[DataEngine sharedDataEngine].searchHistory count] + 1;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    if (tableView == _tableView) {
        [cell setSelectionStyle:NO];
        // Configure the cell...
        for (UIView *view in [cell subviews]) {
            [view removeFromSuperview];
        }
        
        NSInteger startIndex = 3 * indexPath.row;
        int totalCount = [[DataEngine sharedDataEngine].categories count];
        for (int i = 0; i < 3; i++) {
            if (startIndex + i >= totalCount) {
                break;
            }
            
            Category *cate = [[DataEngine sharedDataEngine].categories objectAtIndex:(startIndex + i)];
            
            NSString *imagePath = [[ImageCacheEngine sharedInstance] getImagePathByUrl:[[DataEngine sharedDataEngine] getPNGImageUrlByUUID:cate.uuid]];
            UIImage *cateIconImage = nil;
            if (imagePath == nil) {
                cateIconImage = [UIImage imageNamed:@"categoryIconEmpty.png"];
                [[DataEngine sharedDataEngine] downloadFileByUrl:[[DataEngine sharedDataEngine] getPNGImageUrlByUUID:cate.uuid] type:kDownloadFileTypeImage from:_controllerId];
            } else {
                cateIconImage = [UIImage imageWithContentsOfFile:imagePath];
            }

//            UIImageView *cateItemBackgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"categoryItemBackground"]];
            float x = 0;
            switch (i) {
                case 0:
                    x = 11;
                    break;
                case 1:
                    x = 113;
                    break;
                case 2:
                    x = 215;
                    break;

                default:
                    break;
            }
//            [cateItemBackgroundImageView setFrame:CGRectMake(x, 6, 94, 94)];
//            [cell addSubview:cateItemBackgroundImageView];
            
//            UIImageView *cateIconImageView = [[UIImageView alloc] initWithImage:cateIconImage];
//            [cateIconImageView setFrame:CGRectMake(x + 15, 10, 65, 65)];
//            [cateIconImageView setTag:CATEGORY_LSIT_CELL_TAG_IMAGE];
//            [cell addSubview:cateIconImageView];
            
            UILabel *cateNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 77, 94, 22)];
            [cateNameLabel setText:cate.name];
            [cateNameLabel setTextColor:[UIColor colorWithRed:65/255.0f green:65/255.0f blue:65/255.0f alpha:1.0f]];
            [cateNameLabel setFont:[UIFont systemFontOfSize:12]];
            [cateNameLabel setBackgroundColor:[UIColor clearColor]];
            [cateNameLabel setTag:CATEGORY_LSIT_CELL_TAG_LABEL];
            [cateNameLabel setTextAlignment:NSTextAlignmentCenter];
            [cell addSubview:cateNameLabel];
            
            UIButton *clickButton = [[UIButton alloc] initWithFrame:CGRectMake(x + 15, 10, 65, 65)];
            [clickButton setImage:cateIconImage forState:UIControlStateNormal];
            [clickButton setTag:startIndex + i + CATE_ITEM_TAG];
            [clickButton setShowsTouchWhenHighlighted:NO];
            [clickButton addTarget:self action:@selector(openCate:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:clickButton];
        }

        [cell setBackgroundColor:[UIColor clearColor]];
        cell.accessoryView = NO;
    }

    if (tableView == _searchHistoryTableView) {
        [[cell viewWithTag:CATEGORY_LSIT_CELL_TAG_LINE] removeFromSuperview];
        [[cell viewWithTag:CATEGORY_LSIT_CELL_TAG_CLEAR_BUTTON] removeFromSuperview];
        [[cell viewWithTag:CATEGORY_LSIT_CELL_TAG_SELECTED_BACKGROUND] removeFromSuperview];

        UIView *bgColorView = [[UIView alloc] initWithFrame:cell.bounds];
        [bgColorView setTag:CATEGORY_LSIT_CELL_TAG_SELECTED_BACKGROUND];
        [bgColorView setBackgroundColor:[UIColor colorWithRed:74.0f/255.0f green:83.0f/255.0f blue:99.0f/255.0f alpha:1]];
        [cell setSelectedBackgroundView:bgColorView];

        DataEngine *dataEngine = [DataEngine sharedDataEngine];
        if (indexPath.row < [dataEngine.searchHistory count]) {
            [cell.textLabel setText:[dataEngine.searchHistory objectAtIndex:indexPath.row]];
        }
        [cell.textLabel setTextColor:[UIColor colorWithRed:65.0f/255.0f green:65.0f/255.0f blue:65.0f/255.0f alpha:1]];
        [cell.textLabel setFont:[UIFont boldSystemFontOfSize:14]];
        [cell.textLabel setHighlightedTextColor:[UIColor whiteColor]];
        
        if (indexPath.row >= [dataEngine.searchHistory count]) {
            [cell setSelectionStyle:NO];
            [cell.textLabel setText:@""];
            UIButton *clearButton = [[UIButton alloc] initWithFrame:CGRectMake(93, 20, 134, 40)];
            [clearButton setTitleColor:[UIColor colorWithRed:1.0f/255.0f green:36.0f/255.0f blue:80.0f/255.0f alpha:1] forState:UIControlStateNormal];
            [clearButton setTitleColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1] forState:UIControlStateSelected];
            [clearButton setTitleColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1] forState:UIControlStateHighlighted];
//            [clearButton.titleLabel setTextColor:[UIColor colorWithRed:1.0f/255.0f green:36.0f/255.0f blue:80.0f/255.0f alpha:1]];
            
            [clearButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
            [clearButton setBackgroundImage:[UIImage imageNamed:@"searchClearButton"] forState:UIControlStateNormal];
            [clearButton setTitle:NSLocalizedString(@"清除搜索历史", @"") forState:UIControlStateNormal];
            [cell addSubview:clearButton];
            [clearButton setTag:CATEGORY_LSIT_CELL_TAG_CLEAR_BUTTON];
            [clearButton addTarget:self action:@selector(clearHistory:) forControlEvents:UIControlEventTouchUpInside];
        } else {
            [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];

            UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(0, 39, 320, 2)];
            [line setImage:[UIImage imageNamed:@"listCellLine.png"]];
            [line setTag:CATEGORY_LSIT_CELL_TAG_LINE];
            [cell addSubview:line];
        }
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    
    if (tableView == _tableView) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        return;

    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView == _searchHistoryTableView) {
        if (indexPath.row == [[DataEngine sharedDataEngine].searchHistory count]) {
            // 清除搜索历史
            

        } else {
            NSString *keyword = [[DataEngine sharedDataEngine].searchHistory objectAtIndex:indexPath.row];
            ItemListViewController *itemList = [[ItemListViewController alloc] initWithNibName:@"ItemListViewController" bundle:nil];
            itemList.forAnalysisPath = forAnalysisPath;
            itemList.navigationItem.title = [NSString stringWithFormat:NSLocalizedString(@"%@", @""), keyword];
            itemList.listSource = kItemListFromSearch;
            [itemList setFromTab:NO];
            [itemList setSearchKeyword:keyword];
            
            [self searchBarCancelButtonClicked:_searchBar];
            [self.navigationController pushViewController:itemList animated:YES];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _tableView) {
        return ROW_HEIGHT;
    }
    if (indexPath.row >= [[DataEngine sharedDataEngine].searchHistory count]) {
        return 60;
    } else {
        return 40;
    }
}

- (void)responseDownloadImage:(NSNotification*) notification
{
    NSDictionary *dictionary = (NSDictionary *)[notification userInfo];
    if (![[dictionary objectForKey:REQUEST_SOURCE_KEY] isEqualToString:_controllerId]) {
        return;
    }
    NSString *imagePath = [dictionary objectForKey:TOUI_PARAM_DOWNLOADFILE_FILEPATH];
    if (imagePath) {
        [self.tableView reloadData];
    }
}

- (void)moreButtonClick:(id)sender
{
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate showLeft];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)bar
{
    self.navigationItem.title = @"";
    [bar setFrame:SEARCH_BAR_FULL_RECT];
    [bar setShowsCancelButton:YES animated:YES];
    [searchBackgroundView setHidden:NO];
//    [searchBackgroundView setAlpha:0];
    if ([[DataEngine sharedDataEngine].searchHistory count] > 0) {
        [_searchHistoryTableView setHidden:NO];
    }
    [searchBackgroundView setAlpha:1];
    for (UIView *subView in _searchBar.subviews) {
        if ([subView isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) {
            [subView setHidden:YES];
        }
        if([subView isKindOfClass:UIButton.class]) {
            UIButton *cancelButton = (UIButton *)subView;
            cancelButton.titleLabel.shadowOffset = CGSizeMake(0, 0);
            [cancelButton setBackgroundImage:[[UIImage imageNamed:@"navigationBarButton"] stretchableImageWithLeftCapWidth:20.0 topCapHeight:16.0] forState:UIControlStateNormal];
            [cancelButton setBackgroundImage:[[UIImage imageNamed:@"navigationBarButton_selected"] stretchableImageWithLeftCapWidth:20.0 topCapHeight:16.0] forState:UIControlStateHighlighted];
            break;
        }
    }
//    [UIView animateWithDuration:0.3f
//                     animations:^{
//                     }];
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)bar
{
    self.navigationItem.title = @"分类";

    [bar setShowsCancelButton:NO animated:YES];
        for (UIView *subView in _searchBar.subviews) {
            if ([subView isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) {
                [subView removeFromSuperview];
                break;
            }
        }
    [bar setFrame:SEARCH_BAR_NORMAL_RECT];

    [bar resignFirstResponder];
    [bar setText:nil];
    [_searchHistoryTableView setHidden:YES];
    [UIView animateWithDuration:0.3f
                     animations:^{
                         [searchBackgroundView setAlpha:0];
                     }
                     completion:^(BOOL finished) {
                         [searchBackgroundView setHidden:YES];
                     }];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    ItemListViewController *itemList = [[ItemListViewController alloc] initWithNibName:@"ItemListViewController" bundle:nil];
    itemList.forAnalysisPath = forAnalysisPath;
    itemList.navigationItem.title = [NSString stringWithFormat:NSLocalizedString(@"%@", @""), searchBar.text];
    itemList.listSource = kItemListFromSearch;
    [itemList setFromTab:NO];
    [itemList setSearchKeyword:searchBar.text];
    [_searchBar setFrame:SEARCH_BAR_NORMAL_RECT];
    self.navigationItem.title = @"分类";
    
    [MobClick event:@"分类列表" attributes:[NSDictionary dictionaryWithObjectsAndKeys:searchBar.text ? searchBar.text : KPlaceholder, @"搜索", nil]];
    [UBAnalysis event:@"分类列表" labels:2, @"搜索", searchBar.text ? searchBar.text : KPlaceholder];

    [self searchBarCancelButtonClicked:searchBar];
    [self.navigationController pushViewController:itemList animated:YES];

}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = touches.anyObject;
    if (touch.view == searchBackgroundView) {
        [self searchBarCancelButtonClicked:_searchBar];
    }
}

#pragma mark - UIScrollViewDelegate delegate methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == _searchHistoryTableView) {
        [_searchBar resignFirstResponder];
        for (UIView *cancelButton in _searchBar.subviews) {
            if ([cancelButton isKindOfClass:[UIButton class]]) {
                ((UIButton *)cancelButton).enabled = YES;
                break;
            }
        }
    }
}

- (void)responseSearchHistoryChange:(NSNotification*) notification
{
    [_searchHistoryTableView reloadData];
}

- (void)openCate:(id)sender
{
    int tag = [sender tag] - CATE_ITEM_TAG;
    Category *cate = [[DataEngine sharedDataEngine].categories objectAtIndex:tag];
    [MobClick event:@"分类列表" label:cate.name ? cate.name : KPlaceholder];
    [UBAnalysis event:@"分类列表" label:cate.name ? cate.name : KPlaceholder];
    
    forAnalysisPath = [NSString stringWithFormat:@"分类,%@,%lld", cate.name, [cate.cid longLongValue]];
    ItemListViewController *itemList = [[ItemListViewController alloc] initWithNibName:@"ItemListViewController" bundle:nil];
    itemList.forAnalysisPath = forAnalysisPath;
    itemList.navigationItem.title = cate.name;
    itemList.listSource = kItemListFromCategory;
    itemList.cid = cate.cid;
    
    [self.navigationController pushViewController:itemList animated:YES];
}

- (void)clearHistory:(id)sender
{
    
    RIButtonItem *okButton = [[RIButtonItem alloc] init];
    [okButton setLabel:NSLocalizedString(@"确定", @"")];
    [okButton setAction:^{
        [[DataEngine sharedDataEngine].searchHistory removeAllObjects];
        [[DataEngine sharedDataEngine] saveData];
        [_searchHistoryTableView reloadData];
        [_searchHistoryTableView setHidden:YES];
    }];
    RIButtonItem *cancelButton = [[RIButtonItem alloc] init];
    [cancelButton setLabel:NSLocalizedString(@"取消", @"")];
    [cancelButton setAction:^{
    }];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"确定清除搜索历史吗？", @"")
                                                    message:nil
                                           cancelButtonItem:cancelButton
                                           otherButtonItems:okButton, nil];
    [alert show];
}

@end
