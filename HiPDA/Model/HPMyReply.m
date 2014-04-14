//
//  HPMyReply.m
//  HiPDA
//
//  Created by wujichao on 13-11-22.
//  Copyright (c) 2013年 wujichao. All rights reserved.
//

#import "HPMyReply.h"
#import "HPThread.h"

#import "EGOCache.h"
#import "HPHttpClient.h"
#import <AFHTTPRequestOperation.h>
#import "NSString+Additions.h"

#define kHPMyReplies @"myReplies"
#define DEBUG_ayscn_myreply 0

@implementation HPMyReply

+ (HPMyReply *)sharedReply {
    
    static HPMyReply *sharedReply = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedReply = [[HPMyReply alloc] init];
        
        if ([[EGOCache globalCache] hasCacheForKey:kHPMyReplies]) {
            sharedReply.myReplies = (NSMutableArray *)[[EGOCache globalCache] objectForKey:kHPMyReplies];
        } else {
            sharedReply.myReplies = [NSMutableArray arrayWithCapacity:10];
        }
    });
    return sharedReply;
    
}
+ (void)ayscnMyRepliesWithBlock:(void (^)(NSArray *threads, NSError *error))block
                           page:(NSInteger)page {

    NSString *path = [NSString stringWithFormat:@"forum/my.php?item=posts&page=%ld", page];
    
    [[HPHttpClient sharedClient] getPathContent:path parameters:nil success:^(AFHTTPRequestOperation *operation, NSString *html)
     {
         if(DEBUG_ayscn_myreply) NSLog(@"html %@", html);
         
     
         
         /*
          <th><a href="redirect.php?goto=findpost&amp;pid=23355813&amp;ptid=1272557" target="_blank">{酝酿改进中} D版 iOS 客户端</a></th>
          <td class="forum"><a href="forumdisplay.php?fid=2" target="_blank">Discovery</a></td>
          <td class="nums">正常</td>
          <td class="lastpost">
          <em>2013-11-22 21:27</em>
          </td>
          </tr>
          <tr>
          <td class="folder">&nbsp;</td>
          <td class="icon">&nbsp;</td>
          <th colspan="4" class="lighttxt">回复  zongxuenian  
          过几天发内测邀请, 您把新的udid到时候回复我</th>
          </tr><tr>
          */
         NSString *pattern = @"<th><a href=\"redirect\\.php\\?goto=findpost&amp;pid=(\\d+)&amp;ptid=(\\d+)\" target=\"_blank\">(.*?)</a></th>.*?fid=(\\d+).*?lighttxt\">(.*?)</th>";
         
         NSRegularExpression *reg =
         [[NSRegularExpression alloc] initWithPattern:pattern
                                              options:NSRegularExpressionDotMatchesLineSeparators
                                                error:nil];
         
         NSArray *matches = [reg matchesInString:html
                                         options:0
                                           range:NSMakeRange(0, [html length])];
         
         NSMutableArray *threads = [NSMutableArray arrayWithCapacity:[matches count]];
         
         if(DEBUG_ayscn_myreply)  NSLog(@"threads matches count %ld", [matches count]);
         
         for (NSTextCheckingResult *result in matches) {
             
             if ([result numberOfRanges] == 6) {
                 
                 NSRange pidRange = NSMakeRange([result rangeAtIndex:1].location, [result rangeAtIndex:1].length);
                 NSString *pidString = [html substringWithRange:pidRange];
                 NSInteger pid = [pidString integerValue];
                 
                 NSRange tidRange = NSMakeRange([result rangeAtIndex:2].location, [result rangeAtIndex:2].length);
                 NSString *tidString = [html substringWithRange:tidRange];
                 NSInteger tid = [tidString integerValue];
                 
                 NSRange titleRange = NSMakeRange([result rangeAtIndex:3].location, [result rangeAtIndex:3].length);
                 NSString *title = [html substringWithRange:titleRange];
                 
                 NSRange fidRange = NSMakeRange([result rangeAtIndex:4].location, [result rangeAtIndex:4].length);
                 NSString *fidString = [html substringWithRange:fidRange];
                 NSInteger fid = [fidString integerValue];
                 
                 NSRange detailRange = NSMakeRange([result rangeAtIndex:5].location, [result rangeAtIndex:5].length);
                 NSString *detailRaw = [html substringWithRange:detailRange];
                 NSMutableString *detail = [NSMutableString stringWithString:detailRaw];
                 [detail replaceOccurrencesOfString:@"\n" withString:@" " options:NSCaseInsensitiveSearch range:NSMakeRange(0, [detail length])];
                 
                 HPThread *thread = [[HPThread alloc] init];
                 thread.tid = tid;
                 thread.title = title;
                 thread.fid = fid;
                 thread.pid = pid;
                 thread.replyDetail = detail;
                 
                 if(DEBUG_ayscn_myreply) NSLog(@"tid %@ title %@ fid %@ detail %@", tidString, title, fidString, detail);
                 
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

- (void)cacheMyReplies:(NSArray *)threads {
    
    _myReplies = [NSMutableArray arrayWithArray:threads];
    [[EGOCache globalCache] setObject:_myReplies forKey:kHPMyReplies];
    
}

@end
