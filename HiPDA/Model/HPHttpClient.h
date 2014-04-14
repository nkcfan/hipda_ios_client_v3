//
//  HPHttpClient.h
//  HiPDA
//
//  Created by wujichao on 13-11-11.
//  Copyright (c) 2013年 wujichao. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <AFHTTPClient.h>

@interface HPHttpClient : AFHTTPClient

+ (HPHttpClient *)sharedClient;

+ (NSString *)GBKresponse2String:(id) responseObject;

- (void)getPathContent:(NSString *)path
            parameters:(NSDictionary *)parameters
               success:(void (^)(AFHTTPRequestOperation *operation, NSString *html))success
               failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

@end
