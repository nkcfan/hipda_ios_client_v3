//
//  HPBaseCompostionViewController.h
//  HiPDA
//
//  Created by wujichao on 14-3-5.
//  Copyright (c) 2014年 wujichao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPSendPost.h"
#import "HPViewController.h"

@protocol HPCompositionDoneDelegate <NSObject>
@required
- (void)compositionDoneWithType:(ActionType)type error:(NSError *)error;
@end

@interface HPBaseCompostionViewController : HPViewController

@property (nonatomic, strong) UIActivityIndicatorView *indicator;

@property (nonatomic, strong) id <HPCompositionDoneDelegate> delegate;
@property ActionType actionType;
//@property (nonatomic, strong)NSString *content;
@property (nonatomic, strong) UITextView *contentTextFiled;
@property (nonatomic, strong) NSMutableArray *imagesString;


- (void)doneWithError:(NSError *)error;

@end
