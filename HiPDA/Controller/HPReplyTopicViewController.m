//
//  HPReplyTopicViewController.m
//  HiPDA
//
//  Created by wujichao on 14-3-5.
//  Copyright (c) 2014年 wujichao. All rights reserved.
//

#import "HPReplyTopicViewController.h"
#import "HPThread.h"
#import "HPUser.h"
#import "HPSearch.h"

#import "UIAlertView+Blocks.h"
#import <SVProgressHUD.h>
#import "NSString+Additions.h"


@interface HPReplyTopicViewController ()

@property (nonatomic, strong)NSString *formhash;
@property (nonatomic, assign)BOOL waitingForToken;

@property (nonatomic, strong)NSTimer *countDownTimer;
@property (nonatomic, assign)NSTimeInterval secondsCountDown;

@end

@implementation HPReplyTopicViewController

/*
 required
    tid 
    fid
 */

- (id)initWithThread:(HPThread *)thread delegate:(id<HPCompositionDoneDelegate>)delegate {
    
    self = [super init];
    if (self) {
        _thread = thread;
        self.actionType = ActionTypeNewPost;
        [self setDelegate:delegate];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"回复";
    [self.contentTextFiled becomeFirstResponder];
    
    [self loadFormhash];
}

- (void)loadFormhash {
    
    [self.indicator startAnimating];

    
    [HPSendPost loadParametersWithBlock:^(NSDictionary *parameters, NSError *error) {
         
         [self.indicator stopAnimating];
         
         _formhash = [parameters objectForKey:@"formhash"];
         
         
         if (_formhash) {
             
             if (_waitingForToken) {
                 _waitingForToken = NO;
                 [self send:nil];
             }
             
         } else {
            
             [UIAlertView showConfirmationDialogWithTitle:@"出错啦"
                message:[NSString stringWithFormat:@"获取回复token失败(错误信息:%@), 是否重试?", [error localizedDescription]]
                handler:^(UIAlertView *alertView, NSInteger buttonIndex)
              {
                  if (buttonIndex == [alertView cancelButtonIndex]) {
                      ;
                  } else {
                      [self loadFormhash];
                  }
              }];
         }
     }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)send:(id)sender {
    
    
    if (!_formhash) {
        [SVProgressHUD showWithStatus:@"正在获取回复token, 马上好"];
        _waitingForToken = YES;
        return;
    }
    
    // check
    if ([self.contentTextFiled.text isEqualToString:@""] ||
        [self.contentTextFiled.text isEqualToString:@"content here..."]) {
        [SVProgressHUD showErrorWithStatus:@"请输入内容"];
        return;
    }
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [SVProgressHUD showWithStatus:@"发送中..."];
    
    [HPSendPost sendReplyWithThread:_thread
                            content:self.contentTextFiled.text
                       imagesString:self.imagesString
                           formhash:_formhash
                              block:
     ^(NSString *msg, NSError *error) {
         self.navigationItem.rightBarButtonItem.enabled = YES;
         if (error) {
             
             if ([[error localizedDescription] indexOf:@"您两次发表间隔少于 30 秒"] != -1) {
                 [SVProgressHUD dismiss];
                 [UIAlertView showConfirmationDialogWithTitle:@"太快啦"
                                                      message:@"您两次发表间隔少于 30 秒, 是否开启定时器?"
                                                      handler:^(UIAlertView *alertView, NSInteger buttonIndex)
                  {
                      if (buttonIndex == [alertView cancelButtonIndex]) {
                          ;
                      } else {
                          _secondsCountDown = 31;
                          _countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeFireMethod) userInfo:nil repeats:YES];
                      }
                  }];
             } else {
                 [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
             }
         } else {
             [SVProgressHUD showSuccessWithStatus:@"发送成功"];
             [self doneWithError:nil];
         }
     }];
}

-(void)timeFireMethod{
    _secondsCountDown--;
    [SVProgressHUD showProgress:_secondsCountDown/31.f];
    if(_secondsCountDown == 0){
        [_countDownTimer invalidate];
        [self send:nil];
    }
}

@end
