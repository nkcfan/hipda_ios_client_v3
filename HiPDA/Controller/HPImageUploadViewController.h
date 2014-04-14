//
//  HPImageUploadViewController.h
//  HiPDA
//
//  Created by wujichao on 14-3-28.
//  Copyright (c) 2014年 wujichao. All rights reserved.
//

#import "HPViewController.h"

@protocol HPImageUploadDelegate <NSObject>
@required
- (void)completeWithAttachString:(NSString *)string error:(NSError *)error;
@end

@interface HPImageUploadViewController : HPViewController

@property (nonatomic, strong) id <HPImageUploadDelegate> delegate;

@end
