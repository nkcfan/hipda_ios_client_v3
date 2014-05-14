//
//  HPAttention.h
//  HiPDA
//
//  Created by nkcfan on 5/14/14.
//  Copyright (c) 2014 nkcfan. All rights reserved.
//

#import <Foundation/Foundation.h>
@class HPThread;
@interface HPAttention : NSObject

+ (BOOL)isAttentionWithTid:(NSInteger)tid;
+ (void)addAttention:(HPThread *)thread block:(void (^)(BOOL isSuccess, NSError *error))block;
+ (void)removeAttention:(NSInteger)tid block:(void (^)(NSString *msg, NSError *error))block;
@end
