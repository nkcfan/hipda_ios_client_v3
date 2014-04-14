//
//  HPBaseCompostionViewController.m
//  HiPDA
//
//  Created by wujichao on 14-3-5.
//  Copyright (c) 2014年 wujichao. All rights reserved.
//

#import "HPBaseCompostionViewController.h"
#import "HPImageUploadViewController.h"
#import "SWRevealViewController.h"

#import "WUDemoKeyboardBuilder.h"

#import "UIButton+Additions.h"
#import "UIImageView+Additions.h"
#import "HPTheme.h"
#import "HPSetting.h"


#define TOOLBAR_HEIGHT 40.f

@interface HPBaseCompostionViewController () <UITextViewDelegate, HPImageUploadDelegate>



@end

@implementation HPBaseCompostionViewController {
    
    UIView *toolbar;
    UIButton *photoBnt;
    UIButton *emotionBnt;
    UIButton *mentionBnt;
    UIActivityIndicatorView *tokenIndicator;
    UILabel *tokenLabel;
    
}

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
    
    _contentTextFiled = [[UITextView alloc] initWithFrame:self.view.bounds];
    _contentTextFiled.font = [UIFont systemFontOfSize:16.0f];
    _contentTextFiled.delegate = self;
    _contentTextFiled.text = @"content here...";
    _contentTextFiled.keyboardAppearance = [HPTheme keyboardAppearance];

    
    UIColor *backgroudColor = [HPTheme backgroundColor];
    if (![Setting boolForKey:HPSettingNightMode]) {
        _contentTextFiled.textColor = [UIColor blackColor];
        
    } else {
        _contentTextFiled.textColor = [UIColor colorWithRed:109.f/255.f green:109.f/255.f blue:109.f/255.f alpha:1.f];
    }
  
    _contentTextFiled.backgroundColor = backgroudColor;
    [self.view addSubview:_contentTextFiled];
    
    [self.view setBackgroundColor:[HPTheme backgroundColor]];
    
    toolbar = [[UIView alloc] init];
    toolbar.backgroundColor = backgroudColor;
    toolbar.userInteractionEnabled = YES;
    [self.view addSubview:toolbar];
    
    
    UIImage *separator_img = [UIImage imageNamed:@"compose_section_sp"];
    UIImageView *separator = [[UIImageView alloc] initWithImage:separator_img];
    separator.frame = CGRectMake(0, 0, separator_img.size.width - 10, separator_img.size.height);
    [toolbar addSubview:separator];
    
    
    photoBnt = [[UIButton alloc] init];
    [toolbar addSubview:photoBnt];
    [photoBnt addTarget:self action:@selector(photoButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    [photoBnt setImage:[UIImage imageNamed:@"compose_camera"] forState:UIControlStateNormal];
    photoBnt.showsTouchWhenHighlighted = YES;
    [photoBnt sizeToFit];
    photoBnt.center = CGPointMake(25, 20);
    photoBnt.hitTestEdgeInsets = UIEdgeInsetsMake(0, -5, 0, -5);
    
    emotionBnt = [[UIButton alloc] init];
    [toolbar addSubview:emotionBnt];
    [emotionBnt setTapTarget:self action:@selector(emotionButtonTouched)];
    [emotionBnt setImage:[UIImage imageNamed:@"compose_emotion"] forState:UIControlStateNormal];
    
    emotionBnt.showsTouchWhenHighlighted = YES;
    [emotionBnt sizeToFit];
    emotionBnt.center = CGPointMake(75, 20);
    emotionBnt.hitTestEdgeInsets = UIEdgeInsetsMake(0, -5, 0, -5);
    
    mentionBnt = [[UIButton alloc] init];
    //[toolbar addSubview:mentionBnt];
    [mentionBnt setTapTarget:self action:@selector(mentionButtonTouched)];
    [mentionBnt setImage:[UIImage imageNamed:@"compose_at"] forState:UIControlStateNormal];
    mentionBnt.showsTouchWhenHighlighted = YES;
    [mentionBnt sizeToFit];
    mentionBnt.center = CGPointMake(125, 20);
    mentionBnt.hitTestEdgeInsets = UIEdgeInsetsMake(0, -5, 0, -5);
    
    
    /*
    tokenLabel = [UILabel new];
    tokenLabel.text = @"正在获取Token...";
    tokenLabel.textColor = [UIColor colorWithRed:97.f/255.f green:103.f/255.f blue:108.f/255.f alpha:1.f];
    [tokenLabel sizeToFit];
    CGRect frame = tokenLabel.frame;
    frame.origin.y = 10.f;
    frame.origin.x = self.view.frame.size.width - frame.size.width - 5.f;
    tokenLabel.frame = frame;
    [toolbar addSubview:tokenLabel];

    tokenIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    frame = tokenIndicator.frame;
    frame.origin.y = 10.f;
    frame.origin.x = tokenLabel.frame.origin.x - 25.f;
    tokenIndicator.frame = frame;
    [toolbar addSubview:tokenIndicator];
    tokenIndicator.hidesWhenStopped = NO;
    */
     
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
    
    /*
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    */
    
    _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    //_indicator.hidesWhenStopped = NO;
    
    UIBarButtonItem *indicatorBtn = [[UIBarButtonItem alloc] initWithCustomView:_indicator];
    
    UIBarButtonItem *sendBtn = [[UIBarButtonItem alloc]
                                initWithTitle:@"发送"
                                style:UIBarButtonItemStylePlain target:self action:@selector(send:)];
    
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc]
                                  initWithTitle:@"取消"
                                  style:UIBarButtonItemStylePlain target:self action:@selector(cancelCompose:)];
    
    [[self navigationItem] setRightBarButtonItems:@[sendBtn,indicatorBtn]];
    self.navigationItem.leftBarButtonItem = cancelBtn;
}


