//
//  HPThreadCell.h
//  HiPDA
//
//  Created by wujichao on 14-3-17.
//  Copyright (c) 2014年 wujichao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCSwipeTableViewCell.h"

@class HPThread;

@interface HPThreadCell : MCSwipeTableViewCell

@property (nonatomic, strong) HPThread *thread;

- (void)configure:(HPThread *)thread;

+ (CGFloat)heightForCellWithThread:(HPThread *)thread;

- (void)markRead;
- (UIView *)viewWithImageName:(NSString *)imageName;
@end
