//
//  MoreViewController.m
//  iTaoshenbian
//
//  Created by 郭雪 on 12-9-12.
//
//

#import "MoreViewController.h"
#import "AppDelegate.h"
#import "CustomNavigationBar.h"
#import "DataEngine.h"
#import "Constants+APIRequest.h"
#import "Constants+NotificationName.h"
#import "UIAlertView+Blocks.h"
#import "Constants.h"
#import "Banner.h"
#import "CategoryViewController.h"
#import "MeController.h"
#import "FavouriteController.h"
#import "RecommendViewController.h"
#import "RecommendForDrawerViewController.h"
#import "Menu.h"
#import "ItemListViewController.h"
#import "ItemDetailViewController.h"
#import "TSBWebViewController.h"
#import "SecurityViewController.h"
#import "ShopWindowViewController.h"
#import "Itemlist2ViewController.h"

@implementation MoreListCell

- (void) layoutSubviews {
    [super layoutSubviews];
    self.textLabel.frame = CGRectMake(self.textLabel.frame.origin.x + 10, self.textLabel.frame.origin.y, self.textLabel.frame.size.width, self.textLabel.frame.size.height);
}

@end

@interface MoreViewController (private)

- (void)responseMenus:(NSNotification *)notification;

@end

@implementation MoreViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [MobClick event:@"菜单页面" label:@"进入页面"];
    [UBAnalysis event:@"菜单页面" label:@"进入页面"];
    [super viewDidLoad];
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"moreTableBackground.png"]];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(responseMenus:)
                                                 name:REQUEST_MENUS
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [MobClick beginLogPageView:@"菜单页面"];
    [MobClick event:@"菜单页面" label:@"页面显示"];
    [UBAnalysis event:@"菜单页面" label:@"页面显示"];
    [UBAnalysis startTracPage:@"菜单页面" labels:0];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [MobClick event:@"菜单页面" label:@"页面隐藏"];
    [MobClick endLogPageView:@"菜单页面"];
    [UBAnalysis event:@"菜单页面" label:@"页面隐藏"];
    [UBAnalysis endTracPage:@"菜单页面" labels:0];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    DataEngine *dataEngine = [DataEngine sharedDataEngine];
    if (dataEngine.menu && dataEngine.menu.groups && [dataEngine.menu.groups count] > 0) {
        return [dataEngine.menu.groups count];
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 22;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    DataEngine *dataEngine = [DataEngine sharedDataEngine];
    MenuGroup *group = [dataEngine.menu.groups objectAtIndex:section];
    if (group.groupName && [group.groupName length] > 0) {
        UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(13, 4, 74, 16)];
        l.text = group.groupName;
        l.backgroundColor = [UIColor clearColor];
        l.textColor = [UIColor colorWithRed:77.0 / 255.0 green:89.0 / 255.0 blue:126.0 / 255.0 alpha:1.0];
        l.font = [UIFont boldSystemFontOfSize:10.0];
        l.textAlignment = UITextAlignmentCenter;
        
        UIImageView *backgrounder = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"moreTableHeaderBackground.png"]];
        backgrounder.frame = CGRectMake(0, 0, 320, 22);
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 22)];
        view.backgroundColor = [UIColor clearColor];
        [view addSubview:backgrounder];
        [view addSubview:l];
        
        return view;
    }
    else {
        return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    DataEngine *dataEngine = [DataEngine sharedDataEngine];
    MenuGroup *group = [dataEngine.menu.groups objectAtIndex:section];
    if (group && group.menuItems && [group.menuItems count] > 0) {
        return [group.menuItems count];
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    MoreListCell *cell = (MoreListCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    // Configure the cell...
    if (cell == nil) {
        cell = [[MoreListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"moreTableCellBackground.png"]];
        cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"moreTableCellBackgroundSelected.png"]];
        [cell.textLabel setBackgroundColor:[UIColor clearColor]];
        [cell.detailTextLabel setBackgroundColor:[UIColor clearColor]];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14.0];
        cell.textLabel.textColor = [UIColor colorWithRed:176.0 / 255.0 green:176.0 / 255.0 blue:176.0 / 255.0 alpha:1.0];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    else {
        cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"moreTableCellBackground.png"]];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    
    DataEngine *dataEngine = [DataEngine sharedDataEngine];
    
    MenuGroup *group = [dataEngine.menu.groups objectAtIndex:indexPath.section];
    MenuItem *item = [group.menuItems objectAtIndex:indexPath.row];
    
    [cell.textLabel setText:item.menuName];
    
    UIViewController *controller = [((UINavigationController *)self.viewDeckController.centerController).viewControllers objectAtIndex:0];
    
    switch ([item.menuType intValue]) {
        case kMenuActionTypeList:
        case kMenuActionTypeListAuto:
        case kMenuActionTypeListDiscount:
        {
            switch (((MenuItemTreasureList *)item).treasureShowType) {
                case kTreasureListShowType222:
                    if ([controller isKindOfClass:[Itemlist2ViewController class]] && [((Itemlist2ViewController *)controller).bannerId isEqualToNumber:((MenuItemTreasureList *)item).bannerId]) {
                        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
                    }
                    break;
                case kTreasureListShowTypeList:
                    if ([controller isKindOfClass:[ItemListViewController class]] && [((ItemListViewController *)controller).bannerId isEqualToNumber:((MenuItemTreasureList *)item).bannerId]) {
                        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
                    }
                    break;
                default:
                    break;
            }
        }
            break;
        case kMenuActionTypeTreasure:
        {
            if ([controller isKindOfClass:[ItemDetailViewController class]] && [((ItemDetailViewController *)controller).treasureId isEqualToNumber:((MenuItemTreasureDetail *)item).tid]) {
                [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
        }
            break;
        case kMenuActionTypeLink:
        {
            if ([controller isKindOfClass:[TSBWebViewController class]] && [((TSBWebViewController *)controller).url isEqualToString:((MenuItemLink *)item).url]) {
                [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
        }
            break;
        case kMenuActionTypeSence:
        {
            switch (((MenuItemSence *)item).tileShowType) {
                case kTileShowType123:
                    if ([controller isKindOfClass:[RecommendForDrawerViewController class]] && [((RecommendForDrawerViewController *)controller).bannerId isEqualToNumber:((MenuItemSence *)item).bannerId]) {
                        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
                    }
                    break;
                case kTileShowTypeBigPicture:
                    if ([controller isKindOfClass:[ShopWindowViewController class]] && [((ShopWindowViewController *)controller).bannerId isEqualToNumber:((MenuItemSence *)item).bannerId]) {
                        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
                    }
                    break;
                default:
                    break;
            }
        }
            break;
        case kMenuActionTypeCategory:
        {
            if ([controller isKindOfClass:[CategoryViewController class]]) {
                [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
        }
            break;
        case kMenuActionTypeFavorite:
        {
            if ([controller isKindOfClass:[FavouriteController class]]) {
                [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
        }
            break;
        case kMenuActionTypeSettings:
        {
            if ([controller isKindOfClass:[MeController class]]) {
                [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
        }
            break;
        case kMenuActionTypeBackHomePage:
        {
            if ([controller isKindOfClass:[RecommendViewController class]]) {
                [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
        }
            break;
        case kMenuActionTypePin:
        {
            if ([controller isKindOfClass:[SecurityViewController class]]) {
                [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
        }
            break;
        default:
            break;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DataEngine *dataEngine = [DataEngine sharedDataEngine];
    
    MenuGroup *group = [dataEngine.menu.groups objectAtIndex:indexPath.section];
    MenuItem *item = [group.menuItems objectAtIndex:indexPath.row];
    [MobClick event:@"菜单页面" attributes:[NSDictionary dictionaryWithObjectsAndKeys:item.menuName ? item.menuName : KPlaceholder, @"点击菜单", nil]];
    [UBAnalysis event:@"菜单页面" labels:3, @"点击菜单", item.menuName ? item.menuName : KPlaceholder, [item.bannerId stringValue]];
    NSString *fromText = @"";
    
    UIViewController *controller = [((UINavigationController *)self.viewDeckController.centerController).viewControllers objectAtIndex:0];
    
    switch ([item.menuType intValue]) {
        case kMenuActionTypeList:
        case kMenuActionTypeListAuto:
        case kMenuActionTypeListDiscount:
        {
            switch (((MenuItemTreasureList *)item).treasureShowType) {
                case kTreasureListShowType222:
                    if ([controller isKindOfClass:[Itemlist2ViewController class]] && [((Itemlist2ViewController *)controller).bannerId isEqualToNumber:((MenuItemTreasureList *)item).bannerId]) {
                        [self.viewDeckController closeLeftViewAnimated:YES];
                    } else {
                        Itemlist2ViewController *itemList = [[Itemlist2ViewController alloc] initWithNibName:@"Itemlist2ViewController" bundle:nil];
                        itemList.forAnalysisPath = fromText;
                        itemList.listSource = kItemListFromBanner;
                        itemList.isFirstClass = YES;
                        itemList.bannerId = ((MenuItemTreasureList *)item).bannerId;
                        itemList.tileType = [item.menuType intValue];
                        itemList.title = item.menuName;
                        UINavigationController *navList = [[UINavigationController alloc] initWithRootViewController:itemList];
                        [navList setValue:[[CustomNavigationBar alloc] init] forKeyPath:@"navigationBar"];
                        self.viewDeckController.centerController = navList;
                        self.viewDeckController.panningView = itemList.view;
                        [self.viewDeckController closeLeftViewAnimated:YES];
                        [tableView reloadData];
                    }

                    break;
                case kTreasureListShowTypeList:
                    if ([controller isKindOfClass:[ItemListViewController class]] && [((ItemListViewController *)controller).bannerId isEqualToNumber:((MenuItemTreasureList *)item).bannerId]) {
                        [self.viewDeckController closeLeftViewAnimated:YES];
                    } else {
                        ItemListViewController *itemList = [[ItemListViewController alloc] initWithNibName:@"ItemListViewController" bundle:nil];
                        itemList.forAnalysisPath = fromText;
                        itemList.listSource = kItemListFromBanner;
                        itemList.isFirstClass = YES;
                        itemList.bannerId = ((MenuItemTreasureList *)item).bannerId;
                        itemList.tileType = [item.menuType intValue];
                        itemList.title = item.menuName;
                        UINavigationController *navList = [[UINavigationController alloc] initWithRootViewController:itemList];
                        [navList setValue:[[CustomNavigationBar alloc] init] forKeyPath:@"navigationBar"];
                        self.viewDeckController.centerController = navList;
                        self.viewDeckController.panningView = itemList.view;
                        [self.viewDeckController closeLeftViewAnimated:YES];
                        [tableView reloadData];
                    }
                    break;
                default:
                    break;
            }
        }
            break;
        case kMenuActionTypeTreasure:
        {
            if ([controller isKindOfClass:[ItemDetailViewController class]] && [((ItemDetailViewController *)controller).treasureId isEqualToNumber:((MenuItemTreasureDetail *)item).tid]) {
                [self.viewDeckController closeLeftViewAnimated:YES];
            }
            else {
                NSString *fromText = [NSString stringWithFormat:@"左侧菜单,%@,%lld", item.menuName, [item.bannerId longLongValue]];
                [MobClick event:@"商品详情页面" attributes:[NSDictionary dictionaryWithObjectsAndKeys:fromText, @"进入来源", nil]];
                [UBAnalysis event:@"商品详情页面" labels:2, @"进入来源", fromText];

                ItemDetailViewController *itemDetail = [[ItemDetailViewController alloc] initWithNibName:@"ItemDetailViewController" bundle:nil];
                itemDetail.isFirstClass = YES;
                itemDetail.treasureId = ((MenuItemTreasureDetail *)item).tid;
                itemDetail.treasuresArray = nil;
                itemDetail.preViewName = item.menuName;
                UINavigationController *navDetail = [[UINavigationController alloc] initWithRootViewController:itemDetail];
                [navDetail setValue:[[CustomNavigationBar alloc] init] forKeyPath:@"navigationBar"];
                self.viewDeckController.centerController = navDetail;
                self.viewDeckController.panningView = itemDetail.view;
                [self.viewDeckController closeLeftViewAnimated:YES];
                [tableView reloadData];
            }
        }
            break;
        case kMenuActionTypeLink:
        {
            if ([controller isKindOfClass:[TSBWebViewController class]] && [((TSBWebViewController *)controller).url isEqualToString:((MenuItemLink *)item).url]) {
                [self.viewDeckController closeLeftViewAnimated:YES];
            }
            else {
                TSBWebViewController *tradeView = [[TSBWebViewController alloc] initWithNibName:@"TSBWebViewController" bundle:nil];
                tradeView.isFirstClass = YES;
                tradeView.url = ((MenuItemLink *)item).url;
                tradeView.showTitle = item.menuName;
                UINavigationController *navWeb = [[UINavigationController alloc] initWithRootViewController:tradeView];
                [navWeb setValue:[[CustomNavigationBar alloc] init] forKeyPath:@"navigationBar"];
                self.viewDeckController.centerController = navWeb;
                self.viewDeckController.panningView = tradeView.view;
                [self.viewDeckController closeLeftViewAnimated:YES];
                [tableView reloadData];
            }
        }
            break;
        case kMenuActionTypeSence:
        {
            switch (((MenuItemSence *)item).tileShowType) {
                case kTileShowType123:
                    if ([controller isKindOfClass:[RecommendForDrawerViewController class]] && [((RecommendForDrawerViewController *)controller).bannerId isEqualToNumber:((MenuItemSence *)item).bannerId]) {
                        [self.viewDeckController closeLeftViewAnimated:YES];
                    } else {
                        Banner *banner = [[Banner alloc] init];
                        banner.bannerId = ((MenuItemSence *)item).bannerId;
                        banner.title = ((MenuItemSence *)item).menuName;
                        [[DataEngine sharedDataEngine] addbanner:banner];
                        RecommendForDrawerViewController *recommendViewController = [[RecommendForDrawerViewController alloc] initWithNibName:@"RecommendForDrawerViewController" bundle:nil];
                        recommendViewController.forAnalysisPath = fromText;
                        recommendViewController.isFirstClass = YES;
                        recommendViewController.bannerId = banner.bannerId;
                        UINavigationController *navRec = [[UINavigationController alloc] initWithRootViewController:recommendViewController];
                        [navRec setValue:[[CustomNavigationBar alloc] init] forKeyPath:@"navigationBar"];
                        self.viewDeckController.centerController = navRec;
                        self.viewDeckController.panningView = recommendViewController.view;
                        [self.viewDeckController closeLeftViewAnimated:YES];
                        [tableView reloadData];
                    }
                    break;
                case kTileShowTypeBigPicture:
                    if ([controller isKindOfClass:[ShopWindowViewController class]] && [((ShopWindowViewController *)controller).bannerId isEqualToNumber:((MenuItemSence *)item).bannerId]) {
                        [self.viewDeckController closeLeftViewAnimated:YES];
                    } else {
                        Banner *banner = [[Banner alloc] init];
                        banner.bannerId = ((MenuItemSence *)item).bannerId;
                        banner.title = ((MenuItemSence *)item).menuName;
                        [[DataEngine sharedDataEngine] addbanner:banner];
                        ShopWindowViewController *shopWIndowViewController = [[ShopWindowViewController alloc] initWithNibName:@"ShopWindowViewController" bundle:nil];
                        shopWIndowViewController.forAnalysisPath = fromText;
                        shopWIndowViewController.isFirstClass = YES;
                        shopWIndowViewController.bannerId = banner.bannerId;
                        shopWIndowViewController.showTitle = banner.title;
                        UINavigationController *navRec = [[UINavigationController alloc] initWithRootViewController:shopWIndowViewController];
                        [navRec setValue:[[CustomNavigationBar alloc] init] forKeyPath:@"navigationBar"];
                        self.viewDeckController.centerController = navRec;
                        self.viewDeckController.panningView = shopWIndowViewController.view;
                        [self.viewDeckController closeLeftViewAnimated:YES];
                        [tableView reloadData];
                    }
                    break;
                default:
                    break;
            }
        }
            break;
        case kMenuActionTypeCategory:
        {
            if ([controller isKindOfClass:[CategoryViewController class]]) {
                [self.viewDeckController closeLeftViewAnimated:YES];
            }
            else {
                CategoryViewController *categoryViewController = [[CategoryViewController alloc] initWithNibName:@"CategoryViewController" bundle:nil];
                UINavigationController *navCat = [[UINavigationController alloc] initWithRootViewController:categoryViewController];
                [navCat setValue:[[CustomNavigationBar alloc] init] forKeyPath:@"navigationBar"];
                self.viewDeckController.centerController = navCat;
                self.viewDeckController.panningView = categoryViewController.view;
                [self.viewDeckController closeLeftViewAnimated:YES];
                [tableView reloadData];
            }
        }
            break;
        case kMenuActionTypeFavorite:
        {
            if ([controller isKindOfClass:[FavouriteController class]]) {
                [self.viewDeckController closeLeftViewAnimated:YES];
            }
            else {
                FavouriteController *favouriteController = [[FavouriteController alloc] init];
                UINavigationController *navFav = [[UINavigationController alloc] initWithRootViewController:favouriteController];
                [navFav setValue:[[CustomNavigationBar alloc] init] forKeyPath:@"navigationBar"];
                self.viewDeckController.centerController = navFav;
                self.viewDeckController.panningView = favouriteController.view;
                [self.viewDeckController closeLeftViewAnimated:YES];
                [tableView reloadData];
            }
        }
            break;
        case kMenuActionTypeSettings:
        {
            if ([controller isKindOfClass:[MeController class]]) {
                [self.viewDeckController closeLeftViewAnimated:YES];
            }
            else {
                MeController *meController = [[MeController alloc] initWithNibName:@"MeController" bundle:nil];
                UINavigationController *navPer = [[UINavigationController alloc] initWithRootViewController:meController];
                [navPer setValue:[[CustomNavigationBar alloc] init] forKeyPath:@"navigationBar"];
                self.viewDeckController.centerController = navPer;
                self.viewDeckController.panningView = meController.view;
                [self.viewDeckController closeLeftViewAnimated:YES];
                [tableView reloadData];
            }
        }
            break;
        case kMenuActionTypeBackHomePage:
        {
            if ([controller isKindOfClass:[RecommendViewController class]]) {
                [self.viewDeckController closeLeftViewAnimated:YES];
            }
            else {
                RecommendViewController *recommendViewController = [[RecommendViewController alloc] initWithNibName:@"RecommendViewController" bundle:nil];
                UINavigationController *navRec = [[UINavigationController alloc] initWithRootViewController:recommendViewController];
                [navRec setValue:[[CustomNavigationBar alloc] init] forKeyPath:@"navigationBar"];
                self.viewDeckController.centerController = navRec;
                self.viewDeckController.panningView = recommendViewController.view;
                [self.viewDeckController closeLeftViewAnimated:YES];
                [tableView reloadData];
            }
        }
            break;
        case kMenuActionTypePin:
        {
            if ([controller isKindOfClass:[SecurityViewController class]]) {
                [self.viewDeckController closeLeftViewAnimated:YES];
            }
            else {
                SecurityViewController *securityViewController = [[SecurityViewController alloc] initWithNibName:@"SecurityViewController" bundle:nil];
                UINavigationController *navPer = [[UINavigationController alloc] initWithRootViewController:securityViewController];
                [navPer setValue:[[CustomNavigationBar alloc] init] forKeyPath:@"navigationBar"];
                self.viewDeckController.centerController = navPer;
                self.viewDeckController.panningView = securityViewController.view;
                [self.viewDeckController closeLeftViewAnimated:YES];
                [tableView reloadData];
            }
        }
            break;
        default:
            break;
    }
}

- (void)responseMenus:(NSNotification *)notification
{
    [self.tableView reloadData];
}

@end