-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - actions

- (void)send:(id)sender {
    
    NSLog(@"send: need implement");
    assert(0);
}

- (void)doneWithError:(NSError *)error {
    
    [self close:nil];
    NSLog(@"doneWithError %@", [error localizedDescription]);
    [self.delegate compositionDoneWithType:_actionType error:error];
}

- (void)addImage:(id)sender {
    
    HPImageUploadViewController *ivc = [[HPImageUploadViewController alloc] init];
    ivc.delegate = self;
    [self presentViewController:[HPCommon NVCWithRootVC:ivc] animated:YES completion:nil];
}

- (void)close:(id)sender {
    [self cancelCompose:nil];
}

- (void)cancelCompose:(id)sender {
    
    // todo draft
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - imageUploadDelegate

- (void)completeWithAttachString:(NSString *)string error:(NSError *)error {
    
    NSString *text = _contentTextFiled.text;
    _contentTextFiled.text = [NSString stringWithFormat:@"%@[attachimg]%@[/attachimg]", text, string];
    
    // add to images array
    if (!_imagesString) {
        _imagesString = [NSMutableArray arrayWithCapacity:3];
    }
    [_imagesString addObject:string];
    
    NSLog(@"completeWithAttachString %@", string);
}


#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    NSLog(@"textViewDidBeginEditing");
    if ([_contentTextFiled.text isEqualToString:@"content here..."]) {
        textView.text = @"";
        
        // dark
        //textView.textColor = [UIColor blackColor];
    }
}


#pragma mark - keyborad

// keyborad height
- (void)keyboardWasShown:(NSNotification *)notification
{
    
    // Get the size of the keyboard.
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    //NSLog(@"height %f", keyboardSize.height);
    
    //CGFloat toolbar_height = 40;
    //toolbar.frame = CGRectMake(0, contentTV.bottom, self.view.width, toolbar_height);
    
    
    [UIView animateWithDuration:0.2f animations:^{
        
        
        
        float height = [self.view bounds].size.height - _contentTextFiled.frame.origin.y - keyboardSize.height - TOOLBAR_HEIGHT;
        _contentTextFiled.frame =
        CGRectMake(_contentTextFiled.frame.origin.x,
                   _contentTextFiled.frame.origin.y,
                   _contentTextFiled.frame.size.width,
                   height);
        
        toolbar.frame = CGRectMake(0, _contentTextFiled.frame.origin.y + _contentTextFiled.frame.size.height, self.view.frame.size.width, TOOLBAR_HEIGHT);
    }];
}


- (void)photoButtonTouched {
    [self addImage:nil];
}

- (void)emotionButtonTouched {
    
    if (!self.contentTextFiled.emoticonsKeyboard) {
        [emotionBnt setImage:[UIImage imageNamed:@"compose_emotion_on"] forState:UIControlStateNormal];
    } else {
        [emotionBnt setImage:[UIImage imageNamed:@"compose_emotion"] forState:UIControlStateNormal];
    }
    
    if (self.contentTextFiled.isFirstResponder) {
        if (self.contentTextFiled.emoticonsKeyboard) [self.contentTextFiled switchToDefaultKeyboard];
        else [self.contentTextFiled switchToEmoticonsKeyboard:[WUDemoKeyboardBuilder sharedEmoticonsKeyboard]];
    } else {
        [self.contentTextFiled switchToEmoticonsKeyboard:[WUDemoKeyboardBuilder sharedEmoticonsKeyboard]];
        [self.contentTextFiled becomeFirstResponder];
    }
}

- (void)mentionButtonTouched {
    ;
}

@end
