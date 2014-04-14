//
//  HPSetForumsViewController.m
//  HiPDA
//
//  Created by wujichao on 13-12-7.
//  Copyright (c) 2013年 wujichao. All rights reserved.
//

#import "HPSetForumsViewController.h"
#import <SVProgressHUD.h>
#import "HPSetting.h"
#import "HPForum.h"

@interface HPSetForumsViewController ()

@property (strong, nonatomic) RETableViewManager *manager;
@property (strong, nonatomic) RETableViewSection *forumSection;

@property (strong, nonatomic) NSArray *allForums;

@property (strong, nonatomic) __block NSMutableArray *titles;

@end

@implementation HPSetForumsViewController

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

    self.title = @"板块设定";
    
    _titles = [NSMutableArray arrayWithArray:[Setting objectForKey:HPSettingFavForumsTitle]];
    _allForums = [HPForum forumsTitle];
    
    _manager = [[RETableViewManager alloc] initWithTableView:self.tableView delegate:self];
    
    _forumSection = [self addForumSection];
    [_manager addSection:_forumSection];
    
    UIBarButtonItem *addForumBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addForum:)];
    
    self.navigationItem.rightBarButtonItem = addForumBtn;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (RETableViewSection *)addForumSection {
    
    RETableViewSection *section = [RETableViewSection section];
    
    for (int i = 0; i < [_titles count]; i++ ) {
        //NSString *title = [NSString stringWithFormat:@"#%d", i+1];
        [section addItem:[self radioItemWithTitle:_titles[i] style:section.style]];
    }
    
    return section;
}


- (RERadioItem *)radioItemWithTitle:(NSString *)atitle style:(RETableViewCellStyle *)style {
    __typeof (&*self) __weak weakSelf = self;

    __block NSString *title = atitle;
    
    RERadioItem *radioItem = [RERadioItem itemWithTitle:nil value:title selectionHandler:^(RERadioItem *item) {
        [item deselectRowAnimated:YES];
        
        // Present options controller
        //
        RETableViewOptionsController *optionsController = [[RETableViewOptionsController alloc] initWithItem:item options:_allForums multipleChoice:NO completionHandler:^{
            //[weakSelf.navigationController popViewControllerAnimated:YES];
            
            if ([title isEqualToString:item.value]) {
                [weakSelf.navigationController popViewControllerAnimated:YES];
                return;
            }
            
            NSUInteger i = [_titles indexOfObject:title];
            if (i == NSNotFound) return;
            //NSLog(@"%@ %d", title, i);
            
            if ([item.value isEqualToString:@"删除该板块"]) {
                
                if (i == 0) {
                    [SVProgressHUD showErrorWithStatus:@"首页不可删哦"];
                    item.value = title;
                } else if (_titles.count <= 1) {
                    [SVProgressHUD showErrorWithStatus:@"至少选择一个版块"];
                    item.value = title;
                } else {
                    [_titles removeObjectAtIndex:i];
                    [item deleteRowWithAnimation:UITableViewRowAnimationFade];
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }

            } else {
                
                if ([_titles indexOfObject:item.value] == NSNotFound) {
                    [_titles replaceObjectAtIndex:i withObject:item.value];
                    title = item.value;
                    [item reloadRowWithAnimation:UITableViewRowAnimationNone];
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                } else {
                    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"已有版块%@", item.value]];
                    item.value = title;
                }
            }
        }];
        
        // Adjust styles
        //
        optionsController.delegate = weakSelf;
        optionsController.style = style;
        if (weakSelf.tableView.backgroundView == nil) {
            optionsController.tableView.backgroundColor = weakSelf.tableView.backgroundColor;
            optionsController.tableView.backgroundView = nil;
        }
        
        // Push the options controller
        //
        [weakSelf.navigationController pushViewController:optionsController animated:YES];
    }];

    
    return radioItem;
}

- (void)save:(id)sender {
    NSLog(@"save %@", _titles);
    
    NSMutableArray *new_fids = [NSMutableArray arrayWithCapacity:10];
    for (NSString *key in _titles) {
        NSNumber *value = [[HPForum forumsDict] objectForKey:key];
        NSLog(@"save %@ %@", key,value);
        [new_fids addObject:value];
    }
    
    [Setting saveObject:new_fids forKey:HPSettingFavForums];
    [Setting saveObject:_titles forKey:HPSettingFavForumsTitle];
}



- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self save:nil];
}

- (void)addForum:(id)sender {
    
    // i = 0 @"删除该版块"
    for (int i=1; i < _allForums.count; i++) {
        NSString *title = _allForums[i];
        if ([_titles indexOfObject:title] == NSNotFound) {
            [_titles addObject:title];
            [_forumSection addItem:[self radioItemWithTitle:title style:_forumSection.style]];
            [_forumSection reloadSectionWithAnimation:UITableViewRowAnimationFade];
            break;
        }
    }
}


@end
