//
//  HPMyReplyViewController.m
//  HiPDA
//
//  Created by wujichao on 13-11-22.
//  Copyright (c) 2013年 wujichao. All rights reserved.
//

#import "HPMyReplyViewController.h"
#import "HPThread.h"
#import "HPUser.h"
#import "HPMyReply.h"
#import "HPReadViewController.h"
#import "HPIndecator.h"

#import "UIAlertView+Blocks.h"
#import <SVProgressHUD.h>

#import <UI7TableViewCell.h>
#import "SWRevealViewController.h"

@interface HPMyReplyViewController ()

@property NSInteger current_page;

@end

@implementation HPMyReplyViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
     self.title = @"我的回复";
    
    [self addPageControlBtn];
    [self addRevealActionBI];
    
    [self addRefreshControl];
    
    
    //[self load];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [self addGuesture];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [self removeGuesture];
    [super viewWillDisappear:animated];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
- (void)load {
    _current_page = 1;
    [self.refreshControl beginRefreshing];
    [self ayscn:nil];
}

- (void)refresh:(id)sender {
    
    if ([self.refreshControl isRefreshing]) {
        //return;
    }
    
    _current_page = 1;
    
    if ([sender isKindOfClass:[UIRefreshControl class]]) {
        ;
    } else {
        //[HPIndecator show];
        [self showRefreshControl];
    }
    
    [self ayscn:nil];
}

- (void)setup {
    _myReplies = [[HPMyReply sharedReply] myReplies];
    NSLog(@"_myReplies %@",_myReplies);
    
    _current_page = 1;
}

- (void)ayscn:(id)sender {
    
    if ([sender isKindOfClass:[NSString class]]) {
        [SVProgressHUD showWithStatus:sender];
    } else {
        ;//[SVProgressHUD showWithStatus:@"同步中..."];
    }
    //_myReplies = nil;
    //[self.tableView reloadData];
    
    [HPMyReply ayscnMyRepliesWithBlock:^(NSArray *threads, NSError *error) {
        
        if (error) {
            [SVProgressHUD dismiss];
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
            
        } else if ([threads count]){
            [SVProgressHUD dismiss];
            
            if (_current_page == 1) {
                [[HPMyReply sharedReply] cacheMyReplies:threads];
            }
            _myReplies = threads;
            [self.tableView reloadData];
            
            if (![self.refreshControl isRefreshing]) {
                [self.tableView setContentOffset:CGPointZero animated:NO];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:NO];
                [self.tableView flashScrollIndicators];
            }
            
        } else {
            [SVProgressHUD showErrorWithStatus:@"您没有回复帖子"];
        }
        
        [self.refreshControl endRefreshing];
        [HPIndecator dismiss];
        
    } page:_current_page];
}


- (void)prevPage:(id)sender {
    
    
    if (_current_page > 1) {
        _current_page--;
        [self ayscn:@"加载上一页..."];
    } else {
        [SVProgressHUD showErrorWithStatus:@"已经是第一页"];
    }
    
}

- (void)nextPage:(id)sender {
    NSLog(@"_myReplies count %ld", _myReplies.count);
    if (_myReplies.count >= 49) {
        _current_page++;
        [self ayscn:@"加载下一页..."];
    } else {
        [SVProgressHUD showErrorWithStatus:@"已经是最后一页"];
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_myReplies count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"HPMyReplyCell";
    UI7TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (!cell) {
        cell = [[UI7TableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    HPThread *thread = [_myReplies objectAtIndex:indexPath.row];
    cell.textLabel.text = thread.title;
    cell.detailTextLabel.text = thread.replyDetail;
    
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    HPThread *thread = [_myReplies objectAtIndex:indexPath.row];
    
    HPReadViewController *rvc = [[HPReadViewController alloc] initWithThread:thread
                                                                    find_pid:thread.pid];

    
    [self.navigationController pushViewController:rvc animated:YES];
}


@end
