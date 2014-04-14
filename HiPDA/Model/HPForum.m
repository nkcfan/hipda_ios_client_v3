//
//  HPForum.m
//  HiPDA
//
//  Created by wujichao on 14-3-19.
//  Copyright (c) 2014年 wujichao. All rights reserved.
//

#import "HPForum.h"
#import "HPHttpClient.h"

@implementation HPForum

- (id)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _fid = [[attributes valueForKeyPath:@"fid"] integerValue];
    _title = [attributes valueForKeyPath:@"title"];
    
    return self;
}

#pragma mark - 
+ (NSArray *)forumsTitle {
    return  @[
        @"删除该板块",
        @"Discovery",
        @"Buy & Sell",
        @"PalmOS",
        @"PocketPC",
        @"E-INK",
        @"Smartphone",
        @"已完成交易",
        @"DC,NB,MP3",
        @"Geek Talks",
        @"意欲蔓延",
        @"iOS",
        @"疑似机器人",
        @"吃喝玩乐",
        @"Joggler",
        @"La Femme",
        @"麦客爱苹果",
        @"随笔与文集",
        @"站务与公告",
        @"只讨论2.0",
        @"Google"
    ];
}

+ (NSDictionary *)forumsDict {
    return @{
        @"Discovery": @2,
        @"Buy & Sell": @6,
        @"PalmOS": @12,
        @"PocketPC": @14,
        @"E-INK": @59,
        @"Smartphone": @9,
        @"已完成交易": @63,
        @"DC,NB,MP3": @50,
        @"Geek Talks": @7,
        @"意欲蔓延": @24,
        @"iOS": @56,
        @"疑似机器人": @57,
        @"吃喝玩乐": @25,
        @"Joggler": @62,
        @"La Femme": @51,
        @"麦客爱苹果": @22,
        @"随笔与文集": @23,
        @"站务与公告": @5,
        @"只讨论2.0": @64,
        @"Google": @60
    };
}


#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInteger:_fid forKey:@"fid"];
    [aCoder encodeObject:_title forKey:@"title"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _fid = [aDecoder decodeIntegerForKey:@"fid"];
        _title = [aDecoder decodeObjectForKey:@"title"];
    }
    return self;
}

+ (void)getType:(int)fid {
    
    NSString *path = S(@"forum/post.php?action=newthread&fid=%d", fid);
    [[HPHttpClient sharedClient] getPathContent:path parameters:nil success:^(AFHTTPRequestOperation *operation, NSString *html) {
        
        /*
        {"1":[], "2":[], "3":[]}
         
        [{key:"分类", value:0},
        {key:"聚会", value:9}];
         */
        
        NSMutableString *results = [NSMutableString stringWithString:S(@"\"%d\":[\n", fid)];
        
       NSArray *ms = [RX(@"<option value=\"(\\d+)\">(.*?)</option>") matchesWithDetails:html];
        BOOL success = NO;
        for (RxMatch *m in ms) {
            success = YES;
            
            RxMatchGroup *g1 = [m.groups objectAtIndex:1];
            RxMatchGroup *g2 = [m.groups objectAtIndex:2];
            //NSLog(@"%@, %@", g1.value, g2.value);
            
            NSString *s = [NSString stringWithFormat:@"{\"key\":\"%@\", \"value\":%@},\n", g2.value, g1.value];
            [results appendString:s];
            
        }
        [results replaceCharactersInRange:NSMakeRange(results.length-2, 1) withString:@""];
        [results appendString:@"]"];
        
        if (success)
            NSLog(@"%@",results);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        ;
    }];
    
}

+ (NSArray *)forumTypeWithFid:(NSInteger)fid {
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"forums_type" ofType:@"plist"]];
    //NSLog(@"%@",dict);
    
    return [dict objectForKey:S(@"%ld", fid)];
}
@end
