//
//  CLog.h
//  iChat
//
//  Created by 郭雪 on 11-5-12.
//  Copyright 2011年 MobileWo. All rights reserved.
//
#ifdef DEBUG
#define NSLog(format, ...) NSLog(format, ## __VA_ARGS__)
#else
#define NSLog(format, ...)
#endif
