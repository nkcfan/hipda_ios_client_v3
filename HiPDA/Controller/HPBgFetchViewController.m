//
//  HPBgFetchViewController.m
//  HiPDA
//
//  Created by wujichao on 14-4-12.
//  Copyright (c) 2014年 wujichao. All rights reserved.
//

#import "HPBgFetchViewController.h"
#import "HPSetting.h"
#import "MultilineTextItem.h"


@interface HPBgFetchViewController ()

@property (strong, nonatomic) RETableViewManager *manager;
@property (strong, nonatomic) RETableViewSection *forumSection;

@end

@implementation HPBgFetchViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"后台应用程序刷新";
    
    
    _manager = [[RETableViewManager alloc] initWithTableView:self.tableView delegate:self];
    
    RETableViewSection *section = [RETableViewSection sectionWithHeaderTitle:nil];
    [_manager addSection:section];
    
    
    BOOL enableBgFetchNotice = [Setting boolForKey:HPSettingBgFetchNotice];
    REBoolItem *enableBgFetchNoticeItem = [REBoolItem itemWithTitle:@"新消息" value:enableBgFetchNotice switchValueChangeHandler:^(REBoolItem *item) {
        
        NSLog(@"enableBgFetchNotice Value: %@", item.value ? @"YES" : @"NO");
        [Setting saveBool:item.value forKey:HPSettingBgFetchNotice];
        
    }];
    
    BOOL enableBgFetchThread = [Setting boolForKey:HPSettingBgFetchThread];
    REBoolItem *enableBgFetchThreadItem = [REBoolItem itemWithTitle:@"帖子列表" value:enableBgFetchThread switchValueChangeHandler:^(REBoolItem *item) {
        
        NSLog(@"enableBgFetchThread Value: %@", item.value ? @"YES" : @"NO");
        [Setting saveBool:item.value forKey:HPSettingBgFetchThread];
        
    }];
    
    self.manager[@"MultilineTextItem"] = @"MultilineTextCell";
    [section addItem:enableBgFetchNoticeItem];
    [section addItem:enableBgFetchThreadItem];
    [section addItem:[MultilineTextItem itemWithTitle:
        @"你的 iOS 设备可以根据你使用 HiPDA 的频率和时间智能安排来更新未读提醒并提示您。\n\n"
        @"开启帖子列表选项后, 你的 iOS 设备在你打开 HiPDA 之前, 通常会提前为您刷新好帖子列表。\n\n"
        @"注意: \n"
        @"1. 谨慎开启, 会额外消耗电量和流量, 刷新的次数和您每天打开 HiPDA 次数大抵相当, iOS 系统会智能安排刷新的频率, 尽可能的减少电量的消耗。\n"
        @"2. 你需要在系统 设置 > 通用 > 应用程序后台刷新中允许 HiPDA 才可以使本页的设置生效。"
    ]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
