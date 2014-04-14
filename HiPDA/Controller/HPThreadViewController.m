//
//  HPThreadViewController.m
//  HiPDA
//
//  Created by wujichao on 13-11-11.
//  Copyright (c) 2013年 wujichao. All rights reserved.
//

#import "HPHttpClient.h"
#import "HPThread.h"
#import "HPUser.h"
#import "HPCache.h"
#import "HPMessage.h"
#import "HPNewPost.h"
#import "HPAccount.h"
#import "HPDatabase.h"
#import "HPTheme.h"

#import "HPThreadViewController.h"
#import "HPThreadCell.h"
#import "HPReadViewController.h"
#import "SWRevealViewController.h"
#import "EGORefreshTableFooterView.h"
#import "HPLoginViewController.h"
#import "HPRearViewController.h"
#import "HPNewThreadViewController.h"

#import <SVProgressHUD.h>
#import <ZAActivityBar/ZAActivityBar.h>
#import "UIAlertView+Blocks.h"
#import <UIImageView+WebCache.h>
#import "UIBarButtonItem+ImageItem.h"
#import "EGORefreshTableFooterView.h"
#import "BBBadgeBarButtonItem.h"
#import "HPIndecator.h"

typedef enum{
	PullToRefresh = 0,
	ClickToRefresh,
	LoadMore
} LoadType;


@interface HPThreadViewController () <MCSwipeTableViewCellDelegate, UIAlertViewDelegate, HPCompositionDoneDelegate>

@property (nonatomic, strong) NSMutableArray *threads;
@property (nonatomic, assign) NSInteger current_fid;
@property (nonatomic, assign) NSInteger current_page;

@property (nonatomic, strong) UIBarButtonItem *refreshButtonBI;
@property (nonatomic, strong) UIBarButtonItem *refreshIndicatorBI;
@property (nonatomic, strong) UIActivityIndicatorView *refreshIndicator;
@property (nonatomic, strong) UIBarButtonItem *composeBI;

@property (nonatomic, assign) BOOL loadingMore;
@property (nonatomic, strong) EGORefreshTableFooterView *loadingMoreView;

@property (nonatomic, strong) NSDate *lastBgFetchDate;

@end

@implementation HPThreadViewController {
    ;
}


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        ;
    }
    return self;
}

- (id)initDefaultForum:(NSInteger)fid title:(NSString *)title
{
    self = [super init];
    if (self) {
        _current_page = 1;
        _current_fid = fid;
        self.title = title;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //
    [self setActionButton];
    
    self.tableView.rowHeight = 70.0f;
    [self.tableView setBackgroundColor:[HPTheme backgroundColor]];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    //
    [self.tableView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:(__bridge void *)(self)];
    
    //
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                            action:@selector(refresh:)
                  forControlEvents:UIControlEventValueChanged];
    self.refreshControl.backgroundColor = [UIColor clearColor];
    
    //
    [self refresh:[UIButton new]];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    /*
    static BOOL firstTime = YES;
    if (firstTime) {
        ;
    }
    firstTime = NO;
     */
    
    SWRevealViewController *revealController = [self revealViewController];
    [self.navigationController.view addGestureRecognizer:revealController.panGestureRecognizer];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(applicationDidBecomeActiveNotification:)
     name:UIApplicationDidBecomeActiveNotification
     object:[UIApplication sharedApplication]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
     SWRevealViewController *revealController = [self revealViewController];
    [self.navigationController.view removeGestureRecognizer:revealController.panGestureRecognizer];
    
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:UIApplicationDidBecomeActiveNotification
     object:[UIApplication sharedApplication]];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    NSLog(@"threadVC dealloc");
    
    [self.tableView removeObserver:self forKeyPath:@"contentOffset" context:(__bridge void *)self];
}

#pragma mark -
- (void)setActionButton {
    
    /*
    UIBarButtonItem *revealBI = [UIBarButtonItem barItemWithImage:[UIImage imageNamed:@"menu2.png"]
                                                             size:CGSizeMake(40.f, 40.f)
                                                           target:self
                                                           action:@selector(revealToggle:)];
     */
    
    self.navigationItem.leftBarButtonItem = [[HPRearViewController sharedRearVC] sharedRevealActionBI];
    
    _refreshButtonBI = [UIBarButtonItem barItemWithImage:[[UIImage imageNamed:@"home_refresh.png"] changeColor:[UIColor grayColor]]
                                              size:CGSizeMake(40.f, 40.f)
                                            target:self
                                            action:@selector(refresh:)];
    _refreshIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    _refreshIndicatorBI = [[UIBarButtonItem alloc] initWithCustomView:_refreshIndicator];
    
    
    [_refreshIndicator setActivityIndicatorViewStyle:[HPTheme indicatorViewStyle]];
    
    _composeBI = [UIBarButtonItem barItemWithImage:[UIImage imageNamed:@"write.png"]
                                                              size:CGSizeMake(30.f, 30.f)
                                                            target:self
                                                            action:@selector(newThread:)];
    
    self.navigationItem.rightBarButtonItems = @[_composeBI,_refreshButtonBI];
}

