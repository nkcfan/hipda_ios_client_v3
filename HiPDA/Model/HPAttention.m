//
//  HPAttention.m
//  HiPDA
//
//  Created by nkcfan on 5/14/14.
//  Copyright (c) 2014 nkcfan. All rights reserved.
//

#import "NSString+Additions.h"
#import "HPAttention.h"
#import "HPThread.h"
#import "HPHttpClient.h"
#import "EGOCache.h"
#import <AFHTTPRequestOperation.h>

#define DEBUG_Attention 0
#define DEBUG_ayscn_Attention 0

@implementation HPAttention


NSString *cacheKey(NSInteger tid) {
    NSString *key = [NSString stringWithFormat:@"attention_%d", tid];
    return key;
}

+ (BOOL)isAttentionWithTid:(NSInteger)tid {
    return [[EGOCache globalCache] hasCacheForKey:cacheKey(tid)];
}

+ (void)addAttention:(HPThread *)thread block:(void (^)(BOOL isSuccess, NSError *error))block {
    NSString *key = cacheKey(thread.tid);
    
    // 0
    // check
    if ([[EGOCache globalCache] hasCacheForKey:key]) {
        
        NSDictionary *details = [NSDictionary dictionaryWithObject:@"您曾经关注过这个主题" forKey:NSLocalizedDescriptionKey];
        block(NO, [NSError errorWithDomain:@"world" code:200 userInfo:details]);
        
        return;
    }
    
    // 1
    // cache
    // 864000 10days
    [[EGOCache globalCache] setObject:@YES forKey:key withTimeoutInterval:864000];
    
    // 2
    // submit
    //http://www.hi-pda.com/forum/my.php?item=attention&tid=1404188&inajax=1&ajaxtarget=favorite_msg&action=add
    
    NSString *path = [NSString stringWithFormat:@"forum/my.php?item=attention&tid=%d&inajax=1&ajaxtarget=favorite_msg&action=add", thread.tid];
    
    if (DEBUG_Attention) NSLog(@"favorite path %@", path);
    
    [[HPHttpClient sharedClient] getPathContent:path parameters:nil success:^(AFHTTPRequestOperation *operation, NSString *html) {
        
        if (DEBUG_ayscn_Attention) NSLog(@"attention html : %@",html);
        
        if (block) {
            if ([html indexOf:@"指定主题已成功加入到关注列表中"] != -1 ||
                [html indexOf:@"您正在关注这个主题"] !=-1 ) {
                block(YES, nil);
                
            } else {
                NSString *err = [html stringBetweenString:@"<![CDATA[" andString:@"]]"];
                if (!err) {
                    err = @"";
                }
                NSDictionary *details = [NSDictionary dictionaryWithObject:err forKey:NSLocalizedDescriptionKey];
                block(NO, [NSError errorWithDomain:@"world" code:200 userInfo:details]);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(NO, error);
        }
    }];
}

+ (void)removeAttention:(NSInteger)tid block:(void (^)(NSString *msg, NSError *error))block {
    
    // 1
    // de-cache
    // 864000 10days
    NSString *key = cacheKey(tid);
    [[EGOCache globalCache] removeCacheForKey:key];
    
    // 2
    // submit
    //http://www.hi-pda.com/forum/my.php?item=attention&tid=1404188&inajax=1&ajaxtarget=favorite_msg&action=remove
    NSString *path = [NSString stringWithFormat:@"forum/my.php?item=attention&tid=%d&inajax=1&ajaxtarget=favorite_msg&action=remove", tid];
    
    if (DEBUG_Attention) NSLog(@"attention path %@", path);
    
    [[HPHttpClient sharedClient] getPathContent:path parameters:nil success:^(AFHTTPRequestOperation *operation, NSString *html) {
        
        if (DEBUG_ayscn_Attention) NSLog(@"attention html : %@",html);
        
        if (block) {
            if ([html indexOf:@"已取消对此主题的关注"] != -1) {
                block(@"success", nil);
                
            } else {
                NSString *err = [html stringBetweenString:@"<![CDATA[" andString:@"]]"];
                if (!err) {
                    err = @"";
                }
                NSDictionary *details = [NSDictionary dictionaryWithObject:err forKey:NSLocalizedDescriptionKey];
                block(@"", [NSError errorWithDomain:@"world" code:200 userInfo:details]);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(@"", error);
        }
    }];
}

@end
