//
//  HPCache.h
//  HiPDA
//
//  Created by wujichao on 13-11-15.
//  Copyright (c) 2013年 wujichao. All rights reserved.
//

#import <Foundation/Foundation.h>
@class HPThread;
@interface HPCache : NSObject


@property (nonatomic, strong) NSMutableArray *bgThreads;

@property (nonatomic, strong) NSMutableArray *preloadThreads;
@property (nonatomic, assign) NSInteger preloadThreadsCount;


+ (HPCache *)sharedCache;

// 帖子列表缓存
- (void)cacheForum:(NSArray *)threads
               fid:(NSInteger)fid
              page:(NSInteger)page;
- (NSArray *)loadForum:(NSInteger)fid
                  page:(NSInteger)page;


- (void)cacheThread:(NSArray *)posts
               info:(NSDictionary *)info
                tid:(NSInteger)tid
               page:(NSInteger)page
       expiredAfter:(NSInteger)duration;

- (void)cacheThread:(NSArray *)posts
               info:(NSDictionary *)info
                tid:(NSInteger)tid
               page:(NSInteger)page;


- (NSArray *)loadThread:(NSInteger)tid
                   page:(NSInteger)page;

- (NSDictionary *)loadThreadInfo:(NSInteger)tid
                            page:(NSInteger)page;


- (void)cacheBgThread:(HPThread *)thread block:(void (^)(NSError *error))block;
- (NSMutableArray *)allBgThreads;
- (void)clearBgThreads;
- (void)removeBgThreadAtIndex:(NSInteger)index;

- (BOOL)isReadThread:(NSInteger)tid;
- (void)readThread:(NSInteger)tid;

- (BOOL)existAvatar:(NSInteger)uid;
- (void)notExistAvatar:(NSInteger)uid;

@end
