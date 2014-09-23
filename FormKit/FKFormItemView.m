//
//  FKFormItemView.m
//  FormKit
//
//  Created by Hong Wei Zhuo on 17/9/14.
//  Copyright (c) 2014 ___zhuohongwei___. All rights reserved.
//

#import "FKFormItemView.h"
#import "FKFormItem.h"
#import "FKBorderedView.h"

#define kBorderColor        [UIColor colorWithWhite:0.78f alpha:1.f]
#define kPlaceholderColor   [UIColor colorWithWhite:0.78f alpha:1.f]
#define kDisabledLabelColor [UIColor colorWithWhite:0.78f alpha:1.f];
#define kNormalLabelColor   [UIColor colorWithRed:0.36f green:0.64f blue:0.9f alpha:1.f];

@implementation FKFormItemView

-(void)layoutSubviews {
    [super layoutSubviews];
    if (self.item) {
        [self.item layout];
    }
}

-(void)reload {
}

-(FKFormItemView *)rootFormItemView {
    if (!self.superview) {
        return self;
    } else if ([self.superview isKindOfClass:[FKFormItemView class]]) {
        FKFormItemView *parent = (FKFormItemView *) self.superview;
        return [parent rootFormItemView];
    }
    return self;
}
@end

@implementation FKFormView
@end


@implementation FKFormRowView
@end


@implementation FKFormColumnView
@end


static const CGFloat kDefaultLabelWidthRatio = 0.3;

@interface FKInputControlView () {
    NSArray *_keyPaths;
}
@end

@implementation FKInputControlView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _keyPaths = @[NSStringFromSelector(@selector(label)),
                      NSStringFromSelector(@selector(name)),
                      NSStringFromSelector(@selector(value)),
                      NSStringFromSelector(@selector(placeholder)),
                      NSStringFromSelector(@selector(disabled))];
        _labelWidthRatio = kDefaultLabelWidthRatio;
    }
    return self;
}

-(void)setItem:(FKFormItem *)item {
    //TODO: remove keypaths for previous item??
    super.item = item;
    if (item != nil) {
        for (NSString *keyPath in _keyPaths) {
            [item addObserver:self forKeyPath:keyPath options:0 context:NULL];
        }
    }
}


-(CGFloat)heightForWidth:(CGFloat)width {
    //override to provide height
    return 0;
}

-(void)dealloc {
    if (self.item) {
        for (NSString *keyPath in _keyPaths) {
            [self.item removeObserver:self forKeyPath:keyPath];
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    for (NSString *testPath in _keyPaths) {
        if ([testPath isEqualToString:keyPath]) {
            [self.item reload];
            return;
        }
    }
}

@end


@interface FKTextFieldView () <UITextFieldDelegate> {
    UILabel *_fieldLabel;
    UITextField *_textField;
    FKBorderedView *_bv1;
    FKBorderedView *_bv2;
}

@property (nonatomic, strong, readwrite) UILabel *fieldLabel;
@property (nonatomic, strong, readwrite) UITextField *textField;

-(void)textFieldValueChanged:(id)sender;

@end


@implementation FKTextFieldView

static const CGFloat kTextFieldInset = 10.f;

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _bv1 = [FKBorderedView new];
        _bv1.borderColor = kBorderColor;
        _bv1.borders = UIRectEdgeBottom | UIRectEdgeRight;
        
        _fieldLabel = [UILabel new];
        _fieldLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16.f];
        _fieldLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _fieldLabel.adjustsFontSizeToFitWidth = YES;
        _fieldLabel.numberOfLines = 1;
        _fieldLabel.textColor = self.tintColor;
        
        [_bv1 addSubview:_fieldLabel];
        
        _bv2 = [FKBorderedView new];
        _bv2.borderColor = kBorderColor;
        _bv2.borders = UIRectEdgeBottom;
        
        _textField = [UITextField new];
        _textField.delegate = self;
        [_textField addTarget:self action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
        
        [_bv2 addSubview:_textField];
        
        [self addSubview:_bv1];
        [self addSubview:_bv2];
    }
    return self;
}

