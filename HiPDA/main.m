//
//  main.m
//  HiPDA
//
//  Created by wujichao on 13-11-6.
//  Copyright (c) 2013年 wujichao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UI7Kit/UI7Kit.h>
#import "HPAppDelegate.h"

int main(int argc, char * argv[])
{
    @autoreleasepool {
        [UI7Kit excludeClassNamesFromAutopatch:@[@"UI7TableViewCell"]];
        [UI7Kit excludeClassNamesFromAutopatch:@[@"UI7PickerView"]];
        [UI7Kit patchIfNeeded];
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([HPAppDelegate class]));
    }
}
