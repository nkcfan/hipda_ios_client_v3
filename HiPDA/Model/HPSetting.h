//
//  HPSetting.h
//  HiPDA
//
//  Created by wujichao on 14-3-13.
//  Copyright (c) 2014年 wujichao. All rights reserved.
//

#import <Foundation/Foundation.h>

#define Setting ([HPSetting sharedSetting])

@interface HPSetting : NSObject

+ (HPSetting*)sharedSetting;

- (void)loadSetting;
- (void)loadDefaults;

- (void)save;

- (id)objectForKey:(NSString *)key;
- (BOOL)boolForKey:(NSString *)key;
- (NSInteger)integerForKey:(NSString *)key;
- (CGFloat)floatForKey:(NSString *)key;

- (void)saveObject:(id)value forKey:(NSString *)key;
- (void)saveInteger:(NSInteger)value forKey:(NSString *)key;
- (void)saveBool:(BOOL)value forKey:(NSString *)key;
- (void)saveFloat:(float)value forKey:(NSString *)key;

- (NSString *)postTail;
- (void)setPostTail:(NSString *)postTail;
- (NSString *)isPostTailAllow:(NSString *)postTail;

@end
