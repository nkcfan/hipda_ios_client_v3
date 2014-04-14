//
//  NSHTTPCookieStorage+info.h
//  HiPDA
//
//  Created by wujichao on 14-3-17.
//  Copyright (c) 2014年 wujichao. All rights reserved.
//


#import <Foundation/Foundation.h>


/*
 http://stackoverflow.com/questions/771498/where-are-an-uiwebviews-cookies-stored
 */
@interface NSHTTPCookieStorage (Info)

+ (NSDictionary*) describeCookies;
+ (NSDictionary *) describeCookie:(NSHTTPCookie *)cookie;

@end