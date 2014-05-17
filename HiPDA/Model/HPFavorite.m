//
//  HPFavorite.m
//  HiPDA
//
//  Created by wujichao on 13-11-17.
//  Copyright (c) 2013年 wujichao. All rights reserved.
//

#import "HPFavorite.h"
#import "HPThread.h"
#import "HPSendPost.h"

#import "NSString+Additions.h"
#import "EGOCache.h"

#import "HPHttpClient.h"
#import <AFHTTPRequestOperation.h>

#define DEBUG_Favorite 0
#define kHPFavoriteKey @"favorites"
#define DEBUG_del_Favorite 0
#define DEBUG_ayscn_Favorite 0

@implementation HPFavorite

+ (HPFavorite *)sharedFavorite {
    static HPFavorite *sharedFavorite = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedFavorite = [[HPFavorite alloc] init];
        
        if ([[EGOCache globalCache] hasCacheForKey:kHPFavoriteKey]) {
            sharedFavorite.favorites = (NSMutableArray *)[[EGOCache globalCache] objectForKey:kHPFavoriteKey];
        } else {
            sharedFavorite.favorites = [NSMutableArray arrayWithCapacity:10];
        }
    });
    return sharedFavorite;
}


- (void)favoriteWith:(HPThread *)thread block:(void (^)(BOOL isSuccess, NSError *error))block {
    
    NSString *key = [NSString stringWithFormat:@"favorites_%ld", thread.tid];
    
    
    // 0
    // check
    if ([[EGOCache globalCache] hasCacheForKey:key]) {

        NSDictionary *details = [NSDictionary dictionaryWithObject:@"您曾经收藏过这个主题" forKey:NSLocalizedDescriptionKey];
        block(NO, [NSError errorWithDomain:@"world" code:200 userInfo:details]);
        
        return;
    }
    
    
    // 1
    // add & cache
    //[_favorites addObject:thread];
    [_favorites insertObject:thread atIndex:0];
    
    // 864000 10days
    [[EGOCache globalCache] setObject:@YES forKey:key withTimeoutInterval:864000];
    [[EGOCache globalCache] setObject:_favorites forKey:kHPFavoriteKey withTimeoutInterval:864000];
    
    
    // 2 submit
    //http://www.hi-pda.com/forum/my.php?item=favorites&tid=1273648&inajax=1&ajaxtarget=favorite_msg
    
    NSString *path = [NSString stringWithFormat:@"forum/my.php?item=favorites&tid=%ld&inajax=1&ajaxtarget=favorite_msg", thread.tid];
    
    if (DEBUG_Favorite) NSLog(@"favorite path %@", path);
    
    [[HPHttpClient sharedClient] getPathContent:path parameters:nil success:^(AFHTTPRequestOperation *operation, NSString *html) {
        
        if (DEBUG_ayscn_Favorite) NSLog(@"favorite html : %@",html);
        
        if (block) {
            if ([html indexOf:@"此主题已成功添加到收藏夹中"] != -1 ||
                [html indexOf:@"您曾经收藏过这个主题"] !=-1 ) {
                block(YES, nil);
                
                if (DEBUG_Favorite) NSLog(@"all favorite %@", _favorites);
                
            } else {
                NSString *err = [html stringBetweenString:@"<![CDATA[" andString:@"]]"];
                if (!err) {
                    err = @"";
                }
                NSDictionary *details = [NSDictionary dictionaryWithObject:err forKey:NSLocalizedDescriptionKey];
                block(NO, [NSError errorWithDomain:@"world" code:200 userInfo:details]);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(NO, error);
        }
    }];
}

+ (BOOL)isFavoriteWithTid:(NSInteger)tid {
    
    NSString *key = [NSString stringWithFormat:@"favorites_%ld", tid];
    return [[EGOCache globalCache] hasCacheForKey:key];
}

- (void)favoriteThreads:(NSArray *)threads {
    
    [_favorites removeAllObjects];
    [_favorites addObjectsFromArray:threads];
    
    for (HPThread *thread in _favorites) {
        
        NSString *key = [NSString stringWithFormat:@"favorites_%ld", thread.tid];
        
        // cache key
        [[EGOCache globalCache] setObject:@YES forKey:key withTimeoutInterval:864000];
    }
    
    // cache all
    [[EGOCache globalCache] setObject:_favorites forKey:kHPFavoriteKey withTimeoutInterval:864000];
}

- (void)removeFavoritesWithTid:(NSInteger)tid block:(void (^)(NSString *msg, NSError *error))block{
    
    __block NSUInteger index = -1;
    [_favorites enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        HPThread *t = (HPThread *)obj;
        index = idx;
        
        if (t.tid == tid) {
            
            *stop = YES;
        }
    }];
    [self removeFavoritesAtIndex:index block:block];
}

