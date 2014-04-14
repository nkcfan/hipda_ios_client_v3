//
//  HPNotice.h
//  HiPDA
//
//  Created by wujichao on 13-11-25.
//  Copyright (c) 2013年 wujichao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HPNotice : NSObject

@property(nonatomic, strong)NSMutableArray *myNotices;


+ (HPNotice *)sharedNotice;
+ (void)ayscnMyNoticesWithBlock:(void (^)(NSArray *threads, NSError *error))block
                           page:(NSInteger)page;
+ (void)ignoreNotice;


- (void)cacheMyNotices:(NSArray *)threads;

@end
