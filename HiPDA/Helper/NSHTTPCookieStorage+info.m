//
//  NSHTTPCookieStorage+info.m
//  HiPDA
//
//  Created by wujichao on 14-3-17.
//  Copyright (c) 2014年 wujichao. All rights reserved.
//


#import "NSHTTPCookieStorage+info.h"

@implementation NSHTTPCookieStorage (Info)

+ (NSDictionary*) describeCookies {
    NSMutableDictionary *descriptions = [NSMutableDictionary new];
    
    [[[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies] enumerateObjectsUsingBlock:^(NSHTTPCookie* obj, NSUInteger idx, BOOL *stop) {
        [descriptions setObject:[[self class] describeCookie:obj] forKey:[[obj name] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }];
    
    NSLog(@"Cookies:\n\n%@", descriptions);
    return descriptions;
}

+ (NSDictionary *) describeCookie:(NSHTTPCookie *)cookie {
    return @{@"value" : [[cookie value] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
             @"domain" : [cookie domain] ? [cookie domain]  : @"n/a",
             @"path" : [cookie path] ? [cookie path] : @"n/a",
             @"expiresDate" : [cookie expiresDate] ? [cookie expiresDate] : @"n/a",
             @"sessionOnly" : [cookie isSessionOnly] ? @1 : @0,
             @"secure" : [cookie isSecure] ? @1 : @0,
             @"comment" : [cookie comment] ? [cookie comment] : @"n/a",
             @"commentURL" : [cookie commentURL] ? [cookie commentURL] : @"n/a",
             @"version" : @([cookie version]) };
    
}

@end