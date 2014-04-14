//
//  HPBackgroundViewController.m
//  HiPDA
//
//  Created by wujichao on 13-11-15.
//  Copyright (c) 2013年 wujichao. All rights reserved.
//

#import "HPThread.h"
#import "HPUser.h"
#import "HPCache.h"
#import "HPTheme.h"
#import "HPSetting.h"
#import "HPBackgroundViewController.h"
#import "HPReadViewController.h"

#import <UI7Kit/UI7TableViewCell.h>
#import <SVProgressHUD.h>
#import "UIAlertView+Blocks.h"



@interface HPBackgroundViewController () <UIActionSheetDelegate>

@end

@implementation HPBackgroundViewController

+ (HPBackgroundViewController *)sharedBgView {
    static HPBackgroundViewController *sharedBgView = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedBgView = [[HPBackgroundViewController alloc] init];
    });
    return sharedBgView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"待读";
    
    [self addRevealActionBI];
    
    // clear btn
    UIBarButtonItem *clearButtonItem = [
                                         [UIBarButtonItem alloc] initWithTitle:@"清除"
                                         style:UIBarButtonItemStylePlain
                                         target:self
                                         action:@selector(clear:)];
    self.navigationItem.rightBarButtonItems = @[clearButtonItem, self.editButtonItem];
    
    self.tableView.backgroundColor = [HPTheme backgroundColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self addGuesture];
    
    if (![_cachedThreads count] && [NSStandardUserDefaults boolForKey:kHPBgVCTip or:YES]) {
        [UIAlertView showConfirmationDialogWithTitle:@"提示"
                                             message:@"在帖子上左滑滑可以预载入"
                                             handler:^(UIAlertView *alertView, NSInteger buttonIndex)
         {
             if (buttonIndex == [alertView cancelButtonIndex]) {
                 ;
             } else {
                 [NSStandardUserDefaults saveBool:NO forKey:kHPBgVCTip];
             }
         }];
    }
    
    // triger reload data
    [self.tableView reloadData];
    
    NSLog(@"_cachedThreads %@", _cachedThreads);
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [self removeGuesture];
    [super viewWillDisappear:animated];
}


- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

#pragma mark - 

- (void)setup {
    _cachedThreads = [[HPCache sharedCache] allBgThreads];
    NSLog(@"_cachedThreads %@",_cachedThreads);
}


- (void)clear:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:@"清除所有"
                                  otherButtonTitles:nil, nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSLog(@"buttonIndex = %i", buttonIndex);
    
    if (buttonIndex == 0) {
        
        [[HPCache sharedCache] clearBgThreads];
        
        //todo
        [self.tableView reloadData];
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
    return [_cachedThreads count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"HPBgCell";
    UI7TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (!cell) {
        cell = [[UI7TableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    HPThread *thread = [_cachedThreads objectAtIndex:indexPath.row];
    cell.textLabel.text = thread.title;
    cell.textLabel.textColor = [HPTheme textColor];
    
    if ([Setting boolForKey:HPSettingNightMode]) {
        UIView *bgColorView = [[UIView alloc] init];
        bgColorView.backgroundColor = rgb(20.f, 20.f, 20.f);;
        [cell setSelectedBackgroundView:bgColorView];
    } else {
        [cell setSelectedBackgroundView:nil];
    }
    
    if (indexPath.row % 2 == 0) {
        [cell.contentView setBackgroundColor:[HPTheme oddCellColor]];
    } else {
        [cell.contentView setBackgroundColor:[HPTheme evenCellColor]];
    }
    
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
        [_cachedThreads removeObjectAtIndex:indexPath.row];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    HPThread *thread = [_cachedThreads objectAtIndex:indexPath.row];
    HPReadViewController *rvc = [[HPReadViewController alloc] initWithThread:thread];
    
    [self.navigationController pushViewController:rvc animated:YES];
    
    //[_cachedThreads removeObjectAtIndex:indexPath.row];
    [[HPCache sharedCache] removeBgThreadAtIndex:indexPath.row];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - theme
- (void)themeDidChanged {
    [self.tableView reloadData];
    [self.tableView setBackgroundColor:[HPTheme backgroundColor]];
}

@end
