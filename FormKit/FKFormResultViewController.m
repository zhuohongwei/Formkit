//
//  FKFormResultViewController.m
//  FormKit
//
//  Created by Hong Wei Zhuo on 18/9/14.
//  Copyright (c) 2014 ___zhuohongwei___. All rights reserved.
//

#import "FKFormResultViewController.h"

@interface FKFormResultLayoutView : UIView

@property (nonatomic, strong, readonly) UIImageView *imageView;
@property (nonatomic, strong, readonly) UILabel *label;

@end


@implementation FKFormResultLayoutView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        _label = [UILabel new];
        _label.font = [UIFont fontWithName:@"HelveticaNeue" size:16.f];
        _label.numberOfLines = 0;
        _label.lineBreakMode = NSLineBreakByWordWrapping;
        _label.textAlignment = NSTextAlignmentCenter;
        _label.preferredMaxLayoutWidth = CGRectGetWidth(frame) - 20.f;
        [self addSubview:_label];
        
        _imageView = [UIImageView new];
        [self addSubview:_imageView];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat w = CGRectGetWidth(self.bounds);
    CGFloat h = CGRectGetHeight(self.bounds);
    
    _label.preferredMaxLayoutWidth = w - 20.f;
    
    CGRect f;
    
    CGFloat th = 0.f;
    
    th += _imageView.image.size.height;
    th += 10.f;
    th += _label.intrinsicContentSize.height;
    
    CGFloat cy = floorf((h-th)/2.f);
    
    f = _imageView.frame;
    f.size = _imageView.intrinsicContentSize;
    f.origin = CGPointMake((w - f.size.width)/2, cy);
    _imageView.frame = f;
    
    cy += _imageView.bounds.size.height + 10.f;
    
    f = _label.frame;
    f.size = _label.intrinsicContentSize;
    f.origin = CGPointMake((w - f.size.width)/2, ceilf(cy));
    _label.frame = f;
}

@end


@interface FKFormResultViewController () {
    FKFormResultLayoutView *_layoutView;
    UIImage *_image;
    NSAttributedString *_message;
}

-(void)dismiss:(id)sender;

@end

@implementation FKFormResultViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _disableBackButton = NO;
    }
    return self;
}


-(void)loadView {
    [super loadView];
    _layoutView = [[FKFormResultLayoutView alloc] initWithFrame:self.view.bounds];
    _layoutView.autoresizingMask = ~UIViewAutoresizingNone;
    _layoutView.label.attributedText = _message;
    _layoutView.imageView.image = _image;
    
    [self.view addSubview:_layoutView];
    [_layoutView setNeedsLayout];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *dismissButton = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss:)];
    self.navigationItem.rightBarButtonItem = dismissButton;

    self.navigationItem.hidesBackButton = _disableBackButton;
}

- (void)setDisableBackButton:(BOOL)disableBackButton {
    _disableBackButton = disableBackButton;
    self.navigationItem.hidesBackButton = _disableBackButton;
}

-(void)setImage:(UIImage *)image  andMessage:(NSAttributedString *)message {
    _image = image;
    _message = message;
    
    if (![self isViewLoaded]) {
        return;
    }
    
    _layoutView.imageView.image = image;
    _layoutView.label.attributedText = message;
    [_layoutView setNeedsLayout];
}

-(void)dismiss:(id)sender {
    if (self.delegate) {
        [self.delegate formResultViewControllerDidDismissFormResult:self];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end

