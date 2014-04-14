//
//  HPCache.m
//  HiPDA
//
//  Created by wujichao on 13-11-15.
//  Copyright (c) 2013年 wujichao. All rights reserved.
//

#import "HPCache.h"
#import "HPThread.h"
#import "HPNewPost.h"
#import "EGOCache.h"
#import "HPSetting.h"

#define DEBUG_CACHE 0
#define kHPBgList @"kHPBgList"

@implementation HPCache

+ (HPCache *)sharedCache {
    static HPCache *sharedCache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedCache = [[HPCache alloc] init];
        //sharedCache.bgThreads = [NSMutableArray arrayWithCapacity:10];
    
        if ([[EGOCache globalCache] hasCacheForKey:kHPBgList]) {
            sharedCache.bgThreads = (NSMutableArray *)[[EGOCache globalCache] objectForKey:kHPBgList];
        } else {
            sharedCache.bgThreads = [NSMutableArray arrayWithCapacity:10];
        }
        
        sharedCache.preloadThreads = [NSMutableArray arrayWithCapacity:10];
        sharedCache.preloadThreadsCount = 0;
    });
    
    return sharedCache;
}

// 帖子列表缓存 60s
- (void)cacheForum:(NSArray *)threads
               fid:(NSInteger)fid
              page:(NSInteger)page {
    
    if (DEBUG_CACHE) NSLog(@"cacheForum(%ld-%ld) %@", fid, page, threads ? @"POST": @"NULL");
    
    NSString *key = [NSString stringWithFormat:@"forum_%ld_%ld", fid, page];
    
    [[EGOCache globalCache] setObject:threads forKey:key withTimeoutInterval:60.0f];
}

// 返回帖子列表
- (NSArray *)loadForum:(NSInteger)fid
                  page:(NSInteger)page {
    
    NSString *key = [NSString stringWithFormat:@"forum_%ld_%ld", fid, page];
    if (DEBUG_CACHE) NSLog(@"loadForum(%ld-%ld) %@", fid, page, [[EGOCache globalCache] objectForKey:key] ? @"YES": @"NO");
    return (NSArray *)[[EGOCache globalCache] objectForKey:key];
}


- (void)cacheThread:(NSArray *)posts
               info:(NSDictionary *)info
                tid:(NSInteger)tid
               page:(NSInteger)page
       expiredAfter:(NSInteger)duration {
    NSString *key = [NSString stringWithFormat:@"thread_%ld_%ld", tid, page];
    NSString *key4info = [NSString stringWithFormat:@"thread_info_%ld_%ld", tid, page];
    if (DEBUG_CACHE) NSLog(@"cacheThread(%ld-%ld,%lds) %@", tid, page, duration, posts ? @"Thread": @"NULL");
    
    [[EGOCache globalCache] setObject:posts forKey:key withTimeoutInterval:duration];
    [[EGOCache globalCache] setObject:info forKey:key4info withTimeoutInterval:duration];
}
// 帖子缓存 300s
- (void)cacheThread:(NSArray *)posts
               info:(NSDictionary *)info
                tid:(NSInteger)tid
               page:(NSInteger)page {
    [self cacheThread:posts info:info tid:tid page:page expiredAfter:300];
}

- (NSArray *)loadThread:(NSInteger)tid
                   page:(NSInteger)page {
    NSString *key = [NSString stringWithFormat:@"thread_%ld_%ld", tid, page];
    if (DEBUG_CACHE) NSLog(@"loadThread(%ld-%ld) %@", tid, page, [[EGOCache globalCache] objectForKey:key] ? @"YES":@"NO");
    return (NSArray *)[[EGOCache globalCache] objectForKey:key];
}

- (NSDictionary *)loadThreadInfo:(NSInteger)tid
                       page:(NSInteger)page {
    NSString *key = [NSString stringWithFormat:@"thread_info_%ld_%ld", tid, page];
    if (DEBUG_CACHE) NSLog(@"loadThread info (%ld-%ld) %@", tid, page, [[EGOCache globalCache] objectForKey:key] ? @"YES":@"NO");
    return (NSDictionary *)[[EGOCache globalCache] objectForKey:key];
}

//
- (void)cacheBgThread:(HPThread *)thread block:(void (^)(NSError *error))block {
    
   
    
    // 1
    // save thread to a thread list
    [_bgThreads addObject:thread];
    [[EGOCache globalCache] setObject:_bgThreads forKey:kHPBgList withTimeoutInterval:864000];
    
    
    // 2
    // cacheThread page 1 expiredAfter 600s
    [HPNewPost loadThreadWithTid:thread.tid
                             page:1
                     forceRefresh:NO
                        printable:YES
                         authorid:0
                  redirectFromPid:0
                            block:^(NSArray *posts, NSDictionary *parameters, NSError *error)
     {
         float lastMinite = [Setting floatForKey:HPSettingBGLastMinite];
         if (DEBUG_CACHE) NSLog(@"cacheBgThread(%@ tid%ld) %@", thread.title,thread.tid, posts ? @"POST": @"NULL");
         
         [[HPCache sharedCache] cacheThread:[NSArray arrayWithArray:posts]
                                       info:parameters
                                        tid:thread.tid
                                       page:1
                               expiredAfter:lastMinite * 60];
         
         block(error);
     }];
}

- (NSArray *)allBgThreads {
    // return thread list
    if (DEBUG_CACHE) NSLog(@"allBgThreads(%@)", _bgThreads);
    return _bgThreads;
}

- (void)clearBgThreads {
    [_bgThreads removeAllObjects];
    [[EGOCache globalCache] setObject:_bgThreads forKey:kHPBgList withTimeoutInterval:864000];
}

- (void)removeBgThreadAtIndex:(NSInteger)index {
    [_bgThreads removeObjectAtIndex:index];
    [[EGOCache globalCache] setObject:_bgThreads forKey:kHPBgList withTimeoutInterval:864000];
}

//
- (BOOL)isReadThread:(NSInteger)tid {
    
    NSString *key = [NSString stringWithFormat:@"read_%ld", tid];
    
    if ([[EGOCache globalCache] hasCacheForKey:key]) {
        return YES;
    }
    
    return NO;
}
- (void)readThread:(NSInteger)tid {
    
    NSString *key = [NSString stringWithFormat:@"read_%ld", tid];
    
    if (DEBUG_CACHE) NSLog(@"readThread %@", key);
    
    // 864000 10days
    [[EGOCache globalCache] setObject:@YES forKey:key withTimeoutInterval:864000];
}

- (BOOL)existAvatar:(NSInteger)uid {
    
    NSString *key = [NSString stringWithFormat:@"notExistAvatar_%ld", uid];
    
    if ([[EGOCache globalCache] hasCacheForKey:key]) {
        return NO;
    }
    
    return YES;
}

- (void)notExistAvatar:(NSInteger)uid {
    
    NSString *key = [NSString stringWithFormat:@"notExistAvatar_%ld", uid];
    
    if (DEBUG_CACHE) NSLog(@"notExistAvatar %@", key);
    
    // 864000 10days
    [[EGOCache globalCache] setObject:@YES forKey:key withTimeoutInterval:864000];
}


@end
