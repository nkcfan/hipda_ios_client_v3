//
//  HPReplyViewController.h
//  HiPDA
//
//  Created by wujichao on 14-3-5.
//  Copyright (c) 2014年 wujichao. All rights reserved.
//

#import "HPBaseCompostionViewController.h"
@class HPNewPost;


@interface HPReplyViewController : HPBaseCompostionViewController

- (id)initWithPost:(HPNewPost *)post
        actionType:(ActionType)type
            thread:(HPThread *)thread
              page:(NSInteger)page
          delegate:(id<HPCompositionDoneDelegate>)delegate;

@end
