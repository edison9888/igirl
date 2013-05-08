//
//  ItemDetailView.m
//  iTBK
//
//  Created by 郭雪 on 12-9-28.
//
//

#import "ItemDetailView.h"
#import "ItemDetailViewController.h"
#import "AppDelegate.h"
#import "ImageCacheEngine.h"
#import "DataEngine.h"
#import "Constants.h"
#import "Treasure.h"
#import "CustomNavigationBar.h"
#import "RTLabel.h"
#import <QuartzCore/QuartzCore.h>
#import "TBSeller.h"
#import "NSStringExtra.h"

#define CELLTAG 9001
#define CREDITSTAG 9002
#define SIMILARIMAGETAG 9003

#define MAINIMAGEDEFAULTHEIGHT 250
#define COMMENTSTABLEVIEWDEFAULTHEIGHT 35
#define DETAILWEBVIEWDEFAULTHEIGHT 1

#define SELLERVIEWHEIGHT 0
#define SIMILARVIEWHEIGHT 122
#define SPACERHEIGHT 5

#define DETAIL_VIEW_SIMILAR_TAG 12306
#define DETAIL_VIEW_TOP_TAG 12307
#define DETAIL_VIEW_IMAGES_TAG 12308
#define DETAIL_VIEW_COMMENT_TAG 12309
#define BOTTOM_DETAIL_HEIGHT 50

@interface ItemDetailView ()

- (CGFloat)addComment:(Rate*)comment addSubView:(BOOL)addSubView;
- (void)extendTopViewHeight:(CGFloat)offset;
- (void)extendSellerViewHeight;
- (void)resortSellerCredits;
- (void)extendCommentViewHeight:(CGFloat)offset;
- (void)extendDetailViewHeight:(CGFloat)offset;
- (void)extendSimilarViewHeight;
- (void)resortSimilarItems;

- (void)requestDownloadImage:(NSString *)picUrl;
- (void)responseDownloadFile:(NSNotification *)notification;
- (void)responseGetItemDetail:(NSNotification *)notification;
- (void)responseGetSellerInfo:(NSNotification *)notification;
- (void)responseGetOtherItems:(NSNotification *)notification;

- (IBAction)openOthers:(id)sender;

@end

@implementation ItemDetailView

@synthesize treasureId;
@synthesize itemDetailViewController;
@synthesize bodyScrollView;
@synthesize hideSimilar;

- (id)init
{
    self = [super init];
    if (self) {
        _controllerId = [[NSString alloc] initWithFormat:@"%p", self];
        commentLabelsArray = [[NSMutableArray alloc] initWithCapacity:5];
        similarItemsArray = [[NSMutableArray alloc] initWithCapacity:3];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(responseDownloadFile:)
                                                     name:REQUEST_DOWNLOADFILE_NOTIFICATION_NAME
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(responseGetItemDetail:)
                                                     name:REQUEST_GETITEMDETAIL
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(responseGetSellerInfo:)
                                                     name:REQUEST_TBSELLERINFO
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(responseGetOtherItems:)
                                                     name:REQUEST_OTHERITEMS
                                                   object:nil];
        detailBackground = [[UIImage imageNamed:@"detailBackground"] stretchableImageWithLeftCapWidth:25 topCapHeight:25];

        //UITapGestureRecognizer *tapImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapMainImage)];
        //[mainImage addGestureRecognizer:tapImage];
        [bodyScrollView setContentSize:CGSizeMake(320.0, similarView.frame.size.height + similarView.frame.origin.y + BOTTOM_DETAIL_HEIGHT)];
    }

    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didTapMainImage
{
    
}

- (void)updateFavouriteButton
{
    DataEngine *dataEngine = [DataEngine sharedDataEngine];
    if ([dataEngine.favories containsObject:treasureId]) {
//        [customNavigationBar setText:NSLocalizedString(@"取消收藏", @"") onBackButton:itemDetailViewController.favouriteButton leftCapWidth:20.0];

    }
    else {
//        [customNavigationBar setText:NSLocalizedString(@"收藏", @"") onBackButton:itemDetailViewController.favouriteButton leftCapWidth:20.0];
    }
}