#pragma mark - load

- (void)loadForum:(NSInteger)fid title:(NSString *)title {
    self.title = title;
    _current_fid = fid;
    [self refresh:[UIButton new]];
}

- (void)load:(LoadType)type
     refresh:(BOOL)refresh {

    
    
    __weak HPThreadViewController *weakSelf = self;
    [HPThread loadThreadsWithFid:_current_fid
                            page:_current_page
                    forceRefresh:refresh
                           block:^(NSArray *threads, NSError *error)
     {
         // 防止无限登陆
         static int error_count = 0;
         
         [self.refreshControl endRefreshing];
         if (!error) {
             
             error_count = 0;
            
             if (threads.count == 0) {
                 [UIAlertView showWithTitle:@"加载失败"
                                    message:@"返回结果为空, 可能是由于您设置了每页帖子15条, 而置顶帖超过15个, 是否前往个人中心修改为默认?"
                                    handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                     if (buttonIndex != [alertView cancelButtonIndex]) {
                         [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.hi-pda.com/forum/memcp.php?action=profile&typeid=5"]];
                     }
                 }];
                 
                 if (_bgFetchBlock) {
                     _bgFetchBlock(UIBackgroundFetchResultFailed);
                 }
                 
             } else if (type != LoadMore) {
                 
                 _threads = [NSMutableArray arrayWithArray:threads];
                 [weakSelf.tableView reloadData];
                 
                 if (type == ClickToRefresh) {
                     NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                     [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:NO];
                 }
                 
             } else { // loadMore
                 
                 NSUInteger statingIndex = [_threads count];
                 
                 // 去重, O(50^2)
                 NSArray *oldThreads = [NSArray arrayWithArray:_threads];
                 BOOL isSame = NO;
                 for (HPThread *thread in threads) {
                     isSame = NO;
                     for (HPThread *oldthread in oldThreads) {
                         if (oldthread.tid == thread.tid) {
                             isSame = YES;
                             break;
                         }
                     }
                     if (!isSame) [_threads addObject:thread];
                 }
                 NSUInteger endingIndex = [_threads count];
                 
                 NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:endingIndex - statingIndex];
                 for (NSUInteger index = statingIndex; index < endingIndex; index++) {
                     NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                     [indexPaths addObject:indexPath];
                 }
                 
                 [weakSelf.tableView beginUpdates];
                 [weakSelf.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationBottom];
                 [weakSelf.tableView endUpdates];
             }
             
             [self.tableView flashScrollIndicators];
             if (_bgFetchBlock) {
                 _bgFetchBlock(UIBackgroundFetchResultNewData);
                 _lastBgFetchDate = [NSDate new];
             }
             
         } else {
             
             if (error.code == NSURLErrorUserAuthenticationRequired) {
                 NSLog(@"重新登陆...");
                 if ([HPAccount isSetAccount]) {
                     [SVProgressHUD showWithStatus:@"重新登陆中..."];
                 }
                 
                 
                 error_count++;
                 if (error_count == 1) {
                     ;
                 } else {
                     if (_bgFetchBlock) {
                         _bgFetchBlock(UIBackgroundFetchResultFailed);
                     }
                 }
                 
             } else {
                 
                 [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
                 
                 if (_bgFetchBlock) {
                     _bgFetchBlock(UIBackgroundFetchResultFailed);
                 }
             }
         }
        
         if (type == PullToRefresh) {
             
         }
         
         switch (type) {
             case PullToRefresh:
                 [self.refreshControl endRefreshing];
                 break;
             case ClickToRefresh:
                 self.navigationItem.rightBarButtonItems = @[_composeBI,_refreshButtonBI];
                 break;
             case LoadMore:
                 [self loadMoreDone];
                 break;
             default:
                 break;
         }
         
         [self performSelector:@selector(addLoadMoreView) withObject:nil afterDelay:1.f];
                   
     }];
}


- (void)refresh:(id)sender {
    LoadType type = 0;
    
    if ([sender isKindOfClass:[UIRefreshControl class]]) {
        
        type = PullToRefresh;
        
    } else if ([sender isKindOfClass:[UIButton class]]) {
        
        type = ClickToRefresh;
        //NSLog(@"%@, %@", _composeBI,_refreshIndicatorBI);
        self.navigationItem.rightBarButtonItems = @[_composeBI,_refreshIndicatorBI];
        [_refreshIndicator startAnimating];
        
    } else {
        NSLog(@"unknown sender %@", sender);
    }
    
    NSLog(@"refresh...");
    _current_page = 1;
    [self load:type refresh:YES];
}

