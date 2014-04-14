//
//  HPTheme.h
//  HiPDA
//
//  Created by wujichao on 14-3-13.
//  Copyright (c) 2014年 wujichao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HPTheme : NSObject


+ (UIColor *)backgroundColor;
+ (UIColor *)textColor;
+ (UIColor *)blackOrWhiteColor;

+ (UIColor *)readColor;

+ (UIColor *)oddCellColor;
+ (UIColor *)evenCellColor;

+ (UIColor *)threadJumpColor;
+ (UIColor *)threadPreloadColor;

+ (UIActivityIndicatorViewStyle)indicatorViewStyle;
+ (UIKeyboardAppearance)keyboardAppearance;




@end