- (void)boundItemValues:(BOOL)visiable
{
    isVisiable = visiable;
    
    DataEngine *dataEngine = [DataEngine sharedDataEngine];
    
    Treasure *treasure = [dataEngine.treasures objectForKey:treasureId];

    [similarView setBackgroundColor:[UIColor clearColor]];

    [[similarView viewWithTag:DETAIL_VIEW_SIMILAR_TAG] removeFromSuperview];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:detailBackground];
    [backgroundImageView setFrame:CGRectMake(0, 0, similarView.frame.size.width, 111)];
    [backgroundImageView setTag:DETAIL_VIEW_SIMILAR_TAG];
    [similarView insertSubview:backgroundImageView atIndex:0];
    
    if (treasure && [treasure isKindOfClass:[TreasureDetail class]]) {
        if (treasure.picUrl && [treasure.picUrl length] > 0) {
            NSString *realUrl = [NSString stringWithFormat:@"%@_%@.jpg", treasure.picUrl, [dataEngine getImageSize:kImageSizeDetail]];
            NSString *imagePath = [[ImageCacheEngine sharedInstance] getImagePathByUrl:realUrl];
            if(imagePath){
                UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
                
                CGFloat offset = 0.0;
                CGFloat height = image.size.height * 300.0 / image.size.width;
                offset += height - mainItemImage.frame.size.height;
                mainItemImage.image = image;
                [self extendTopViewHeight:offset];
            }
            else if (isVisiable) {
                [self requestDownloadImage:realUrl];
            }
        }
        else {
            mainItemImage.image = [UIImage imageNamed:@"noPicLarge.png"];
        }
        
        priceLabel.text = [NSString stringWithFormat:@"¥%1.2f", [treasure.price floatValue]];
        CGSize priceSize = [priceLabel.text sizeWithFont:priceLabel.font
                                       constrainedToSize:CGSizeMake(120, CGFLOAT_MAX)
                                           lineBreakMode:UILineBreakModeWordWrap];
        priceSize.width += 10;
        CGFloat offset = priceLabel.frame.size.width - priceSize.width;
        priceLabel.frame = CGRectMake(priceLabel.frame.origin.x + offset, priceLabel.frame.origin.y, priceSize.width, priceLabel.frame.size.height);
        [priceLabel.layer setCornerRadius:4];
        [priceLabel.layer setMasksToBounds:YES];
        titleLabel.frame = CGRectMake(10, titleLabel.frame.origin.y, 302 - priceLabel.frame.size.width - 20, titleLabel.frame.size.height);
        titleLabel.text = treasure.title;
        
//        sellerNameLabel.text = ((TreasureDetail *)treasure).nick;
//        TBSeller *seller = [dataEngine getTBSellerByNick:((TreasureDetail *)treasure).nick];
//        if (seller) {
            [self resortSellerCredits];
            [self extendSellerViewHeight];
//        }
//        else if (isVisiable) {
//            [dataEngine getTBSellerInfo:((TreasureDetail *)treasure).nick from:_controllerId];
//        }
        
//        sellerLabel.text = NSLocalizedString(@"宝贝来源", @"");
        commentLabel.text = NSLocalizedString(@"评价详情", @"");
        detailLabel.text = NSLocalizedString(@"宝贝详情", @"");
        similarLabel.text = NSLocalizedString(@"相关热卖", @"");
        
        if (isVisiable) {
            [commentLabelsArray removeAllObjects];
            CGFloat offset = 0;
            int count = 0;
            for (Rate *comment in ((TreasureDetail *)treasure).rate) {
                if (comment) {
                    CGFloat offsetone = [self addComment:comment addSubView:YES];
                    offset += offsetone;
                    count ++;
                }
                if (count >= 5) {
                    break;
                }
            }
            
            if (count == 0) {
                Rate *commentNone = [[Rate alloc] init];
                commentNone.nick = NSLocalizedString(@"暂无评论", @"");
                commentNone.content = @"";
                CGFloat offsetone = [self addComment:commentNone addSubView:NO];
                offset += offsetone;
            }
            
            offset -= commentTableView.frame.size.height;
            [commentTableView reloadData];
            [self extendCommentViewHeight:offset];
            
            for (UIView *view in detailImagesView.subviews) {
                [view removeFromSuperview];
            }
            
            int imgIndex = 1;
            CGFloat dy = 0.0;
            CGFloat offsetImg = 0.0;
            for (NSString *imgUrl in ((TreasureDetail *)treasure).images) {
                UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(4.0, dy, 294.0, 1.0)];
                imgView.tag = imgIndex;
                
                NSString *imagePath = [[ImageCacheEngine sharedInstance] getImagePathByUrl:imgUrl];
                if(imagePath){
                    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
                    imgView.image = image;
                    
                    CGFloat height = image.size.height * 294.0 / image.size.width;
                    
                    imgView.frame = CGRectMake(4, dy, 294.0, height);
                    dy += height;
                    offsetImg += height;
                }
                else{
                    [self requestDownloadImage:imgUrl];
                    dy += 1.0;
                    offsetImg += 1.0;
                }

                imgIndex ++;
                [detailImagesView addSubview:imgView];
            }
            
            [self extendDetailViewHeight:offsetImg];
            
            if ([similarItemsArray count] == 0) {
                [dataEngine getOtherItems:treasureId from:_controllerId];
            }
            
            itemDetailViewController.buyButton.enabled = YES;
        }
    }
    else if (treasure) {
        if (treasure.picUrl && [treasure.picUrl length] > 0) {
            NSString *realUrl = [NSString stringWithFormat:@"%@_%@.jpg", treasure.picUrl, [dataEngine getImageSize:kImageSizeDetail]];
            NSString *imagePath = [[ImageCacheEngine sharedInstance] getImagePathByUrl:realUrl];
            if(imagePath){
                UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
                mainItemImage.image = image;
            }
            else if (isVisiable) {
                [self requestDownloadImage:realUrl];
            }
        }
        else {
            mainItemImage.image = [UIImage imageNamed:@"noPicLarge.png"];
        }
        
        priceLabel.text = [NSString stringWithFormat:@"¥%1.2f", [treasure.price floatValue]];
        CGSize priceSize = [priceLabel.text sizeWithFont:priceLabel.font
                                       constrainedToSize:CGSizeMake(120, CGFLOAT_MAX)
                                           lineBreakMode:UILineBreakModeWordWrap];
        priceSize.width += 10;
        CGFloat offset = priceLabel.frame.size.width - priceSize.width;
        priceLabel.frame = CGRectMake(priceLabel.frame.origin.x + offset, priceLabel.frame.origin.y, priceSize.width, priceLabel.frame.size.height);
        [priceLabel.layer setCornerRadius:4];
        [priceLabel.layer setMasksToBounds:YES];
        titleLabel.frame = CGRectMake(10, titleLabel.frame.origin.y, 302 - priceLabel.frame.size.width - 20, titleLabel.frame.size.height);
        titleLabel.text = treasure.title;
        
//        sellerLabel.text = NSLocalizedString(@"宝贝来源", @"");
        commentLabel.text = NSLocalizedString(@"评价详情", @"");
        detailLabel.text = NSLocalizedString(@"宝贝详情", @"");
        similarLabel.text = NSLocalizedString(@"相似款比价", @"");
        
        if (isVisiable) {
            [commentLabelsArray removeAllObjects];
            CGFloat offset = 0;
            Rate *commentNone = [[Rate alloc] init];
            commentNone.nick = NSLocalizedString(@"暂无评论", @"");
            commentNone.content = @"";
            CGFloat offsetone = [self addComment:commentNone addSubView:NO];
            offset += offsetone;
            
            offset -= commentTableView.frame.size.height;
            [commentTableView reloadData];
            [self extendCommentViewHeight:offset];
            
            [dataEngine getItemDetail:treasureId from:_controllerId];
            
            itemDetailViewController.buyButton.enabled = NO;
        }
    }
    else {
        if (isVisiable) {
            AppDelegate *delegate= (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [delegate showActivityView:NSLocalizedString(@"正在载入...", @"") inView:delegate.window];
            [dataEngine getItemDetail:treasureId from:_controllerId];
            
            itemDetailViewController.buyButton.enabled = NO;
        }
    }
    float height = similarView.frame.size.height + similarView.frame.origin.y + BOTTOM_DETAIL_HEIGHT;
    NSLog(@"height:%f", height);
    [bodyScrollView setContentSize:CGSizeMake(320.0, similarView.frame.size.height + similarView.frame.origin.y + BOTTOM_DETAIL_HEIGHT)];

}

