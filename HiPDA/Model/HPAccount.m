//
//  HPAccount.m
//  HiPDA
//
//  Created by wujichao on 13-11-11.
//  Copyright (c) 2013年 wujichao. All rights reserved.
//

#import "HPCommon.h"
#import "HPAccount.h"
#import "HPHttpClient.h"
#import "HPSetting.h"
#import "HPTheme.h"
#import "RegExCategories.h"
#import "HPMessage.h"

#import "HPRearViewController.h"

#import "SSKeychain.h"
#import "NSString+Additions.h"
#import "AFHTTPRequestOperation.h"
#import "NSHTTPCookieStorage+info.h"

#import "HPLoginViewController.h"

#import <AudioToolbox/AudioToolbox.h>


/*
 loginfield // username uid email
 username
 password
 questionid
 */
/*
 0 安全提问
 1 母亲的名字
 2 爷爷的名字
 3 父亲出生的城市
 4 您其中一位老师的名字
 5 您个人计算机的型号
 6 您最喜欢的餐馆名称
 7 驾驶执照的最后四位数字
 */
/*
 answer
 formhash // 69dd40ac
 */

@interface HPAccount ()

@property (nonatomic, strong) NSTimer *checkTimer;

@end

@implementation HPAccount


+ (HPAccount *)sharedHPAccount {
    static HPAccount *_sharedHPAccount = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedHPAccount = [[HPAccount alloc] init];
    });
    
    return _sharedHPAccount;
}

+ (BOOL)isSetAccount {
    NSString *username = [NSStandardUserDefaults stringForKey:kHPAccountUserName or:@""];
    NSString *credential = [SSKeychain passwordForService:kHPKeychainService account:username];
    NSArray *arr = [credential componentsSeparatedByString:@"\n"];
    
    return [username length] && [credential length] && [arr count] == 3;
}


- (void)loginWithBlock:(void (^)(BOOL isLogin, NSError *error))block {
    
    // acquire account info
    if (![HPAccount isSetAccount]) {
        HPLoginViewController *loginvc = [[HPLoginViewController alloc] init];
        
        [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:[HPCommon NVCWithRootVC:loginvc] animated:YES completion:^{
            ;
        }];
        block(NO, [NSError errorWithDomain:@".hi-pda.com" code:kHPNoAccountCode userInfo:nil]);
        return;
    }
    
    NSLog(@"login step1");
    [[HPHttpClient sharedClient] getPath:@"forum/logging.php?action=login" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *src = [HPHttpClient GBKresponse2String:responseObject];
        
        NSString *formhash = [src stringBetweenString:@"formhash\" value=\"" andString:@"\""];
        if (formhash) {
            
            NSLog(@"login get formhash %@", formhash);
            [self _loginWithFormhash:formhash block:block];
            
        } else {
            
            NSString *alert_info = [src stringBetweenString:@"<div class=\"alert_info\">\n<p>" andString:@"</p>"];
            NSString *alert_error = [src stringBetweenString:@"<div class=\"alert_error\">\n<p>" andString:@"</p></div>"];
            NSString *msg = nil;
            if (alert_info) msg = alert_info;
            else if (alert_error) msg = alert_error;
            else msg = src;
            
            if (block) {
                NSLog(@"login step1 找不到token %@", src);
                block(NO, [NSError errorWithDomain:@".hi-pda.com" code:NSURLErrorUserAuthenticationRequired userInfo:@{NSLocalizedDescriptionKey:S(@"找不到token, 错误信息: %@", msg)}]);
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(NO, error);
        }
    }];
}