-(CGFloat)heightForWidth:(CGFloat)width {
    return 44.f;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat h = self.bounds.size.height;
    CGFloat w = self.bounds.size.width;

    CGFloat w1 = floor(w*self.labelWidthRatio);
    CGFloat w2 = w - w1;
    
    _bv1.frame = (CGRect) {0, 0, w1, h};
    
    CGFloat labelWidth = _fieldLabel.intrinsicContentSize.width;
    labelWidth = MIN(labelWidth, CGRectGetWidth(_bv1.frame) - 2*kTextFieldInset);
    CGFloat labelHeight = _fieldLabel.intrinsicContentSize.height;
    labelHeight = MIN(labelHeight, CGRectGetHeight(_bv1.frame) - 2*kTextFieldInset);
    _fieldLabel.frame = (CGRect) {kTextFieldInset, (h - labelHeight - kTextFieldInset), labelWidth, labelHeight};
    
    _bv2.frame = (CGRect) {CGRectGetMaxX(_bv1.frame), 0, w2, h};
    
    CGFloat textFieldWidth = _bv2.bounds.size.width - 2*kTextFieldInset;
    _textField.frame = (CGRect) {kTextFieldInset, (h - _textField.intrinsicContentSize.height - kTextFieldInset), textFieldWidth, _textField.intrinsicContentSize.height};
}

-(void)reload {
    FKInputItem *input = (FKInputItem *) self.item;
    _fieldLabel.text = input.label;
    
    UITextRange *textRange = _textField.selectedTextRange;
    _textField.text = input.value;
    _textField.selectedTextRange = textRange;
    _textField.placeholder = input.placeholder;
    
    if (input.disabled) {
        _textField.enabled = NO;
        _fieldLabel.textColor = kDisabledLabelColor;
    } else {
        _textField.enabled = YES;
        _fieldLabel.textColor = self.tintColor;
    }
    
    [self setNeedsLayout];
}

-(void)textFieldValueChanged:(id)sender {
    FKInputItem *input = (FKInputItem *)self.item;
    input.value = self.textField.text;
    FKForm *form = (FKForm *)input.rootItem;
    [form valueChangedForItem:(FKInputItem *)self.item];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    FKForm *form = (FKForm *)self.item.rootItem;
    [form focusItem:(FKInputItem *)self.item];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    FKForm *form = (FKForm *)self.item.rootItem;
    [form defocusItem:(FKInputItem *)self.item];
}

@end



@interface FKSelectFieldView () {
    UIImageView *_disclosureIndicatorView;
    FKBorderedView *_bv1;
    FKBorderedView *_bv2;
    UIView *_selectedBackgroundView;
}

@property (nonatomic, strong, readwrite) UILabel *fieldLabel;
@property (nonatomic, strong, readwrite) UILabel *valueLabel;
-(void)selectFieldTapped:(id)sender;

@end

@implementation FKSelectFieldView

static const CGFloat kSelectFieldInset = 10.f;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _bv1 = [FKBorderedView new];
        _bv1.borderColor = kBorderColor;
        _bv1.borders = UIRectEdgeBottom | UIRectEdgeRight;
        
        _fieldLabel = [UILabel new];
        _fieldLabel.backgroundColor = [UIColor clearColor];
        _fieldLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16.f];
        _fieldLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _fieldLabel.adjustsFontSizeToFitWidth = YES;
        _fieldLabel.numberOfLines = 1;
        _fieldLabel.textColor = self.tintColor;
        
        [_bv1 addSubview:_fieldLabel];
        
        _bv2 = [FKBorderedView new];
        _bv2.borderColor = kBorderColor;
        _bv2.borders = UIRectEdgeBottom;
        
        _valueLabel = [UILabel new];
        _valueLabel.backgroundColor = [UIColor clearColor];
        _valueLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16.f];
        _valueLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _valueLabel.numberOfLines = 1;
        
        _disclosureIndicatorView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fk_disclosure_indicator"]];
        
        [_bv2 addSubview:_valueLabel];
        [_bv2 addSubview:_disclosureIndicatorView];
        
        [self addSubview:_bv1];
        [self addSubview:_bv2];
        
        _bv2.userInteractionEnabled = YES;
        
        _selectedBackgroundView = [UIView new];
        _selectedBackgroundView.backgroundColor = [UIColor lightGrayColor];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectFieldTapped:)];
        tapGesture.numberOfTapsRequired = 1;
        [_bv2 addGestureRecognizer:tapGesture];
    }
    return self;
}