- (void)setVisiable
{
    if (isVisiable) {
        return;
    }
    
    isVisiable = YES;
    
    DataEngine *dataEngine = [DataEngine sharedDataEngine];
    
    Treasure *treasure = [dataEngine.treasures objectForKey:treasureId];
    if (treasure && [treasure isKindOfClass:[TreasureDetail class]]) {
        if (treasure.picUrl && [treasure.picUrl length] > 0) {
            NSString *realUrl = [NSString stringWithFormat:@"%@_%@.jpg", treasure.picUrl, [dataEngine getImageSize:kImageSizeDetail]];
            NSString *imagePath = [[ImageCacheEngine sharedInstance] getImagePathByUrl:realUrl];
            if(imagePath == nil){
                [self requestDownloadImage:realUrl];
            }
        }
        
//        TBSeller *seller = [dataEngine getTBSellerByNick:((TreasureDetail *)treasure).nick];
//        if (seller == nil) {
//            [dataEngine getTBSellerInfo:((TreasureDetail *)treasure).nick from:_controllerId];
//        }
        
        [commentLabelsArray removeAllObjects];
        CGFloat offset = 0;
        int count = 0;
        for (Rate *comment in ((TreasureDetail *)treasure).rate) {
            if (comment) {
                CGFloat offsetone = [self addComment:comment addSubView:YES];
                offset += offsetone;
                count ++;
            }
            if (count >= 5) {
                break;
            }
        }
        
        if (count == 0) {
            Rate *commentNone = [[Rate alloc] init];
            commentNone.nick = NSLocalizedString(@"暂无评论", @"");
            commentNone.content = @"";
            CGFloat offsetone = [self addComment:commentNone addSubView:NO];
            offset += offsetone;
        }
        
        offset -= commentTableView.frame.size.height;
        [commentTableView reloadData];
        [self extendCommentViewHeight:offset];
        
        for (UIView *view in detailImagesView.subviews) {
            [view removeFromSuperview];
        }
        
        int imgIndex = 1;
        CGFloat dy = 0.0;
        CGFloat offsetImg = 0.0;
        for (NSString *imgUrl in ((TreasureDetail *)treasure).images) {
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, dy, 280.0, 1.0)];
            imgView.tag = imgIndex;
            
            NSString *imagePath = [[ImageCacheEngine sharedInstance] getImagePathByUrl:imgUrl];
            if(imagePath){
                UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
                imgView.image = image;
                
                CGFloat height = image.size.height * 280.0 / image.size.width;
                
                imgView.frame = CGRectMake(10.0, dy, 280.0, height);
                dy += height;
                offsetImg += height;
            }
            else{
                [self requestDownloadImage:imgUrl];
                dy += 1.0;
                offsetImg += 1.0;
            }
            
            imgIndex ++;
            [detailImagesView addSubview:imgView];
        }
        
        [self extendDetailViewHeight:offsetImg];
        
        if ([similarItemsArray count] == 0) {
            [dataEngine getOtherItems:treasureId from:_controllerId];
        }
        
        itemDetailViewController.buyButton.enabled = YES;
    }
    else if (treasure) {
        if (treasure.picUrl && [treasure.picUrl length] > 0) {
            NSString *realUrl = [NSString stringWithFormat:@"%@_%@.jpg", treasure.picUrl, [dataEngine getImageSize:kImageSizeDetail]];
            NSString *imagePath = [[ImageCacheEngine sharedInstance] getImagePathByUrl:realUrl];
            if(imagePath == nil){
                [self requestDownloadImage:realUrl];
            }
        }
        
        [commentLabelsArray removeAllObjects];
        CGFloat offset = 0;
        Rate *commentNone = [[Rate alloc] init];
        commentNone.nick = NSLocalizedString(@"暂无评论", @"");
        commentNone.content = @"";
        CGFloat offsetone = [self addComment:commentNone addSubView:NO];
        offset += offsetone;
        
        offset -= commentTableView.frame.size.height;
        [commentTableView reloadData];
        [self extendCommentViewHeight:offset];
        
        [dataEngine getItemDetail:treasureId from:_controllerId];
        
        itemDetailViewController.buyButton.enabled = NO;
    }
    else {
        AppDelegate *delegate= (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [delegate showActivityView:NSLocalizedString(@"正在载入...", @"") inView:delegate.window];
        [dataEngine getItemDetail:treasureId from:_controllerId];
        
        itemDetailViewController.buyButton.enabled = NO;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    return [commentLabelsArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ((UIView*)[commentLabelsArray objectAtIndex:indexPath.row]).frame.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ItemDetailCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    else {
        for (UIView* view in [cell subviews]) {
            if(view.tag == CELLTAG)
            {
                [view removeFromSuperview];
            }
        }
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    UIView *view = ((UIView*)[commentLabelsArray objectAtIndex:indexPath.row]);
    [cell addSubview:view];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)addComment:(Rate*)comment addSubView:(BOOL)addSubView
{
    CGSize labelSize;
    if(addSubView){
        RTLabel *label = [[RTLabel alloc] initWithFrame:CGRectMake(10, 0, 280, 1600)];
        [label setParagraphReplacement:@""];
        label.font = [UIFont systemFontOfSize:12];
        label.textColor = [UIColor grayColor];
        [label setLineSpacing:5];
        
        //[label setText:[NSString stringWithFormat:NSLocalizedString(@"<font color='#FF8D1D'><b>%1$@</b></font>  <font color='#BEBEBE'>(%2$@)</font>\n<font color='#5B5B5B'>%3$@</font>", @""), comment.nick, comment.created, comment.content]];
        NSString *deal = comment.nick;
        if (deal == nil || [deal length] == 0) {
//            deal = NSLocalizedString(@"默认款式", @"");
        }
        [label setText:[NSString stringWithFormat:NSLocalizedString(@"<font color='#ff8d1d' size=10>%1$@</font>\n<font color='#5B5B5B' size=10>%2$@</font>", @""), deal, [comment.content stringByTrimmingBoth]]];
        labelSize = [label optimumSize];
        labelSize.height += 5;
        label.frame = CGRectMake(10, 2, 280, labelSize.height);
        
        UIView *cellView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, label.frame.size.height)];
        [cellView addSubview:label];
        
        UIImageView *line = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"detailCommentSplit.png"]];
        [cellView addSubview:line];
        line.frame = CGRectMake(0, cellView.frame.size.height, 300, 2);
        
        cellView.tag = CELLTAG;
        [commentLabelsArray addObject:cellView];
        return labelSize.height;
    }
    else{
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 35)];
        label.font = [UIFont systemFontOfSize:12];
        label.textColor = [UIColor grayColor];
        label.textAlignment = UITextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        [label setText:[NSString stringWithFormat:NSLocalizedString(@"%@", @""), comment.nick]];
        UIView *cellView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 35)];
        [cellView addSubview:label];
        cellView.tag = CELLTAG;
        [commentLabelsArray addObject:cellView];
        labelSize = label.frame.size;
        return labelSize.height;
    }
}