- (void)_loginWithFormhash:(NSString *)formhash block:(void (^)(BOOL isLogin, NSError *error))block {
    
    NSString *username = [NSStandardUserDefaults stringForKey:kHPAccountUserName or:@""];
    NSString *credential = [SSKeychain passwordForService:kHPKeychainService account:username];
    NSArray *arr = [credential componentsSeparatedByString:@"\n"];
    if ([arr count] < 3) {
        NSLog(@"login credential does not contain 3 components");
        block(NO, [NSError errorWithDomain:@".hi-pda.com" code:NSURLErrorUserAuthenticationRequired userInfo:@{NSLocalizedDescriptionKey:@"Keychain出问题了"}]);
        return;
    }
    NSString *password = arr[0];
    NSString *questionid = arr[1];
    NSString *answer = arr[2];
    
    NSDictionary *parameters = @{
         @"loginfield":@"username",
         @"username":username,
         @"password":password,
         @"questionid":questionid,
         @"answer":answer,
         @"cookietime":@"2592000",
         @"referer":@"http://www.hi-pda.com/forum/index.php",
         @"formhash":formhash
    };
    
    NSLog(@"login step2 parameters %@", parameters);
    
    [[HPHttpClient sharedClient] postPath:@"forum/logging.php?action=login&loginsubmit=yes&inajax=1&inajax=1" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *html = [HPHttpClient GBKresponse2String:responseObject];
        //NSLog(@"login html : %@",html);
        
        BOOL isSuccess = ([html indexOf:@"欢迎您回来"] != -1);
        NSString *errMsg = [html stringBetweenString:@"<![CDATA[" andString:@"]]"];
        if (!errMsg) errMsg = html;
        if (!html) errMsg = @"null response";
        
        if (isSuccess) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kHPUserLoginSuccess object:nil];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:kHPUserLoginError object:nil userInfo:@{@"error":[NSError errorWithDomain:@".hi-pda.com" code:NSURLErrorUserAuthenticationRequired userInfo:@{NSLocalizedDescriptionKey:errMsg}]}];
        }
        
        if (block) {
            block(isSuccess, [NSError errorWithDomain:@".hi-pda.com" code:NSURLErrorUserAuthenticationRequired userInfo:@{NSLocalizedDescriptionKey:errMsg}]);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(NO, error);
        }
    }];
}

