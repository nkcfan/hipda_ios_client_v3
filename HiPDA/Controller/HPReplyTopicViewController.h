//
//  HPReplyTopicViewController.h
//  HiPDA
//
//  Created by wujichao on 14-3-5.
//  Copyright (c) 2014年 wujichao. All rights reserved.
//

#import "HPBaseCompostionViewController.h"

@class HPThread;
@interface HPReplyTopicViewController : HPBaseCompostionViewController

@property (nonatomic, strong)HPThread *thread;

- (id)initWithThread:(HPThread *)thread delegate:(id<HPCompositionDoneDelegate>)delegate;

@end
