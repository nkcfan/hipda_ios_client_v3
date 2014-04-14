//
//  HPUser.h
//  HiPDA
//
//  Created by wujichao on 13-11-11.
//  Copyright (c) 2013年 wujichao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HPUser : NSObject<NSCoding>

@property (nonatomic, assign) NSInteger uid;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSURL *avatarImageURL;
//@property (nonatomic, strong) UIImage *avatar;

- (id)initWithAttributes:(NSDictionary *)attributes;


+ (NSURL *)avatarStringWithUid:(NSInteger)_uid;

@end
