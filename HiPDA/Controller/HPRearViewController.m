//
//  HPRearViewController.m
//  HiPDA
//
//  Created by wujichao on 14-3-18.
//  Copyright (c) 2014年 wujichao. All rights reserved.
//

#import "HPSetting.h"
#import "HPTheme.h"
#import "HPRearCell.h"
#import "HPAccount.h"

#import "HPRearViewController.h"
#import "SWRevealViewController.h"

#import "HPThreadViewController.h"
#import "HPMessageViewController.h"
#import "HPMyNoticeViewController.h"
#import "HPBackgroundViewController.h"
#import "HPFavoriteViewController.h"
#import "HPMyThreadViewController.h"
#import "HPMyReplyViewController.h"
#import "HPSearchViewController.h"
#import "HPSettingViewController.h"

#import "NSUserDefaults+Convenience.h"
#import "UIAlertView+Blocks.h"
#import <SVProgressHUD.h>
#import "BBBadgeBarButtonItem.h"

#define TOP_CELL_HEIGHT ((IOS7_OR_LATER) ? 64.f : 44.f )
#define TAG_OVERVIEW 1011


@interface HPRearViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong)UITableView *tableView;

@property (nonatomic, strong)NSMutableArray *vc_instances;
@property (nonatomic, strong)NSArray *vc_classes;
@property (nonatomic, strong)NSArray *vc_names;

@property (nonatomic, assign)NSInteger current_fid;
@property (nonatomic, strong)NSString *current_title;
@property (nonatomic, strong)NSArray *fids;
@property (nonatomic, strong)NSArray *fids_title;

@property (nonatomic, strong)UITableViewCell *topCell;

@property (nonatomic, strong)HPThreadViewController *threadViewController;
@property (nonatomic, strong)UINavigationController *threadNavViewController;

@property (nonatomic, strong)BBBadgeBarButtonItem *revealBI;

@end

@implementation HPRearViewController

+ (HPRearViewController*)sharedRearVC {
    static dispatch_once_t once;
    static HPRearViewController *sharedRearVC;
    dispatch_once(&once, ^ {
        sharedRearVC = [[self alloc] init];
        [sharedRearVC setup];
    });
    return sharedRearVC;
}

- (void)setup {
    _vc_classes = @[[HPThreadViewController class],
                    [HPMessageViewController class],
                    [HPMyNoticeViewController class],
                    [HPMyThreadViewController class],
                    [HPMyReplyViewController class],
                    [HPFavoriteViewController class],
                    [HPBackgroundViewController class],
                    ];
    
    _vc_names = @[@"HOME",
                  @"短消息",
                  @"帖子消息",
                  @"我的帖子",
                  @"我的回帖",
                  @"收藏",
                  @"待读"];
    
    _vc_instances = [NSMutableArray arrayWithCapacity:_vc_classes.count];
    for (int i = 0; i < _vc_classes.count; i++) {
        [_vc_instances addObject:[NSNull null]];
    }
    
    
    _fids = [Setting objectForKey:HPSettingFavForums];
    _fids_title = [Setting objectForKey:HPSettingFavForumsTitle];
    _current_fid = [[_fids objectAtIndex:0] integerValue];
    _current_title = [_fids_title objectAtIndex:0];
    
    
    _threadViewController = [[HPThreadViewController alloc] initDefaultForum:_current_fid title:_current_title];
    _threadNavViewController = [[UINavigationController alloc] initWithRootViewController:_threadViewController];
    NSLog(@"%@", _fids);
}


- (id)vcAtIndex:(NSUInteger)index {
    
    if(index == 0) return _threadViewController;
    
    id vc = _vc_instances[index];
    if (vc == [NSNull null]) {
        NSLog(@"new %@", _vc_classes[index]);
        Class C = _vc_classes[index];
        vc = [[C alloc] init];
        [_vc_instances replaceObjectAtIndex:index withObject:vc];
    }
    return vc;
}

