//
//  HPMyThread.h
//  HiPDA
//
//  Created by wujichao on 13-11-22.
//  Copyright (c) 2013年 wujichao. All rights reserved.
//

#import <Foundation/Foundation.h>
@class HPThread;
@interface HPMyThread : NSObject

@property(nonatomic, strong)NSMutableArray *myThreads;

+ (HPMyThread *)sharedMyThread;
+ (void)ayscnMyThreadWithBlock:(void (^)(NSArray *threads, NSError *error))block
                          page:(NSInteger)page;
- (void)cacheMyThreads:(NSArray *)threads;
@end
