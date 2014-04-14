//
//  HPSearch.m
//  HiPDA
//
//  Created by wujichao on 13-11-22.
//  Copyright (c) 2013年 wujichao. All rights reserved.
//

#import "HPSearch.h"

#import "HPHttpClient.h"
#import <AFHTTPRequestOperation.h>
#import "NSString+Additions.h"

#define DEBUG_Search 0


@implementation HPSearch


+ (void)searchWithParameters:(NSDictionary *)parameters
                        type:(HPSearchType)type
                        page:(NSInteger)page
                       block:(void (^)(NSArray *results, NSInteger pageCount,NSError *error))block
{
    
    NSString *path = nil;
    switch (type) {
        case HPSearchTypeTitle:
        {
            NSString *key = [parameters objectForKey:@"key"];
            path = [NSString stringWithFormat:@"forum/search.php?srchtxt=%@&srchtype=title&searchsubmit=true&st=on&srchuname=&srchfilter=all&srchfrom=0&before=&orderby=lastpost&ascdesc=desc&srchfid[0]=all&page=%ld", key, page];
            break;
        }
        case HPSearchTypeFullText:
        {
            NSString *key = [parameters objectForKey:@"key"];
            path = [NSString stringWithFormat:@"forum/search.php?srchtype=fulltext&srchtxt=%@&searchsubmit=true&st=on&srchuname=&srchfilter=all&srchfrom=0&before=&orderby=lastpost&ascdesc=desc&page=%ld", key, page];
            break;
        }
        default:
            NSLog(@"error HPSearchType %ld", type);
            break;
    }
    

    NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    path = [path stringByAddingPercentEscapesUsingEncoding:gbkEncoding];
    
    
    [[HPHttpClient sharedClient] getPathContent:path parameters:nil success:^(AFHTTPRequestOperation *operation, NSString *html)
     {         
         if(DEBUG_Search) NSLog(@"html %@", html);
         
    
         
         NSString *pageCountString = [html stringBetweenString:@"相关主题 " andString:@" 个"];
         NSInteger pageCount = 0;
         if(DEBUG_Search) NSLog(@"pageCountString _%@_", pageCountString);
         if (pageCountString && ![pageCountString isEqualToString:@""]) {
             
             pageCount = [pageCountString integerValue];
             pageCount = pageCount / 50 + ((pageCount % 50) == 0 ? 0 : 1);
             pageCount = pageCount > 20 ? 20 : pageCount;
             if(DEBUG_Search) NSLog(@"in _%@_ %ld", pageCountString, pageCount);
         }
         
         NSMutableArray *results = [NSMutableArray arrayWithCapacity:50];
         NSString *pattern = nil;
         NSArray *props = nil;
         
         switch (type) {
             case HPSearchTypeTitle:
             {
                 pattern = @"th class=\"subject.*?<a href=\"viewthread\\.php\\?tid=(\\d+)[^>]+>(.*?)</a>.*?fid=(\\d+)\">(.*?)</a>.*?uid=(\\d+)\">(.*?)</a>.*?<em>(.*?)</em>";
                 
                 props = @[@"tidString", @"title",
                           @"fidString", @"forum",
                           @"uidString", @"username",
                           @"dateString"];
                 
                 break;
             }
             case HPSearchTypeFullText:
             {
                 pattern = @"<a href=\"gotopost\\.php\\?pid=(\\d+)\" target=\"_blank\">(.*?)</a>.*?sp_content\">(.*?)</div>.*?fid=(\\d+)\">(.*?)</a>.*?uid=(\\d+)\">(.*?)</a>";
                 
                 props = @[@"pidString", @"title", @"detail",
                           @"fidString", @"forum",
                           @"uidString", @"username"];
                 break;
             }
             default:
                 NSLog(@"error HPSearchType %ld", type);
                 break;
         }
         NSRegularExpression *reg =
         [[NSRegularExpression alloc] initWithPattern:pattern
                                              options:NSRegularExpressionDotMatchesLineSeparators
                                                error:nil];
         
         NSArray *matches = [reg matchesInString:html
                                         options:0
                                           range:NSMakeRange(0, [html length])];
         
         
         if(DEBUG_Search)  NSLog(@"threads matches count %ld", [matches count]);
         
         for (NSTextCheckingResult *result in matches) {
             
             if ([result numberOfRanges] == [props count] + 1) {
                 
                 NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:[props count]];
                 
                 for (int i=0; i < [props count]; i++) {
                     NSString *prop = [props objectAtIndex:i];
                     
                     NSRange range = NSMakeRange([result rangeAtIndex:i+1].location, [result rangeAtIndex:i+1].length);
                     NSString *value = [html substringWithRange:range];
                     
                     //<em style="color:red;">软件</em>
                     // 『』
                     // \n
                     if ([prop isEqualToString:@"title"] || [prop isEqualToString:@"detail"]) {
                         NSMutableString *raw = [NSMutableString stringWithString:value];
                         [raw replaceOccurrencesOfString:@"<em style=\"color:red;\">" withString:@"「" options:NSLiteralSearch range:NSMakeRange(0, [raw length])];
                         [raw replaceOccurrencesOfString:@"</em>" withString:@"」" options:NSLiteralSearch range:NSMakeRange(0, [raw length])];
                         
                         [raw replaceOccurrencesOfString:@"\n" withString:@"  " options:NSLiteralSearch range:NSMakeRange(0, [raw length])];
                         value = [NSString stringWithString:raw];
                     }
                     
                     
                     [dict setObject:value forKey:prop];
                 }
                 
                 
                 if(DEBUG_Search) NSLog(@"dict %@", dict);
                 
                 [results addObject:dict];
                 
             } else {
                 NSLog(@"error %@ %ld", result, [result numberOfRanges]);
             }
         }
         
         if (block) {
             block([NSArray arrayWithArray:results], pageCount, nil);
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         if (block) {
             block([NSArray array], 0, error);
         }
     }];
}


@end
