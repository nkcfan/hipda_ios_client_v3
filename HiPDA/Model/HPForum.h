//
//  HPForum.h
//  HiPDA
//
//  Created by wujichao on 14-3-19.
//  Copyright (c) 2014年 wujichao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HPForum : NSObject<NSCoding>

- (id)initWithAttributes:(NSDictionary *)attributes;

@property (nonatomic, assign)NSInteger fid;
@property (nonatomic, strong)NSString *title;

+ (NSArray *)forumsTitle;
+ (NSDictionary *)forumsDict;

//+ (void)getType:(int)fid;
+ (NSArray *)forumTypeWithFid:(NSInteger)fid;
@end