- (void)loadmore:(id)sender {
    _current_page = _current_page + 1;
    [self load:LoadMore];
}

- (void)load:(LoadType)type {
    [self load:type refresh:NO];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_threads count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HPThread *thread = [_threads objectAtIndex:indexPath.row];
    
    static NSString *CellIdentifier = @"_HPThreadCell_";
    HPThreadCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[HPThreadCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // configure
    [cell configure:thread];
    
    // MCSwipeTableViewCell
    [self addActionsForCell:cell forRowAtIndexPath:indexPath];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [HPThreadCell heightForCellWithThread:[_threads objectAtIndex:indexPath.row]];
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    HPThread *thread = [_threads objectAtIndex:indexPath.row];
    
    // mark read
    HPThreadCell *cell = (HPThreadCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell markRead];
    [[HPCache sharedCache] readThread:thread.tid];
    
    HPReadViewController *readVC =
    [[HPReadViewController alloc] initWithThread:thread];
    [self.navigationController pushViewController:readVC animated:YES];
}

#pragma mark - NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ((__bridge id)context != self) {
        return;
    }
    if (!_loadingMoreView) {
        return;
    }
    
    CGRect f = _loadingMoreView.frame;
    f.origin.y = [self tableViewHeight];
    _loadingMoreView.frame = f;
}

#pragma mark - loadMore & UIScrollViewDelegate

- (void)addLoadMoreView {
    
    if (_threads.count == 0) return;
    
    if (_loadingMoreView == nil) {
        _loadingMoreView = [[EGORefreshTableFooterView alloc] initWithFrame:CGRectMake(0.0f, [self tableViewHeight], 320.0f, 600.0f)];
		_loadingMoreView.backgroundColor = [UIColor clearColor];
		[self.tableView addSubview:_loadingMoreView];
		self.tableView.showsVerticalScrollIndicator = YES;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
	if (scrollView.isDragging) {
        float endOfTable = [self endOfTableView:scrollView];
        if (_loadingMoreView.state == EGOOPullRefreshPulling && endOfTable < 0.0f && endOfTable > -65.0f && !_loadingMore) {
			[_loadingMoreView setState:EGOOPullRefreshNormal];
		} else if (_loadingMoreView.state == EGOOPullRefreshNormal && endOfTable < -65.0f && !_loadingMore) {
			[_loadingMoreView setState:EGOOPullRefreshPulling];
		}
	}
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset {
    //NSLog(@"scrollViewWillEndDragging");
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
    if ([self endOfTableView:scrollView] <= -65.0f && !_loadingMore) {
        _loadingMore = YES;
        [self loadmore:nil];
        [_loadingMoreView setState:EGOOPullRefreshLoading];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.2];
        //UIEdgeInsets edgeInset = UIEdgeInsetsMake(0.0f, 0.0f, 60.0f, 0.0f);
        // -70大概是一个cell的高, 此举可实现下拉刷新后上滚的效果
        UIEdgeInsets edgeInset = UIEdgeInsetsMake(-70.f, 0.0f, 60.0f, 0.0f);
        if (IOS7_OR_LATER) {
            edgeInset.top += 64.0f;
        }
        [self.tableView setContentInset:edgeInset];
        [UIView commitAnimations];
	}
}

- (void)loadMoreDone {
	
	_loadingMore = NO;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
    UIEdgeInsets edgeInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
    if (IOS7_OR_LATER) edgeInset.top = 64.0f;
	[self.tableView setContentInset:edgeInset];
	[UIView commitAnimations];
    
    if ([_loadingMoreView state] != EGOOPullRefreshNormal) {
        [_loadingMoreView setState:EGOOPullRefreshNormal];
    }
}

- (float)tableViewHeight {
    // return height of table view
    return [self.tableView contentSize].height;
}

- (float)endOfTableView:(UIScrollView *)scrollView {
    return [self tableViewHeight] - scrollView.bounds.size.height - scrollView.bounds.origin.y;
}



#pragma mark - MCSwipeTableViewCellDelegate

// When the user starts swiping the cell this method is called
- (void)swipeTableViewCellDidStartSwiping:(MCSwipeTableViewCell *)cell {
    //NSLog(@"Did start swiping the cell!");
}

// When the user ends swiping the cell this method is called
- (void)swipeTableViewCellDidEndSwiping:(MCSwipeTableViewCell *)cell {
    //NSLog(@"Did end swiping the cell!");
}

// When the user is dragging, this method is called and return the dragged percentage from the border
- (void)swipeTableViewCell:(MCSwipeTableViewCell *)cell didSwipWithPercentage:(CGFloat)percentage {
    //NSLog(@"Did swipe with percentage : %f", percentage);
}

- (void)addActionsForCell:(HPThreadCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [cell setDelegate:self];
    if (indexPath.row % 2 == 0) {
        [cell.contentView setBackgroundColor:[HPTheme oddCellColor]];
        [cell setDefaultColor:[HPTheme oddCellColor]];
    } else {
        [cell.contentView setBackgroundColor:[HPTheme evenCellColor]];
        [cell setDefaultColor:[HPTheme evenCellColor]];
    }
    
    cell.shouldAnimateIcons = YES;
    cell.firstTrigger = 0.18f;
    cell.secondTrigger = 0.40f;
    
    [cell setSwipeGestureWithView:[cell viewWithImageName:@"last.png"]
                            color:[HPTheme threadJumpColor]
                             mode:MCSwipeTableViewCellModeSwitch
                            state:MCSwipeTableViewCellState3
                  completionBlock:
     ^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
         
         HPThread *thread = [_threads objectAtIndex:[self.tableView indexPathForCell:cell].row];
         
         HPReadViewController *rvc = [[HPReadViewController alloc]
                                      initWithThread:thread
                                      page:NSIntegerMax
                                      forceFullPage:YES];
         
         [self.navigationController pushViewController:rvc animated:YES];
         
     }];
    
    [cell setSwipeGestureWithView:[cell viewWithImageName:@"clock.png"]
                            color:[HPTheme threadPreloadColor]
                             mode:MCSwipeTableViewCellModeSwitch
                            state:MCSwipeTableViewCellState4
                  completionBlock:
     ^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
         
         HPThread *thread = [_threads objectAtIndex:[self.tableView indexPathForCell:cell].row];
         NSLog(@"background open thread %@", thread.title);

         [(HPThreadCell *)cell markRead];
         [[HPCache sharedCache] readThread:thread.tid];
         [HPIndecator show];
         
         
         [[HPCache sharedCache] cacheBgThread:thread block:^(NSError *error) {
             [HPIndecator dismiss];
         }];
         
         
         if ([NSStandardUserDefaults boolForKey:kHPHomeTip4Bg or:YES]) {
             [UIAlertView showConfirmationDialogWithTitle:@"提示"
                                                  message:@"帖子已预载入\n在「待读」界面查看"
                                                  handler:^(UIAlertView *alertView, NSInteger buttonIndex)
              {
                  if (buttonIndex != [alertView cancelButtonIndex]) {
                      [NSStandardUserDefaults saveBool:NO forKey:kHPHomeTip4Bg];
                  }
              }];
         }
     }];
    
}