/*
+ (HPThreadViewController *)threadViewController {
    return [[HPRearViewController sharedRearVC] threadViewController];
}
*/
+ (UINavigationController *)threadNavViewController {
    return [[HPRearViewController sharedRearVC] threadNavViewController];
}

+ (void)threadVCRefresh {
    [[[HPRearViewController sharedRearVC] threadViewController] refresh:[UIButton new]];
}


#pragma mark - life cycle

- (void)viewDidLoad
{
    NSLog(@"viewDidLoad");
    [super viewDidLoad];
	
    _tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];

    /*
    tableView.rowHeight = 45;
    tableView.sectionFooterHeight = 22;
    tableView.sectionHeaderHeight = 22;
    tableView.scrollEnabled = YES;
    tableView.showsVerticalScrollIndicator = YES;
    tableView.userInteractionEnabled = YES;
    tableView.bounces = YES;
     */
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [self.view addSubview:_tableView];
    
    
    self.tableView.backgroundColor = rgb(26.f, 26.f, 26.f);

    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    
    NSLog(@"rear did load done");
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return _vc_classes.count + _fids.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"menuCell";
	HPRearCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
	if (nil == cell)
	{
		cell = [[HPRearCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
	}
    
   
    NSInteger row = indexPath.row;
    if (row == 0) {
        
        return [self topCell];
        
    } else if (row > 0 && row < _vc_names.count){
        //cell.textLabel.text = _vc_names[indexPath.row];
        
        
        [cell configure:_vc_names[indexPath.row]];
        
        NSInteger pm_count = [Setting integerForKey:HPPMCount];
        NSInteger notice_count = [Setting integerForKey:HPNoticeCount];
        
        if (row == 1) {
            if (pm_count > 0) {
                [cell showNumber:pm_count];
            } else {
                [cell hideNumber];
            }
        } else if (row == 2){
            if (notice_count > 0) {
                [cell showNumber:notice_count];
            } else {
                [cell hideNumber];
            }
        }
        
    } else if (row == _vc_names.count){
        static UITableViewCell *placeholderCell = nil;
        if (!placeholderCell) {
            placeholderCell = [UITableViewCell new];
            placeholderCell.backgroundColor = rgb(26.f, 26.f, 26.f);
            placeholderCell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        return placeholderCell;
    } else {
        //cell.textLabel.text = _fids_title[row - _vc_names.count - 1];
        [cell configure:_fids_title[row - _vc_names.count - 1]];
        
        static BOOL first = YES;
        if (first && row == _vc_names.count+1) {
            [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition: UITableViewScrollPositionNone];
            
            first = NO;
        }
    }
    
    if (IOS7_OR_LATER) {
        //cell.separatorInset =  UIEdgeInsetsMake(0, 0, 0, 1000);
    }
    
    
    /*
    cell.backgroundColor = [HPTheme backgroundColor];
    cell.textLabel.textColor = [HPTheme textColor];
     */
    //cell.backgroundColor = rgb(38.f, 38.f, 38.f);
    //cell.textLabel.textColor = rgb(186.f, 186.f, 186.f);

	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        return TOP_CELL_HEIGHT;
    } else if (indexPath.row == _vc_classes.count){
        
        CGFloat screent_height = self.view.bounds.size.height;
        CGFloat other_hight_sum = TOP_CELL_HEIGHT + (_vc_classes.count-1)*44.f + _fids.count*44.f;
        
        return MAX(screent_height - other_hight_sum, 0.f);
        
    } else {
        return 44.f;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SWRevealViewController *revealController = self.revealViewController;
    UINavigationController *frontNavigationController = (id)revealController.frontViewController;
    NSInteger row = indexPath.row;
    
    if (row == 0) {
        
    } else if (row < _vc_classes.count) {
        if ( ![frontNavigationController.topViewController isKindOfClass:_vc_classes[row]] )
        {
            id vc = [self vcAtIndex:row];
            [revealController setFrontViewController:[HPCommon NVCWithRootVC:vc] animated:YES];
            [vc performSelector:@selector(refresh:) withObject:nil afterDelay:0.1f];
        }
        else
        {
            [revealController revealToggle:self];
            [frontNavigationController.topViewController performSelector:@selector(refresh:) withObject:nil afterDelay:0.1f];
        }
    } else if (row == _vc_classes.count) {
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
    } else {
        
        NSInteger index = row - _vc_names.count - 1;
        
        if ( ![frontNavigationController.topViewController isKindOfClass:_vc_classes[0]] )
        {
            /*
            HPThreadViewController *threadVC = [self vcAtIndex:0];
            UINavigationController *navigationController = [HPCommon NVCWithRootVC:threadVC];
            
            
            _current_fid = [_fids[index] integerValue];
            _current_title = _fids_title[index];
            
            [revealController setFrontViewController:navigationController animated:YES];
            [threadVC loadForum:_current_fid title:_current_title];
             */
            
            UINavigationController *navigationController = [self threadNavViewController];
            
            NSInteger fid = [_fids[index] integerValue];
            if (_current_fid != fid) {
                navigationController.viewControllers = @[_threadViewController];
                
                _current_fid = [_fids[index] integerValue];
                _current_title = _fids_title[index];
                [_threadViewController loadForum:_current_fid title:_current_title];
            }
            
            [revealController setFrontViewController:navigationController animated:YES];
        }
        else
        {
            NSInteger fid = [_fids[index] integerValue];
            if (_current_fid != fid) {
                
                _current_fid = fid;
                _current_title = _fids_title[index];
                HPThreadViewController *threadVC = [self vcAtIndex:0];
                [threadVC loadForum:_current_fid title:_current_title];
            }
            [revealController revealToggle:self];
        }
    }
}

#pragma mark -

- (void)switchToMessageVC {
    [self switchToVC:1];
}

- (void)switchToNoticeVC {
    [self switchToVC:2];
}

- (void)switchToVC:(NSInteger)row
{
    SWRevealViewController *revealController = self.revealViewController;
    UINavigationController *frontNavigationController = (id)revealController.frontViewController;
   
    if ( ![frontNavigationController.topViewController isKindOfClass:_vc_classes[row]] )
    {
        id vc = [self vcAtIndex:row];
        [revealController setFrontViewController:[HPCommon NVCWithRootVC:vc] animated:YES];
        [vc performSelector:@selector(refresh:) withObject:nil afterDelay:0.1f];
    }
    else
    {
        //[revealController revealToggle:self];
        [frontNavigationController.topViewController performSelector:@selector(refresh:) withObject:nil afterDelay:0.1f];
    }
}

#pragma mark - cells

- (UITableViewCell *)topCell {
    if (_topCell) return _topCell;
    
    
    CGFloat dy = IOS7_OR_LATER ? 20.f : 0.f;
    
    _topCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"topCell"];
    [_topCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    

    /*
    UILabel *label = [UILabel new];
    [_topCell.contentView addSubview:label];
    label.text = @"Hi";
    label.textColor = rgb(186.f, 186.f, 186.f);
    label.font = [UIFont fontWithName:@"STHeitiSC-Light" size:18.f];
    [label sizeToFit];
    label.center = CGPointMake(50, dy+23.f);
     */
    UIView *m = [UIView new];
    m.backgroundColor = rgb(186.f, 186.f, 186.f);
    m.frame = CGRectMake(42, dy+33.f, 10, 2);
    [_topCell.contentView addSubview:m];

    
    UIButton *settingB = [[UIButton alloc] init];
    [_topCell.contentView addSubview:settingB];
    [settingB addTarget:self action:@selector(showSettingVC:) forControlEvents:UIControlEventTouchUpInside];
    [settingB setImage:[UIImage imageNamed:@"settings.png"] forState:UIControlStateNormal];
    [settingB setImage:[UIImage imageNamed:@"settings_highlight.png"] forState:UIControlStateHighlighted];
    settingB.showsTouchWhenHighlighted = YES;
    [settingB sizeToFit];
    settingB.center = CGPointMake(20, dy+23.f);
    
    UIButton *searchB = [[UIButton alloc] init];
    [_topCell.contentView addSubview:searchB];
    [searchB addTarget:self action:@selector(showSearchVC:) forControlEvents:UIControlEventTouchUpInside];
    [searchB setImage:[UIImage imageNamed:@"search.png"] forState:UIControlStateNormal];
    [settingB setImage:[UIImage imageNamed:@"search_highlight.png"] forState:UIControlStateHighlighted];
    searchB.showsTouchWhenHighlighted = YES;
    [searchB sizeToFit];
    searchB.center = CGPointMake(70, dy+23.f);
    
    _topCell.backgroundColor = rgb(26.f, 26.f, 26.f);
    
    return _topCell;
}

#pragma mark - actions

- (void)showSettingVC:(id)sender {
    
    HPSettingViewController *settingVC = [HPSettingViewController new];
    [self presentViewController:[HPCommon NVCWithRootVC:settingVC] animated:YES completion:nil];
}

- (void)showSearchVC:(id)sender {
    
    HPSearchViewController *searchVC = [HPSearchViewController new];
    [self presentViewController:[HPCommon NVCWithRootVC:searchVC] animated:YES completion:nil];
}

#pragma mark - 
- (UIBarButtonItem *)sharedRevealActionBI {
    
    if (_revealBI) return _revealBI;
    
    
    UIButton *revealButton = [UIButton buttonWithType:UIButtonTypeCustom];
    revealButton.bounds = CGRectMake(0, 0, 40.f, 40.f);
    [revealButton setImage:[UIImage imageNamed:@"menu2.png"] forState:UIControlStateNormal];
    [revealButton addTarget:[self revealViewController] action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    
    _revealBI = [[BBBadgeBarButtonItem alloc] initWithCustomUIButton:revealButton];
    _revealBI.badgeValue = S(@"%ld", [[HPAccount sharedHPAccount] badgeNumber]);
    
    _revealBI.badgeBGColor   = [UIColor redColor];
    _revealBI.badgeTextColor = [UIColor whiteColor];
    _revealBI.badgeFont      = [UIFont systemFontOfSize:10.0];
    _revealBI.badgePadding   = 1;
    _revealBI.badgeMinSize   = 6;
    _revealBI.badgeOriginX = 22;
    _revealBI.badgeOriginY = 4;
    
    return _revealBI;
}

- (void)updateBadgeNumber {
    
    // a
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[[HPAccount sharedHPAccount] badgeNumber]];
    
    // b
    _revealBI.badgeValue = S(@"%ld", [[HPAccount sharedHPAccount] badgeNumber]);

    // c
    [self.tableView reloadData];
    
}


#pragma mark - 
- (void)forumDidChanged {
    
    
    
    _fids = [Setting objectForKey:HPSettingFavForums];
    _fids_title = [Setting objectForKey:HPSettingFavForumsTitle];
    [_tableView reloadData];
}

#pragma mark - theme
- (void)themeDidChanged {
    
    [_threadViewController themeDidChanged];
    
    [self.tableView reloadData];
    
    for (id vc in _vc_instances) {
        if (vc != [NSNull null])
            [vc performSelector:@selector(themeDidChanged) withObject:nil];
    }
    
    if ([Setting boolForKey:HPSettingNightMode]) {
        [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    } else {
        [[UINavigationBar appearance] setBarStyle:UIBarStyleDefault];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }
    
}



#pragma mark - SWRevealViewControllerDelegate
/*
 https://github.com/John-Lluch/SWRevealViewController/issues/63
 */
- (void)revealController:(SWRevealViewController *)revealController didMoveToPosition:(FrontViewPosition)position
{
    UIView *frontView = nil;
    UINavigationController *frontNC = (UINavigationController *)revealController.frontViewController;
    if (frontNC.viewControllers.count > 1) {
        return;
    } else {
        //frontView = frontNC.topViewController.view;
        frontView = frontNC.topViewController.navigationController.view;
    }
    
    if (revealController.frontViewPosition == FrontViewPositionRight) {
        
        UIView *existingOverView = (UIView *)[frontView viewWithTag:TAG_OVERVIEW];
        if (!existingOverView) {
            NSLog(@"new");
            UIView *overView = [[UIView alloc]initWithFrame:frontView.bounds];
            overView.tag = TAG_OVERVIEW;
            
            /*
            overView.backgroundColor = [UIColor blackColor];
            overView.alpha = .0f;
            */
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:revealController action:@selector(revealToggle:)];
            [overView addGestureRecognizer:tap];
            
            
            existingOverView = overView;
        }
        
        
        [frontView addSubview:existingOverView];
        
        /*
        existingOverView.alpha = 0.f;
        [UIView animateWithDuration:.3f animations:^{
           existingOverView.alpha = 0.1;
        }];
         */
        
        //在navi上加上panGesture 就不用再
        //[existingOverView addGestureRecognizer:revealController.panGestureRecognizerCopy];
        
    }
    else {
        
        UIView *existingOverView = (UIView *)[frontView viewWithTag:TAG_OVERVIEW];
        if (existingOverView) {
            [existingOverView removeFromSuperview];
            
            /*
            [UIView animateWithDuration:.3f animations:^{
                existingOverView.alpha = 0.f;
            }];
             */
            
        }
        //[frontView addGestureRecognizer:revealController.panGestureRecognizer];
    }
}


/*
- (void)revealController:(SWRevealViewController *)revealController willMoveToPosition:(FrontViewPosition)position {
    ;
}

// This will be called inside the reveal animation, thus you can use it to place your own code that will be animated in sync
- (void)revealController:(SWRevealViewController *)revealController animateToPosition:(FrontViewPosition)position {
    ;
}

// Implement this to return NO when you want the pan gesture recognizer to be ignored
- (BOOL)revealControllerPanGestureShouldBegin:(SWRevealViewController *)revealController {
    
    NSLog(@"revealControllerPanGestureShouldBegin");
    
    UINavigationController *frontNC = (UINavigationController *)revealController.frontViewController;
    if (frontNC.viewControllers.count == 1 && [frontNC.topViewController respondsToSelector:@selector(revealControllerPanGestureShouldBegin:)]) {
        NSLog(@"revealControllerPanGestureShouldBegin");
        
        return (BOOL)[frontNC.topViewController performSelector:@selector(revealControllerPanGestureShouldBegin:) withObject:revealController];
    }
    
    return YES;
}

// Called when the gestureRecognizer began and ended
- (void)revealControllerPanGestureBegan:(SWRevealViewController *)revealController {
    ;
}
- (void)revealControllerPanGestureEnded:(SWRevealViewController *)revealController {
    ;
}


// The following methods provide a means to track the evolution of the gesture recognizer.
// The 'location' parameter is the X origin coordinate of the front view as the user drags it
// The 'progress' parameter is a positive value from 0 to 1 indicating the front view location relative to the
// rearRevealWidth or rightRevealWidth. 1 is fully revealed, dragging ocurring in the overDraw region will result in values above 1.
- (void)revealController:(SWRevealViewController *)revealController panGestureBeganFromLocation:(CGFloat)location progress:(CGFloat)progress;
- (void)revealController:(SWRevealViewController *)revealController panGestureMovedToLocation:(CGFloat)location progress:(CGFloat)progress;
- (void)revealController:(SWRevealViewController *)revealController panGestureEndedToLocation:(CGFloat)location progress:(CGFloat)progress;
*/
@end