-(CGFloat)heightForWidth:(CGFloat)width {
    return 44.f;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat h = self.bounds.size.height;
    CGFloat w = self.bounds.size.width;
    
    CGFloat w1 = floor(w*self.labelWidthRatio);
    CGFloat w2 = w - w1;
    
    _bv1.frame = (CGRect) {0, 0, w1, h};
    
    CGFloat labelWidth = _fieldLabel.intrinsicContentSize.width;
    labelWidth = MIN(labelWidth, CGRectGetWidth(_bv1.frame) - 2*kSelectFieldInset);
    
    CGFloat labelHeight = _fieldLabel.intrinsicContentSize.height;
    labelHeight = MIN(labelHeight, CGRectGetHeight(_bv1.frame) - 2*kSelectFieldInset);
    
    _fieldLabel.frame = (CGRect) {kSelectFieldInset, (h - labelHeight - kSelectFieldInset), labelWidth, labelHeight};
    
    _bv2.frame = (CGRect) {CGRectGetMaxX(_bv1.frame), 0, w2, h};
    
    CGRect f = _disclosureIndicatorView.frame;
    f.size = _disclosureIndicatorView.intrinsicContentSize;
    _disclosureIndicatorView.frame = f;
    
    labelWidth = _valueLabel.intrinsicContentSize.width;
    labelWidth = MIN(labelWidth, CGRectGetWidth(_bv2.frame) - 3*kSelectFieldInset-_disclosureIndicatorView.bounds.size.width);
    labelHeight = _valueLabel.intrinsicContentSize.height;
    labelHeight = MIN(labelHeight, CGRectGetHeight(_bv2.frame) - 2*kSelectFieldInset);
    
    _valueLabel.frame = (CGRect) {kSelectFieldInset, (h - _valueLabel.intrinsicContentSize.height - kSelectFieldInset),  labelWidth, labelHeight};
    
    f = _disclosureIndicatorView.frame;
    f.origin = CGPointMake(_bv2.bounds.size.width - _disclosureIndicatorView.intrinsicContentSize.width - kSelectFieldInset, (h - _disclosureIndicatorView.intrinsicContentSize.height)/2);
    _disclosureIndicatorView.frame = f;
}

-(void)reload {
    FKSelectFieldItem *input = (FKSelectFieldItem *) self.item;
    _fieldLabel.text = input.label;
    _valueLabel.text = input.displayValue;
    if (!input.value || ([input.value isKindOfClass:[NSArray class]] && [(NSArray *)input.value count] == 0)) {
        _valueLabel.textColor = kPlaceholderColor;
    } else {
        _valueLabel.textColor = [UIColor blackColor];
    }
    
    if (input.disabled) {
        _valueLabel.textColor = kDisabledLabelColor;
        _fieldLabel.textColor = kDisabledLabelColor;
    } else {
        _fieldLabel.textColor = self.tintColor;
    }
    
    [self setNeedsLayout];
}

-(void)selectFieldTapped:(id)sender {
    FKInputItem *input = (FKInputItem *) self.item;
    if (input.disabled) {
        return;
    }
    
    _selectedBackgroundView.frame = self.bounds;
    _selectedBackgroundView.layer.opacity = 0.0;
    [self insertSubview:_selectedBackgroundView atIndex:0];
    
    [UIView animateWithDuration:0.1 animations:^{
        _selectedBackgroundView.layer.opacity = 0.3f;
        
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            _selectedBackgroundView.layer.opacity = 0.0f;
            
        } completion:^(BOOL finished) {
            [_selectedBackgroundView removeFromSuperview];
            FKForm *form = (FKForm *) [self.item rootItem];
            FKInputItem *input = (FKInputItem *) self.item;
            [form focusItem:input];
        }];
    }];
}

