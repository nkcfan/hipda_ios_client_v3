//
//  HPSearchViewController.m
//  HiPDA
//
//  Created by wujichao on 13-11-22.
//  Copyright (c) 2013年 wujichao. All rights reserved.
//

#import "HPSearchViewController.h"
#import "HPReadViewController.h"

#import "HPSearch.h"

#import "UIAlertView+Blocks.h"
#import <SVProgressHUD.h>

#import <UI7TableViewCell.h>
#import "SWRevealViewController.h"

#define FONT_SIZE 16.0f
#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN 10.0f

@interface HPSearchViewController ()

@end

@implementation HPSearchViewController {
@private
    NSInteger _current_page;
    NSInteger _page_count;
    
    UIBarButtonItem *_searchButtonItem;
    UIBarButtonItem *_nextPageButtonItem;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    self.title = @"搜索";
    
    // search btn
    _searchButtonItem = [
                         [UIBarButtonItem alloc] initWithTitle:@"搜索"
                         style:UIBarButtonItemStylePlain
                         target:self
                         action:@selector(search:)];
    
    _nextPageButtonItem = [self addPageControlBtn];
    
    self.navigationItem.rightBarButtonItem = _searchButtonItem;
    
    [self addCloseBI];
    
//    // revealButton
//    UIBarButtonItem *revealButtonItem = [
//                                         [UIBarButtonItem alloc] initWithTitle:@"Menu"
//                                         style:UIBarButtonItemStylePlain
//                                         target:self action:@selector(revealToggle:)];
//    self.navigationItem.leftBarButtonItem = revealButtonItem;
    
    
    // search bar
    //
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];
    _searchBar.delegate = self;
    
    _searchBar.placeholder=@"keywords";
    [_searchBar becomeFirstResponder];
    
    _searchBar.showsScopeBar = YES;
    _searchBar.scopeButtonTitles = @[@"标题", @"全文"];
    
    _searchBar.frame = CGRectMake(0, 0, self.tableView.frame.size.width, 44 + 40);

    self.tableView.tableHeaderView = _searchBar;
}

