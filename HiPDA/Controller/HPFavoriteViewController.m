//
//  HPFavoriteViewController.m
//  HiPDA
//
//  Created by wujichao on 13-11-22.
//  Copyright (c) 2013年 wujichao. All rights reserved.
//

#import "HPThread.h"
#import "HPUser.h"
#import "HPFavorite.h"
#import "HPFavoriteViewController.h"
#import "HPReadViewController.h"

#import "UIAlertView+Blocks.h"
#import <SVProgressHUD.h>

#import <UI7TableViewCell.h>
#import "SWRevealViewController.h"

@interface HPFavoriteViewController ()

@end

@implementation HPFavoriteViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"收藏";
    
    // ayscn btn
    UIBarButtonItem *ayscnButtonItem = [
                                        [UIBarButtonItem alloc] initWithTitle:@"同步"
                                        style:UIBarButtonItemStylePlain
                                        target:self
                                        action:@selector(confirm:)];
    self.navigationItem.rightBarButtonItems = @[ayscnButtonItem, self.editButtonItem];
    
    [self addRevealActionBI];
    
    if (![_favoritedThreads count]) {
        [self confirm:nil];
    }
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

- (void)setup {
    _favoritedThreads = [[HPFavorite sharedFavorite] favorites];
    NSLog(@"_favoritedThreads %@",_favoritedThreads);
}


- (void)confirm:(id)sender {
    [UIAlertView showConfirmationDialogWithTitle:@"同步"
                                         message:@"您确定同步与HiPDA论坛的收藏吗?"
                                         handler:^(UIAlertView *alertView, NSInteger buttonIndex)
     {
         if (buttonIndex == [alertView cancelButtonIndex]) {
             ;
         } else {
             [self ayscn:nil];
         }
     }];
}

- (void)ayscn:(id)sender {
    
    [SVProgressHUD showWithStatus:@"同步中..."];
    
    _favoritedThreads = nil;
    [self.tableView reloadData];
    
    [HPFavorite ayscnFavoritesWithBlock:^(NSArray *threads, NSError *error)
     {
         if (error) {
             [SVProgressHUD dismiss];
             [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
             
         } else if ([threads count]){
             [SVProgressHUD dismiss];
             
             [[HPFavorite sharedFavorite] favoriteThreads:threads];
             _favoritedThreads = [[HPFavorite sharedFavorite] favorites];
             [self.tableView reloadData];
             
             NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
             [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:NO];
             [self.tableView flashScrollIndicators];
             
         } else {
             [SVProgressHUD showErrorWithStatus:@"您没有收藏条目"];
         }
     }];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_favoritedThreads count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"HPFavoriteCell";
    UI7TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UI7TableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    HPThread *thread = [_favoritedThreads objectAtIndex:indexPath.row];
    cell.textLabel.text = thread.title;
    
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        [[HPFavorite sharedFavorite] removeFavoritesAtIndex:indexPath.row block:^(NSString *msg, NSError *error) {
            if(!error) {
                [SVProgressHUD showSuccessWithStatus:@"删除成功"];
            } else {
                [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
            }
        }];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    HPThread *thread = [_favoritedThreads objectAtIndex:indexPath.row];
    HPReadViewController *readVC = [[HPReadViewController alloc] initWithThread:thread];
    
    [self.navigationController pushViewController:readVC animated:YES];
}



@end
