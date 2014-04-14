//
//  HPSetting.m
//  HiPDA
//
//  Created by wujichao on 14-3-13.
//  Copyright (c) 2014年 wujichao. All rights reserved.
//

#import "HPSetting.h"
#import "HPForum.h"

#import "NSString+Additions.h"
#import "NSUserDefaults+Convenience.h"

#define DEBUG_SETTING 0

@interface HPSetting()

@property (nonatomic, strong) NSMutableDictionary *globalSettings;

@end



@implementation HPSetting


+ (HPSetting*)sharedSetting {
    
    static dispatch_once_t once;
    static HPSetting *sharedSetting;
    dispatch_once(&once, ^ {
        sharedSetting = [[self alloc] init];
    });
    return sharedSetting;
}



- (void)loadSetting {
    
    _globalSettings = [NSStandardUserDefaults objectForKey:HPSettingDic];
    
    ///////////
    // app update setting
    if (_globalSettings) {
        
        NSMutableSet *keysInA = [NSMutableSet setWithArray:[[HPSetting defualts] allKeys]];
        NSSet *keysInB = [NSSet setWithArray:[_globalSettings allKeys]];
        [keysInA minusSet:keysInB];
    
        NSLog(@"keys in A that are not in B: %@", keysInA);
        
        for (NSString *key in keysInA) {
            id value = [[HPSetting defualts] objectForKey:key];
            [_globalSettings setObject:value forKey:key];
        }
    }
    //////////
    
    if (!_globalSettings) {
        [self loadDefaults];
    }
    if (DEBUG_SETTING) NSLog(@"load  _globalSettings %@", _globalSettings);
}

- (void)loadDefaults {
    
    NSDictionary *defaults = [HPSetting defualts];
    
    // todo 加key 升级 后检测
    
    _globalSettings = [NSMutableDictionary dictionaryWithDictionary:defaults];
    if (DEBUG_SETTING) NSLog(@"load  loadDefaults %@", _globalSettings);
    [self save];
}

+ (NSDictionary *)defualts {
    NSDictionary *defaults = @{HPSettingTail:@"iOS fly ~",
                               HPSettingFavForums:@[@2, @6, @59],
                               HPSettingFavForumsTitle:@[@"Discovery", @"Buy & Sell", @"E-INK"],
                               HPSettingShowAvatar:@YES,
                               HPSettingOrderByDate:@NO,
                               HPSettingNightMode:@NO,
                               HPSettingFontSize:@16.f,
                               HPSettingFontSizeAdjust:@100,
                               HPSettingLineHeight:@1.5,
                               HPSettingLineHeightAdjust:@150,
                               HPSettingTextFont:@"STHeitiSC-Light",
                               HPSettingImageWifi:@0,
                               HPSettingImageWWAN:@0,
                               HPPMCount:@0,
                               HPNoticeCount:@0,
                               HPSettingBGLastMinite:@20.f,
                               HPSettingBgFetchNotice:@YES,
                               HPSettingBgFetchThread:@NO
                               };
    return defaults;
}

- (void)save {
    [NSStandardUserDefaults saveObject:_globalSettings forKey:HPSettingDic];
    if (DEBUG_SETTING) NSLog(@"save  _globalSettings %@", _globalSettings);
}

#pragma mark -

- (id)objectForKey:(NSString *)key {
    if (DEBUG_SETTING) NSLog(@"objectForKey %@: %@", key, [_globalSettings objectForKey:key]);
    if (!key) {
        NSLog(@"ERROR: objectForKey %@", key);
        return nil;
    }
    return [_globalSettings objectForKey:key];
}

- (BOOL)boolForKey:(NSString *)key {
    return [[self objectForKey:key] boolValue];
}

- (NSInteger)integerForKey:(NSString *)key {
    return [[self objectForKey:key] integerValue];
}

- (CGFloat)floatForKey:(NSString *)key {
    return [[self objectForKey:key] floatValue];
}

#pragma mark - 

- (void)saveObject:(id)value forKey:(NSString *)key {
    if (DEBUG_SETTING) NSLog(@"saveObject %@: %@", key, value);
    
    if (!key || !value) {
        NSLog(@"ERROR: saveObject %@: %@", key, value);
        return;
    }
    [_globalSettings setObject:value forKey:key];
    [self save];
}

- (void)saveInteger:(NSInteger)value forKey:(NSString *)key {
    [self saveObject:[NSNumber numberWithInteger:value] forKey:key];
}

- (void)saveBool:(BOOL)value forKey:(NSString *)key {
    [self saveObject:[NSNumber numberWithBool:value] forKey:key];
}

- (void)saveFloat:(float)value forKey:(NSString *)key {
    [self saveObject:[NSNumber numberWithFloat:value] forKey:key];
}


#pragma mark - post tail
// return @"" or @"[size=1]%@[/size]"
- (NSString *)postTail {
    NSString *tail = [self objectForKey:HPSettingTail];
    if (!tail || [tail isEqualToString:@""]) {
        return @"";
    } else {
        return [NSString stringWithFormat:@"[size=1]%@[/size]", tail];;
    }
}

- (void)setPostTail:(NSString *)postTail {
    if (!postTail) postTail = @"";
    [self saveObject:postTail forKey:HPSettingTail];
}

- (NSString *)isPostTailAllow:(NSString *)postTail {
    //
    if ([postTail indexOf:@"["] != -1 ||
        [postTail indexOf:@"]"] != -1) {
        return @"不允许使用标签";
    }
    //
    NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSUInteger length = [postTail lengthOfBytesUsingEncoding:encoding];
    if (length > 16) {
        // 改成八字
        return @"中文七字以内, 英文十四字以内";
    }
    return nil;
}


#pragma mark - 
/*
- (NSArray *)defaultForums {
    
    HPForum *f1 = [[HPForum alloc] initWithAttributes:@{@"title":@"Discovery", @"fid":@2}];
    HPForum *f2 = [[HPForum alloc] initWithAttributes:@{@"title":@"Buy & Sell", @"fid":@6}];
    HPForum *f3 = [[HPForum alloc] initWithAttributes:@{@"title":@"PalmOS", @"fid":@14}];
    
    return @[f1,f2,f3];
}
*/


@end
