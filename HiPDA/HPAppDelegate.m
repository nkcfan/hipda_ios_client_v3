//
//  HPAppDelegate.m
//  HiPDA
//
//  Created by wujichao on 13-11-6.
//  Copyright (c) 2013年 wujichao. All rights reserved.
//

#import "HPAppDelegate.h"
#import "SWRevealViewController.h"
#import "HPThreadViewController.h"
#import <AFNetworking.h>
#import "SDURLCache.h"
#import "HPAccount.h"
#import "HPHttpClient.h"
#import "HPMessage.h"
#import "HPRearViewController.h"
#import "HPSetting.h"
#import "HPThreadViewController.h"
#import "HPDatabase.h"
#import "NSUserDefaults+Convenience.h"
#import "EGOCache.h"

#import "HPMessage.h"
#import "HPNotice.h"

#define AlertPMTag 1357
#define AlertNoticeTag 2468


@interface HPAppDelegate()

@property (nonatomic, strong)HPRearViewController *rearViewController;

@end
@implementation HPAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // clean
    if ([NSStandardUserDefaults objectForKey:@"hp-mark-old-273"] == nil) {
        [self clean];
        [NSStandardUserDefaults saveObject:@"whoiam" forKey:@"hp-mark-old-273"];
        NSLog(@"clean done");
    } else {
        NSLog(@"clean already");
    }
    
    //
    SDURLCache *URLCache = [[SDURLCache alloc] initWithMemoryCapacity:10 * 1024 * 1024 diskCapacity:50 * 1024 * 1024 diskPath:[SDURLCache defaultCachePath]];
    [NSURLCache setSharedURLCache:URLCache];
    
    //
    NSData *cookiesdata = [[NSUserDefaults standardUserDefaults] objectForKey:@"kUserDefaultsCookie"];
    if([cookiesdata length]) {
        NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData:cookiesdata];
        NSHTTPCookie *cookie;
        for (cookie in cookies) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
        }
    }
    
    // NetworkActivityIndicator
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    
    // defualt setting
    //
    [Setting loadSetting];
    
    // reachabilty
    //
    HPHttpClient *client = [HPHttpClient sharedClient];
    [client setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        [NSStandardUserDefaults saveInteger:status forKey:kHPNetworkStatus];
        
        if (status == AFNetworkReachabilityStatusNotReachable) {
            NSLog(@"Not reachable");
        } else {
            if (status == AFNetworkReachabilityStatusReachableViaWiFi) {
                NSLog(@"wifi");
            } else if (status == AFNetworkReachabilityStatusReachableViaWWAN) {
                NSLog(@"2g3g");
            }
        }
    }];
    
    
    //
    [HPDatabase prepareDb];
    
    // dark
    if ([Setting boolForKey:HPSettingNightMode]) {
        [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
    
    //
    _rearViewController = [HPRearViewController sharedRearVC];
    UINavigationController *frontNavigationController = [HPRearViewController threadNavViewController];
    
	SWRevealViewController *revealController = [[SWRevealViewController alloc] initWithRearViewController:_rearViewController frontViewController:frontNavigationController];
    
    revealController.rearViewRevealWidth = 100.f;
    revealController.rearViewRevealOverdraw = 0.f;
    revealController.frontViewShadowRadius = 0.f;

    revealController.delegate = _rearViewController;
    
    self.viewController = revealController;
    self.window.rootViewController = self.viewController;
    self.window.backgroundColor = [UIColor blackColor];
    [self.window makeKeyAndVisible];
    
    [[HPAccount sharedHPAccount] startCheckWithDelay:30.f];
    
    UILocalNotification *localNotification =
    [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotification) {
        [self FinishLaunchingWithReciveLocalNotification:localNotification];
    }

    
    // background fetch
    BOOL enableBgFetch = IOS7_OR_LATER &&
    ([Setting boolForKey:HPSettingBgFetchThread] || [Setting boolForKey:HPSettingBgFetchNotice]);
    if (enableBgFetch) {
        [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    }
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    //
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL: [NSURL URLWithString:@"www.hi-pda.com"]];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:cookies];
    //NSLog(@"save cookies %@", data);
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"kUserDefaultsCookie"];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    // reset applicationIconBadgeNumber
    application.applicationIconBadgeNumber  = [[HPAccount sharedHPAccount] badgeNumber];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    [self showAlert];
}

