//
//  HPBackgroundViewController.h
//  HiPDA
//
//  Created by wujichao on 13-11-15.
//  Copyright (c) 2013年 wujichao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPBaseTableViewController.h"

@interface HPBackgroundViewController : HPBaseTableViewController


@property(nonatomic, strong)NSMutableArray *cachedThreads;

+ (HPBackgroundViewController *)sharedBgView;

@end
