//
//  HPFavorite.h
//  HiPDA
//
//  Created by wujichao on 13-11-17.
//  Copyright (c) 2013年 wujichao. All rights reserved.
//

#import <Foundation/Foundation.h>
@class HPThread;
@interface HPFavorite : NSObject

@property(nonatomic, strong)NSMutableArray *favorites;

+ (HPFavorite *)sharedFavorite;
+ (BOOL)isFavoriteWithTid:(NSInteger)tid;
+ (void)ayscnFavoritesWithBlock:(void (^)(NSArray *threads, NSError *error))block;

- (void)favoriteWith:(HPThread *)thread block:(void (^)(BOOL isSuccess, NSError *error))block;
- (void)removeFavoritesWithTid:(NSInteger)tid block:(void (^)(NSString *msg, NSError *error))block;
- (void)removeFavoritesAtIndex:(NSInteger)index block:(void (^)(NSString *msg, NSError *error))block;
- (void)favoriteThreads:(NSArray *)threads;
@end
