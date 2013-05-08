//
//  ErrorCodeUtils.m
//  Three Hundred
//
//  Created by 郭雪 on 11-8-26.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "ErrorCodeUtils.h"
#import "Constants.h"

@implementation ErrorCodeUtils

+ (NSString*)errorDetailFromErrorCode:(int)errorCode
{
    NSString* errorDetail = nil;
    switch (errorCode) {
        case -1001:
            errorDetail = NSLocalizedString(@"请求超时，请检查您的网络。", @"");
            break;
        case -1002:
            errorDetail = NSLocalizedString(@"请求错误，不支持的URL", @"");
            break;
        case -1004:
            errorDetail = NSLocalizedString(@"请求错误，无法连接服务器", @"");
            break;
        case -1009:
            errorDetail = NSLocalizedString(@"没有网络连接了，请检查您的网络。", @"");
            break;
        case 404:
            errorDetail = NSLocalizedString(@"未找到指定的文件。", @"");
            break;
        case 500:
            errorDetail = NSLocalizedString(@"服务器错误。", @"");
            break;
            //API error
        case 1101:
            errorDetail = NSLocalizedString(@"接口参数错误。", @"");
            break;
        case 1201:
            errorDetail = NSLocalizedString(@"未找到指定商品。", @"");
            break;
        case 2001:
            errorDetail = NSLocalizedString(@"缺少必要传入参数", @"");
            break;
        case 2002:
            errorDetail = NSLocalizedString(@"设备已被禁用。", @"");
            break;
        default:
            errorDetail = NSLocalizedString(@"未知错误", @"");
            break;
    }
    return errorDetail;
}

+ (NSString*)errorDetailFromSinaErrorCode:(int)errorCode
{
    NSString* errorDetail = nil;
    switch (errorCode) {
        case TSB_ERROR_CODE_SINA_USER_INFO_FAILED:
            errorDetail = NSLocalizedString(@"获取新浪用户信息失败。", @"");
            break;
        default:
            errorDetail = NSLocalizedString(@"未知错误", @"");
            break;
    }
    return errorDetail;
}

@end