//
//- (void)old____loginWithBlock:(void (^)(BOOL isLogin, NSError *error))block {
//    
//    _loginfield = @"username";
//    _formhash = @"69dd40ac";
//    
//    _username = [NSStandardUserDefaults stringForKey:kHPAccountUserName or:@""];
//    _password = [NSStandardUserDefaults stringForKey:kHPAccountPassword or:@""];
//    _questionid = [NSStandardUserDefaults stringForKey:kHPAccountQuestionid or:@""];
//    _answer = [NSStandardUserDefaults stringForKey:kHPAccountAnswer or:@""];
//    _uid = [NSStandardUserDefaults stringForKey:kHPAccountUID or:@""];
//    
//    //NSLog(@"loginWithBlock call _username: %@",_username);
//    if (![HPAccount isSetAccount]) {
//        
//        HPLoginViewController *loginvc = [[HPLoginViewController alloc] init];
//        
//        [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:[HPCommon NVCWithRootVC:loginvc] animated:YES completion:^{
//            ;
//        }];
//        block(NO, [NSError errorWithDomain:@".hi-pda.com" code:kHPNoAccountCode userInfo:nil]);
//        return;
//    }
//    
//    NSString *loginPath = [NSString stringWithFormat:@"forum/logging.php?action=login&loginsubmit=yes&inajax=1&answer=%@&cookietime=2592000&formhash=%@&loginfield=%@&password=%@&questionid=%@&referer=http://www.hi-pda.com/forum/forumdisplay.php?fid=2&username=%@", _answer, _formhash, _loginfield, _password, _questionid, _username];
//    loginPath = [loginPath stringByAddingPercentEscapesUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)];
//    
//    NSLog(@"loginPath %@", loginPath);
//    
//    NSLog(@"login before");
//    [NSHTTPCookieStorage describeCookies];
//    
//    [[HPHttpClient sharedClient] getPath:loginPath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        
//        //NSHTTPURLResponse *response = [operation response];
//        
//        // note
//        // 三处改变
//        // 1 这里
//        // 2 httpclient handle cookie
//        // 3 每次开启和结束是保存cooclie
//        // 4 httpclient shared set cookie header
//        /*
//         //NSArray * all = [NSHTTPCookie cookiesWithResponseHeaderFields:[response allHeaderFields] forURL:[NSURL URLWithString:@"http://www.hi-pda.com"]];
//         //NSLog(@"How many Cookies: %d", all.count);
//         
//         //[[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:all forURL:[NSURL URLWithString:@"http://www.hi-pda.com"] mainDocumentURL:nil];
//         */
//        
//        NSLog(@"login done");
//        [NSHTTPCookieStorage describeCookies];
//        
//        
//        NSString *html = [HPHttpClient GBKresponse2String:responseObject];
//        //NSLog(@"login html : %@",html);
//        
//        BOOL isSuccess = ([html indexOf:@"欢迎您回来"] != -1);
//        NSString *errMsg = [html stringBetweenString:@"<![CDATA[" andString:@"]]"];
//        if (!errMsg) errMsg = html;
//        if (!html) errMsg = @"null response";
//        
//        if (isSuccess) {
//            [[NSNotificationCenter defaultCenter] postNotificationName:kHPUserLoginSuccess object:nil];
//        } else {
//            [[NSNotificationCenter defaultCenter] postNotificationName:kHPUserLoginError object:nil userInfo:@{@"error":errMsg}];
//        }
//        
//        if (block) {
//            block(isSuccess, [NSError errorWithDomain:@".hi-pda.com" code:NSURLErrorUserAuthenticationRequired userInfo:@{NSLocalizedDescriptionKey:errMsg}]);
//        }
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        if (block) {
//            block(NO, error);
//        }
//    }];
//}


- (void)logout {
    
    NSString *username = [NSStandardUserDefaults stringForKey:kHPAccountUserName or:@""];
    [SSKeychain deletePasswordForService:kHPKeychainService account:username];


    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    
    [Setting loadDefaults];
   
    // clear cookies
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *each in cookieStorage.cookies) {
        [cookieStorage deleteCookie:each];
    }
    
    NSLog(@"logout done");
}




//fake
- (void)registerWithBlock:(void (^)(BOOL isLogin, NSError *error))block {
    
    NSString *loginPath = @"forum/register.php";
    [[HPHttpClient sharedClient] getPath:loginPath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (block) {
            block(YES, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(NO, error);
        }
    }];
}

- (void)startCheckWithDelay:(NSTimeInterval)delay {
    NSLog(@"startCheckWithDelay %f", delay);
    if (delay == 0.f) {
        [self _checkMsgAndNoticeStep1];
    } else {
        [self performSelector:@selector(checkMsgAndNotice) withObject:nil afterDelay:delay];
    }
}


- (void)checkMsgAndNotice {
    
    _checkTimer = [NSTimer scheduledTimerWithTimeInterval:60*5 target:self selector: @selector(_checkMsgAndNoticeStep1) userInfo:nil repeats:YES];
    //_checkTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector: @selector(_checkMsgAndNoticeStep1) userInfo:nil repeats:YES];
    [_checkTimer fire];
}

