//
//  HPHttpClient.m
//  HiPDA
//
//  Created by wujichao on 13-11-11.
//  Copyright (c) 2013年 wujichao. All rights reserved.
//

#import "HPHttpClient.h"
#import "AFHTTPRequestOperation.h"
#import "HPAccount.h"

#import "NSString+Additions.h"

static NSString * const kHPClientBaseURLString = @"http://www.hi-pda.com/";

@implementation HPHttpClient

+ (HPHttpClient *)sharedClient {
    static HPHttpClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[HPHttpClient alloc] initWithBaseURL:[NSURL URLWithString:kHPClientBaseURLString]];
    });
    
    /*
     * login cookies
     */
    /*
    NSArray * availableCookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:@"http://www.hi-pda.com"]];
    NSDictionary * headers = [NSHTTPCookie requestHeaderFieldsWithCookies:availableCookies];
    //NSLog(@"headers %@", headers);
    */
    /*
    NSString *Cookie = [headers objectForKey:@"Cookie"];
    NSLog(@"_sharedClient cookie %@", Cookie);
     */
    //[_sharedClient setDefaultHeader:@"Cookie" value:[headers objectForKey:@"Cookie"]];
    
    // not work?
    [_sharedClient setStringEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)];
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    
    [self setDefaultHeader:@"Host" value:@"www.hi-pda.com"];
    [self setDefaultHeader:@"User-Agent" value:@"Mozilla/5.0 (iPhone; CPU iPhone OS 7_0_3 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11B508 Safari/9537.53"];
    [self setDefaultHeader:@"Accept" value:@"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"];
    [self setDefaultHeader:@"Accept-Encoding" value:@"gzip, deflate"];
    [self setDefaultHeader:@"Accept-Language" value:@"zh-cn"];
    
    [self setDefaultHeader:@"Referer" value:@"http://www.hi-pda.com/forum/forumdisplay.php?fid=2"];
    
    return self;
}

- (void)getPathContent:(NSString *)path
            parameters:(NSDictionary *)parameters
               success:(void (^)(AFHTTPRequestOperation *operation, NSString *html))success
               failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
	[super getPath:path
        parameters:parameters
           success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSError *error;
        NSString *content = [HPHttpClient prepareHTML:responseObject error:&error];
        //NSLog(@"content html %@", content);
        
        if (error) {
            failure(operation, error);
        } else {
            success(operation, content);
        }
    }
           failure:failure
    ];
}

/*
 * overwrite add cookies handle
 */
- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                      path:(NSString *)path
                                parameters:(NSDictionary *)parameters {
    NSMutableURLRequest *request = [super requestWithMethod:method path:path parameters:parameters];
    
    if (!request) {
        NSLog(@"!request");
        return nil;
    }
    
    [request setHTTPShouldHandleCookies:YES];
    
    return request;
}



+ (NSString *)GBKresponse2String:(id) responseObject {
    
    NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    
    NSString *src = [[NSString alloc] initWithData:responseObject encoding:gbkEncoding];
    
    if (!src) src = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
    
    return src;
}

+ (NSString *)prepareHTML:(id)responseObject error:(NSError **)error{
    
    NSString *src = [HPHttpClient GBKresponse2String:responseObject];
    //NSLog(@"%@", src);
    
    if ([src indexOf:@"loginform"] != -1) {
        
        // need login
        [[HPAccount sharedHPAccount] loginWithBlock:^(BOOL isLogin, NSError *err) {
            NSLog(@"relogin %@", isLogin?@"success":@"fail");
        }];
        
        if (error) {
            *error = [NSError errorWithDomain:@".hi-pda.com" code:NSURLErrorUserAuthenticationRequired userInfo:nil];
        }
    }
    
    return src;
}

@end