- (void)viewWillAppear:(BOOL)animated {
    
    //[self addGuesture];
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

- (void)setup {
    _current_page = 1;
}

- (void)revealToggle:(id)sender {
    [_searchBar resignFirstResponder];
    
    SWRevealViewController *revealController = [self revealViewController];
    [revealController revealToggle:sender];
}


- (void)search:(id)sender {
    
    [_searchBar resignFirstResponder];
    
    // tip
    NSString *tip = NULL;
    if ([sender isKindOfClass:[NSString class]]) {
        tip = (NSString *)sender;
    } else {
        tip = @"搜索中...";
    }
    
    
    // key
    NSString *key = _searchBar.text;
    HPSearchType type = _searchBar.selectedScopeButtonIndex;
    
    if (!key || [key isEqualToString:@""]) {
        
        [SVProgressHUD showErrorWithStatus:@"请输入关键词"];
        [_searchBar becomeFirstResponder];
        return;
    }
    
    NSLog(@"key %@, type : %d", key, type);
    
    
    // update ui
    self.title = [NSString stringWithFormat:@"搜索: %@", key];
    
    
    
    [SVProgressHUD showWithStatus:tip];
    
    //_results = nil;
    //[self.tableView reloadData];
    
    NSDictionary *parameters = @{@"key": key};
    
    [HPSearch searchWithParameters:parameters
                              type:type
                              page:_current_page
                             block:^(NSArray *results, NSInteger pageCount, NSError *error) {
                                 
                                 if (error) {
                                     [SVProgressHUD dismiss];
                                     
                                     [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
                                     
                                     // update ui
                                     self.title = @"搜索";
                                     self.navigationItem.rightBarButtonItem = _searchButtonItem;
                                     
                                 } else if ([results count]){
                                     [SVProgressHUD dismiss];
                                     
                                     _results = results;
                                     _page_count = pageCount;
                                     
                                     [self.tableView reloadData];
                                     
                                     NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                     [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:NO];
                                     [self.tableView flashScrollIndicators];
                                     
                                     // update ui
                                     self.title = [NSString stringWithFormat:@"搜索: %@ (%d/%d)", key, _current_page, _page_count];
                                     self.navigationItem.rightBarButtonItem = _nextPageButtonItem;
                                     
                                 } else {
                                     //NSLog(@"in");
                                     
                                     [SVProgressHUD showErrorWithStatus:@"对不起，没有找到匹配结果。"];
                                     //NSLog(@"in2");
                                     [_searchBar becomeFirstResponder];
                                     
                                     // update ui
                                     self.title = @"搜索";
                                     self.navigationItem.rightBarButtonItem = _searchButtonItem;
                                 }
                             }];
}

- (void)prevPage:(id)sender {
    
    if (_current_page <= 1) {
        [SVProgressHUD showErrorWithStatus:@"已经是第一页"];
    } else {
        _current_page--;
        [self search:[NSString stringWithFormat:@"前往第%d页...", _current_page]];
    }
}

- (void)nextPage:(id)sender {
    
    //NSLog(@"sender %@", sender);
    
    if (_current_page >= _page_count) {
        [SVProgressHUD showErrorWithStatus:@"已经是最后一页"];
    } else {
        _current_page++;
        [self search:[NSString stringWithFormat:@"前往第%d页...", _current_page]];
    }
}

#pragma mark -  UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    //NSLog(@"searchBar.text %@", searchBar.text);
    
    [self search:searchBar];
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    //NSLog(@"selectedScope %d", selectedScope);
    
    // update ui
    self.title = @"搜索";
    _current_page = 1;
    self.navigationItem.rightBarButtonItem = _searchButtonItem;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    // update ui
    self.title = @"搜索";
    self.navigationItem.rightBarButtonItem = _searchButtonItem;
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
    return [_results count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"HPSearchCell";
    UI7TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (!cell) {
        cell = [[UI7TableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = [UIFont systemFontOfSize:FONT_SIZE];
        //cell.detailTextLabel.numberOfLines = 0;
    }
    
    NSMutableDictionary *dict = [_results objectAtIndex:indexPath.row];
    
    HPSearchType type = _searchBar.selectedScopeButtonIndex;
    
    switch (type) {
        case HPSearchTypeTitle:
        {
            cell.textLabel.text = [dict objectForKey:@"title"];
            
            
            NSString *moreInfo = [NSString stringWithFormat:@"%@  -  %@  -  %@",
                                  [dict objectForKey:@"forum"],
                                  [dict objectForKey:@"username"],
                                  [dict objectForKey:@"dateString"]];
            cell.detailTextLabel.text = moreInfo;
            break;
        }
        case HPSearchTypeFullText:
        {
            cell.textLabel.text = [dict objectForKey:@"detail"];
            
            
            NSString *moreInfo = [NSString stringWithFormat:@"标题: %@, 作者: %@",
                                  [dict objectForKey:@"title"],
                                  [dict objectForKey:@"username"]];
            cell.detailTextLabel.text = moreInfo;
            break;
        }
        default:
            NSLog(@"error HPSearchType %d", type);
            break;
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSMutableDictionary *dict = [_results objectAtIndex:indexPath.row];
    
    HPThread *thread = [HPThread new];
    thread.fid = [[dict objectForKey:@"fidString"] integerValue];
    thread.tid = [[dict objectForKey:@"tidString"] integerValue];
    thread.title = [dict objectForKey:@"title"];
    NSInteger find_pid = [[dict objectForKey:@"pidString"] integerValue];
    
    HPReadViewController *rvc = [[HPReadViewController alloc] initWithThread:thread find_pid:find_pid];
    
    [self.navigationController pushViewController:rvc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSMutableDictionary *dict = [_results objectAtIndex:indexPath.row];
    NSString *text = nil;
    HPSearchType type = _searchBar.selectedScopeButtonIndex;
    switch (type) {
        case HPSearchTypeTitle:
        {
            text = [dict objectForKey:@"title"];
            break;
        }
        case HPSearchTypeFullText:
        {
            text = [dict objectForKey:@"detail"];
            break;
        }
        default:
            NSLog(@"error HPSearchType %d", type);
            break;
    }

    
    CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000.0f);
    
    NSAttributedString *attributedText = [[NSAttributedString alloc]initWithString:text attributes:@{
                                                                                            NSFontAttributeName:[UIFont systemFontOfSize:FONT_SIZE]
                                        }];
    CGRect rect = [attributedText boundingRectWithSize:constraint
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    CGSize size = rect.size;
    
    //NSLog(@"%f", size.height);
    CGFloat height = MAX(size.height + 20 , 50.0f);
    
    return height + (CELL_CONTENT_MARGIN * 2);
    
    /*

    CGSize sizeToFit = [[dict objectForKey:@"title"] sizeWithFont:[UIFont systemFontOfSize:16.0f] constrainedToSize:CGSizeMake(320.0f, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
    
    return fmaxf(70.0f, sizeToFit.height + 40.0f);*/
}





@end
