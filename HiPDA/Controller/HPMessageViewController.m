//
//  HPMessageViewController.m
//  HiPDA
//
//  Created by wujichao on 13-12-1.
//  Copyright (c) 2013年 wujichao. All rights reserved.
//

#import "HPMessageViewController.h"
#import "HPMessageDetailViewController.h"
#import "HPMessage.h"
#import "HPUser.h"
#import "HPIndecator.h"
#import "HPSetting.h"

#import "UIAlertView+Blocks.h"
#import <SVProgressHUD.h>

#import <UI7TableViewCell.h>
#import "SWRevealViewController.h"
#import "HPRearViewController.h"

@interface HPMessageViewController ()

@property NSInteger current_page;

@end

@implementation HPMessageViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.title = @"短消息";
    

    [self addPageControlBtn];
    [self addRevealActionBI];
    
    [self addRefreshControl];
    
    
    //[self load];
   
    NSLog(@"message count %ld", [Setting integerForKey:HPPMCount]);
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
}

#pragma mark -

- (void)load {
    _current_page = 1;
    [self.refreshControl beginRefreshing];
    [self ayscn:nil];
}

- (void)refresh:(id)sender {
    
    _current_page = 1;
    
    if ([sender isKindOfClass:[UIRefreshControl class]]) {
        
    } else {
        //[HPIndecator show];
        [self showRefreshControl];
    }
    
    [self ayscn:nil];
}


- (void)setup {
    _message_list = [[HPMessage sharedMessage] message_list];
    _current_page = 1;
}


- (void)ayscn:(id)sender {
    
    if ([sender isKindOfClass:[NSString class]]) {
        [SVProgressHUD showWithStatus:sender];
    } else {
        ;//[self.refreshControl beginRefreshing];
    }
    
    //_message_list = nil;
    //[self.tableView reloadData];
    [HPMessage loadMessageListWithBlock:^(NSArray *list, NSError *error) {
        
        if (error) {
            [SVProgressHUD dismiss];
            
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
            
        } else if ([list count]){
            [SVProgressHUD dismiss];
            
            if (_current_page == 1) {
                [[HPMessage sharedMessage] cacheMyMessages:list];
            }
            _message_list = list;
            [self.tableView reloadData];
            
            if (![self.refreshControl isRefreshing]) {
                [self.tableView setContentOffset:CGPointZero animated:NO];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:NO];
                [self.tableView flashScrollIndicators];
            }
            
            [Setting saveInteger:0 forKey:HPPMCount];
            [[HPRearViewController sharedRearVC] updateBadgeNumber];
            
        } else {
            [SVProgressHUD showErrorWithStatus:@"您没有私人消息"];
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
    if (_message_list.count >= 50) {
        _current_page++;
        [self ayscn:@"加载下一页..."];
    } else {
        [SVProgressHUD showErrorWithStatus:@"已经是最后一页"];
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_message_list count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"HPMyMessageCell";
    UI7TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    //UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    
    if (!cell) {
        cell = [[UI7TableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
        //[cell.contentView addSubview:dateLabel];
    }
    
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:[_message_list objectAtIndex:indexPath.row]];
    
    HPUser *user = [info objectForKey:@"user"];
    
    cell.textLabel.text = [info objectForKey:@"summary"];
    
    NSString *detail = [NSString stringWithFormat:@"与: %@   %@",
                        user.username,
                        [info objectForKey:@"dateString"]];
    cell.detailTextLabel.text = detail;
    
    //dateLabel.text = [info objectForKey:@"dateString"];
    //dateLabel.textAlignment = NSTextAlignmentRight;
    
    if ([[info objectForKey:@"isUnread"] boolValue]) {
        cell.textLabel.textColor = [UIColor redColor];
        [info setObject:@NO forKey:@"isUnread"];
    } else {
        cell.textLabel.textColor = [UIColor blackColor];
    }

    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    HPMessageDetailViewController *detailViewController =
        [[HPMessageDetailViewController alloc] init];
    
    NSDictionary *info = [_message_list objectAtIndex:indexPath.row];
    detailViewController.user = [info objectForKey:@"user"];
    
    [self.navigationController pushViewController:detailViewController animated:YES];
}

@end
