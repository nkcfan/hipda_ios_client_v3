//
//  HPSettingViewController.m
//  HiPDA
//
//  Created by wujichao on 13-11-20.
//  Copyright (c) 2013年 wujichao. All rights reserved.
//

#import "HPSettingViewController.h"
#import "HPReadViewController.h"
#import "HPSetForumsViewController.h"
#import "HPRearViewController.h"
#import "HPBgFetchViewController.h"

#import "MultilineTextItem.h"
#import "HPSetting.h"
#import "HPAccount.h"
#import "HPTheme.h"

#import "SDURLCache.h"

#import "NSUserDefaults+Convenience.h"
#import "RETableViewManager.h"
#import "RETableViewOptionsController.h"
#import <SVProgressHUD.h>
#import "SWRevealViewController.h"
#import "UIAlertView+Blocks.h"
#import "DZWebBrowser.h"
#import <SDWebImage/SDImageCache.h>

// mail
#import <MessageUI/MFMailComposeViewController.h>
#import "sys/utsname.h"

#define VERSION ([[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"])
#define BUILD ([[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"])

@interface HPSettingViewController () <UIWebViewDelegate>

@property (strong, nonatomic) RETableViewManager *manager;
@property (strong, nonatomic) RETableViewSection *preferenceSection;
@property (strong, nonatomic) RETableViewSection *imageSection;
@property (strong, nonatomic) RETableViewSection *aboutSection;

@end

