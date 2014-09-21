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
#import "UIView+FKAdditions.h"

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
    if (self) {
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
    
    UIBarButtonItem *_submitButton;
    UIBarButtonItem *_cancelButton;
    UIBarButtonItem *_deleteButton;
}

@end

@implementation FKFormViewController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.form = nil;
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    return self;
}

-(id)init {
    return [[FKFormViewController alloc] initWithNibName:nil bundle:nil];
}

- (void)loadView {
    [super loadView];
    
    _layoutView = [[FKFormViewControllerLayoutView alloc] initWithFrame:self.view.bounds];
    _layoutView.autoresizingMask = ~UIViewAutoresizingNone;
    _layoutView.scrollView.scrollEnabled = YES;
    _layoutView.scrollView.bounces = YES;
    
    [self.view addSubview:_layoutView];
    
    if (!_form) {
        return;
    }
    
    FKFormView *formView = (FKFormView *) [_form createView];
    [_layoutView setFormView:formView];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    if (!_form) {
        return;
    }
    
    [self setupNavigationItem];
}

-(UIBarButtonItem *)submitButton {
    if (_submitButton == nil) {
        _submitButton = [[UIBarButtonItem alloc] initWithTitle:_form.submitLabel?_form.submitLabel:@"Submit" style:UIBarButtonItemStylePlain target:self action:@selector(submit:)];
    }
    return _submitButton;
}

-(UIBarButtonItem *)cancelButton {
    if (_cancelButton == nil) {
        _cancelButton = [[UIBarButtonItem alloc] initWithTitle:_form.cancelLabel?_form.cancelLabel:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
    }
    return _cancelButton;
}

-(UIBarButtonItem *)deleteButton {
    if (_deleteButton == nil) {
        _deleteButton = [[UIBarButtonItem alloc] initWithTitle:_form.deleteLabel?_form.deleteLabel:@"Delete" style:UIBarButtonItemStylePlain target:self action:@selector(delete:)];
        [_deleteButton setTitleTextAttributes:
            @{NSForegroundColorAttributeName:[UIColor redColor]} forState:UIControlStateNormal];
        [_deleteButton setTitleTextAttributes:
            @{NSForegroundColorAttributeName:[[UIColor redColor] colorWithAlphaComponent:.5f]} forState:UIControlStateHighlighted];
    }
    return _deleteButton;
}

-(void)setForm:(FKForm *)form {
    _form = form;
    
    if (_form && !_form.delegate) {
        _form.delegate = self;
    }
    
    if (self.isViewLoaded) {
        [_layoutView setFormView:nil];
        [_layoutView setNeedsLayout];
        
        self.navigationItem.title = nil;
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.rightBarButtonItems = @[];
        
        _cancelButton = nil;
        _submitButton = nil;
        _deleteButton = nil;
        
        if (!_form) {
            return;
        }
        
        FKFormView *formView = (FKFormView *) [_form createView];
        [_layoutView setFormView:formView];
        [_layoutView setNeedsLayout];
        
        [self setupNavigationItem];
    }
}

-(void)setupNavigationItem {
    self.navigationItem.title = _form.title;
    self.navigationItem.leftBarButtonItem = self.cancelButton;
    
    NSMutableArray *rightBarButtonItems = [NSMutableArray array];
    
    if (_form.purpose & FKFormPurposeSubmit) {
        [rightBarButtonItems addObject:self.submitButton];
    }
    
    if (_form.purpose & FKFormPurposeDelete) {
        [rightBarButtonItems addObject:self.deleteButton];
    }
    
    self.navigationItem.rightBarButtonItems = rightBarButtonItems;
}

-(void)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)submit:(id)sender {
}

-(void)delete:(id)sender {
}

#pragma mark - convenience methods

/*
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
*/

-(void)presentViewControllerForSelectFieldItem:(FKSelectFieldItem *)selectFieldItem {
    FKFormSelectViewController *controller = [[FKFormSelectViewController alloc] initWithSelectFieldItem:selectFieldItem];
    if (self.navigationController) {
        [self.navigationController pushViewController:controller animated:YES];
    } else {
        [self presentViewController:controller animated:YES completion:nil];
    }
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

-(void)form:(FKForm *)form didFocusItem:(FKInputItem *)item {
    if ([item isKindOfClass:[FKSelectFieldItem class]]
        && ![item isKindOfClass:[FKInlineSelectFieldItem class]]) {
        [self presentViewControllerForSelectFieldItem:(FKSelectFieldItem *)item];
    }
}

-(void)form:(FKForm *)form didDefocusItem:(FKInputItem *)item {
}

-(void)form:(FKForm *)form valueDidChangedForItem:(FKInputItem *)item {
}

@end
