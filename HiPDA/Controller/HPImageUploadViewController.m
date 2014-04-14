//
//  HPImageUploadViewController.m
//  HiPDA
//
//  Created by wujichao on 14-3-28.
//  Copyright (c) 2014年 wujichao. All rights reserved.
//

#import "HPImageUploadViewController.h"

#import "HPAccount.h"
#import <QuartzCore/QuartzCore.h>
#import <SVProgressHUD.h>
#import "HPSendPost.h"
#import "HPTheme.h"
#import "HPSetting.h"

#import "UIImage+Resize.h"
#import "UIImage+fixOrientation.h"

#define kBoarderWidth 3.0
#define kCornerRadius 8.0

@interface HPImageUploadViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPopoverControllerDelegate>

@property (nonatomic, strong)UIImageView *imageView;
@property (nonatomic, strong)UIImage *image;
@property (nonatomic, strong)NSData *imageData;
@property NSInteger imageSize;

@property (nonatomic, assign)CGFloat targetSize;

@end

@implementation HPImageUploadViewController

- (id)init {
    
    self = [super init];
    if (self) {
        _targetSize = 600.f;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"上传图片";
    
    CGRect f = self.view.bounds;
    if (IOS7_OR_LATER) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        f.size.height -= 64.f;
    } else {
        f.size.height -= 44.f;
    }
    
    self.view.backgroundColor = [HPTheme backgroundColor];
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5.f, 5.f, f.size.width-10.f, f.size.height - 74.f - 12.f)];
    [self.view addSubview:_imageView];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [_imageView.layer setBorderColor:[rgb(205.f, 205.f, 205.f) CGColor]];
    [_imageView.layer setBorderWidth:.5f];
    
    UIView *container = [UIView new];
    container.frame = CGRectMake(0, f.size.height - 44, f.size.width, 44.f);
    container.backgroundColor = rgb(245.f, 245.f, 245.f);
    [self.view addSubview:container];
    
    UIView *line = [UIView new];
    line.backgroundColor = rgb(205.f, 205.f, 205.f);
    line.frame = CGRectMake(0, 0, container.frame.size.width, .5);
    [container addSubview:line];
    
    UISegmentedControl *segmentControl = [[UISegmentedControl alloc]initWithItems:@[@"~100kb",@"~200kb",@"~400kb", @"~600kb"]];
    [segmentControl setSegmentedControlStyle:UISegmentedControlStyleBar];
    [segmentControl sizeToFit];
    segmentControl.center = CGPointMake(container.frame.size.width - segmentControl.frame.size.width/2 - 5.f, container.frame.size.height /2 );
    [segmentControl addTarget:self action:@selector(segmentedControlValueDidChange:) forControlEvents:UIControlEventValueChanged];
    [segmentControl setSelectedSegmentIndex:1];
    [container addSubview:segmentControl];
    
    UILabel *label = [UILabel new];
    [container addSubview:label];
    label.text = @"大小";
    [label sizeToFit];
    label.backgroundColor = [UIColor clearColor];
    label.center = CGPointMake((container.frame.size.width - segmentControl.frame.size.width)/2.f, container.frame.size.height/2);
    
    
    UIView *container2 = [UIView new];
    [self.view addSubview:container2];
    container2.frame = CGRectMake(0, f.size.height - 78.f, f.size.width, 34.f);
    container2.backgroundColor = rgb(245.f, 245.f, 245.f);
    UIView *line2 = [UIView new];
    line2.backgroundColor = rgb(205.f, 205.f, 205.f);
    line2.frame = CGRectMake(0, 0, f.size.width, .5);
    [container2 addSubview:line2];
    
    UIView *line3 = [UIView new];
    line3.backgroundColor = rgb(205.f, 205.f, 205.f);
    line3.frame = CGRectMake(container2.frame.size.width/2, 2.f, .5, container2.frame.size.height - 4.f);
    [container2 addSubview:line3];
    
    UIButton *selectBtnA = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [container2 addSubview:selectBtnA];
    selectBtnA.tag = 0;
    [selectBtnA setTitle:@"拍照" forState:UIControlStateNormal];
    selectBtnA.titleLabel.font = [UIFont systemFontOfSize:18.f];
    [selectBtnA addTarget:self action:@selector(selectPic:) forControlEvents:UIControlEventTouchUpInside];
    [selectBtnA sizeToFit];
    selectBtnA.center = CGPointMake(container2.frame.size.width/4.f, container2.frame.size.height/2.f);
    
    UIButton *selectBtnB = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [container2 addSubview:selectBtnB];
    selectBtnB.tag = 1;
    [selectBtnB setTitle:@"从图库选取" forState:UIControlStateNormal];
    selectBtnB.titleLabel.font = [UIFont systemFontOfSize:18.f];
    [selectBtnB addTarget:self action:@selector(selectPic:) forControlEvents:UIControlEventTouchUpInside];
    [selectBtnB sizeToFit];
    selectBtnB.center = CGPointMake(container2.frame.size.width/4.f*3.f, container2.frame.size.height/2.f);
    
    if ([Setting boolForKey:HPSettingNightMode]) {
        container.backgroundColor = [HPTheme backgroundColor];
        container2.backgroundColor = [HPTheme backgroundColor];
        label.textColor = [HPTheme textColor];
    }

    
    // btn
    UIBarButtonItem *sendBtn = [[UIBarButtonItem alloc]initWithTitle:@"上传" style:UIBarButtonItemStylePlain target:self action:@selector(uploadPic:)];
    
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc]
                                  initWithTitle:@"取消"
                                  style:UIBarButtonItemStylePlain target:self action:@selector(cancelUpload:)];
    
    [self.navigationItem setRightBarButtonItem:sendBtn];
    [self.navigationItem setLeftBarButtonItem:cancelBtn];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.

}

