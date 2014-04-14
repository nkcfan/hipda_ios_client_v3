//
//  HPViewController.m
//  HiPDA
//
//  Created by wujichao on 14-3-20.
//  Copyright (c) 2014年 wujichao. All rights reserved.
//

#import "HPViewController.h"

@interface HPViewController ()

@end

@implementation HPViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSLog(@"%@ add Login/out Notification", self.class);
    
    //
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess:) name:kHPUserLoginSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginError:) name:kHPUserLoginError object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    NSLog(@"%@ remove Login/out Notification", self.class);
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHPUserLoginSuccess object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHPUserLoginError object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loginError:(NSNotification *)notification
{
    ;
}

- (void)loginSuccess:(NSNotification *)notification
{
    ;
}

#pragma mark - theme
- (void)themeDidChanged {
    ;
}

@end


#pragma mark - HPTableViewController

@interface HPTableViewController ()

@end

@implementation HPTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSLog(@"%@ add Login/out Notification", self.class);
    
    //
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess:) name:kHPUserLoginSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginError:) name:kHPUserLoginError object:nil];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    NSLog(@"%@ remove Login/out Notification", self.class);
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHPUserLoginSuccess object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHPUserLoginError object:nil];
}



- (void)loginError:(NSNotification *)notification
{
    ;
}

- (void)loginSuccess:(NSNotification *)notification
{
    ;
}

#pragma mark - theme
- (void)themeDidChanged {
    ;
}

- (void)dealloc
{
    NSLog(@"%@ dealloc", self.class);
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHPUserLoginSuccess object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHPUserLoginError object:nil];
}

@end
