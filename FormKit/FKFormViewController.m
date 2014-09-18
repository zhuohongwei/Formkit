//
//  FKFormViewController.m
//  FormKit
//
//  Created by Hong Wei Zhuo on 18/9/14.
//  Copyright (c) 2014 ___zhuohongwei___. All rights reserved.
//

#import "FKFormViewController.h"
#import "FKFormItem.h"
#import "FKFormItemView.h"
#import "FKFormSelectViewController.h"
#import "FKFormResultViewController.h"
#import "UIView+Glass.h"
#import "UIView+Debug.h"

@interface FKFormViewControllerLayoutView : UIView {
    FKFormView *_formView;
}
@property (nonatomic,readonly) UIScrollView * scrollView;
@property (nonatomic) UIEdgeInsets contentInset;

-(void)setFormView:(FKFormView *)formView;
@end

@implementation FKFormViewControllerLayoutView

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self)
    {
        _contentInset = UIEdgeInsetsMake(20, 10, 10, 0);
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
        [self addSubview:_scrollView];
    }
    return self;
}

-(void)setFormView:(FKFormView *)formView {
    if (_formView) {
        [_formView removeFromSuperview];
    }
    _formView = formView;
    [_scrollView addSubview:_formView];
}

- (void)layoutSubviews {
    _scrollView.frame = self.bounds;
    
    CGFloat formWidth = self.bounds.size.width - _contentInset.left - _contentInset.right;
    CGFloat formHeight = [_formView.item heightForWidth:formWidth];
    
    _formView.frame = CGRectMake(0, 0, formWidth, formHeight);
    _scrollView.contentSize = CGSizeMake(formWidth, formHeight);
    _scrollView.contentInset = _contentInset;
}

- (void)setContentInset:(UIEdgeInsets)contentInset {
    _contentInset = contentInset;
    _scrollView.contentInset = _contentInset;
}
@end

@interface FKFormViewController () {
    FKFormViewControllerLayoutView * _layoutView;
    UIView *_overlayView;
    
    UIBarButtonItem * _submitButton;
    UIBarButtonItem * _cancelButton;
    UIBarButtonItem * _deleteButton;
}

@end

@implementation FKFormViewController

- (void)loadView {
    [super loadView];
    
    _layoutView = [[FKFormViewControllerLayoutView alloc] initWithFrame:self.view.bounds];
    _layoutView.autoresizingMask = ~UIViewAutoresizingNone;
    _layoutView.scrollView.scrollEnabled = YES;
    _layoutView.scrollView.bounces = YES;
    
    [self.view addSubview:_layoutView];
    
    if (_form) {
        FKFormView *formView = (FKFormView *) [_form createView];
        [_layoutView setFormView:formView];
    }
}
-(UIBarButtonItem *)submitButton
{
    if (_submitButton == nil)
    {
        _submitButton = [UIHelpers barButtonWithTitle:_form.submitLabel?_form.submitLabel:@"Submit" target:self action:@selector(submit:)];
    }
    return _submitButton;
}
-(UIBarButtonItem *)cancelButton
{
    if (_cancelButton == nil)
    {
        _cancelButton = [UIHelpers barButtonWithTitle:_form.cancelLabel?_form.cancelLabel:@"Cancel" target:self action:@selector(cancel:)];
    }
    return _cancelButton;
}
-(UIBarButtonItem *)deleteButton
{
    if (_deleteButton == nil)
    {
        _deleteButton = [UIHelpers barButtonWithTitle:_form.deleteLabel?_form.deleteLabel:@"Delete" target:self action:@selector(delete:)];
        
        UIButton * btn = (UIButton *)_deleteButton.customView;
        [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [btn setTitleColor:[[UIColor redColor] colorWithAlphaComponent:.5f] forState:UIControlStateHighlighted];
    }
    return _deleteButton;
}
-(void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    self.navigationItem.title = _form.title;
    
    self.navigationItem.leftBarButtonItem = self.cancelButton;
    self.navigationItem.rightBarButtonItem = self.submitButton;
}

-(void)setForm:(FKForm *)form {
    _form = form;
    
    if (!_form.delegate) {
        _form.delegate = self;
    }
    
    if (self.isViewLoaded && _form) {
        FKFormView *formView = (FKFormView *) [_form createView];
        [_layoutView setFormView:formView];
        [_layoutView setNeedsLayout];
        
        self.navigationItem.title = _form.title;
        
        UIBarButtonItem *cancelButton = self.navigationItem.leftBarButtonItem;
        cancelButton.title = _form.cancelLabel?_form.cancelLabel:@"Cancel";
        
        UIBarButtonItem *submitButton = self.navigationItem.rightBarButtonItem;
        submitButton.title = _form.submitLabel?_form.submitLabel:@"Submit";
    }
}

-(void)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)submit:(id)sender {
}
-(void)delete:(id)sender
{
    
}
#pragma mark - convenience methods

-(void)overlayMessage:(NSString *)message {
    [self removeOverlay];
    _overlayView = [UIView frostedGlassInView:self.view];
    
    _overlayView.layer.opacity = 0.f;
    
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _overlayView.frame.size.width, 50)];
    [messageLabel setBackgroundColor:mRgb(0x6a, 0xa1, 0xdf)];
    [messageLabel setTextColor:mRgb(0x0a, 0x59, 0x99)];
    [messageLabel setText:message];
    [messageLabel setTextAlignment:NSTextAlignmentCenter];
    [_overlayView addSubview:messageLabel];
    
    [UIView animateWithDuration:0.2 animations:^{
        _overlayView.layer.opacity = 1.f;
    } completion:^(BOOL finished) {
    }];
}

-(void)removeOverlay {
    if (_overlayView) {
        [UIView animateWithDuration:0.2 animations:^{
            _overlayView.layer.opacity = 0.f;
        } completion:^(BOOL finished) {
            [_overlayView removeFromSuperview];
            _overlayView = nil;
        }];
    }
}

-(void)presentViewControllerForSelectFieldItem:(FKSelectFieldItem *)selectFieldItem {
    FKFormSelectViewController *controller = [[FKFormSelectViewController alloc] initWithSelectFieldItem:selectFieldItem];
    [self.navigationController pushViewController:controller animated:YES];
}

-(void)presentSuccessMessage:(NSAttributedString *)message {
    FKFormResultViewController *controller = [[FKFormResultViewController alloc] init];
    controller.disableBackButton = YES;
    [controller setImage:[UIImage imageNamed:@"1040-checkmark"] andMessage:message];
    [self.navigationController pushViewController:controller animated:YES];
}

-(void)presentFailureMessage:(NSAttributedString *)message {
    FKFormResultViewController *controller = [[FKFormResultViewController alloc] init];
    [controller setImage:[UIImage imageNamed:@"791-warning"] andMessage:message];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - FKFormDelegate

-(void)form:(FKForm *)form didFocusItem:(ISInputItem *)item {
    if ([item isKindOfClass:[FKSelectFieldItem class]]) {
        [self presentViewControllerForSelectFieldItem:(FKSelectFieldItem *)item];
    }
}

-(void)form:(FKForm *)form didDefocusItem:(ISInputItem *)item {
    
}

-(void)form:(FKForm *)form valueDidChangedForItem:(ISInputItem *)item {
    
}

@end
