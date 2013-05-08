//
//  UBAnalysis.h
//  UBAnalysis
//
//  Created by 晋辉 卫 on 4/10/12.
//  Copyright (c) 2012 MobileWoo. All rights reserved.
//

#import <Foundation/Foundation.h>

#define KUBAVersion @"2.0.0"
#define KPlaceholder @"-"

typedef enum {
	ReportTypeBatch = 0,
	ReportTypeRealtime
} ReportType;

void UBUncaughtExceptionHandler(NSException *exception);

@interface UBAnalysis : NSObject

/*方法名:
 *		startWithAppkey:channelId:testServer
 *		startWithAppkey:channelId:reportType
 *介绍:
 *		类方法初始化UBAnalysis实例，设置AppKey，渠道
 *参数说明:
 *		AppKey:应用key
 *		cid:渠道号
 *		ReportType:发送统计信息的策略设置，有两种可选的发送策略
 *					1.ReportTypeBatch		:批量发送。每次发送的时机在软件开启的时候进行发送
 *					2.ReportTypeRealtime	:实时发送。每当有事件（event）产生时，进行发送
 */
+ (void)startWithAppkey:(NSString *)appKey channelId:(NSString *)cid testServer:(BOOL)test;
+ (void)startWithAppkey:(NSString *)appKey channelId:(NSString *)cid reportType:(ReportType)rp;

#pragma mark event logs
/*方法名:
 *		event:(NSString *)eventId
 *		event:(NSString *)eventId label:(NSString *)label
 *介绍:
 *       使用前，请先到友盟App管理后台的设置->编辑自定义事件 中添加相应的事件ID，然后在工程中传入相应的事件ID即可 
 *		类方法，生成一条事件记录，并保存到本地缓存
 *参数说明:
 *		无参数版本可以方便的生成一条事件记录，并将分类标签设为空，计数设为1
 *		label:为某事件ID添加该事件的分类标签统计。在友盟的统计后台中，可以通过同一事件ID进行统计和整理。同一事件ID的不同的标签，也会分别进行统计，方便同一事件的不同标签的对比。
 *		accumulation:为某一事件的某一分类进行累加统计。为减少网络交互，可以自行对某一事件ID的某一分类标签进行累加，再传入次数作为参数即可。
 *
 */
+ (void)event:(NSString *)eventId label:(NSString *)label;

+ (void)event:(NSString *)eventId labels:(int)labelCount,...;

+ (void)startTracPage:(NSString *)eventId labels:(int)labelCount,...;

+ (void)endTracPage:(NSString *)eventId labels:(int)labelCount,...;

+ (void)exception:(NSString *)name stacktrace:(NSArray *)traces;

#pragma mark helper
/*方法名:
 *		isJailbroken
 *介绍:
 *		类方法，判断设备是否越狱，判断方法根据 apt和Cydia.app的path来判断
 *参数说明:
 *		无
 *
 */
+ (BOOL)isJailbroken;
/*方法名:
 *		isPirated
 *介绍:
 *		类方法，判断软件是否破解
 *参数说明:
 *		无
 *
 */
+ (BOOL)isPirated;

@end
