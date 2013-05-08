//
//  BookListItemView.m
//  iGirl
//
//  Created by Gao Fuxiao on 13-4-27.
//  Copyright (c) 2013年 MobileWoo. All rights reserved.
//

#import "BookListItemView.h"
#import "Banner.h"
#import "Constants+Enum.h"
#import "DataEngine.h"
#import "ImageCacheEngine.h"
#import "Book.h"

#define IMAGE_HEIGHT            293
#define IMAGE_WIDTH             293

#define OFFSET_BG_VIEW_Y 7
#define OFFSET_IMAGE_VIEW_Y 13
#define OFFSET_ITEM_SPACE 4
#define OFFSET_PRICE_AND_SALE_LABEL_HEIGHT 23
#define OFFSET_PRICE_LABEL_HEIGHT 46
#define OFFSET_SALES_LABEL_HEIGHT 14
#define OFFSET_REMAINTIME_LABEL_HEIGHT 14
#define OFFSET_REMAINTIME_LABEL_TOP 5

#define OFFSET_DESC_LABEL_Y 9
#define OFFSET_REMAIN_BODY_Y 9
#define OFFSET_REMAIN_BODY_HEIGHT 29

@interface BookListItemView (Private)

// 重置label.frame.x
- (void) resetLabelX;

@end

@implementation BookListItemView
@synthesize itemBook;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        //加入对下载书籍事件的监听
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateStatusLabel:)
                                                     name:NOTIFICATION_DOWNLOAD_ITEM_START
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateStatusLabel:)
                                                     name:NOTIFICATION_DOWNLOAD_ITEM_FINISH
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateStatusLabel:)
                                                     name:NOTIFICATION_DOWNLOAD_STATUS_REFRESH
                                                   object:nil];
        
        bgView = [[UIImageView alloc] initWithFrame:CGRectMake(6, OFFSET_BG_VIEW_Y, 308, frame.size.height)];
        [bgView setBackgroundColor:[UIColor clearColor]];
        UIImage *bgImage = [UIImage imageNamed:@"recommend_item_bg.png"];
        [bgView setImage:[bgImage stretchableImageWithLeftCapWidth:200 topCapHeight:100]];
        [self addSubview:bgView];

        // 宝贝图片
        bookImage = [[UIImageView alloc] initWithFrame:CGRectMake(14, OFFSET_IMAGE_VIEW_Y, IMAGE_WIDTH, IMAGE_HEIGHT)];
        [bookImage setBackgroundColor:[UIColor clearColor]];
        [bookImage setImage:[UIImage imageNamed:@"emptyLarge.png"]];
        [self addSubview:bookImage];
        
        // 书籍下载状态
        statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(220, bookImage.frame.size.height + bookImage.frame.origin.y - OFFSET_DESC_LABEL_Y , 100, -20.0)];
        statusLabel.backgroundColor = [UIColor clearColor];
        [statusLabel setTextAlignment:NSTextAlignmentLeft];
        statusLabel.numberOfLines = 0;
        [statusLabel setLineBreakMode:NSLineBreakByCharWrapping];
        statusLabel.textColor = [UIColor colorWithRed:14.0f/255.0f green:54.0f/255.0f blue:82.0f/255.0f alpha:1];
        statusLabel.font = [UIFont systemFontOfSize:13];
        statusLabel.textAlignment = UITextAlignmentCenter;
        [self addSubview:statusLabel];
    }
    return self;
}

