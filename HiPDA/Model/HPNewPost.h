//
//  HPNewPost.h
//  HiPDA
//
//  Created by wujichao on 14-2-25.
//  Copyright (c) 2014年 wujichao. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HPUser;
@class HPThread;

@interface HPNewPost : NSObject

@property (nonatomic, assign) NSInteger pid;
@property (nonatomic, strong) HPUser *user;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, assign) NSInteger floor;

@property (nonatomic, strong) NSString *body;
@property (nonatomic, strong) NSString *body_html;

@property (nonatomic, strong) NSArray *images;


+ (void)loadThreadWithTid:(NSInteger)tid
                     page:(NSInteger)page // page = 0 last

             forceRefresh:(BOOL)forceRefresh // 强制刷新
                printable:(BOOL)printable // 加载打印版网页

                 authorid:(NSInteger)authorid // 只看某人
          redirectFromPid:(NSInteger)redirectFromPid //在搜索全文结果中, 只能拿到pid

                    block:(void (^)(NSArray *posts, NSDictionary *parameters, NSError *error))block;

+ (void)cancelRequstOperationWithTid:(NSInteger)tid;

+ (NSString *)dateString:(NSDate *)date;

+ (NSString *)preProcessHTML:(NSMutableString *)HTML;
@end
