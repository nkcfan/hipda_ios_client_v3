//
//  HPLoginViewController.m
//  HiPDA
//
//  Created by wujichao on 13-11-21.
//  Copyright (c) 2013年 wujichao. All rights reserved.
//

#import "HPRegisterViewController.h"


#import "HPAccount.h"

#import "NSUserDefaults+Convenience.h"
#import "RETableViewManager.h"
#import "RETableViewOptionsController.h"
#import <SVProgressHUD.h>
#import "SWRevealViewController.h"
#import "UIAlertView+Blocks.h"
#import "DZWebBrowser.h"

@interface HPRegisterViewController ()

@property (strong, nonatomic) RETableViewManager *manager;
@property (strong, nonatomic) RETableViewSection *section;

@property (strong, nonatomic) RETextItem *usernameItem;
@property (strong, nonatomic) RETextItem *passwordItem;
@property (strong, nonatomic) RETextItem *repasswordItem;

@property (strong, nonatomic) RETextItem *emailItem;

@property (strong, nonatomic) RETableViewItem *LoginBtnItem;

@end

@implementation HPRegisterViewController

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
    
    
    self.title = NSLocalizedString(@"注册", nil);
    
    
    // Create manager
    //
    self.manager = [[RETableViewManager alloc] initWithTableView:self.tableView delegate:self];
    
    
    self.section = [RETableViewSection sectionWithHeaderTitle:@""];
    
    //__typeof (&*self) __weak weakSelf = self;
    
    self.usernameItem = [RETextItem itemWithTitle:@"用户名" value:nil placeholder:@"username"];
    self.passwordItem = [RETextItem itemWithTitle:@"密码" value:nil placeholder:@"******"];
    self.passwordItem.secureTextEntry = YES;
    
    self.repasswordItem = [RETextItem itemWithTitle:@"密码确认" value:nil placeholder:@"******"];
    self.repasswordItem.secureTextEntry = YES;
    
    self.emailItem = [RETextItem itemWithTitle:@"Email" value:nil placeholder:@"邮箱"];
    
    
    self.LoginBtnItem = [RETableViewItem itemWithTitle:@"提交" accessoryType:UITableViewCellAccessoryNone selectionHandler:^(RETableViewItem *item) {
        
        item.title = @"正在提交...";
        [item reloadRowWithAnimation:UITableViewRowAnimationAutomatic];
        
        NSString *username = self.usernameItem.value;
        NSString *password = self.passwordItem.value;
        NSString *repassword = self.repasswordItem.value;
        
        if (!(username && password)) {
            item.title = @"确定";
            [item reloadRowWithAnimation:UITableViewRowAnimationAutomatic];
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:@"请填写用户名和密码" delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
            return;
        }
        
        if (![password isEqualToString:repassword]) {
            item.title = @"确定";
            [item reloadRowWithAnimation:UITableViewRowAnimationAutomatic];
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:@"两次密码不一致" delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
            return;
        }
        
        
        [SVProgressHUD showWithStatus:@"正在提交..."];
        [[HPAccount sharedHPAccount] registerWithBlock:^(BOOL isLogin, NSError *error)
         {
             [SVProgressHUD dismiss];
             [self.view endEditing:YES];
             
             item.title = @"提交";
             [item reloadRowWithAnimation:UITableViewRowAnimationAutomatic];
             
             [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"提示", nil) message:@"感谢您的注册, 请等待管理人员进行审核" delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
         }];
    }];
    
    self.LoginBtnItem.textAlignment = NSTextAlignmentCenter;
    
    [_section addItem:self.usernameItem];
    [_section addItem:self.passwordItem];
    [_section addItem:self.repasswordItem];
    [_section addItem:self.LoginBtnItem];
    
    [self.manager addSection:_section];
}


@end
