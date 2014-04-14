//
//  HPRearCell.m
//  HiPDA
//
//  Created by wujichao on 14-3-25.
//  Copyright (c) 2014年 wujichao. All rights reserved.
//

#import "HPRearCell.h"
#define MARGIN 4.f
#define WIDTH 100.f
#define HEIGHT 44.f

@implementation HPRearCell {
    
@private
    
    UIView *_container;
    
    UILabel *_label;
    UILabel *_numLabel;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) {
        return nil;
    }
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.contentView.backgroundColor = rgb(26.f, 26.f, 26.f);
    
    _container = [[UIView alloc] initWithFrame:CGRectMake(MARGIN, MARGIN/2, WIDTH-MARGIN*2, HEIGHT-MARGIN)];
    _container.backgroundColor = rgb(38.f, 38.f, 38.f);
    CALayer *layer  = _container.layer;
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:3.0];

    
    _label = [UILabel new];
    _label.backgroundColor = [UIColor clearColor];//rgb(38.f, 38.f, 38.f);
    _label.textColor = rgb(186.f, 186.f, 186.f);
    _label.font = [UIFont fontWithName:@"STHeitiSC-Light" size:16.f];
    [_container addSubview:_label];

    
    _numLabel = [UILabel new];
    _numLabel.backgroundColor = rgb(186.f, 186.f, 186.f);
    _numLabel.textColor = [UIColor blackColor];
    _numLabel.font = [UIFont fontWithName:@"STHeitiSC-Light" size:16.f];
    CALayer *nlayer  = _numLabel.layer;
    [nlayer setMasksToBounds:YES];
    [nlayer setCornerRadius:2.0];
    [_container addSubview:_numLabel];
    
    
    [self.contentView addSubview:_container];
    //self.separatorInset =  UIEdgeInsetsMake(0, 0, 0, 1000);
    return self;
}

- (void)configure:(NSString *)title {
    _label.text = title;
    [_label sizeToFit];
    CGRect f = _label.frame;
    f.origin.x = 10.f;
    f.origin.y = 12.f;
    _label.frame = f;
}

- (void)showNumber:(NSInteger)num {
    
    [_numLabel setHidden:NO];
    
    _numLabel.text = S(@"%ld", num);
    _numLabel.textAlignment = NSTextAlignmentCenter;
    [_numLabel sizeToFit];
    CGRect f = _numLabel.frame;
    f.origin.x = _label.frame.origin.x + _label.frame.size.width + 3.f;
    f.origin.y = _label.frame.origin.y + 1.f;
    f.size.width += 2.f;
    f.size.height -= 2.f;
    _numLabel.frame = f;
    
    [self setNeedsDisplay];
    
    //NSLog(@"%@", NSStringFromCGRect(f));
}

- (void)hideNumber {
    [_numLabel setHidden:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
    
    if (selected) {
        _label.textColor = [UIColor whiteColor];
    } else {
        _label.textColor = rgb(186.f, 186.f, 186.f);
    }
}


- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)prepareForReuse {
    [self hideNumber];
}

@end
