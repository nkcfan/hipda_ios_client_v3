//
//  HPMyReply.h
//  HiPDA
//
//  Created by wujichao on 13-11-22.
//  Copyright (c) 2013年 wujichao. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HPThread;
@interface HPMyReply : NSObject

@property(nonatomic, strong)NSMutableArray *myReplies;


+ (HPMyReply *)sharedReply;
+ (void)ayscnMyRepliesWithBlock:(void (^)(NSArray *threads, NSError *error))block
                          page:(NSInteger)page;

- (void)cacheMyReplies:(NSArray *)threads;

@end