-(CGFloat)getCellHeight:(Book *)book
{
    float returnHeight = OFFSET_BG_VIEW_Y;
    
    NSString *realUrl = nil;
    
    realUrl = [NSString stringWithFormat:@"%@_%@.jpg", book.picUrl, [[DataEngine sharedDataEngine] getImageSize:kImageSizeDetail]];

    UIImage *image = nil;
    if (realUrl) {
        NSString *imagePath = [[ImageCacheEngine sharedInstance] getImagePathByUrl:realUrl];
        if (imagePath != nil) {
            image = [UIImage imageWithContentsOfFile:imagePath];
        }
    }
    // 图
    float imageHeight = IMAGE_HEIGHT;
    returnHeight = imageHeight + OFFSET_IMAGE_VIEW_Y * 2 - OFFSET_BG_VIEW_Y / 2;
    
    if (image) {
        imageHeight = image.size.height;
        CGFloat offset = 0.0;
        CGFloat height = image.size.height * 300.0 / image.size.width;
        offset += height - IMAGE_HEIGHT;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, OFFSET_IMAGE_VIEW_Y, IMAGE_WIDTH, IMAGE_HEIGHT)];
        [imageView setImage:image];
        [imageView setFrame:CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y, IMAGE_WIDTH, imageView.frame.size.height + offset)];
        imageHeight = imageView.frame.size.height;
        imageView = nil;
        returnHeight = imageHeight + OFFSET_IMAGE_VIEW_Y * 2 - OFFSET_BG_VIEW_Y / 2;
    }
    
    return returnHeight;
}


- (void) setItemBook:(Book *)book
{
    NSString *realUrl = nil;
    
    realUrl = [NSString stringWithFormat:@"%@_%@.jpg", book.picUrl, [[DataEngine sharedDataEngine] getImageSize:kImageSizeDetail]];

    UIImage *image = nil;
    if (realUrl) {
        NSString *imagePath = [[ImageCacheEngine sharedInstance] getImagePathByUrl:realUrl];
        if (imagePath != nil) {
            image = [UIImage imageWithContentsOfFile:imagePath];
        }
    }
    // 图
    if (image) {
        [bookImage setImage:image];
        CGFloat height = image.size.height * 300.0 / image.size.width;
        [bookImage setFrame:CGRectMake(bookImage.frame.origin.x, bookImage.frame.origin.y, IMAGE_WIDTH, height)];
    }
    CGFloat offsetY = bookImage.frame.origin.y + bookImage.frame.size.height;
    [bgView setFrame:CGRectMake(bgView.frame.origin.x, bgView.frame.origin.y, bgView.frame.size.width, offsetY)];
    [statusLabel setFrame:CGRectMake(bgView.frame.size.width - 100, bookImage.frame.size.height + bookImage.frame.origin.y - OFFSET_ITEM_SPACE , 100, -20.0)];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *docPath = [documentPaths objectAtIndex:0];
    NSString *bookPath = [docPath stringByAppendingFormat:@"/downloads/%d/%d.pdf", [book.bookId intValue], [book.bookId intValue]];

    BOOL isDownloaded = [fileManager fileExistsAtPath:bookPath];
    if (isDownloaded) {
        statusLabel.text = NSLocalizedString(@"已下载", @"");
    } else {
        statusLabel.text = NSLocalizedString(@"未下载", @"");
    }
    [self resetLabelX];
    itemBook = book;
}

-(void)updateStatusLabel:(NSNotification *)notification
{
    NSDictionary *tempDictionary = [notification userInfo];
    int bookId = [[tempDictionary valueForKey:@"bookId"]intValue];
    if (bookId == [itemBook.bookId intValue]) {
        if ([notification.name isEqualToString:NOTIFICATION_DOWNLOAD_ITEM_START]) {
            statusLabel.text = NSLocalizedString(@"下载中", @"");
        } else if([notification.name isEqualToString:NOTIFICATION_DOWNLOAD_ITEM_FINISH]) {
            statusLabel.text = NSLocalizedString(@"已下载", @"");
        } else {
            int progress = [[tempDictionary valueForKey:@"progress"] floatValue]*100;
            statusLabel.text = [NSString stringWithFormat:@"下载中...%d%%",progress];
        }
        [self resetLabelX];
    }
}

- (void) resetLabelX
{
    CGSize opSize = [statusLabel.text sizeWithFont:statusLabel.font constrainedToSize:CGSizeMake(bgView.frame.size.width, MAXFLOAT)];
    [statusLabel setFrame:CGRectMake(bgView.frame.size.width - opSize.width - 15, statusLabel.frame.origin.y, opSize.width, opSize.height)];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
