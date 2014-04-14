//
//  HPMessageDetailViewController.h
//  HiPDA
//
//  Created by wujichao on 13-12-1.
//  Copyright (c) 2013年 wujichao. All rights reserved.
//

#import <JSMessagesViewController/JSMessagesViewController.h>
#import <JSMessagesViewController/JSMessage.h>

@class HPUser;
@interface HPMessageDetailViewController : JSMessagesViewController<JSMessagesViewDataSource, JSMessagesViewDelegate>

@property (strong, nonatomic) HPUser *user;

@end