@implementation HPSettingViewController

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

    // 在 RETableViewManager  修改字体 ui7kit 没patch tablecell
    
    self.title = @"设置";
    
    
    UIBarButtonItem *closeButtonItem = [
                                         [UIBarButtonItem alloc] initWithTitle:@"完成"
                                         style:UIBarButtonItemStylePlain
                                         target:self action:@selector(close:)];
     self.navigationItem.leftBarButtonItem = closeButtonItem;
    
    // clear btn
    UIBarButtonItem *clearButtonItem = [
                                        [UIBarButtonItem alloc] initWithTitle:@"重置"
                                        style:UIBarButtonItemStylePlain
                                        target:self
                                        action:@selector(reset:)];
    self.navigationItem.rightBarButtonItem = clearButtonItem;
    
    if (IOS7_OR_LATER) {
        //[self.tableView setBackgroundColor:[HPTheme backgroundColor]];
    }
  
     
    // Create manager
    //
    self.manager = [[RETableViewManager alloc] initWithTableView:self.tableView delegate:self];
    
    
    
    self.preferenceSection = [self addPreferenceControls];
    self.imageSection = [self addImageControls];
    
    if (IOS7_OR_LATER) {
        RETableViewSection *bgFetchSection = [RETableViewSection sectionWithHeaderTitle:@" " footerTitle:nil];
        RETableViewItem *bgFetchItem = [RETableViewItem itemWithTitle:@"后台应用程序刷新" accessoryType:UITableViewCellAccessoryDisclosureIndicator selectionHandler:^(RETableViewItem *item) {
            
            HPBgFetchViewController *vc = [[HPBgFetchViewController alloc] initWithStyle:UITableViewStylePlain];
            [self.navigationController pushViewController:vc animated:YES];
            
            [item deselectRowAnimated:YES];
        }];
        [bgFetchSection addItem:bgFetchItem];
        [self.manager addSection:bgFetchSection];
    }
    
    self.aboutSection = [self addAboutControls];
    
    RETableViewSection *logoutSection = [RETableViewSection sectionWithHeaderTitle:@"  " footerTitle:@" "];
    RETableViewItem *logoutItem = [RETableViewItem itemWithTitle:@"登出" accessoryType:UITableViewCellAccessoryNone selectionHandler:^(RETableViewItem *item) {
        
        [UIAlertView showConfirmationDialogWithTitle:@"登出"
                                             message:@"您确定要登出当前账号吗?"
                                             handler:^(UIAlertView *alertView, NSInteger buttonIndex)
         {
             
             if (buttonIndex == [alertView cancelButtonIndex]) {
                 ;
             } else {
                 
                 [[HPAccount sharedHPAccount] logout];
                 [self close:nil];
             }
         }];
        
        [item deselectRowAnimated:YES];
    }];
    logoutItem.textAlignment = NSTextAlignmentCenter;
    [logoutSection addItem:logoutItem];
    [self.manager addSection:logoutSection];
    
    RETableViewSection *versionSection = [RETableViewSection section];
    RETableViewItem *versionItem = [RETableViewItem itemWithTitle:[NSString stringWithFormat:@"版本 %@", VERSION] accessoryType:UITableViewCellAccessoryNone selectionHandler:^(RETableViewItem *item) {
        
        [item deselectRowAnimated:YES];
    }];
    versionItem.textAlignment = NSTextAlignmentCenter;
    [versionSection addItem:versionItem];
    
    [self.manager addSection:versionSection];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (RETableViewSection *)addPreferenceControls {
    
    RETableViewSection *section = [RETableViewSection sectionWithHeaderTitle:nil footerTitle:@"  "];
    //RETableViewSection *section = [RETableViewSection section];
    
    //
    BOOL isNightMode = [Setting boolForKey:HPSettingNightMode];
    REBoolItem *isNightModeItem = [REBoolItem itemWithTitle:@"夜间模式" value:isNightMode switchValueChangeHandler:^(REBoolItem *item) {
        
        NSLog(@"isNightMode Value: %@", item.value ? @"YES" : @"NO");
        [Setting saveBool:item.value forKey:HPSettingNightMode];

        if (item.value) {
            ;
        } else {
            ;
        }
        
        [[HPRearViewController sharedRearVC] themeDidChanged];
    }];
    
    // isShowAvatar
    //
    BOOL isShowAvatar = [Setting boolForKey:HPSettingShowAvatar];
    REBoolItem *isShowAvatarItem = [REBoolItem itemWithTitle:@"显示头像" value:isShowAvatar switchValueChangeHandler:^(REBoolItem *item) {
        
        NSLog(@"isShowAvatar Value: %@", item.value ? @"YES" : @"NO");
        [Setting saveBool:item.value forKey:HPSettingShowAvatar];
        
        if (item.value) {
            ;
        } else {
            ;
        }
        
        
        [[HPRearViewController sharedRearVC] themeDidChanged];
    }];
    
    
    // isOrderByDateline
    //
    BOOL isOrderByDateline = [Setting boolForKey:HPSettingOrderByDate];
    REBoolItem *isOrderByDatelineItem = [REBoolItem itemWithTitle:@"按发帖时间排序" value:isOrderByDateline switchValueChangeHandler:^(REBoolItem *item) {
        NSLog(@"isOrderByDateline Value: %@", item.value ? @"YES" : @"NO");
        [Setting saveBool:item.value forKey:HPSettingOrderByDate];
    }];
    
    //
    //
    NSString *postTail = [Setting objectForKey:HPSettingTail];
    RETextItem *postTailText = [RETextItem itemWithTitle:@"小尾巴" value:postTail placeholder:@"留空"];
    
    postTailText.returnKeyType = UIReturnKeyDone;
    postTailText.onEndEditing = ^(RETextItem *item) {
        NSLog(@"setPostTail _%@_", item.value);
        
        NSString *msg = [Setting isPostTailAllow:item.value];
        if (!msg) {
            [Setting setPostTail:item.value];
            
            [SVProgressHUD showSuccessWithStatus:@"已保存"];
        } else {
            [SVProgressHUD showErrorWithStatus:msg];
        }
    };
    
    //
    //
    RETableViewItem *setForumItem = [RETableViewItem itemWithTitle:@"板块设定" accessoryType:UITableViewCellAccessoryDisclosureIndicator selectionHandler:^(RETableViewItem *item) {
        
        HPSetForumsViewController *setForumsViewController = [[HPSetForumsViewController alloc] initWithStyle:UITableViewStylePlain];
        [self.navigationController pushViewController:setForumsViewController animated:YES];
        [item deselectRowAnimated:YES];
    }];
    
    
    [section addItem:isNightModeItem];
    [section addItem:isShowAvatarItem];
    [section addItem:isOrderByDatelineItem];
    [section addItem:postTailText];
    [section addItem:setForumItem];
    
    [_manager addSection:section];
    return section;
}


