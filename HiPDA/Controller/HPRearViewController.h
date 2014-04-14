//
//  HPRearViewController.h
//  HiPDA
//
//  Created by wujichao on 14-3-18.
//  Copyright (c) 2014年 wujichao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWRevealViewController.h"
@class HPThreadViewController;

@interface HPRearViewController : UIViewController<SWRevealViewControllerDelegate>

+ (HPRearViewController*)sharedRearVC;
- (id)vcAtIndex:(NSUInteger)index;
- (void)forumDidChanged;

//+ (HPThreadViewController *)threadViewController;
+ (UINavigationController *)threadNavViewController;
+ (void)threadVCRefresh;

- (void)themeDidChanged;

- (void)switchToMessageVC;
- (void)switchToNoticeVC;

- (void)updateBadgeNumber;
- (UIBarButtonItem *)sharedRevealActionBI;

@end