- (void)_checkMsgAndNoticeStep1 {
    
    NSLog(@"_checkMsgAndNoticeStep1...");
    
    NSTimeInterval t = [[NSDate date] timeIntervalSince1970];
    NSString *randomPath = [NSString stringWithFormat:@"forum/pm.php?checknewpm=%d&inajax=1&ajaxtarget=myprompt_check", (int)t];
    //NSLog(@"%@", randomPath);
    
    [[HPHttpClient sharedClient] getPath:randomPath
                              parameters:nil
                                 success:
     ^(AFHTTPRequestOperation *operation, id responseObject) {
        
         
         NSString *html = [HPHttpClient GBKresponse2String:responseObject];
         if ([html indexOf:@"您还未登录"] == -1) {
             
             [self _checkMsgAndNoticeStep2];
             
         } else {
             
             [[HPAccount sharedHPAccount] loginWithBlock:^(BOOL isLogin, NSError *err) {
                 NSLog(@"relogin %@", isLogin?@"success":@"fail");
                 
                 if (isLogin) {
                     
                     [self _checkMsgAndNoticeStep2];
                     
                 } else {
                     
                     if (_noticeRetrieveBlock) {
                         _noticeRetrieveBlock(UIBackgroundFetchResultFailed);
                     }
                 }
             }];
         }
     }
                                 failure:
     ^(AFHTTPRequestOperation *operation, NSError *error)
    {
        NSLog(@"_checkMsgAndNoticeSetp1 error %@", error);
        if (_noticeRetrieveBlock) {
            _noticeRetrieveBlock(UIBackgroundFetchResultFailed);
        }
    }];
}

- (void)_checkMsgAndNoticeStep2 {
    
     NSLog(@"_checkMsgAndNoticeStep2...");
    
    [[HPHttpClient sharedClient] getPathContent:@"forum/memcp.php?action=credits" parameters:nil success:^(AFHTTPRequestOperation *operation, NSString *html) {
        
        //NSLog(@"checkMsgAndNotice %@", html);
        
        NSInteger pm_count = 0, notice_count = 0;
        RxMatch *m1 = [RX(@"私人消息 \\((\\d+)\\)") firstMatchWithDetails:html];
        RxMatch *m2 = [RX(@"帖子消息 \\((\\d+)\\)") firstMatchWithDetails:html];
        
        if (m1) {
            RxMatchGroup *g1 = [m1.groups objectAtIndex:1];
            pm_count = [g1.value integerValue];
            NSLog(@"get new pm_count %d", pm_count);
        }
        if (m2) {
            RxMatchGroup *g2 = [m2.groups objectAtIndex:1];
            notice_count = [g2.value integerValue];
            NSLog(@"get new notice_count %d", notice_count);
        }
        
        [Setting saveInteger:pm_count forKey:HPPMCount];
        [Setting saveInteger:notice_count forKey:HPNoticeCount];
        
        if (pm_count || notice_count) {
            [self addLocalNotification];
            
            if (_noticeRetrieveBlock) {
                _noticeRetrieveBlock(UIBackgroundFetchResultNewData);
            }
        } else {
            if (_noticeRetrieveBlock) {
                _noticeRetrieveBlock(UIBackgroundFetchResultNoData);
            }
        }
        
        [[HPRearViewController sharedRearVC] updateBadgeNumber];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"_checkMsgAndNoticeSetp2 error %@", error);
        if (_noticeRetrieveBlock) {
            _noticeRetrieveBlock(UIBackgroundFetchResultFailed);
        }
    }];
}

- (void)addLocalNotification {
    
    // clear older
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    NSInteger pm_count = [Setting integerForKey:HPPMCount];
    NSInteger notice_count = [Setting integerForKey:HPNoticeCount];
    
    NSString *msg = nil;
    if (pm_count > 0) {
        msg = S(@"您有新的短消息(%d)", pm_count);
    } else if (notice_count > 0){
        msg = S(@"您有新的帖子消息(%d)", notice_count);
    } else {
        //
        return;
    }
    
    // Creates the notification
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = [[NSDate date] dateByAddingTimeInterval:1];
    localNotification.alertBody = msg;
    localNotification.repeatInterval = 0;
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.applicationIconBadgeNumber = [[HPAccount sharedHPAccount] badgeNumber];
    
    // And then sets it
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}


- (NSInteger)badgeNumber {
    NSInteger pm_count = [Setting integerForKey:HPPMCount];
    NSInteger notice_count = [Setting integerForKey:HPNoticeCount];
    return pm_count+notice_count;
}

@end