- (void)showAlert {
    
    //clear
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    NSInteger pm_count = [Setting integerForKey:HPPMCount];
    NSInteger notice_count = [Setting integerForKey:HPNoticeCount];
    
    NSString *msg = nil;
    int tag = -1;
    if (pm_count > 0) {
        msg = S(@"您有新的短消息(%d)", pm_count);
        tag = AlertPMTag;
    } else if (notice_count > 0){
        msg = S(@"您有新的帖子消息(%d)", notice_count);
        tag = AlertNoticeTag;
    } else {
        
        //
        return;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提醒"
                                                    message:msg
                                                   delegate:self
                                          cancelButtonTitle:@"忽略"
                                          otherButtonTitles:@"查看", nil];
    alert.tag = tag;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

    if (buttonIndex == 0) {
        
        if (alertView.tag == AlertPMTag) {
            
            [HPMessage ignoreMessage];
            
        } else if (alertView.tag == AlertNoticeTag) {
            
            [HPNotice ignoreNotice];
            
        } else {
            ;
        }

    } else if (buttonIndex == 1) {
        if (_rearViewController) {
            
            if (alertView.tag == AlertPMTag) {
                
                [_rearViewController switchToMessageVC];
                
            } else if (alertView.tag == AlertNoticeTag) {
                
                [_rearViewController switchToNoticeVC];
                
            } else {
                ;
            }
        } else {
            ;
        }
        
    } else {
        ;
    }
}

- (void)FinishLaunchingWithReciveLocalNotification:(UILocalNotification *)localNotification {
    
    NSLog(@"Notification Body: %@",localNotification.alertBody);
    NSLog(@"%@", localNotification.userInfo);
    
    [self showAlert];
}


-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    /*
    UINavigationController *navigationController = (UINavigationController*)self.window.rootViewController;
    
    id fetchViewController = navigationController.topViewController;
    if ([fetchViewController respondsToSelector:@selector(fetchDataResult:)]) {
        [fetchViewController fetchDataResult:^(NSError *error, NSArray *results){
            if (!error) {
                if (results.count != 0) {
                    //Update UI with results.
                    //Tell system all done.
                    completionHandler(UIBackgroundFetchResultNewData);
                } else {
                    completionHandler(UIBackgroundFetchResultNoData);
                }
            } else {
                completionHandler(UIBackgroundFetchResultFailed);
            }
        }];
    } else {
        completionHandler(UIBackgroundFetchResultFailed);
    }
    */
    __block int count = 0;
    
    UINavigationController *navigationController = (UINavigationController*)self.viewController.frontViewController;
    id topVC = navigationController.topViewController;
    //NSLog(@"self.viewController.frontViewPosition %d\nFrontViewPositionLeft %d", self.viewController.frontViewPosition, FrontViewPositionLeft);
    
    if ([Setting boolForKey:HPSettingBgFetchThread] &&
        [topVC isKindOfClass:[HPThreadViewController class]] &&
        self.viewController.frontViewPosition == FrontViewPositionLeft) {
        
        HPThreadViewController *tvc = (HPThreadViewController *)topVC;
        [tvc setBgFetchBlock:^(UIBackgroundFetchResult result) {
            count++;
            NSLog(@"count %d bgFetchBlock result %d",count, result);
            if (count >= 2) {
                NSLog(@"complated!");
                completionHandler(result);
            }
        }];
        [HPRearViewController threadVCRefresh];
        
    } else {
        count++;
        if (count >= 2) {
            NSLog(@"pass !");
            completionHandler(UIBackgroundFetchResultNoData);
        }
    }
    
    if ([Setting boolForKey:HPSettingBgFetchNotice]) {
        [[HPAccount sharedHPAccount] setNoticeRetrieveBlock:^(UIBackgroundFetchResult result) {
            count++;
            NSLog(@"count %d noticeRetrieveBlock result %d",count, result);
            if (count >= 2) {
                NSLog(@"complated!");
                completionHandler(result);
            }
        }];
        [[HPAccount sharedHPAccount] startCheckWithDelay:0.f];
        
    } else {
        count++;
        if (count >= 2) {
            NSLog(@"pass !");
            completionHandler(UIBackgroundFetchResultNoData);
        }
    }

    /*
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = [[NSDate date] dateByAddingTimeInterval:.5];
    localNotification.alertBody = @"new check";
    localNotification.repeatInterval = 0;
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
     */
}


- (void)clean {
    // NSUserDefaults
    //
    
    // clear cookies
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *each in cookieStorage.cookies) {
        [cookieStorage deleteCookie:each];
    }

    // clear egocache
    [[EGOCache globalCache] clearCache];
}



@end
