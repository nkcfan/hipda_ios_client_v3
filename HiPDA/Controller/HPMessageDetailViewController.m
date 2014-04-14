//
//  HPMessageDetailViewController.m
//  HiPDA
//
//  Created by wujichao on 13-12-1.
//  Copyright (c) 2013年 wujichao. All rights reserved.
//

#import "HPMessageDetailViewController.h"
#import <UIImageView+AFNetworking.h>

#import "HPMessage.h"
#import "HPUser.h"

#import <UIImageView+WebCache.h>
#import <SVProgressHUD.h>
#import "NSUserDefaults+Convenience.h"

@interface HPMessageDetailViewController () <JSMessagesViewDataSource, JSMessagesViewDelegate>

@property (strong, nonatomic) NSMutableArray *messages;

@end


@implementation HPMessageDetailViewController

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    self.delegate = self;
    self.dataSource = self;
    [super viewDidLoad];
    
    self.title = [NSString stringWithFormat:@"与 %@", _user.username];
    [self setBackgroundColor:[UIColor whiteColor]];
    
    //
    //
    [[JSBubbleView appearance] setFont:[UIFont systemFontOfSize:16.0f]];
    self.messageInputView.textView.placeHolder = NSLocalizedString(@"New Message", nil);
    self.sender = [NSStandardUserDefaults stringForKey:kHPAccountUserName];
    
    
    // refresh btn
    UIBarButtonItem *refreshButtonItem = [
                                          [UIBarButtonItem alloc] initWithTitle:@"刷新"
                                          style:UIBarButtonItemStylePlain
                                          target:self
                                          action:@selector(refresh:)];
    self.navigationItem.rightBarButtonItem = refreshButtonItem;
    
    // gesture
    UISwipeGestureRecognizer *rightSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(back:)];
    rightSwipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:rightSwipeGesture];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self refresh:nil];
}

#pragma mark -

- (void)back:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)refresh:(id)sender {
    
    
    
    [SVProgressHUD showWithStatus:@"载入中..."];
    [HPMessage loadMessageDetailWithUid:_user.uid
                              daterange:5
                                  block:^(NSArray *lists, NSError *error)
     {
         if (error) {
             [SVProgressHUD dismiss];
             [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
             
         } else if ([lists count]){
             [SVProgressHUD dismiss];
             
             _messages = [NSMutableArray arrayWithArray:lists];
             [self.tableView reloadData];
             [self scrollToBottomAnimated:YES];
             
         } else {
             [SVProgressHUD showErrorWithStatus:@"没有记录"];
         }
     }];
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _messages.count;
}

#pragma mark - Messages view delegate: REQUIRED

- (void)didSendText:(NSString *)text fromSender:(NSString *)sender onDate:(NSDate *)date
{
    [SVProgressHUD showWithStatus:@"发送中..."];
    [HPMessage sendMessageWithUsername:_user.username message:text block:^(NSError *error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        } else {
            
            [SVProgressHUD showSuccessWithStatus:@"已送达"];
            
            NSDictionary *newMessage = @{
                                         @"message":text,
                                         @"date":date,
                                         @"username":sender
                                         };
            
            [_messages addObject:newMessage];
            [JSMessageSoundEffect playMessageSentSound];
            
            [self finishSend];
            [self scrollToBottomAnimated:YES];
        }
    }];
}

- (JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *current_name = [[_messages objectAtIndex:indexPath.row] objectForKey:@"username"];
    if ([current_name isEqualToString:_user.username]) {
        return JSBubbleMessageTypeIncoming;
    } else {
        return JSBubbleMessageTypeOutgoing;
    }
}

- (UIImageView *)bubbleImageViewWithType:(JSBubbleMessageType)type
                       forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(type == JSBubbleMessageTypeIncoming) {
        return [JSBubbleImageViewFactory bubbleImageViewForType:type
                                                          color:[UIColor js_bubbleLightGrayColor]];
    }
    
    return [JSBubbleImageViewFactory bubbleImageViewForType:type
                                                      color:[UIColor js_bubbleBlueColor]];
}

- (JSMessageInputViewStyle)inputViewStyle
{
    return JSMessageInputViewStyleFlat;
}

- (BOOL)shouldDisplayTimestampForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

#pragma mark - Messages view delegate: OPTIONAL

- (void)configureCell:(JSBubbleMessageCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if([cell messageType] == JSBubbleMessageTypeOutgoing) {
        cell.bubbleView.textView.textColor = [UIColor whiteColor];
        
        if([cell.bubbleView.textView respondsToSelector:@selector(linkTextAttributes)]) {
            NSMutableDictionary *attrs = [cell.bubbleView.textView.linkTextAttributes mutableCopy];
            [attrs setValue:[UIColor blueColor] forKey:UITextAttributeTextColor];
            
            cell.bubbleView.textView.linkTextAttributes = attrs;
        }
    }
    
    if(cell.timestampLabel) {
        cell.timestampLabel.textColor = [UIColor lightGrayColor];
        cell.timestampLabel.shadowOffset = CGSizeZero;
        
        static NSDateFormatter *formatter;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        });
        
        NSDate *date = [[self messageForRowAtIndexPath:indexPath] date];
        cell.timestampLabel.text = [formatter stringFromDate:date];
    }
    
    if(cell.subtitleLabel) {
        cell.subtitleLabel.textColor = [UIColor blackColor];
    }
    
#if TARGET_IPHONE_SIMULATOR
    cell.bubbleView.textView.dataDetectorTypes = UIDataDetectorTypeNone;
#else
    cell.bubbleView.textView.dataDetectorTypes = UIDataDetectorTypeAll;
#endif
}

- (BOOL)shouldPreventScrollToBottomWhileUserScrolling
{
    return YES;
}

- (BOOL)allowsPanToDismissKeyboard
{
    return YES;
}

#pragma mark - Messages view data source: REQUIRED

- (JSMessage *)messageForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *message_info = [_messages objectAtIndex:indexPath.row];
    NSString *text = [message_info objectForKey:@"message"];
    NSDate *date = [message_info objectForKey:@"date"];
    NSString *username = [message_info objectForKey:@"username"];
    
    
    if ([[message_info objectForKey:@"isUnread"] boolValue]) {
        text = S(@"%@ (未读)", text);
    }
    
    return [[JSMessage alloc] initWithText:text sender:username date:date];
}

- (UIImageView *)avatarImageViewForRowAtIndexPath:(NSIndexPath *)indexPath sender:(NSString *)sender
{
    return nil;
}

@end
