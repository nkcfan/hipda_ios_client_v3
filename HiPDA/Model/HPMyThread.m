//
//  HPMyThread.m
//  HiPDA
//
//  Created by wujichao on 13-11-22.
//  Copyright (c) 2013年 wujichao. All rights reserved.
//

#import "HPMyThread.h"
#import "HPThread.h"

#import "EGOCache.h"
#import "HPHttpClient.h"
#import <AFHTTPRequestOperation.h>
#import "NSString+Additions.h"

#define kHPMyThread @"myThreads"
#define DEBUG_ayscn_myThread 0

@implementation HPMyThread


+ (HPMyThread *)sharedMyThread {
    static HPMyThread *sharedMyThread = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyThread = [[HPMyThread alloc] init];
        
        if ([[EGOCache globalCache] hasCacheForKey:kHPMyThread]) {
            sharedMyThread.myThreads = (NSMutableArray *)[[EGOCache globalCache] objectForKey:kHPMyThread];
        } else {
            sharedMyThread.myThreads = [NSMutableArray arrayWithCapacity:10];
        }
    });
    return sharedMyThread;
}



+ (void)ayscnMyThreadWithBlock:(void (^)(NSArray *threads, NSError *error))block
                          page:(NSInteger)page
{
    NSString *path = [NSString stringWithFormat:@"forum/my.php?item=threads&page=%ld", page];
    
    [[HPHttpClient sharedClient] getPathContent:path parameters:nil success:^(AFHTTPRequestOperation *operation, NSString *html)
     {         
         if(DEBUG_ayscn_myThread) NSLog(@"html %@", html);
         
     
         
         //<a href="viewthread.php?tid=1278660" target="_blank">New thread test last</a></th>
         //<td class="forum"><a href="forumdisplay.php?fid=57" target="_blank">疑似机器人</a></td>
         NSString *pattern = @"<th><a href=\"viewthread\\.php\\?tid=(\\d+)[^>]*>(.*?)</a></th>.*?fid=(\\d+)";
         
         NSRegularExpression *reg =
         [[NSRegularExpression alloc] initWithPattern:pattern
                                              options:NSRegularExpressionDotMatchesLineSeparators
                                                error:nil];
         
         NSArray *matches = [reg matchesInString:html
                                         options:0
                                           range:NSMakeRange(0, [html length])];
         
         NSMutableArray *threads = [NSMutableArray arrayWithCapacity:[matches count]];
         
         if(DEBUG_ayscn_myThread)  NSLog(@"threads matches count %ld", [matches count]);
         
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
                 
                 if(DEBUG_ayscn_myThread) NSLog(@"tid %@ title %@ fid %@ ", tidString, title, fidString);
                 
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

- (void)cacheMyThreads:(NSArray *)threads {

    _myThreads = [NSMutableArray arrayWithArray:threads];
    [[EGOCache globalCache] setObject:_myThreads forKey:kHPMyThread];
    
}

@end
