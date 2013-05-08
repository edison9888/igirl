//
//  ShopWindowItemView.m
//  iAccessories
//
//  Created by zhang on 13-1-6.
//  Copyright (c) 2013年 MobileWoo. All rights reserved.
//

#import "ShopWindowItemView.h"
#import "Banner.h"
#import "Constants.h"
#import "Constants+Enum.h"
#import "ImageCacheEngine.h"
#import "DataEngine.h"
#import <QuartzCore/QuartzCore.h>

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


@interface ShopWindowItemView(Private)

- (NSString *)refreshViewTimeLabel:(NSDate *)fireDate;

@end

@implementation ShopWindowItemView

@synthesize itemTile = _itemTile;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        bgView = [[UIImageView alloc] initWithFrame:CGRectMake(6, OFFSET_BG_VIEW_Y, 308, frame.size.height)];
        [bgView setBackgroundColor:[UIColor clearColor]];
        UIImage *bgImage = [UIImage imageNamed:@"recommend_item_bg.png"];
        [bgView setImage:[bgImage stretchableImageWithLeftCapWidth:200 topCapHeight:100]];
        [self addSubview:bgView];

        // 宝贝图片
        tileImage = [[UIImageView alloc] initWithFrame:CGRectMake(14, OFFSET_IMAGE_VIEW_Y, IMAGE_WIDTH, IMAGE_HEIGHT)];
        [tileImage setBackgroundColor:[UIColor clearColor]];
        [tileImage setImage:[UIImage imageNamed:@"emptyLarge.png"]];
        [self addSubview:tileImage];

        // 价格销量
        salesAndPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, tileImage.frame.size.height - 8, 233, OFFSET_PRICE_AND_SALE_LABEL_HEIGHT)];
        salesAndPriceLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3f];
        salesAndPriceLabel.textColor = [UIColor whiteColor];
        [salesAndPriceLabel setTextAlignment:NSTextAlignmentCenter];
        salesAndPriceLabel.font = [UIFont boldSystemFontOfSize:12];
        [salesAndPriceLabel setText:@"￥123 销量12345"];
        CGSize opSize = [@"￥123 销量12345" sizeWithFont:salesAndPriceLabel.font constrainedToSize:CGSizeMake(IMAGE_WIDTH, MAXFLOAT)];
        float salesAndPriceLabelWidth = opSize.width + 14;
        [salesAndPriceLabel setFrame:CGRectMake(tileImage.frame.origin.x + IMAGE_WIDTH - salesAndPriceLabelWidth, salesAndPriceLabel.frame.origin.y, salesAndPriceLabelWidth, salesAndPriceLabel.frame.size.height)];
        [salesAndPriceLabel.layer setCornerRadius:2];
        [salesAndPriceLabel.layer setMasksToBounds:YES];
        [self addSubview:salesAndPriceLabel];

        // 推荐内容
        contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, tileImage.frame.size.height + tileImage.frame.origin.y + OFFSET_DESC_LABEL_Y, 283, 45.0)];
        contentLabel.backgroundColor = [UIColor clearColor];
        [contentLabel setTextAlignment:NSTextAlignmentLeft];
        contentLabel.numberOfLines = 0;
        [contentLabel setLineBreakMode:NSLineBreakByCharWrapping];
        contentLabel.textColor = [UIColor colorWithRed:14.0f/255.0f green:54.0f/255.0f blue:82.0f/255.0f alpha:1];
        contentLabel.font = [UIFont systemFontOfSize:13];
        [self addSubview:contentLabel];

        // 剩余时间
        remainTimeBodyView = [[UIView alloc] initWithFrame:CGRectMake(bgView.frame.origin.x, contentLabel.frame.origin.y + contentLabel.frame.size.height + OFFSET_REMAIN_BODY_Y, bgView.frame.size.width, OFFSET_REMAIN_BODY_HEIGHT)];
        [remainTimeBodyView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"shopWindowItemRemainTimeBackground"]]];
        [self addSubview:remainTimeBodyView];
        remainTimeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, bgView.frame.size.width, remainTimeBodyView.frame.size.height)];
        remainTimeButton.backgroundColor = [UIColor clearColor];
        [remainTimeButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [remainTimeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [remainTimeButton setTitle:@"剩余时间：1小时30分钟15秒" forState:UIControlStateNormal];
        [remainTimeButton setImage:[UIImage imageNamed:@"shopWindowItemRemainTimeIcon"] forState:UIControlStateNormal];
        [remainTimeBodyView addSubview:remainTimeButton];
    }
    return self;
}

