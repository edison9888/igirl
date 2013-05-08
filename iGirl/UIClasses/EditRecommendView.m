//
//  RecommendItemView.m
//  iAccessories
//
//  Created by sunxq on 12-12-19.
//  Copyright (c) 2012年 MobileWoo. All rights reserved.
//

#import "EditRecommendView.h"
#import "ImageCacheEngine.h"
#import "Treasure.h"
#import "EditRecommendViewController.h"
#import "ItemDetailViewController.h"

#define IMAGE_HEIGHT            262.0

@implementation EditRecommendView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
//        [self setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"recommend_item_bg.png"]]];
        UIImageView *bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [bgView setImage:[UIImage imageNamed:@"recommend_item_bg.png"]];
        [self addSubview:bgView];
        
        // 宝贝图片
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(1, 0, self.bounds.size.width - 2, IMAGE_HEIGHT)];
        [_imageView setContentMode:UIViewContentModeScaleAspectFill];
        _imageView.clipsToBounds = YES;
        _imageView.userInteractionEnabled = YES;
        [_imageView setImage:[UIImage imageNamed:@"emptyLarge.png"]];
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickImage:)];
        [_imageView addGestureRecognizer:recognizer];
        [self addSubview:_imageView];
        
        // 价格
        _priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(12.0, 271.0, 150.0, 20.0)];
        _priceLabel.backgroundColor = [UIColor clearColor];
        _priceLabel.textColor = [UIColor colorWithRed:200.0f/255.0f green:21.0f/255.0f blue:0.0f/255.0f alpha:1];
        _priceLabel.font = [UIFont boldSystemFontOfSize:15.0];
        [self addSubview:_priceLabel];
        
        // 销量
        _salesLabel = [[UILabel alloc] initWithFrame:CGRectMake(223.0, 274.0, 80.0, 18)];
        _salesLabel.backgroundColor = [UIColor clearColor];
        _salesLabel.textColor = [UIColor colorWithRed:60.0f/255.0f green:60.0f/255.0f blue:60.0f/255.0f alpha:1];
        _salesLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:_salesLabel];
        
        // 推荐内容
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(13.0, 296.0, 285.0, 45.0)];
        _contentLabel.backgroundColor = [UIColor clearColor];
        _contentLabel.numberOfLines = 3;
        _contentLabel.textColor = [UIColor colorWithRed:89.0f/255.0f green:89.0f/255.0f blue:89.0f/255.0f alpha:1];
        _contentLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:_contentLabel];
        
    }
    return self;
}

- (void)loadTreasureImage:(UIImage *)image
{
    [_imageView setImage:image];
}

- (void)loadValues:(Treasure *)treasure
{
    if (treasure == nil) {
        return ;
    }
    // 加载图片
    NSString *imagePath = [[ImageCacheEngine sharedInstance] getImagePathByUrl:treasure.picUrl];
    if (imagePath) {
        UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
        [_imageView setImage:image];
    } else {
        [self.cotroller requestDownloadImage:treasure];
    }
    // 价格
    if (treasure.price) {
        _priceLabel.text = [NSString stringWithFormat:@"价格：￥%.2f", [treasure.price doubleValue]];
    }
    // 销量
    if (treasure.volume) {
        _salesLabel.text = [NSString stringWithFormat:@"销量：%d件", [treasure.volume intValue]];
    }
    // 推荐内容
    if (treasure.recommend) {
        _contentLabel.text = treasure.recommend;
    }
}

- (void)clickImage:(UIGestureRecognizer *)gestureRecognizer
{
    [MobClick event:@"小编推荐" attributes:[NSDictionary dictionaryWithObjectsAndKeys:[self.treasure.tid stringValue], @"点击商品", nil]];

    ItemDetailViewController *itemDetail = [[ItemDetailViewController alloc] initWithNibName:@"ItemDetailViewController" bundle:nil];
    itemDetail.treasureId = self.treasure.tid;
    itemDetail.treasuresArray = nil;
    itemDetail.preViewName = @"今日推荐";
    [self.cotroller.navigationController pushViewController:itemDetail animated:YES];
}


@end