- (void)removeFavoritesAtIndex:(NSInteger)index block:(void (^)(NSString *msg, NSError *error))block{
    
    if (index < 0 || index > [_favorites count]) {
        NSLog(@"index < 0 || index > [_favorites count]");
        NSDictionary *details = [NSDictionary dictionaryWithObject:@"您本设备没有收藏过这个帖子" forKey:NSLocalizedDescriptionKey];
        block(nil, [NSError errorWithDomain:@".hi-pda.com" code:404 userInfo:details]);
        return;
    }
    
    NSInteger tid = [[_favorites objectAtIndex:index] tid];
    
    // 1
    // remove & recache
    [_favorites removeObjectAtIndex:index];
    
    // 864000 10days
    NSString *key = [NSString stringWithFormat:@"favorites_%ld", tid];
    [[EGOCache globalCache] removeCacheForKey:key];
    [[EGOCache globalCache] setObject:_favorites forKey:kHPFavoriteKey withTimeoutInterval:864000];
    
    
    // 2 submit
    [HPSendPost loadParametersWithBlock:^(NSDictionary *results, NSError *error) {
        
        NSString *path = @"forum/my.php?item=favorites&type=thread";
        
        NSString *formhash = [results objectForKey:@"formhash"];
        
        if (!formhash) {
            NSDictionary *details = [NSDictionary dictionaryWithObject:@"获取token失败" forKey:NSLocalizedDescriptionKey];
            block(nil, [NSError errorWithDomain:@"world" code:200 userInfo:details]);
            return;
        };
        
        NSString *tidString = [NSString stringWithFormat:@"%ld", tid];
        
        NSDictionary *parameters = @{@"formhash": formhash,
                                     @"delete[]": tidString,
                                     @"favsubmit": @"true"};
        
        if (DEBUG_del_Favorite) NSLog(@"del favorite path %@ %@", path, parameters);
        
        [[HPHttpClient sharedClient] postPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSString *html = [HPHttpClient GBKresponse2String:responseObject];
            if (DEBUG_del_Favorite) NSLog(@"%@", html);
            
            /*<div class="postbox"><div class="alert_right">
             <p>收藏夹已成功更新，现在将转入更新后的收藏夹。<script>setTimeout("window.location.href ='http://www.hi-pda.com/forum/forumdisplay.php?fid=2';", 1000);</script></p>
             <p class="alert_btnleft"><a href="http://www.hi-pda.com/forum/forumdisplay.php?fid=2">如果您的浏览器没有自动跳转，请点击此链接</a></p>
             </div></div>
             */
            
            if (block) {
                
                if ([html indexOf:@"收藏夹已成功更新"] != -1) {
                    block(@"success", nil);
                } else {
                    NSString *alert = [html stringBetweenString:@"<div class=\"alert_" andString:@"</div>"];
                    NSDictionary *details = [NSDictionary dictionaryWithObject:alert forKey:NSLocalizedDescriptionKey];
                    block(@"", [NSError errorWithDomain:@"world" code:200 userInfo:details]);
                }
            }
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (block) {
                block(@"", error);
            }
        }];
    }];
}


+ (void)ayscnFavoritesWithBlock:(void (^)(NSArray *threads, NSError *error))block
{

    NSString *path = @"forum/my.php?item=favorites&type=thread";
    
    [[HPHttpClient sharedClient] getPathContent:path parameters:nil success:^(AFHTTPRequestOperation *operation, NSString *html) {
        
        NSLog(@" html %@", html);
    
        
        NSString *pattern = @"<a href=\"viewthread\\.php\\?tid=(\\d+)[^>]*>(.*?)</a></th>.*?fid=(\\d+)";
        
        NSRegularExpression *reg =
        [[NSRegularExpression alloc] initWithPattern:pattern
                                             options:NSRegularExpressionDotMatchesLineSeparators
                                               error:nil];
        
        NSArray *matches = [reg matchesInString:html
                                        options:0
                                          range:NSMakeRange(0, [html length])];
        
        NSMutableArray *threads = [NSMutableArray arrayWithCapacity:[matches count]];
        
        if(DEBUG_ayscn_Favorite)  NSLog(@"threads matches count %ld", [matches count]);
        
        for (NSTextCheckingResult *result in matches) {
            
            if ([result numberOfRanges] == 4) {
                
                NSRange tidRange = NSMakeRange([result rangeAtIndex:1].location, [result rangeAtIndex:1].length);
                NSString *tidString = [html substringWithRange:tidRange];
                NSInteger tid = [tidString integerValue];
                
                NSRange titleRange = NSMakeRange([result rangeAtIndex:2].location, [result rangeAtIndex:2].length);
                NSString *title = [html substringWithRange:titleRange];
                
                NSRange fidRange = NSMakeRange([result rangeAtIndex:3].location, [result rangeAtIndex:3].length);
                NSString *fidString = [html substringWithRange:fidRange];
                NSInteger fid = [fidString integerValue];
                
                HPThread *thread = [[HPThread alloc] init];
                thread.tid = tid;
                thread.title = title;
                thread.fid = fid;
                
                if(DEBUG_ayscn_Favorite) NSLog(@"tid %@ title %@ fid %@ ", tidString, title, fidString);
                
                [threads addObject:thread];
                
            } else {
                NSLog(@"error %@ %ld", result, [result numberOfRanges]);
            }
        }
        
        if (block) {
            block([NSArray arrayWithArray:threads], nil);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block([NSArray array], error);
        }
    }];

}

@end