- (void)extendTopViewHeight:(CGFloat)offset
{
    topView.frame = CGRectMake(topView.frame.origin.x, topView.frame.origin.y, topView.frame.size.width, topView.frame.size.height + offset);
    mainItemImage.frame = CGRectMake(mainItemImage.frame.origin.x, mainItemImage.frame.origin.y, mainItemImage.frame.size.width, mainItemImage.frame.size.height + offset);
    titleView.frame = CGRectMake(titleView.frame.origin.x, titleView.frame.origin.y + offset, titleView.frame.size.width, titleView.frame.size.height);
    topShadowImage.frame = CGRectMake(topShadowImage.frame.origin.x, topShadowImage.frame.origin.y + offset, topShadowImage.frame.size.width, topShadowImage.frame.size.height);
    
//    sellerView.frame = CGRectMake(sellerView.frame.origin.x, sellerView.frame.origin.y + offset, sellerView.frame.size.width, sellerView.frame.size.height);
    commentView.frame = CGRectMake(commentView.frame.origin.x, commentView.frame.origin.y + offset, commentView.frame.size.width, commentView.frame.size.height);
    detailView.frame = CGRectMake(detailView.frame.origin.x, detailView.frame.origin.y + offset, detailView.frame.size.width, detailView.frame.size.height);
    similarView.frame = CGRectMake(similarView.frame.origin.x, similarView.frame.origin.y + offset, similarView.frame.size.width, similarView.frame.size.height);
    
    [bodyScrollView setContentSize:CGSizeMake(bodyScrollView.contentSize.width,similarView.frame.size.height + similarView.frame.origin.y + BOTTOM_DETAIL_HEIGHT)];
    
    [[topView viewWithTag:DETAIL_VIEW_TOP_TAG] removeFromSuperview];
    UIImageView *detailViewBackgroundView = [[UIImageView alloc] initWithImage:detailBackground];
    [detailViewBackgroundView setFrame:CGRectMake(0, 0, topView.frame.size.width, topView.frame.size.height)];
    [detailViewBackgroundView setTag:DETAIL_VIEW_TOP_TAG];
    [topView insertSubview:detailViewBackgroundView atIndex:0];
    

    [[commentView viewWithTag:DETAIL_VIEW_COMMENT_TAG] removeFromSuperview];
    UIImageView *detailViewBackgroundView2 = [[UIImageView alloc] initWithImage:detailBackground];
    [detailViewBackgroundView2 setFrame:CGRectMake(0, 0, commentView.frame.size.width, commentView.frame.size.height)];
    [detailViewBackgroundView2 setTag:DETAIL_VIEW_COMMENT_TAG];
    [commentView insertSubview:detailViewBackgroundView2 atIndex:0];
    [bodyScrollView setContentSize:CGSizeMake(bodyScrollView.contentSize.width,similarView.frame.size.height + similarView.frame.origin.y + BOTTOM_DETAIL_HEIGHT)];

    [[detailView viewWithTag:DETAIL_VIEW_IMAGES_TAG] removeFromSuperview];
    UIImageView *detailViewBackgroundView3 = [[UIImageView alloc] initWithImage:detailBackground];
    [detailViewBackgroundView3 setFrame:CGRectMake(0, 0, detailView.frame.size.width, detailView.frame.size.height)];
    [detailViewBackgroundView3 setTag:DETAIL_VIEW_IMAGES_TAG];
    [detailView insertSubview:detailViewBackgroundView3 atIndex:0];
}