- (void) setItemTile:(Tile *)tile
{
    NSString *realUrl = nil;
    if (tile.tileUUID && [tile.tileUUID isKindOfClass:[NSString class]] && [tile.tileUUID length] > 0) {
        realUrl = [[DataEngine sharedDataEngine] getImageUrlByUUID:tile.tileUUID];
    } else if (tile.picUrl && [tile.picUrl isKindOfClass:[NSString class]] && [tile.picUrl length] > 0) {
        realUrl = [NSString stringWithFormat:@"%@_%@.jpg", tile.picUrl, [[DataEngine sharedDataEngine] getImageSize:kImageSizeDetail]];
    }
    UIImage *image = nil;
    if (realUrl) {
        NSString *imagePath = [[ImageCacheEngine sharedInstance] getImagePathByUrl:realUrl];
        if (imagePath != nil) {
            image = [UIImage imageWithContentsOfFile:imagePath];
        }
    }
    // 图
    if (image) {
        [tileImage setImage:image];
        CGFloat height = image.size.height * 300.0 / image.size.width;
        [tileImage setFrame:CGRectMake(tileImage.frame.origin.x, tileImage.frame.origin.y, IMAGE_WIDTH, height)];
    }
    [salesAndPriceLabel setText:[NSString stringWithFormat:@"￥%0.2f 销量:%lld", [tile.treasurePrice floatValue], [tile.volumn longLongValue]]];
    if (tile.treasurePrice && !tile.volumn) {
        [salesAndPriceLabel setText:[NSString stringWithFormat:@"￥%0.2f", [tile.treasurePrice floatValue]]];
    }
    if (!tile.treasurePrice && tile.volumn) {
        [salesAndPriceLabel setText:[NSString stringWithFormat:@"销量:%lld", [tile.volumn longLongValue]]];
    }
    if (!tile.treasurePrice && !tile.volumn) {
        [salesAndPriceLabel setHidden:YES];
    }
    CGSize opSize = [salesAndPriceLabel.text sizeWithFont:salesAndPriceLabel.font constrainedToSize:CGSizeMake(IMAGE_WIDTH, MAXFLOAT)];
    float salesAndPriceLabelWidth = opSize.width + 14;
    [salesAndPriceLabel setFrame:CGRectMake(tileImage.frame.origin.x + IMAGE_WIDTH - salesAndPriceLabelWidth - 5, tileImage.frame.size.height - 15, salesAndPriceLabelWidth, salesAndPriceLabel.frame.size.height)];

    if (tile.recommand) {
        CGRect contentLabelRect = CGRectMake(contentLabel.frame.origin.x, contentLabel.frame.origin.y, contentLabel.frame.size.width, contentLabel.frame.size.height);
        contentLabelRect.origin.y = tileImage.frame.size.height + OFFSET_IMAGE_VIEW_Y + OFFSET_DESC_LABEL_Y;
        [contentLabel setFrame:contentLabelRect];
        [contentLabel setText:tile.recommand];
        CGSize opSize = [tile.recommand sizeWithFont:contentLabel.font constrainedToSize:CGSizeMake(IMAGE_WIDTH, MAXFLOAT)];
        [contentLabel setFrame:CGRectMake(contentLabel.frame.origin.x, tileImage.frame.size.height + OFFSET_IMAGE_VIEW_Y + OFFSET_DESC_LABEL_Y, contentLabel.frame.size.width, opSize.height)];
        
        [bgView setFrame:CGRectMake(bgView.frame.origin.x, bgView.frame.origin.y, bgView.frame.size.width, contentLabel.frame.size.height + contentLabel.frame.origin.y + OFFSET_REMAIN_BODY_Y)];
    } else {
        // 没有说明
        [bgView setFrame:CGRectMake(bgView.frame.origin.x, bgView.frame.origin.y, bgView.frame.size.width, contentLabel.frame.size.height + contentLabel.frame.origin.y + OFFSET_ITEM_SPACE)];
    }

    // 剩余时间
    if (tile.couponTime) {
        float offsetY = contentLabel.frame.origin.y + contentLabel.frame.size.height + OFFSET_REMAIN_BODY_Y;
        if (!tile.recommand) {
            // 没有详情说明
            offsetY = tileImage.frame.origin.y + tileImage.frame.size.height + OFFSET_REMAIN_BODY_Y;
        }
        [remainTimeBodyView setFrame:CGRectMake(remainTimeBodyView.frame.origin.x, offsetY, remainTimeBodyView.frame.size.width, remainTimeBodyView.frame.size.height)];
        NSString *resultTime = [self refreshViewTimeLabel:tile.couponTime];
        if ([resultTime isEqualToString:NSLocalizedString(@"已结束", @"")]) {
            [remainTimeBodyView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"shopWindowItemRemainTimeOutBackground"]]];
        }
        [remainTimeButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"剩余时间：%@", @""), [self refreshViewTimeLabel:tile.couponTime]] forState:UIControlStateNormal];

        [bgView setFrame:CGRectMake(bgView.frame.origin.x, bgView.frame.origin.y, bgView.frame.size.width, remainTimeBodyView.frame.size.height + remainTimeBodyView.frame.origin.y - OFFSET_BG_VIEW_Y)];

    } else {
        [remainTimeBodyView setHidden:YES];
        float offsetY = contentLabel.frame.origin.y + contentLabel.frame.size.height;
        if (!tile.recommand) {
            // 没有详情说明
            offsetY = tileImage.frame.origin.y + tileImage.frame.size.height;
        }
        [bgView setFrame:CGRectMake(bgView.frame.origin.x, bgView.frame.origin.y, bgView.frame.size.width, offsetY)];
    }
}