- (RETableViewSection *) addImageControls {
    
    __typeof (&*self) __weak weakSelf = self;
    
    //RETableViewSection *section = [RETableViewSection sectionWithHeaderTitle:@"Image load"];
    RETableViewSection *section = [RETableViewSection sectionWithHeaderTitle:nil];
    
    HPImageDisplayStyle styleViaWWAN = [Setting integerForKey:HPSettingImageWWAN];
    HPImageDisplayStyle styleViaWifi = [Setting integerForKey:HPSettingImageWifi];
    
    NSArray *options = @[@"显示全部图片", @"仅显示一张图片", @"不显示图片"];
    
    RERadioItem *imageStyleWWANItem = [RERadioItem itemWithTitle:@"移动网络" value:[options objectAtIndex:styleViaWWAN] selectionHandler:^(RERadioItem *item) {
        
        [item deselectRowAnimated:YES];
        
        // Present options controller
        //
        RETableViewOptionsController *optionsController = [[RETableViewOptionsController alloc] initWithItem:item options:options multipleChoice:NO completionHandler:^{
            [weakSelf.navigationController popViewControllerAnimated:YES];
            
            [item reloadRowWithAnimation:UITableViewRowAnimationNone];
            
            HPImageDisplayStyle styleViaWWAN
                = [options indexOfObjectIdenticalTo:item.value];
            [Setting saveInteger:styleViaWWAN forKey:HPSettingImageWWAN];
        }];
        
        optionsController.delegate = weakSelf;
        optionsController.style = section.style;
        if (weakSelf.tableView.backgroundView == nil) {
            optionsController.tableView.backgroundColor = weakSelf.tableView.backgroundColor;
            optionsController.tableView.backgroundView = nil;
        }
        
        [weakSelf.navigationController pushViewController:optionsController animated:YES];
    }];
    RERadioItem *imageStyleWifiItem = [RERadioItem itemWithTitle:@"Wi-Fi" value:[options objectAtIndex:styleViaWifi] selectionHandler:^(RERadioItem *item) {
        
        [item deselectRowAnimated:YES];
        
        // Present options controller
        //
        RETableViewOptionsController *optionsController = [[RETableViewOptionsController alloc] initWithItem:item options:options multipleChoice:NO completionHandler:^{
            [weakSelf.navigationController popViewControllerAnimated:YES];
            
            [item reloadRowWithAnimation:UITableViewRowAnimationNone];
            
            HPImageDisplayStyle styleViaWifi
                = [options indexOfObjectIdenticalTo:item.value];
            //NSLog(@"styleViaWifi %d", styleViaWifi);
            [Setting saveInteger:styleViaWifi forKey:HPSettingImageWifi];
        }];
        
        optionsController.delegate = weakSelf;
        optionsController.style = section.style;
        if (weakSelf.tableView.backgroundView == nil) {
            optionsController.tableView.backgroundColor = weakSelf.tableView.backgroundColor;
            optionsController.tableView.backgroundView = nil;
        }
        
        [weakSelf.navigationController pushViewController:optionsController animated:YES];
    }];
    
    [section addItem:imageStyleWWANItem];
    [section addItem:imageStyleWifiItem];
    
    
    RETableViewItem *cleanItem = [RETableViewItem itemWithTitle:@"清理缓存" accessoryType:UITableViewCellAccessoryDisclosureIndicator selectionHandler:^(RETableViewItem *item) {
        [item deselectRowAnimated:YES];
        
        [SVProgressHUD showWithStatus:@"清理中"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            [[SDImageCache sharedImageCache] clearDisk];
            [[SDURLCache sharedURLCache] removeAllCachedResponses];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showSuccessWithStatus:@"清理完成"];
            });
        });
    
        
        item.title = @"清理缓存";
        [item reloadRowWithAnimation:UITableViewRowAnimationAutomatic];
    }];
    
    
    [[SDImageCache sharedImageCache] calculateSizeWithCompletionBlock:^(NSUInteger fileCount, NSUInteger totalSize) {
        
        NSLog(@"%lu, %lu", fileCount, totalSize);
        //cleanItem.title = [NSString stringWithFormat:@"%d, %lld", fileCount, totalSize];
        cleanItem.title = [NSString stringWithFormat:@"清理缓存 %.1fm", totalSize/(1024.f*1024.f)];
        [cleanItem reloadRowWithAnimation:UITableViewRowAnimationAutomatic];
        
    }];
    
    [section addItem:cleanItem];
    
    
    CGFloat lastMinite = [Setting floatForKey:HPSettingBGLastMinite];
    RERadioItem *lastMiniteItem = [RERadioItem itemWithTitle:@"待读内容保存时间" value:[NSString stringWithFormat:@"%d分钟", (int)lastMinite] selectionHandler:^(RERadioItem *item) {
        [item deselectRowAnimated:YES];
        
        NSArray *options = @[@"10分钟", @"20分钟", @"30分钟",
                             @"1小时",@"3小时",
                             @"一天", @"三天",
                             @"永远"];
        
        // Present options controller
        //
        RETableViewOptionsController *optionsController = [[RETableViewOptionsController alloc] initWithItem:item options:options multipleChoice:NO completionHandler:^{
            [weakSelf.navigationController popViewControllerAnimated:YES];
            
            float lastMinite = 10;
            NSUInteger i = [options indexOfObject:item.value];
            
            switch (i) {
                case 0:case 1:case 2:
                    lastMinite = 10 * (i+1); break;
                case 3: lastMinite = 60; break;
                case 4: lastMinite = 60 * 3; break;
                case 5: lastMinite = 60 * 24; break;
                case 6: lastMinite = 60 * 3 * 24; break;
                case 7: lastMinite = 24 * 24 * 24; break;
                default:
                    lastMinite = 20;
                    break;
            }
            NSLog(@"%f", lastMinite);
            [Setting saveFloat:lastMinite forKey:HPSettingBGLastMinite];
            
            [item reloadRowWithAnimation:UITableViewRowAnimationNone];
        }];
        
        // Adjust styles
        //
        optionsController.delegate = weakSelf;
        optionsController.style = section.style;
        if (weakSelf.tableView.backgroundView == nil) {
            optionsController.tableView.backgroundColor = weakSelf.tableView.backgroundColor;
            optionsController.tableView.backgroundView = nil;
        }
        
        // Push the options controller
        //
        [weakSelf.navigationController pushViewController:optionsController animated:YES];
    }];
    
    [section addItem:lastMiniteItem];
    
    [_manager addSection:section];
    return section;
}