- (void)extendSellerViewHeight
{
//    return;
    CGFloat offset = SELLERVIEWHEIGHT + SPACERHEIGHT;
    commentView.frame = CGRectMake(commentView.frame.origin.x, commentView.frame.origin.y + offset, commentView.frame.size.width, commentView.frame.size.height);
//    if (sellerView.frame.size.height == 0) {
//        sellerView.hidden = NO;
//        sellerView.frame = CGRectMake(sellerView.frame.origin.x, sellerView.frame.origin.y, sellerView.frame.size.width, SELLERVIEWHEIGHT);
    
//        detailView.frame = CGRectMake(detailView.frame.origin.x, detailView.frame.origin.y + offset, detailView.frame.size.width, detailView.frame.size.height);
//        similarView.frame = CGRectMake(similarView.frame.origin.x, similarView.frame.origin.y + offset, similarView.frame.size.width, similarView.frame.size.height);
        
//        [scrollView setContentSize:CGSizeMake(scrollView.contentSize.width,scrollView.contentSize.height + offset)];
//    }
//    [sellerView setHidden:YES];

}

- (void)resortSellerCredits
{
//    [sellerView setHidden:YES];
//    DataEngine *dataEngine = [DataEngine sharedDataEngine];
//    Treasure *treasure = [dataEngine.treasures objectForKey:treasureId];
//    TBSeller *seller = [dataEngine getTBSellerByNick:((TreasureDetail *)treasure).nick];
//    if (seller == nil) {
//        return;
//    }
//    
//    if (seller.avatar && [seller.avatar length] > 0) {
//        NSString *imagePath = [[ImageCacheEngine sharedInstance] getImagePathByUrl:seller.avatar];
//        if(imagePath){
//            UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
//            sellerAvatarImage.image = image;
//        }
//        else if (isVisiable) {
//            [dataEngine downloadFileByUrl:seller.avatar type:kDownloadFileTypeImageAvatar from:_controllerId];
//        }
//    }
//    
//    sellerLocationLabel.text = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"所在地：", @""), seller.location];
//    sellerLocationLabel.text = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"所在地：", @""), ((TreasureDetail *)treasure).location];
//    sellerRateLabel.text = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"好评率：", @""), seller.goodRate];
    
//    for (UIView *view in sellerInfoView.subviews) {
//        if (view.tag == CREDITSTAG) {
//            [view removeFromSuperview];
//        }
//    }
    
//    CGFloat dx = 60.0;
    
//    int score = [seller.sellerCredit intValue];
//    int score = [treasure.sellerCredit intValue];
    
    // 桃心
//    if (score >= 1 && score <= 5) {
//        for (int i = 0; i < score; i++) {
//            UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(i * 10 + dx, sellerRateLabel.frame.origin.y, 10, 10)];
//            [iv setImage:[UIImage imageNamed:@"credit_tx.png"]];
//            iv.tag = CREDITSTAG;
//            [sellerInfoView addSubview:iv];
//        }
//        
//        dx += score * 10;
//    }
    // 钻石
//    else if (score >= 6 && score <= 10) {
//        for (int i = 0; i < score - 5; i++) {
//            UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(i * 10 + dx, sellerRateLabel.frame.origin.y, 10, 10)];
//            [iv setImage:[UIImage imageNamed:@"credit_zs.png"]];
//            iv.tag = CREDITSTAG;
//            [sellerInfoView addSubview:iv];
//        }
//        
//        dx += (score - 5) * 10;
//    }
    // 蓝冠
//    else if (score >= 11 && score <= 15) {
//        for (int i = 0; i < score - 10; i++) {
//            UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(i * 10 + dx, sellerRateLabel.frame.origin.y, 10, 10)];
//            [iv setImage:[UIImage imageNamed:@"credit_lg.png"]];
//            iv.tag = CREDITSTAG;
//            [sellerInfoView addSubview:iv];
//        }
//        
//        dx += (score - 10) * 10;
//    }
//    // 皇冠
//    else if (score >= 16 && score <= 20) {
//        for (int i = 0; i < score - 15; i++) {
//            UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(i * 10 + dx, sellerRateLabel.frame.origin.y, 10, 10)];
//            [iv setImage:[UIImage imageNamed:@"credit_hg.png"]];
//            iv.tag = CREDITSTAG;
//            [sellerInfoView addSubview:iv];
//        }
//        
//        dx += (score - 15) * 10;
//    }
    
    //分割线
//    UIImageView *sp = [[UIImageView alloc] initWithFrame:CGRectMake(dx + 2, sellerRateLabel.frame.origin.y, 1, 10)];
//    [sp setImage:[UIImage imageNamed:@"vSplitLine.png"]];
//    sp.tag = CREDITSTAG;
//    [sellerInfoView addSubview:sp];
//    
//    dx += 5;
    
//    if (seller.isConsumerProtection) {
//        UIImageView *cp = [[UIImageView alloc] initWithFrame:CGRectMake(dx, sellerRateLabel.frame.origin.y, 10, 10)];
//        [cp setImage:[UIImage imageNamed:@"credit_cp.png"]];
//        cp.tag = CREDITSTAG;
//        [sellerInfoView addSubview:cp];
//        
//        dx += 10;
//        
//        //分割线
//        UIImageView *sp = [[UIImageView alloc] initWithFrame:CGRectMake(dx + 2, sellerRateLabel.frame.origin.y, 1, 10)];
//        [sp setImage:[UIImage imageNamed:@"vSplitLine.png"]];
//        sp.tag = CREDITSTAG;
//        [sellerInfoView addSubview:sp];
//        
//        dx += 5;
//    }

//    if (seller.isGoldenSeller) {
//        UIImageView *gs = [[UIImageView alloc] initWithFrame:CGRectMake(dx, sellerRateLabel.frame.origin.y, 10, 10)];
//        [gs setImage:[UIImage imageNamed:@"credit_hg.png"]];
//        gs.tag = CREDITSTAG;
//        [sellerInfoView addSubview:gs];
//        
//        dx += 10;
//        
//        //分割线
//        UIImageView *sp = [[UIImageView alloc] initWithFrame:CGRectMake(dx + 2, sellerRateLabel.frame.origin.y, 1, 10)];
//        [sp setImage:[UIImage imageNamed:@"vSplitLine.png"]];
//        sp.tag = CREDITSTAG;
//        [sellerInfoView addSubview:sp];
//        
//        dx += 5;
//    }

//    sellerRateLabel.frame = CGRectMake(dx, sellerRateLabel.frame.origin.y, sellerRateLabel.frame.size.width, sellerRateLabel.frame.size.height);
}

