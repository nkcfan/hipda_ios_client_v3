//
//  HPNotice.m
//  HiPDA
//
//  Created by wujichao on 13-11-25.
//  Copyright (c) 2013年 wujichao. All rights reserved.
//

#import "HPNotice.h"
#import "HPThread.h"
#import "HPSetting.h"
#import "HPAttention.h"

#import "EGOCache.h"
#import "HPHttpClient.h"
#import <AFHTTPRequestOperation.h>
#import "NSString+Additions.h"

#define kHPMyNotices @"myNotices"
#define DEBUG_MyNotice 0

@implementation HPNotice

+ (HPNotice *)sharedNotice {
    
    static HPNotice *sharedNotice = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedNotice = [[HPNotice alloc] init];
        
        if ([[EGOCache globalCache] hasCacheForKey:kHPMyNotices]) {
            sharedNotice.myNotices = (NSMutableArray *)[[EGOCache globalCache] objectForKey:kHPMyNotices];
        } else {
            sharedNotice.myNotices = [NSMutableArray arrayWithCapacity:10];
        }
    });
    return sharedNotice;
    
}

+ (void)ayscnMyNoticesWithBlock:(void (^)(NSArray *threads, NSError *error))block
                           page:(NSInteger)page {
    
    NSString *path = [NSString stringWithFormat:@"forum/notice.php?filter=threads&page=%ld", page];
    
    [[HPHttpClient sharedClient] getPathContent:path parameters:nil success:^(AFHTTPRequestOperation *operation, NSString *html)
     {
         if(DEBUG_MyNotice) NSLog(@"html %@", html);
         
         
         NSString *main_pattern = @"<div class=\"f_(.*?)\">(.*?)</div>";
         
         
         NSRegularExpression *main_reg =
         [[NSRegularExpression alloc] initWithPattern:main_pattern
                                              options:NSRegularExpressionDotMatchesLineSeparators
                                                error:nil];
         
         NSArray *main_matches = [main_reg matchesInString:html
                                                   options:0
                                                     range:NSMakeRange(0, [html length])];
         
         NSMutableArray *threads = [NSMutableArray arrayWithCapacity:[main_matches count]];
         
         
         if(DEBUG_MyNotice)  NSLog(@"threads matches count %ld", [main_matches count]);
         
         for (NSTextCheckingResult *main_result in main_matches) {
             
             
             if ([main_result numberOfRanges] == 3) {
                 //quote
                 //reply
                 //thread
                 NSString *type = [html substringWithRange:NSMakeRange([main_result rangeAtIndex:1].location, [main_result rangeAtIndex:1].length)];
                 
                 NSString *content = [html substringWithRange:NSMakeRange([main_result rangeAtIndex:2].location, [main_result rangeAtIndex:2].length)];
                 
                 if(DEBUG_MyNotice) NSLog(@"%@ ", type);
                 
                 if ([type isEqualToString:@"thread"]) {
                     
                     // TODO: match 1 only contains the last replier in all, which is also misleading after jumping
                     // to the first reply in the thread
                     NSString *pattern = @"<a[^>]+>(.*?)</a>.*?pid=(\\d+).*?ptid=(\\d+)\">(.*?)</a>";
                     
                     NSRegularExpression *reg =
                     [[NSRegularExpression alloc] initWithPattern:pattern
                                                          options:NSRegularExpressionDotMatchesLineSeparators
                                                            error:nil];
                     
                     NSArray *matches = [reg matchesInString:content
                                                     options:0
                                                       range:NSMakeRange(0, [content length])];
                     
                     if ([matches count] == 1) {
                         
                         NSTextCheckingResult *result = [matches objectAtIndex:0];
                         
                         NSRange heNameRange = NSMakeRange([result rangeAtIndex:1].location, [result rangeAtIndex:1].length);
                         NSString *heName = [content substringWithRange:heNameRange];
                         
                         NSRange pidRange = NSMakeRange([result rangeAtIndex:2].location, [result rangeAtIndex:2].length);
                         NSString *pidString = [content substringWithRange:pidRange];
                         NSInteger pid = [pidString integerValue];
                         
                         NSRange tidRange = NSMakeRange([result rangeAtIndex:3].location, [result rangeAtIndex:3].length);
                         NSString *tidString = [content substringWithRange:tidRange];
                         NSInteger tid = [tidString integerValue];
                         
                         NSRange titleRange = NSMakeRange([result rangeAtIndex:4].location, [result rangeAtIndex:4].length);
                         NSString *title = [content substringWithRange:titleRange];
                         
                         
                         NSString *detail = [NSString stringWithFormat:@"「%@」回复的您的主题", heName];
                         
                         HPThread *thread = [[HPThread alloc] init];
                         thread.tid = tid;
                         thread.pid = pid;
                         thread.title = title;
                         thread.replyDetail = detail;
                         
                         // This thread is in the server attention list, add to local cache
                         [HPAttention cacheAttention:tid];
                         
                         if(DEBUG_MyNotice) NSLog(@"heName %@ tidString %@, title %@, detail %@", heName,tidString,title,detail);
                         
                         [threads addObject:thread];
                     }
                     
                 } else {
                     
                     NSString *pattern = @"<a.*?tid=(\\d+)\">(.*?)</a>.*?summary\"><dt>您的帖子：<dt><dd>(.*?)</dd><dt><a[^>]+>(.*?)</a> 说：</dt><dd>(.*?)</dd></dl>.*?fid=(\\d+).*?pid=(\\d+)";
                     
                     NSRegularExpression *reg =
                     [[NSRegularExpression alloc] initWithPattern:pattern
                                                          options:NSRegularExpressionDotMatchesLineSeparators
                                                            error:nil];
                     
                     NSArray *matches = [reg matchesInString:content
                                                     options:0
                                                       range:NSMakeRange(0, [content length])];
                     
                     if ([matches count] == 1) {
                         
                         NSTextCheckingResult *result = [matches objectAtIndex:0];
                         
                         NSRange tidRange = NSMakeRange([result rangeAtIndex:1].location, [result rangeAtIndex:1].length);
                         NSString *tidString = [content substringWithRange:tidRange];
                         NSInteger tid = [tidString integerValue];
                         
                         NSRange titleRange = NSMakeRange([result rangeAtIndex:2].location, [result rangeAtIndex:2].length);
                         NSString *title = [content substringWithRange:titleRange];
                         
                         NSRange myPostRange = NSMakeRange([result rangeAtIndex:3].location, [result rangeAtIndex:3].length);
                         NSString *myPostRaw = [content substringWithRange:myPostRange];
                         
                         NSRange heNameRange = NSMakeRange([result rangeAtIndex:4].location, [result rangeAtIndex:4].length);
                         NSString *heName = [content substringWithRange:heNameRange];
                         
                         NSRange hePostRange = NSMakeRange([result rangeAtIndex:5].location, [result rangeAtIndex:5].length);
                         NSString *hePostRaw = [content substringWithRange:hePostRange];
                         
                         
                         NSRange fidRange = NSMakeRange([result rangeAtIndex:6].location, [result rangeAtIndex:6].length);
                         NSString *fidString = [content substringWithRange:fidRange];
                         NSInteger fid = [fidString integerValue];
                         
                         NSRange pidRange = NSMakeRange([result rangeAtIndex:7].location, [result rangeAtIndex:7].length);
                         NSString *pidString = [content substringWithRange:pidRange];
                         NSInteger pid = [pidString integerValue];
                         
                         NSMutableString *myPost = [NSMutableString stringWithString:myPostRaw];
                         [myPost replaceOccurrencesOfString:@"\n" withString:@" " options:NSCaseInsensitiveSearch range:NSMakeRange(0, [myPost length])];
                         
                         NSMutableString *hePost = [NSMutableString stringWithString:hePostRaw];
                         [hePost replaceOccurrencesOfString:@"\n" withString:@" " options:NSCaseInsensitiveSearch range:NSMakeRange(0, [hePost length])];
                         
                         NSString *detail = [NSString stringWithFormat:@"「你说」:%@\n「%@说」:%@", myPost, heName, hePost];
                         
                         HPThread *thread = [[HPThread alloc] init];
                         thread.tid = tid;
                         thread.title = title;
                         thread.fid = fid;
                         thread.pid = pid;
                         thread.replyDetail = detail;
                         
                         
                         if(DEBUG_MyNotice) NSLog(@"heName %@, tid %ld title %@ myPost%@ hePost %@ fid %ld detail %@ pid %@ ", tidString, tid,  title, myPost, hePost, fid ,detail, pidString);
                         
                         [threads addObject:thread];
                     }
                 }
                 /*
                  
                  */
                 
             } else {
                 NSLog(@"error %@ %ld", main_result, [main_result numberOfRanges]);
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

+ (void)ignoreNotice {
    [HPNotice ayscnMyNoticesWithBlock:^(NSArray *threads, NSError *error) {
        
        if (!error) {
            [Setting saveInteger:0 forKey:HPNoticeCount];
        }
        
        if (error && error.code == NSURLErrorUserAuthenticationRequired) {
            NSLog(@"ignoreNotice need login");
            
            NSTimeInterval delay = 3.f;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^{
                [HPNotice ayscnMyNoticesWithBlock:^(NSArray *threads, NSError *error) {
                    NSLog(@"ignoreNotice try again %@", error);
                    
                    if (!error) {
                        [Setting saveInteger:0 forKey:HPNoticeCount];
                    }
                    
                } page:1];
            });
        }
        
    } page:1];
}


- (void)cacheMyNotices:(NSArray *)threads {
    
    _myNotices = [NSMutableArray arrayWithArray:threads];
    [[EGOCache globalCache] setObject:_myNotices forKey:kHPMyNotices];
    
}

@end