#pragma mark - actions
- (void)revealToggle:(id)sender {
    
    //NSLog(NSStringFromUIEdgeInsets(self.tableView.contentInset));
    [self.revealViewController revealToggle:sender];
}

- (void)newThread:(id)sender {

    HPNewThreadViewController *tvc = [[HPNewThreadViewController alloc] initWithFourm:_current_fid delegate:self];
    
    [self presentViewController:[HPCommon NVCWithRootVC:tvc] animated:YES completion:nil];
}

- (void)compositionDoneWithType:(ActionType)type error:(NSError *)error {
    [self refresh:[UIButton new]];
}

#pragma mark - login

- (void)loginError:(NSNotification *)notification
{
    NSError *error = [[notification userInfo] objectForKey:@"error"];
    [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
}

- (void)loginSuccess:(NSNotification *)notification
{
    [SVProgressHUD showSuccessWithStatus:@"登陆成功"];
    [self refresh:[UIButton new]];
}

#pragma mark - 
- (void)applicationDidBecomeActiveNotification:(NSNotification *)notification {
    
    // bgfetch
    if (_lastBgFetchDate) {
        
        NSDate *now = [NSDate new];
        NSTimeInterval interval = [now timeIntervalSinceDate:_lastBgFetchDate];
        NSString *tip = nil;
        if (interval < 60) {
            tip = S(@"已在%ds前更新", (int)interval);
        } else {
            tip = S(@"已于%d分钟前更新", (int)(interval/60));
        }
        [ZAActivityBar showSuccessWithStatus:tip];
        //[SVProgressHUD showSuccessWithStatus:S(@"now : %@\nlast : %@\ninterval : %d", now, _lastBgFetchDate, (int)ceil(interval/60.f))];
        
        _lastBgFetchDate = nil;
    }
}

#pragma mark - test
// test
- (void)logout:(id)sender {
    NSLog(@"logout");
    [[HPAccount sharedHPAccount] logout];
}


#pragma mark - theme
- (void)themeDidChanged {
    [self setActionButton];
    [self.tableView reloadData];
    [self.tableView setBackgroundColor:[HPTheme backgroundColor]];
}

@end