- (void)extendCommentViewHeight:(CGFloat)offset
{
    commentView.frame = CGRectMake(commentView.frame.origin.x, commentView.frame.origin.y, commentView.frame.size.width, commentView.frame.size.height + offset);
    commentTableView.frame = CGRectMake(commentTableView.frame.origin.x, commentTableView.frame.origin.y, commentTableView.frame.size.width, commentTableView.frame.size.height + offset);
    commentShadowImage.frame = CGRectMake(commentShadowImage.frame.origin.x, commentShadowImage.frame.origin.y + offset, commentShadowImage.frame.size.width, commentShadowImage.frame.size.height);
    
    detailView.frame = CGRectMake(detailView.frame.origin.x, detailView.frame.origin.y + offset, detailView.frame.size.width, detailView.frame.size.height);
    similarView.frame = CGRectMake(similarView.frame.origin.x, similarView.frame.origin.y + offset, similarView.frame.size.width, similarView.frame.size.height);
    
    [bodyScrollView setContentSize:CGSizeMake(bodyScrollView.contentSize.width,similarView.frame.size.height + similarView.frame.origin.y + BOTTOM_DETAIL_HEIGHT)];
    
    [[commentView viewWithTag:DETAIL_VIEW_COMMENT_TAG] removeFromSuperview];
    UIImageView *detailViewBackgroundView2 = [[UIImageView alloc] initWithImage:detailBackground];
    [detailViewBackgroundView2 setFrame:CGRectMake(0, 0, commentView.frame.size.width, commentView.frame.size.height)];
    [detailViewBackgroundView2 setTag:DETAIL_VIEW_COMMENT_TAG];
    [commentView insertSubview:detailViewBackgroundView2 atIndex:0];

}

- (void)extendDetailViewHeight:(CGFloat)offset
{
    detailView.frame = CGRectMake(detailView.frame.origin.x, detailView.frame.origin.y, detailView.frame.size.width, detailView.frame.size.height + offset);
    detailImagesView.frame = CGRectMake(detailImagesView.frame.origin.x, detailImagesView.frame.origin.y, detailImagesView.frame.size.width, detailImagesView.frame.size.height + offset);
    detailShadowImage.frame = CGRectMake(detailShadowImage.frame.origin.x, detailShadowImage.frame.origin.y + offset, detailShadowImage.frame.size.width, detailShadowImage.frame.size.height);
    
    similarView.frame = CGRectMake(similarView.frame.origin.x, similarView.frame.origin.y + offset, similarView.frame.size.width, similarView.frame.size.height);
    
    [bodyScrollView setContentSize:CGSizeMake(bodyScrollView.contentSize.width,similarView.frame.size.height + similarView.frame.origin.y + BOTTOM_DETAIL_HEIGHT)];

    [[detailView viewWithTag:DETAIL_VIEW_IMAGES_TAG] removeFromSuperview];
    UIImageView *detailViewBackgroundView = [[UIImageView alloc] initWithImage:detailBackground];
    [detailViewBackgroundView setFrame:CGRectMake(0, 0, detailView.frame.size.width, detailView.frame.size.height)];
    [detailViewBackgroundView setTag:DETAIL_VIEW_IMAGES_TAG];
    [detailView insertSubview:detailViewBackgroundView atIndex:0];
}

- (void)extendSimilarViewHeight
{
    if (hideSimilar) {
        return;
    }
    if (similarView.frame.size.height == 0) {
        similarView.hidden = NO;
        similarView.frame = CGRectMake(similarView.frame.origin.x, similarView.frame.origin.y, similarView.frame.size.width, SIMILARVIEWHEIGHT);
//        CGFloat offset = SIMILARVIEWHEIGHT;// + SPACERHEIGHT * 2;
        [bodyScrollView setContentSize:CGSizeMake(bodyScrollView.contentSize.width,similarView.frame.size.height + similarView.frame.origin.y + BOTTOM_DETAIL_HEIGHT)];
    }
}

