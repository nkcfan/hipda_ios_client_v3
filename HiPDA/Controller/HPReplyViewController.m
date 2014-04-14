//
//  HPReplyViewController.m
//  HiPDA
//
//  Created by wujichao on 14-3-5.
//  Copyright (c) 2014年 wujichao. All rights reserved.
//

#import "HPReplyViewController.h"
#import "HPSendPost.h"

#import "HPNewPost.h"
#import "HPThread.h"
#import "HPUser.h"
#import "HPSearch.h"

#import "UIAlertView+Blocks.h"
#import <SVProgressHUD.h>
#import "NSString+Additions.h"
#import "NSString+HTML.h"


@interface HPReplyViewController ()

@property (nonatomic, strong) HPNewPost* post;
@property (nonatomic, strong) HPThread* thread;
@property (nonatomic, assign) NSInteger page;

@property (nonatomic, strong) NSString *formhash;
@property (nonatomic, strong) HPNewPost* correct_post;
@property (nonatomic, assign) BOOL waitingForToken;


@property (nonatomic, strong) NSTimer *countDownTimer;
@property (nonatomic, assign) NSTimeInterval secondsCountDown;

@end

@implementation HPReplyViewController

- (id)initWithPost:(HPNewPost *)post
        actionType:(ActionType)type
            thread:(HPThread *)thread
              page:(NSInteger)page
          delegate:(id<HPCompositionDoneDelegate>)delegate
{
    
    self = [super init];
    if (self) {
        _post = post;
        self.actionType = type;
        _thread = thread;
        _page = page;
        [self setDelegate:delegate];
        
        // 打印版网页木有这两个关键参数
        if (_thread.formhash)   _formhash = thread.formhash;
        if (post.pid) _correct_post = post;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *title = [NSString stringWithFormat:@"%@ %@",
         self.actionType == ActionTypeReply?@"回复:":@"引用:",
         _post.user.username
    ];
    self.title = title;

    [self.contentTextFiled becomeFirstResponder];
    
    if (_formhash && _correct_post) {
        NSLog(@"had _formhash %@, _pid %ld", _formhash, _correct_post.pid);
    } else {
        [self loadFormhashAndPid];
    }
}

- (void)loadFormhashAndPid {
    
    [self.indicator startAnimating];
    
    //http://www.hi-pda.com/forum/viewthread.php?tid=1273829&extra=&page=2
    //http://www.hi-pda.com/forum/post.php?action=reply&fid=57&tid=1273829&reppost=23560522&extra=&page=2
    [HPSendPost loadFormhashAndPid:self.actionType
                              post:_post
                               tid:_thread.tid
                              page:_page
                             block:^(NSString *formhash, HPNewPost *correct_post, NSError *error)
    {
        [self.indicator stopAnimating];
        
        NSLog(@"get correct formhash %@, pid %ld", formhash, correct_post.pid);
        
        _formhash = formhash;
        _correct_post = correct_post;
        
        if (_formhash && _correct_post) {
            
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
                      [self loadFormhashAndPid];
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
    
    if (!_formhash || !_correct_post) {
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
    
    // cut post.body_html
    NSString *postcontent = nil;
    if (self.actionType == ActionTypeQuote) {
        postcontent = [_post.body_html stringByConvertingHTMLToPlainText];
        NSUInteger loc = [postcontent length] >= 150 ? 150:[postcontent length];
        postcontent = [postcontent substringToIndex:loc];
        NSLog(@" _postcontent %@", postcontent);
    }
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [SVProgressHUD showWithStatus:@"发送中..."];
    [HPSendPost sendPostWithContent:self.contentTextFiled.text
                             action:self.actionType
                                fid:_thread.fid
                                tid:_thread.tid
                               post:_correct_post
                        postcontent:postcontent
                            subject:nil
                        thread_type:0
                           formhash:_formhash
                             images:self.imagesString
                              block:^(NSString *msg, NSError *error)
     {
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