@end


@interface FKInlineSelectFieldView () {
    FKBorderedView *_bv1;
    FKBorderedView *_bv2;
    UIView *_selectedBackgroundView;
}

@property (nonatomic, strong, readwrite) UILabel *fieldLabel;
@property (nonatomic, strong, readwrite) NSArray *optionButtons;

-(void)inlineSelectFieldOptionTapped:(id)sender;

@end

@implementation FKInlineSelectFieldView

static const CGFloat kInlineSelectFieldInset = 10.f;
static const CGFloat kInlineSelectFieldOptionSpacing = 8.f;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _bv1 = [FKBorderedView new];
        _bv1.borderColor = kBorderColor;
        _bv1.borders = UIRectEdgeBottom | UIRectEdgeRight;
        
        _fieldLabel = [UILabel new];
        _fieldLabel.backgroundColor = [UIColor clearColor];
        _fieldLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16.f];
        _fieldLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _fieldLabel.adjustsFontSizeToFitWidth = YES;
        _fieldLabel.numberOfLines = 1;
        _fieldLabel.textColor = self.tintColor;
        
        [_bv1 addSubview:_fieldLabel];
        
        _bv2 = [FKBorderedView new];
        _bv2.borderColor = kBorderColor;
        _bv2.borders = UIRectEdgeBottom;
        
        [self addSubview:_bv1];
        [self addSubview:_bv2];
        
        _bv2.userInteractionEnabled = YES;
        
        _selectedBackgroundView = [UIView new];
        _selectedBackgroundView.backgroundColor = [UIColor lightGrayColor];
        
        _optionButtons = @[];
    }
    return self;
}

-(CGFloat)heightForWidth:(CGFloat)width {
    return 44.f;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat h = self.bounds.size.height;
    CGFloat w = self.bounds.size.width;
    
    CGFloat w1 = floor(w*self.labelWidthRatio);
    CGFloat w2 = w - w1;
    
    _bv1.frame = (CGRect) {0, 0, w1, h};
    
    CGFloat labelWidth = _fieldLabel.intrinsicContentSize.width;
    labelWidth = MIN(labelWidth, CGRectGetWidth(_bv1.frame) - 2*kInlineSelectFieldInset);
    
    CGFloat labelHeight = _fieldLabel.intrinsicContentSize.height;
    labelHeight = MIN(labelHeight, CGRectGetHeight(_bv1.frame) - 2*kInlineSelectFieldInset);
    
    _fieldLabel.frame = (CGRect) {kInlineSelectFieldInset, (h - labelHeight - kInlineSelectFieldInset), labelWidth, labelHeight};
    
    _bv2.frame = (CGRect) {CGRectGetMaxX(_bv1.frame), 0, w2, h};
    
    NSUInteger numOfOptionButtons = _optionButtons.count;
    if (numOfOptionButtons > 0) {
        CGFloat totalAllocatableWidth = CGRectGetWidth(_bv2.frame) - 2*kInlineSelectFieldInset - (numOfOptionButtons-1)*kInlineSelectFieldOptionSpacing;
        
        CGFloat totalRequiredWidth = 0;
        for (UIButton *optionButton in _optionButtons) {
            totalRequiredWidth += optionButton.intrinsicContentSize.width;
        }
        
        CGFloat x = kInlineSelectFieldInset;
        for (UIButton *optionButton in _optionButtons) {
            CGFloat buttonWidth = optionButton.intrinsicContentSize.width;
            buttonWidth = (totalRequiredWidth > totalAllocatableWidth)? (buttonWidth/totalRequiredWidth)*totalAllocatableWidth : buttonWidth;
            
            CGFloat buttonHeight = optionButton.intrinsicContentSize.height;
            buttonHeight = MIN(buttonHeight, CGRectGetHeight(_bv2.frame) - 2*kInlineSelectFieldInset);
            
            optionButton.frame = (CGRect) { x, (h - buttonHeight - kInlineSelectFieldInset), buttonWidth, buttonHeight };
            optionButton.frame = CGRectIntegral(optionButton.frame);
            
            x += buttonWidth;
            x += kInlineSelectFieldOptionSpacing;
        }
    }
}

