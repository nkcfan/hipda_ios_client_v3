//
//  HPRearCell.h
//  HiPDA
//
//  Created by wujichao on 14-3-25.
//  Copyright (c) 2014年 wujichao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HPRearCell : UITableViewCell

- (void)configure:(NSString *)title;

- (void)showNumber:(NSInteger)num;
- (void)hideNumber;

@end
