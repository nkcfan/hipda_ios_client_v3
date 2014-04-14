//
//  HPThreadViewController.h
//  HiPDA
//
//  Created by wujichao on 13-11-11.
//  Copyright (c) 2013年 wujichao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPViewController.h"

typedef void (^BgFetchBlock)(UIBackgroundFetchResult result);

@interface HPThreadViewController : HPTableViewController



- (id)initDefaultForum:(NSInteger)fid title:(NSString *)title;
- (void)refresh:(in)sender;
- (void)loadForum:(NSInteger)fid title:(NSString *)title;
- (void)revealToggle:(id)sender;

@property (nonatomic, copy) BgFetchBlock bgFetchBlock;

@end