- (float)getCellHeight:(Tile*) tile
{
    float returnHeight = OFFSET_BG_VIEW_Y;
    NSString *realUrl = nil;
    if (tile.tileUUID && [tile.tileUUID isKindOfClass:[NSString class]] && [tile.tileUUID length] > 0) {
        realUrl = [[DataEngine sharedDataEngine] getImageUrlByUUID:tile.tileUUID];
    } else if (tile.picUrl && [tile.picUrl isKindOfClass:[NSString class]] && [tile.picUrl length] > 0) {
        realUrl = [NSString stringWithFormat:@"%@_%@.jpg", tile.picUrl, [[DataEngine sharedDataEngine] getImageSize:kImageSizeDetail]];
    }
    UIImage *image = nil;
    if (realUrl) {
        NSString *imagePath = [[ImageCacheEngine sharedInstance] getImagePathByUrl:realUrl];
        if (imagePath != nil) {
            image = [UIImage imageWithContentsOfFile:imagePath];
        }
    }
    // 图
    float imageHeight = IMAGE_HEIGHT;
    returnHeight = imageHeight + OFFSET_IMAGE_VIEW_Y;
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
        returnHeight = imageHeight + OFFSET_IMAGE_VIEW_Y;
    }

    // 描述
    float contentLabelY = 0;
    if (tile.recommand) {
        contentLabelY = returnHeight + OFFSET_DESC_LABEL_Y;
        CGSize opSize = [tile.recommand sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(IMAGE_WIDTH, MAXFLOAT)];

        returnHeight = contentLabelY + opSize.height;
    } else {
        returnHeight = imageHeight + OFFSET_ITEM_SPACE;
    }

    // 剩余时间
    float remainTimeLabelY = 0;
    remainTimeLabelY = imageHeight + OFFSET_IMAGE_VIEW_Y;
    if (tile.couponTime) {
        if (tile.recommand) {
            returnHeight = returnHeight + OFFSET_REMAIN_BODY_HEIGHT;
        } else {
            returnHeight = remainTimeLabelY + OFFSET_REMAIN_BODY_HEIGHT;
        }
    } else {
        // 没有剩余时间
        if (tile.recommand) {
            returnHeight = returnHeight;
        } else {
            returnHeight = remainTimeLabelY;
        }
        
    }
    
    returnHeight += OFFSET_BG_VIEW_Y + 3;
    return returnHeight;
}

- (NSString *)refreshViewTimeLabel:(NSDate *)fireDate
{
    NSDate *today = [NSDate date];
    if ([today timeIntervalSince1970] > [fireDate timeIntervalSince1970]) {
        return NSLocalizedString(@"已结束", @"");
    }
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    unsigned int unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    //计算时间差
    NSDateComponents *d = [calendar components:unitFlags fromDate:today toDate:fireDate options:0];
    //倒计时显示
    return [NSString stringWithFormat:NSLocalizedString(@"%02d小时%02d分%02d秒", @""), [d day] * 24 + [d hour], [d minute], [d second]];
}
@end
