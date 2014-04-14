//
//  HPAccount.h
//  HiPDA
//
//  Created by wujichao on 13-11-11.
//  Copyright (c) 2013年 wujichao. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^NoticeRetrieveBlock)(UIBackgroundFetchResult result);



@interface HPAccount : NSObject

@property (nonatomic, copy) NoticeRetrieveBlock noticeRetrieveBlock;

+ (HPAccount *)sharedHPAccount;

//
+ (BOOL)isSetAccount;

// login & out
- (void)loginWithBlock:(void (^)(BOOL isLogin, NSError *error))block;
- (void)logout;


//fake register
- (void)registerWithBlock:(void (^)(BOOL isLogin, NSError *error))block;


// bg fetch
- (void)startCheckWithDelay:(NSTimeInterval)delay;
- (NSInteger)badgeNumber;

@end
