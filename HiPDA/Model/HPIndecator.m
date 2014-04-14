//
//  HPIndecator.m
//  HiPDA
//
//  Created by wujichao on 14-3-26.
//  Copyright (c) 2014年 wujichao. All rights reserved.
//

#import "HPIndecator.h"
#import "HPTheme.h"

#define HPIndecatorTAG 19471947

@interface HPIndecator()

@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@property (nonatomic, assign) NSInteger activityCount;

@end


@implementation HPIndecator

- (id)init {
    if (self = [super init]) {
        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _indicator.tag = HPIndecatorTAG;
        
        CGRect frame = [UIScreen mainScreen].bounds;
        _indicator.frame = CGRectMake(frame.size.width / 2 - 20.0f, frame.size.height / 2 - 20.0f, 40.0f, 40.0f);
        [[UIApplication sharedApplication].keyWindow addSubview:_indicator];
        //NSLog(@"%@", _indicator);
        
        _activityCount = 0;
        return self;
    }
    return nil;
}

- (void)indicatorStart {
    [_indicator setActivityIndicatorViewStyle:[HPTheme indicatorViewStyle]];
    [_indicator startAnimating];
}

- (void)indicatorStop {
    [_indicator stopAnimating];
}

+ (HPIndecator *)sharedIndecator {
    static HPIndecator *sharedIndecator = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedIndecator = [[HPIndecator alloc] init];
    });
    return sharedIndecator;
}

+ (void)show {
    [self sharedIndecator].activityCount = 1;
    [[self sharedIndecator] indicatorStart];
}

+ (void)dismiss {
    [self sharedIndecator].activityCount = 0;
    [[self sharedIndecator] indicatorStop];
}

+ (void)push {
    [self sharedIndecator].activityCount++;
    [[self sharedIndecator] indicatorStart];
}

+ (void)pop {
    [self sharedIndecator].activityCount--;
    if ([self sharedIndecator].activityCount <= 0) {
        [[self sharedIndecator] indicatorStop];
    }
}


@end
