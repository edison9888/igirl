//
//  Itemlist2View.m
//  iAccessories
//
//  Created by sunxq on 13-1-6.
//  Copyright (c) 2013年 MobileWoo. All rights reserved.
//

#import "Itemlist2View.h"
#import "Treasure.h"
#import "DataEngine.h"
#import "ImageCacheEngine.h"
#import "Itemlist2ViewController.h"
#import "ItemDetailViewController.h"
#import "Constants.h"
#import "AppDelegate.h"

#define ITEM_SEP_LENGTH 1.5f

@implementation Itemlist2View
@synthesize source;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // 背景图
        background = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 149, 179)];
        [background setImage:[UIImage imageNamed:@"22itemViewBackground"]];
        [self addSubview:background];

        // 商品图 296 302
        _treasureImage = [[UIImageView alloc] initWithFrame:CGRectMake(1, 1, 147, 151)];
//        [_treasureImage setContentMode:UIViewContentModeScaleAspectFill];
//        _treasureImage.clipsToBounds = YES;
        _treasureImage.userInteractionEnabled = YES;
        [_treasureImage setImage:[UIImage imageNamed:@"emptyLarge.png"]];
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickImage:)];
        [_treasureImage addGestureRecognizer:recognizer];
        [self addSubview:_treasureImage];

        // 价格、销量信息
        priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(1, 152, 74, 27)];
        [priceLabel setTextColor:[UIColor colorWithRed:198.0f/255.0f green:9.0f/255.0f blue:0 alpha:1]];
        [priceLabel setFont:[UIFont boldSystemFontOfSize:12]];
        [priceLabel setBackgroundColor:[UIColor clearColor]];
        [priceLabel setTextAlignment:NSTextAlignmentCenter];
        [priceLabel setText:@""];
        [self addSubview:priceLabel];
        
        salesLabel = [[UILabel alloc] initWithFrame:CGRectMake(74, 152, 74, 27)];
        [salesLabel setTextColor:[UIColor colorWithRed:80.0f/255.0f green:80.0f/255.0f blue:80.0f/255.0f alpha:1]];
        [salesLabel setFont:[UIFont boldSystemFontOfSize:12]];
        [salesLabel setBackgroundColor:[UIColor clearColor]];
        [salesLabel setTextAlignment:NSTextAlignmentCenter];
        [salesLabel setText:@""];
        [self addSubview:salesLabel];

        _infoLabel = [[UILabel alloc] init];
        [_infoLabel setBackgroundColor:[UIColor colorWithRed:0.0f / 255.0f green:0.0f / 255.0f blue:0.0f / 255.0f alpha:0.6]];
        _infoLabel.textColor = [UIColor colorWithRed:255.0f / 255.0f green:255.0f / 255.0f blue:255.0f / 255.0f alpha:1];
        [_infoLabel setFont:[UIFont systemFontOfSize:12.0]];
        [self addSubview:_infoLabel];
    }
    return self;
}

- (void)clickImage:(UIGestureRecognizer *)gestureRecognizer
{
    [MobClick event:@"222模式列表"  attributes:[NSDictionary dictionaryWithObjectsAndKeys:self.cotroller.title ? self.cotroller.title : KPlaceholder, @"点击222列表", nil]];
    [UBAnalysis event:@"222模式列表" labels:2, @"点击222列表", self.cotroller.title ? self.cotroller.title : KPlaceholder];

    NSString *fromText = @"";
    if (self.cotroller.listSource == kItemListFromBanner) {
        fromText = [NSString stringWithFormat:@"%@22列表,%@,%lld", self.cotroller.forAnalysisPath, self.cotroller.title, [self.cotroller.bannerId longLongValue]];
    } else {
        fromText = [NSString stringWithFormat:@"%@22列表,%@,%lld", self.cotroller.forAnalysisPath, self.cotroller.title, [self.cotroller.tileId longLongValue]];
    }
    [MobClick event:@"商品详情页面" attributes:[NSDictionary dictionaryWithObjectsAndKeys:fromText, @"进入来源", nil]];
    [UBAnalysis event:@"商品详情页面" labels:2, @"进入来源", fromText];

    ItemDetailViewController *itemDetail = [[ItemDetailViewController alloc] initWithNibName:@"ItemDetailViewController" bundle:nil];
    itemDetail.treasureId = self.treasure.tid;
    itemDetail.treasuresArray = nil;
    itemDetail.preViewName = self.cotroller.title;
    itemDetail.source = self.source;
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate presentModalViewController:itemDetail animated:YES];
}

- (void)loadValues:(Treasure *)treasure
{
    if (treasure == nil) {
        return ;
    }
    NSMutableString *info = [NSMutableString stringWithCapacity:1];
    if (treasure.price) {
        [priceLabel setText:[NSString stringWithFormat:@"￥%1.2f ", [treasure.price floatValue]]];
    }
    
    if (treasure.volume) {
        [salesLabel setText:[NSString stringWithFormat:@"销量:%d ", [treasure.volume intValue]]];
    }
    
    if (info && [info length] > 0) {
        CGSize size = [info sizeWithFont:[UIFont systemFontOfSize:12.0]];
        _infoLabel.frame = CGRectMake(_treasureImage.frame.origin.x + _treasureImage.frame.size.width - size.width, 132.0f + (15.0f - size.height) / 2, size.width, size.height);
        _infoLabel.text = info;
    }
    
    // 商品图
    DataEngine *dataEngine = [DataEngine sharedDataEngine];
    if (treasure.picUrl && [treasure.picUrl length] > 0) {
        NSString *realUrl = [NSString stringWithFormat:@"%@_%@.jpg", treasure.picUrl, [dataEngine getImageSize:kImageSize22]];
        NSString *imagePath = [[ImageCacheEngine sharedInstance] getImagePathByUrl:realUrl];
        if (imagePath) {
            UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
            [_treasureImage setImage:image];
        } else {
            //下载图片
            if (![self.tableView isDragging] && ![self.tableView isDecelerating]) {
                [self.cotroller requestDownloadImage:realUrl];
            }
        }
    }
}

@end
