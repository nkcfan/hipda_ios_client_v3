//
//  HPBaseTableViewController.h
//  HiPDA
//
//  Created by wujichao on 14-3-8.
//  Copyright (c) 2014年 wujichao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPViewController.h"

@interface HPBaseTableViewController : HPTableViewController

- (void)addGuesture;
- (void)removeGuesture;
- (void)addRefreshControl;
- (UIBarButtonItem *)addPageControlBtn;
- (UIBarButtonItem *)addRevealActionBI;
- (UIBarButtonItem *)addCloseBI;

- (void)refresh:(id)sender;
- (void)showRefreshControl;

@end