- (RETableViewSection *)addAboutControls
{
    //RETableViewSection *section = [RETableViewSection sectionWithHeaderTitle:@"About"];
    RETableViewSection *section = [RETableViewSection sectionWithHeaderTitle:@"  " footerTitle:nil];
    
    // 致谢
    //
    RETableViewItem *aboutItem = [RETableViewItem itemWithTitle:@"致谢" accessoryType:UITableViewCellAccessoryDisclosureIndicator selectionHandler:^(RETableViewItem *item) {
        [item deselectRowAnimated:YES];
        
        UIWebView *webView=[[UIWebView alloc]initWithFrame:self.view.frame];
        webView.delegate = self;
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"acknowledgement" withExtension:@"html"];
        
        [webView loadRequest:[NSURLRequest requestWithURL:url]];
        
        UIViewController *webViewController = [[UIViewController alloc] init];
        [webViewController.view addSubview: webView];
        
        webViewController.title = @"致谢";
        [self.navigationController pushViewController:webViewController animated:YES];
    }];

    
    // Bug & 建议
    //
    RETableViewItem *reportItem = [RETableViewItem itemWithTitle:@"联系作者" accessoryType:UITableViewCellAccessoryDisclosureIndicator selectionHandler:^(RETableViewItem *item) {
        [item deselectRowAnimated:YES];
        
        // 获得设备信息
        //
        /*!
         *  get the information of the device and system
         *  "i386"          simulator
         *  "iPod1,1"       iPod Touch
         *  "iPhone1,1"     iPhone
         *  "iPhone1,2"     iPhone 3G
         *  "iPhone2,1"     iPhone 3GS
         *  "iPad1,1"       iPad
         *  "iPhone3,1"     iPhone 4
         *  @return null
         */
        struct utsname systemInfo;
        uname(&systemInfo);
        //get the device model and the system version
        NSString *device_model = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
        NSString *system_version = [[UIDevice currentDevice] systemVersion];
        NSLog(@"device_model %@, system_version %@", device_model, system_version);
        
        
        MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        [controller setToRecipients:@[@"wujichao@gmail.com"]];
        [controller setSubject:@""];
        [controller setMessageBody:[NSString stringWithFormat:@"\n\n\n网络(eg:移动2g): \n设备: %@ \niOS版本: %@ \n客户端版本: v%@", device_model, system_version, VERSION] isHTML:NO];
        if (controller) [self presentViewController:controller animated:YES completion:NULL];
    }];
    

    
    //
    //
    RETableViewItem *replyItem = [RETableViewItem itemWithTitle:@"回帖建议" accessoryType:UITableViewCellAccessoryDisclosureIndicator selectionHandler:^(RETableViewItem *item) {
        
        HPThread *thread = [HPThread new];
        thread.fid = 2;
        thread.tid = 1272557;
        thread.title = @"D版 iOS 客户端";
    
        HPReadViewController *rvc = [[HPReadViewController alloc] initWithThread:thread];
        [self.navigationController pushViewController:rvc animated:YES];
        
        [item deselectRowAnimated:YES];
    }];
   
    
    
    [section addItem:reportItem];
    [section addItem:replyItem];
    [section addItem:aboutItem];
    
    [_manager addSection:section];
    return section;
}

#pragma mark -

- (void)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        [[HPRearViewController sharedRearVC] forumDidChanged];
    }];
}


- (void)reset:(id)sender {
    
    [UIAlertView showConfirmationDialogWithTitle:@"重置设置"
                                         message:@"您确定要重置所有设置吗?"
                                         handler:^(UIAlertView *alertView, NSInteger buttonIndex)
     {
         if (buttonIndex == [alertView cancelButtonIndex]) {
             ;
         } else {
             
             [Setting loadDefaults];
             [SVProgressHUD showSuccessWithStatus:@"设置已重置"];
             
             [self close:nil];
         }
     }];
}

#pragma mark mail delegate
- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error;
{
    if (result == MFMailComposeResultSent) {
        NSLog(@"sent");
    }
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark webView delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked &&
        [request.URL.scheme hasPrefix:@"http"]) {
        
        [[UIApplication sharedApplication] openURL:request.URL];
        return NO;
    }
    NSLog(@"%@, %ld", request, navigationType);
    
    return YES;
}


@end
