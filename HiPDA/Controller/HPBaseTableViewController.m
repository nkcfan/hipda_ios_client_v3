//
//  HPBaseTableViewController.m
//  HiPDA
//
//  Created by wujichao on 14-3-8.
//  Copyright (c) 2014年 wujichao. All rights reserved.
//

#import "HPBaseTableViewController.h"
#import "SWRevealViewController.h"
#import "UIImage+Color.h"
#import "UIColor+iOS7Colors.h"
#import <SVProgressHUD.h>
#import "HPRearViewController.h"
#import "UIBarButtonItem+ImageItem.h"


@interface HPBaseTableViewController ()

@end

@implementation HPBaseTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)addGuesture {
    SWRevealViewController *revealController = [self revealViewController];
    [self.navigationController.view addGestureRecognizer:revealController.panGestureRecognizer];
}

- (void)removeGuesture {
    SWRevealViewController *revealController = [self revealViewController];
    [self.navigationController.view removeGestureRecognizer:revealController.panGestureRecognizer];
}

- (void)addRefreshControl {
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                            action:@selector(refresh:)
                  forControlEvents:UIControlEventValueChanged];
}

- (UIBarButtonItem *)addPageControlBtn {
    UIImage *up = [[UIImage imageNamed:@"up.png"] changeColor:[UIColor iOS7darkBlueColor]];
    UIImage *down = [[UIImage imageNamed:@"down.png"] changeColor:[UIColor iOS7darkBlueColor]];
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:@[up, down]];
	[segmentedControl addTarget:self action:@selector(segmentChanged:) forControlEvents:UIControlEventValueChanged];
	segmentedControl.frame = CGRectMake(0, 0, 90, 30.f);
	segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
	segmentedControl.momentary = YES;
    
	UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
	self.navigationItem.rightBarButtonItem = segmentBarItem;
    
    return segmentBarItem;
}

- (UIBarButtonItem *)addRevealActionBI {
    // revealButton
    
    SWRevealViewController *revealController = [self revealViewController];
    
    UIBarButtonItem *revealButtonItem = [UIBarButtonItem barItemWithImage:[UIImage imageNamed:@"menu2.png"]
                                                             size:CGSizeMake(40.f, 40.f)
                                                           target:revealController
                                                           action:@selector(revealToggle:)];
    
    self.navigationItem.leftBarButtonItem = revealButtonItem;
     
    return revealButtonItem;
}

- (UIBarButtonItem *)addCloseBI {
    UIBarButtonItem *closeBI = [
                                         [UIBarButtonItem alloc] initWithTitle:@"关闭"
                                         style:UIBarButtonItemStylePlain
                                         target:self action:@selector(close:)];
    self.navigationItem.leftBarButtonItem = closeBI;
    return closeBI;
}

#pragma mark -

- (void)refresh:(id)sender {
    ;
}

- (void)showRefreshControl {
    CGFloat offset = IOS7_OR_LATER ? 64.f:0.f;
    [self.refreshControl beginRefreshing];
    if (self.tableView.contentOffset.y == -offset) {
        [UIView animateWithDuration:0.1
                              delay:0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^(void){
                             
                             self.tableView.contentOffset = CGPointMake(0, -self.refreshControl.frame.size.height - offset);
                             
                         } completion:^(BOOL finished){
                             
                         }];
    }
}

- (void)setup {
    assert(0);
}

- (void)ayscn:(id)sender {
    assert(0);
}

- (void)prevPage:(id)sender {
    assert(0);
}

- (void)nextPage:(id)sender {
    assert(0);
}


#pragma mark - common actions

- (void)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        ;
    }];
}


- (void)segmentChanged:(UISegmentedControl *)sender {
    switch (sender.selectedSegmentIndex) {
        case 0:
            [self prevPage:nil];
            break;
        case 1:
            [self nextPage:nil];
            break;
        default:
            break;
    }
    
    if ( !IOS7_OR_LATER ) {
        [sender setSelectedSegmentIndex:UISegmentedControlNoSegment];
    }
}

#pragma mark - login

- (void)loginError:(NSNotification *)notification
{
    NSError *error = [[notification userInfo] objectForKey:@"error"];
    [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
}

- (void)loginSuccess:(NSNotification *)notification
{
    //[SVProgressHUD showWithStatus:@"loginSuccess"];
    //[self ayscn:nil];
}

@end