-(void)setItem:(FKFormItem *)item {
    super.item = item;
    if (item != nil) {
        for (UIButton *optionButton in _optionButtons) {
            [optionButton removeFromSuperview];
        }
        
        NSMutableArray *optionButtons = [NSMutableArray array];
        FKInlineSelectFieldItem *inlineSelectFieldItem = (FKInlineSelectFieldItem *)item;
        for (id key in inlineSelectFieldItem.sortedKeyValues) {
            
            UIButton *optionButton = [UIButton buttonWithType:UIButtonTypeCustom];
            
            [optionButton setTitle:inlineSelectFieldItem.keyAndDisplayValues[key] forState:UIControlStateNormal];
            [optionButton setTitleColor:kPlaceholderColor forState:UIControlStateNormal];
            [optionButton setTitleColor:kPlaceholderColor forState:UIControlStateDisabled];
            [optionButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.f]];
            [optionButton addTarget:self action:@selector(inlineSelectFieldOptionTapped:) forControlEvents:UIControlEventTouchUpInside];
            
            [_bv2 addSubview:optionButton];
            [optionButtons addObject:optionButton];
        }
        
        _optionButtons = optionButtons.copy;
    }
}

-(void)reload {
    FKInlineSelectFieldItem *input = (FKInlineSelectFieldItem *) self.item;
    _fieldLabel.text = input.label;
    
    NSAssert(_optionButtons.count == input.sortedKeyValues.count, @"Number of option buttons must match the number of key values!");
    
    for (NSUInteger i = 0; i < _optionButtons.count; i++) {
        id key = input.sortedKeyValues[i];
        UIButton *optionButton = _optionButtons[i];
        
        if ([input.value isEqual:key]) {
            [optionButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            
        } else {
            [optionButton setTitleColor:kPlaceholderColor forState:UIControlStateNormal];
        }
        
        [optionButton setEnabled:!input.disabled];
    }
    
    [self setNeedsLayout];
}

-(void)inlineSelectFieldOptionTapped:(id)sender {
    UIButton *optionButton = (UIButton *)sender;
    
    NSUInteger optionButtonIndex = [_optionButtons indexOfObject:optionButton];
    if (optionButtonIndex == NSNotFound) {
        return;
    }
    
    FKInlineSelectFieldItem *input = (FKInlineSelectFieldItem *)self.item;
    FKForm *form = (FKForm *)input.rootItem;
    
    [form focusItem:input];
    
    id optionValue = input.sortedKeyValues[optionButtonIndex];
    
    if (!input.value) {
        input.value = optionValue;
        
    } else if ([optionValue isEqual: input.value]) {
        input.value = nil;
        
    } else {
        input.value = optionValue;
    }
    
    [form valueChangedForItem:(FKInputItem *)input];
}

@end

@implementation FKInlineMultiSelectFieldView

-(void)reload {
    FKInlineSelectFieldItem *input = (FKInlineSelectFieldItem *) self.item;
    self.fieldLabel.text = input.label;
    
    NSAssert(self.optionButtons.count == input.sortedKeyValues.count, @"Number of option buttons must match the number of key values!");
    
    for (NSUInteger i = 0; i < self.optionButtons.count; i++) {
        id key = input.sortedKeyValues[i];
        UIButton *optionButton = self.optionButtons[i];
        
        NSArray *selectedOptionValues = (NSArray *)input.value;
        if ([selectedOptionValues containsObject:key]) {
            [optionButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            
        } else {
            [optionButton setTitleColor:kPlaceholderColor forState:UIControlStateNormal];
        }
        
        [optionButton setEnabled:!input.disabled];
    }
    
    [self setNeedsLayout];
    
}

-(void)inlineSelectFieldOptionTapped:(id)sender {
    UIButton *optionButton = (UIButton *)sender;
    
    NSUInteger optionButtonIndex = [self.optionButtons indexOfObject:optionButton];
    if (optionButtonIndex == NSNotFound) {
        return;
    }
    
    FKInlineSelectFieldItem *input = (FKInlineSelectFieldItem *)self.item;
    FKForm *form = (FKForm *)input.rootItem;
    
    [form focusItem:input];
    
    id optionValue = input.sortedKeyValues[optionButtonIndex];
    
    if (!input.value) {
        input.value = @[optionValue];
        
    } else {
        NSMutableArray *selectedOptionValues = ((NSArray *)input.value).mutableCopy;
        if ([selectedOptionValues containsObject:optionValue]) {
            [selectedOptionValues removeObject:optionValue];
            
        } else {
            [selectedOptionValues addObject:optionValue];
        }
        
        input.value = selectedOptionValues.copy;
    }
    
    [form valueChangedForItem:(FKInputItem *)input];
}

@end

@interface FKSwitchFieldView () {
    FKBorderedView * _bv1;
    FKBorderedView * _bv2;
}
@end

@implementation FKSwitchFieldView

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        _bv1 = [FKBorderedView new];
        _bv1.borderColor = kBorderColor;
        _bv1.borders = UIRectEdgeBottom;
        
        _fieldLabel = [UILabel new];
        _fieldLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16.f];
        _fieldLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _fieldLabel.adjustsFontSizeToFitWidth = YES;
        _fieldLabel.numberOfLines = 1;
        _fieldLabel.textColor = self.tintColor;
        
        [_bv1 addSubview:_fieldLabel];
        
        _bv2 = [FKBorderedView new];
        _bv2.borderColor = kBorderColor;
        _bv2.borders = UIRectEdgeBottom;
        
        _switchControl = [UISwitch new];
        [_switchControl addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
        
        [_bv2 addSubview:_switchControl];
        
        [self addSubview:_bv1];
        [self addSubview:_bv2];
    }
    return self;
}

