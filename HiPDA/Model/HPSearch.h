//
//  HPSearch.h
//  HiPDA
//
//  Created by wujichao on 13-11-22.
//  Copyright (c) 2013年 wujichao. All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
    HPSearchTypeTitle     = 0,
    HPSearchTypeFullText  = 1
} ;
typedef NSUInteger HPSearchType;


@interface HPSearch : NSObject

+ (void)searchWithParameters:(NSDictionary *)parameters
                        type:(HPSearchType)type
                        page:(NSInteger)page
                       block:(void (^)(NSArray *results, NSInteger pageCount, NSError *error))block;


@end

