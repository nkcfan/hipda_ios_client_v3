//
//  HPCommon.m
//  HiPDA
//
//  Created by wujichao on 13-11-12.
//  Copyright (c) 2013年 wujichao. All rights reserved.
//

#import "HPCommon.h"
#import "HPSetting.h"
//#import <SystemConfiguration/CaptiveNetwork.h>

@implementation HPCommon


+ (NSTimeInterval)timeIntervalSince1970WithString:(NSString *)string {
    NSDateFormatter *mmddccyy = [[NSDateFormatter alloc] init];
    mmddccyy.timeStyle = NSDateFormatterNoStyle;
    mmddccyy.dateFormat = @"yyyy/MM/dd";
    
    NSDate *d = [mmddccyy dateFromString:string];
    //NSLog(@"%f", [d timeIntervalSince1970]);
    return [d timeIntervalSince1970];
}

+ (UINavigationController *)NVCWithRootVC:(UIViewController *)rootVC {
    UINavigationController *NVC = [[UINavigationController alloc] initWithRootViewController:rootVC];
    if (![Setting boolForKey:HPSettingNightMode]) {
        NVC.navigationBar.barStyle = UIBarStyleDefault;
    } else {
        NVC.navigationBar.barStyle = UIBarStyleBlack;
    }
    return NVC;
}


+ (id)fetchSSIDInfo
{
    /*
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    NSLog(@"Supported interfaces: %@", ifs);
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        NSLog(@"%@ => %@", ifnam, info);
        if (info && [info count]) { break; }
    }
    return info;
    NSLog(@"%@", info);
   */
    return nil;
    /*
    Supported interfaces: (
 en0
 )
 2014-03-30 19:24:44.303 HiPDA[1867:907] HPCommon.m:47 > {
 BSSID = "c2:75:d5:80:5a:b5";
 SSID = "SUDA_WLAN";
 SSIDDATA = <53554441 5f574c41 4e>;
 }
     */
}

@end
