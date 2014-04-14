//
//  HPThread.h
//  HiPDA
//
//  Created by wujichao on 13-11-11.
//  Copyright (c) 2013年 wujichao. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HPUser;

@interface HPThread : NSObject<NSCoding>

@property (nonatomic, assign) NSInteger fid;
@property (nonatomic, assign) NSInteger tid;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) HPUser *user;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) NSString *dateString;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, assign) NSInteger replyCount;
@property (nonatomic, assign) NSInteger openCount;
@property (nonatomic, assign) NSInteger pageCount;
@property (nonatomic, strong) NSString *formhash;

@property (nonatomic, assign) NSInteger pid; //redirct from pid

@property (nonatomic, readonly, assign) BOOL hasImage;
@property (nonatomic, readonly, assign) BOOL hasAttach;

// for HPMyReply & HPMyNotice
@property (nonatomic, strong) NSString *replyDetail;


- (id)initWithAttributes:(NSDictionary *)attributes;

+ (void)loadThreadsWithFid:(NSInteger)fid
                      page:(NSInteger)page
              forceRefresh:(BOOL)forceRefresh
                     block:(void (^)(NSArray *posts, NSError *error))block;


- (NSString *)shortDate;

@end