- (void)resortSimilarItems
{
    DataEngine *dataEngine = [DataEngine sharedDataEngine];
    float contentWidth = 0;
    if ([similarItemsArray count] <= 3) {
        [scrollToLeft setHidden:YES];
        [scrollToRight setHidden:YES];
    } else {
        [scrollToLeft setHidden:NO];
        [scrollToRight setHidden:NO];
        [scrollToLeft setAlpha:0];
        [scrollToRight setAlpha:1.0f];
    }
    for (int i = 0; i < [similarItemsArray count]; i ++) {
        UIButton *button = (UIButton *)[similarInfoView viewWithTag:i + 1];
        UIImageView *buttonBackground = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"detailBackground"] stretchableImageWithLeftCapWidth:25 topCapHeight:25]];
        Treasure *treasure = [similarItemsArray objectAtIndex:i];

        if (!button) {
            float x = 0;
            if (i > 0) {
                x = i * 81;
            }
            button = [[UIButton alloc] initWithFrame:CGRectMake(x + 1, 1, 77, 77)];
            [buttonBackground setFrame:CGRectMake(x, 0, 79, 79)];
            [similarInfoView addSubview:buttonBackground];
//            [button setBackgroundImage:[[UIImage imageNamed:@"detailBackground"] stretchableImageWithLeftCapWidth:25 topCapHeight:25] forState:UIControlStateNormal];
            [button setTag:SIMILARIMAGETAG + i + 1];
            [similarInfoView addSubview:button];
            
            // 价格
            UILabel *pLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 60, 60, 16)];
            [pLabel setBackgroundColor:[UIColor colorWithRed:228.0 / 255.0 green:68.0 / 255.0 blue:13.0 / 255.0 alpha:1.0]];
            [pLabel setTextColor:[UIColor whiteColor]];
            [pLabel setFont:[UIFont systemFontOfSize:12]];
            [pLabel setTextAlignment:NSTextAlignmentCenter];
            [pLabel.layer setCornerRadius:4];
            [pLabel.layer setMasksToBounds:YES];
            pLabel.text = [NSString stringWithFormat:@"¥%1.2f", [treasure.price floatValue]];
            
            CGSize priceSize = [pLabel.text sizeWithFont:pLabel.font
                                       constrainedToSize:CGSizeMake(70, CGFLOAT_MAX)
                                           lineBreakMode:UILineBreakModeWordWrap];
            pLabel.frame = CGRectMake(button.frame.size.width - priceSize.width - 13, button.frame.size.height + button.frame.origin.y - 20, priceSize.width + 10, 16);
            
            [button addSubview:pLabel];

        }
        if (button && treasure) {
//            UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"recommendItemEmpty.png"]];
//            image.tag = SIMILARIMAGETAG;
//            image.frame = CGRectMake(0, 0, 77, 77);
//            [button setImage:[UIImage imageNamed:@"recommendItemEmpty.png"] forState:UIControlStateNormal];

            if (treasure.picUrl && [treasure.picUrl length] > 0) {
                NSString *realUrl = [NSString stringWithFormat:@"%@_%@.jpg", treasure.picUrl, [dataEngine getImageSize:kImageSizeThumb]];
                NSString *imagePath = [[ImageCacheEngine sharedInstance] getImagePathByUrl:realUrl];
                if (imagePath) {
                    UIImage *imageThumb = [UIImage imageWithContentsOfFile:imagePath];
                    [button setImage:imageThumb forState:UIControlStateNormal];
                } else {
                    //下载图片
                    [self requestDownloadImage:realUrl];
                }
            }
            

//            int score = [treasure.sellerCredit intValue];
            
            // 桃心
//            if (score >= 1 && score <= 5) {
//                for (int i = 0; i < score; i++) {
//                    UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(i * 10, 92, 10, 10)];
//                    [iv setImage:[UIImage imageNamed:@"credit_tx.png"]];
//                    
//                    [button addSubview:iv];
//                }
//            }
//            // 钻石
//            else if (score >= 6 && score <= 10) {
//                for (int i = 0; i < score - 5; i++) {
//                    UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(i * 10, 92, 10, 10)];
//                    [iv setImage:[UIImage imageNamed:@"credit_zs.png"]];
//                    
//                    [button addSubview:iv];
//                }
//            }
//            // 蓝冠
//            else if (score >= 11 && score <= 15) {
//                for (int i = 0; i < score - 10; i++) {
//                    UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(i * 10, 92, 10, 10)];
//                    [iv setImage:[UIImage imageNamed:@"credit_lg.png"]];
//                    
//                    [button addSubview:iv];
//                }
//            }
//            // 皇冠
//            else if (score >= 16 && score <= 20) {
//                for (int i = 0; i < score - 15; i++) {
//                    UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(i * 10, 92, 10, 10)];
//                    [iv setImage:[UIImage imageNamed:@"credit_hg.png"]];
//                    
//                    [button addSubview:iv];
//                }
//            }
            
            button.hidden = NO;
            [button addTarget:self action:@selector(openOthers:) forControlEvents:UIControlEventTouchUpInside];
            contentWidth = buttonBackground.frame.origin.x + buttonBackground.frame.size.width;
        }
        [similarInfoView setContentSize:CGSizeMake(contentWidth, 111)];
    }
}

- (Treasure*)getTreasure
{
    DataEngine *dataEngine = [DataEngine sharedDataEngine];
    Treasure *theTreasure = [dataEngine.treasures objectForKey:treasureId];
    if (theTreasure) {
        return theTreasure;
    }
    
    return nil;
}

- (void)requestDownloadImage:(NSString *)picUrl {
    DataEngine *dataEngine = [DataEngine sharedDataEngine];
    [dataEngine downloadFileByUrl:picUrl type:kDownloadFileTypeImage from:_controllerId];
}