#pragma mark -

- (void)cancelUpload:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)selectPic:(id)sender {
    
    int tag = [sender tag];
    
    UIImagePickerController *imagePicker =
    [[UIImagePickerController alloc] init];
    
    switch (tag) {
        case 0:
            if ([UIImagePickerController
                 isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
            } else {
                [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            }
            break;
        case 1:
            [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            break;
        default:
            NSLog(@"selectPic unknown tag %d", tag);
            break;
    }
    
    [imagePicker setDelegate:self];
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}


- (void)uploadPic:(id)sender {
    if (!_imageData) {
        [SVProgressHUD showErrorWithStatus:@"还没选呢"];
        return;
    }
    
    NSLog(@"upload....");
    
    _imageSize = [_imageData length];
    NSInteger size = _imageSize/1024;
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [SVProgressHUD showWithStatus:[NSString stringWithFormat:@"上传中...(0/%ldkb)", size]];
    
    [HPSendPost uploadImage:_imageData
                  imageName:nil
              progressBlock:^(CGFloat progress)
     {
         NSInteger size = _imageSize/1024;
         NSString *progessString = [NSString stringWithFormat:@"上传中...(%d/%ldkb)", (int)(progress*size), size];
         [SVProgressHUD showProgress:progress status:progessString];
     }
                      block:^(NSString *attach, NSError *error)
     {
         
         if (error) {
             [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
             self.navigationItem.rightBarButtonItem.enabled = YES;
             
         } else {
             
             [SVProgressHUD dismiss];
             [self.delegate completeWithAttachString:attach error:nil];
             [self dismissViewControllerAnimated:YES completion:^{
                 ;
             }];
             
         }
         NSLog(@"attach %@, error %@", attach, [error localizedDescription]);
     }];
}

#pragma mark -

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // 文件尺寸: 小于 976KB
    // 可用扩展名: jpg, jpeg, gif, png, bmp
    
    [SVProgressHUD showWithStatus:@"压缩中..."];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];

        _image = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:CGSizeMake(_targetSize, _targetSize) interpolationQuality:kCGInterpolationDefault];
        
        _imageData = UIImageJPEGRepresentation(_image, 0.35);
        
        NSLog(@"0 image size %ld", [_imageData length]/1024);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [_imageView setImage:_image];
            _image = nil;
        });
    });
    
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -

-(void)segmentedControlValueDidChange:(UISegmentedControl *)segment
{
    NSLog(@"segment.selectedSegmentIndex %d", segment.selectedSegmentIndex);
    switch (segment.selectedSegmentIndex) {
        case 0:
        {
            _targetSize = 400.f;
            break;
        }
        case 1:
        {
            _targetSize = 600.f;
            break;
        }
        case 2:
        {
            _targetSize = 800.f;
            break;
        }
        case 3:
        {
            _targetSize = 1000.f;
            break;
        }
        default:
        {
            _targetSize = 600.f;
            break;
        }
    }
}
@end