-(CGFloat)heightForWidth:(CGFloat)width {
    return 44.f;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat h = self.bounds.size.height;
    CGFloat w = self.bounds.size.width;
    
    CGFloat w1 = floor(w-_switchControl.intrinsicContentSize.width-20.f);
    CGFloat w2 = w-w1;
    
    _bv1.frame = (CGRect) {0, 0, w1, h};
    
    CGFloat labelWidth = _fieldLabel.intrinsicContentSize.width;
    labelWidth = MIN(labelWidth, CGRectGetWidth(_bv1.frame) - 2*kTextFieldInset);
    CGFloat labelHeight = _fieldLabel.intrinsicContentSize.height;
    labelHeight = MIN(labelHeight, CGRectGetHeight(_bv1.frame) - 2*kTextFieldInset);
    _fieldLabel.frame = (CGRect) {kTextFieldInset, (h - labelHeight - kTextFieldInset), labelWidth, labelHeight};
    
    _bv2.frame = (CGRect) {CGRectGetMaxX(_bv1.frame), 0, w2, h};

    CGFloat switchControlWidth = _switchControl.intrinsicContentSize.width;
    CGFloat switchControlHeight = _switchControl.intrinsicContentSize.height;
    _switchControl.frame = (CGRect) {
        w2-switchControlWidth-10.f,
        floor((h - switchControlHeight)/2.f),
        switchControlWidth,
        switchControlHeight
    };
}

-(void)reload {
    
    FKSwitchFieldItem *input = (FKSwitchFieldItem *)self.item;
    _fieldLabel.text = input.label;
    _switchControl.on = [input.value boolValue];
    
    if (input.disabled) {
        _switchControl.enabled = NO;
        _fieldLabel.textColor = kDisabledLabelColor;
    } else {
        _switchControl.enabled = YES;
        _fieldLabel.textColor = self.tintColor;
    }
    
    [self setNeedsLayout];
}

-(void)switchValueChanged:(UISwitch *)switchControl {
    FKSwitchFieldItem *input = (FKSwitchFieldItem *)self.item;
    input.value = @(switchControl.on);
    FKForm *form = (FKForm *)input.rootItem;
    [form valueChangedForItem:input];
}

@end