- (void)responseDownloadFile:(NSNotification *)notification {
    NSDictionary *dictionary = (NSDictionary *)[notification userInfo];
    if (![[dictionary objectForKey:REQUEST_SOURCE_KEY] isEqualToString:_controllerId]) {
        return;
    }
    
    NSNumber *downloadType = [dictionary objectForKey:TOUI_PARAM_DOWNLOADFILE_FILETYPE];
    NSString *downloadUrl = [dictionary objectForKey:TOUI_PARAM_DOWNLOADFILE_FILEURL];
    
    if ([downloadType intValue] == kDownloadFileTypeImage) {
        NSString *imagePath = [dictionary objectForKey:TOUI_PARAM_DOWNLOADFILE_FILEPATH];
        UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
        if (image) {
            DataEngine *dataEngine = [DataEngine sharedDataEngine];
            NSString *realTreasureDetailUrl = [NSString stringWithFormat:@"%@_%@.jpg", self.treasure.picUrl, [dataEngine getImageSize:kImageSizeDetail]];
            if ([realTreasureDetailUrl isEqualToString:downloadUrl]) {
                CGFloat offset = 0.0;
                CGFloat height = image.size.height * 300.0 / image.size.width;
                offset += height - mainItemImage.frame.size.height;
                mainItemImage.image = image;
                [self extendTopViewHeight:offset];
            }
            else {
                BOOL otherItemImageFound = NO;
                if (similarItemsArray && [similarItemsArray count] > 0) {
                    int index = 0;
                    for (Treasure *t in similarItemsArray) {
                        NSString *realThumbUrl = [NSString stringWithFormat:@"%@_%@.jpg", t.picUrl, [dataEngine getImageSize:kImageSizeThumb]];
                        if ([realThumbUrl isEqualToString:downloadUrl]) {
                            UIButton *button = (UIButton *)[similarInfoView viewWithTag:SIMILARIMAGETAG + index + 1];
                            if (button) {
                                [button setImage:image forState:UIControlStateNormal];
//                                UIImageView *imageView = (UIImageView *)[button viewWithTag:SIMILARIMAGETAG];
//                                if (imageView) {
//                                    imageView.image = image;
//                                }
                            }
                            
                            otherItemImageFound = YES;
                            break;
                        }
                        index ++;
                    }
                }
                
                if (!otherItemImageFound) {
                    int imgIndex = 1;
                    CGFloat offset = 0.0;
                    BOOL imageFound = NO;
                    
                    DataEngine *dataEngine = [DataEngine sharedDataEngine];
                    Treasure *theTreasure = [dataEngine.treasures objectForKey:treasureId];
                    if (theTreasure && [theTreasure isKindOfClass:[TreasureDetail class]]) {
                        for (NSString *imgUrl in ((TreasureDetail *)theTreasure).images) {
                            UIImageView *imgView = (UIImageView *)[detailImagesView viewWithTag:imgIndex];
                            if ([imgUrl isEqualToString:downloadUrl]) {
                                imgView.image = image;
                                CGFloat height = image.size.height * 280.0 / image.size.width;
                                offset += height - imgView.frame.size.height;
                                imgView.frame = CGRectMake(imgView.frame.origin.x, imgView.frame.origin.y, imgView.frame.size.width, height);
                                [self extendDetailViewHeight:offset];
                                imageFound = YES;
                            }
                            else {
                                if (imageFound) {
                                    imgView.frame = CGRectMake(imgView.frame.origin.x, imgView.frame.origin.y + offset, imgView.frame.size.width, imgView.frame.size.height);
                                }
                            }
                            
                            imgIndex ++;
                        }
                    }
                }
            }
        }
    }
    else if ([downloadType intValue] == kDownloadFileTypeImageAvatar) {
//        NSString *imagePath = [dictionary objectForKey:TOUI_PARAM_DOWNLOADFILE_FILEPATH];
//        UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
//        if (image) {
//            sellerAvatarImage.image = image;
//        }
    }
}

- (void)responseGetItemDetail:(NSNotification *)notification {
    NSDictionary *dictionary = (NSDictionary *)[notification userInfo];
    if (![[dictionary objectForKey:REQUEST_SOURCE_KEY] isEqualToString:_controllerId]) {
        return;
    }
    
    NSNumber *returnCode = [dictionary objectForKey:RETURN_CODE];
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (returnCode && [returnCode isKindOfClass:[NSNumber class]] && [returnCode intValue] == NO_ERROR) {
        NSNumber* tid = [dictionary objectForKey:TOUI_PARAM_TREASURE_DETAIL_ITEMID];
        if (tid) {
            [delegate hideActivityView:delegate.window];
            [self boundItemValues:YES];
        }
        else {
            [delegate showFailedActivityView:NSLocalizedString(@"宝贝出错", @"") interval:ERROR_MESSAGE_SHOW_INTERVAL_NORMAL inView:delegate.window];
        }
    } else {
        [delegate showFailedActivityView:[dictionary objectForKey:TOUI_REQUEST_ERROR_MESSAGE] interval:ERROR_MESSAGE_SHOW_INTERVAL_NORMAL inView:delegate.window];
    }
}

- (void)responseGetSellerInfo:(NSNotification *)notification
{
    NSDictionary *dictionary = (NSDictionary *)[notification userInfo];
    if (![[dictionary objectForKey:REQUEST_SOURCE_KEY] isEqualToString:_controllerId]) {
        return;
    }
    
    NSNumber *returnCode = [dictionary objectForKey:RETURN_CODE];
    if (returnCode && [returnCode isKindOfClass:[NSNumber class]] && [returnCode intValue] == NO_ERROR) {
        [self resortSellerCredits];
        [self extendSellerViewHeight];
    }
}

- (void)responseGetOtherItems:(NSNotification *)notification
{
    NSDictionary *dictionary = (NSDictionary *)[notification userInfo];
    if (![[dictionary objectForKey:REQUEST_SOURCE_KEY] isEqualToString:_controllerId]) {
        return;
    }
    
    NSNumber *returnCode = [dictionary objectForKey:RETURN_CODE];
    if (returnCode && [returnCode isKindOfClass:[NSNumber class]] && [returnCode intValue] == NO_ERROR) {
        NSArray* other = [dictionary objectForKey:TOUI_PARAM_OTHER_ITEMS];
        if (other && [other count] > 0 && [similarItemsArray count] == 0) {
            similarItemsArray = [NSMutableArray arrayWithArray:other];
            [self resortSimilarItems];
            [self extendSimilarViewHeight];
        }
    }
}

- (IBAction)openOthers:(id)sender
{
    UIButton *button = (UIButton *)sender;
    Treasure *treasure = [similarItemsArray objectAtIndex:button.tag - 1 - SIMILARIMAGETAG];
    ItemDetailViewController *itemDetail = [[ItemDetailViewController alloc] initWithNibName:@"ItemDetailViewController" bundle:nil];
    itemDetail.treasureId = treasure.tid;
    itemDetail.treasuresArray = nil;
    itemDetail.preViewName = NSLocalizedString(@"相似商品", @"");
    itemDetail.isFirstClass = NO;
    itemDetail.fromSimilar = YES;
    [itemDetailViewController.navigationController pushViewController:itemDetail animated:YES];

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == similarInfoView) {
        
        [scrollToLeft setAlpha:scrollView.contentOffset.x / 100];
        float recommendWidth = [similarInfoView contentSize].width - scrollView.frame.size.width;
        float offsetRight = recommendWidth - scrollView.contentOffset.x;
        if (offsetRight >= 0) {
            float rightAlpha = offsetRight / 100;
            [scrollToRight setAlpha:rightAlpha];
        }
    }
}

@end
