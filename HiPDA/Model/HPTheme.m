//
//  HPTheme.m
//  HiPDA
//
//  Created by wujichao on 14-3-13.
//  Copyright (c) 2014年 wujichao. All rights reserved.
//

#import "HPTheme.h"
#import "HPSetting.h"

@implementation HPTheme

+ (HPTheme*)sharedTheme {
    static dispatch_once_t once;
    static HPTheme *sharedTheme;
    dispatch_once(&once, ^ {
        sharedTheme = [[self alloc] init];
    });
    return sharedTheme;
}

+ (UIColor *)backgroundColor {
    if (![Setting boolForKey:HPSettingNightMode]) {
        
        static UIColor *lightBackgroundColor = nil;
        if (!lightBackgroundColor) lightBackgroundColor = rgb(241.f, 241.f, 239.f);
        return lightBackgroundColor;
        
    } else {
        
        static UIColor *darkBackgroundColor = nil;
        if (!darkBackgroundColor) darkBackgroundColor = rgb(10.f, 11.f, 14.f);
        return darkBackgroundColor;
    }
}

+ (UIColor *)textColor {
    if (![Setting boolForKey:HPSettingNightMode]) {
        
        static UIColor *lightTextColor = nil;
        if (!lightTextColor) lightTextColor = [UIColor blackColor];
            return lightTextColor;
        
    } else {
        
        static UIColor *darkTextColor = nil;
        if (!darkTextColor) darkTextColor = rgb(156.f, 156.f, 156.f);
        return darkTextColor;
    }
}

+ (UIColor *)blackOrWhiteColor {
    if (![Setting boolForKey:HPSettingNightMode]) {
        
        static UIColor *lightTextColor = nil;
        if (!lightTextColor) lightTextColor = [UIColor blackColor];
        return lightTextColor;
        
    } else {
        
        static UIColor *darkTextColor = nil;
        if (!darkTextColor) darkTextColor = [UIColor whiteColor];
        return darkTextColor;
    }
}


+ (UIColor *)readColor {
    if (![Setting boolForKey:HPSettingNightMode]) {
        
        static UIColor *lightReadColor = nil;
        if (!lightReadColor) lightReadColor = rgb(100.f, 100.f, 100.f);
        return lightReadColor;
        
    } else {
        
        static UIColor *darkReadColor = nil;
        if (!darkReadColor) darkReadColor = rgb(100.f, 100.f, 100.f);
        return darkReadColor;
    }
}


+ (UIColor *)oddCellColor {
    if (![Setting boolForKey:HPSettingNightMode]) {
        
        static UIColor *lightOddCellColor = nil;
        if (!lightOddCellColor) lightOddCellColor = rgb(243.f, 243.f, 243.f);
        return lightOddCellColor;
        
    } else {
        
        static UIColor *darkOddCellColor = nil;
        if (!darkOddCellColor) darkOddCellColor = rgb(10.f, 11.f, 14.f);
        return darkOddCellColor;
    }
}

+ (UIColor *)evenCellColor {
    if (![Setting boolForKey:HPSettingNightMode]) {
        
        static UIColor *lightEvenCellColor = nil;
        if (!lightEvenCellColor) lightEvenCellColor = [UIColor whiteColor];
        return lightEvenCellColor;
        
    } else {
        
        static UIColor *darkEvenCellColor = nil;
        if (!darkEvenCellColor) darkEvenCellColor = rgb(10.f, 11.f, 14.f);
        return darkEvenCellColor;
    }
}


+ (UIActivityIndicatorViewStyle)indicatorViewStyle {
    
    if (![Setting boolForKey:HPSettingNightMode]) {
        
        static UIActivityIndicatorViewStyle lightStyle = -1;
        if (lightStyle < 0) lightStyle = UIActivityIndicatorViewStyleGray;
        return lightStyle;
        
    } else {
        
        static UIActivityIndicatorViewStyle darkStyle = -1;
        if (darkStyle < 0) darkStyle = UIActivityIndicatorViewStyleWhite;
        return darkStyle;
    }
}

+ (UIKeyboardAppearance)keyboardAppearance {
    
    if (![Setting boolForKey:HPSettingNightMode]) {
        
        static UIKeyboardAppearance lightStyle = -1;
        if (lightStyle < 0) lightStyle = UIKeyboardAppearanceDefault;
        return lightStyle;
        
    } else {
        
        static UIKeyboardAppearance darkStyle = -1;
        if (darkStyle < 0) darkStyle = (!IOS7_OR_LATER ? UIKeyboardAppearanceAlert : UIKeyboardAppearanceDark);
        return darkStyle;
    }
}

+ (UIColor *)threadJumpColor {
    static UIColor *threadJumpColor = nil;
    if (!threadJumpColor) threadJumpColor = rgb(85.f, 213.f, 80.f);
    return threadJumpColor;
}

+ (UIColor *)threadPreloadColor {
    static UIColor *threadPreloadColor = nil;
    if (!threadPreloadColor) threadPreloadColor = rgb(206.f, 149.f, 98.f);
    return threadPreloadColor;
}



@end
