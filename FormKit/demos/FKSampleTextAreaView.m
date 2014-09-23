//
//  FKSampleTextAreaView.m
//  FormKit
//
//  Created by Hong Wei Zhuo on 23/9/14.
//  Copyright (c) 2014 ___zhuohongwei___. All rights reserved.
//

#import "FKSampleTextAreaView.h"
#import "FKBorderedView.h"
#import "FKSampleTextAreaItem.h"

@interface FKSampleTextAreaView() {
}
@end

static const CGFloat kTextAreaViewInset = 8;
static const CGFloat kTextAreaViewHeight = 120;

@implementation FKSampleTextAreaView

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _fieldLabel = [UILabel new];
        _fieldLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16.f];
        _fieldLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _fieldLabel.adjustsFontSizeToFitWidth = YES;
        _fieldLabel.numberOfLines = 1;
        _fieldLabel.textColor = self.tintColor;
        
        _textView = [UITextView new];
        _textView.editable = YES;
        _textView.layer.borderWidth = 1/[UIScreen mainScreen].scale;
        _textView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        
        [self addSubview:_fieldLabel];
        [self addSubview:_textView];
    }
    return self;
}

-(CGFloat)heightForWidth:(CGFloat)width {
    return kTextAreaViewHeight;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat h = self.bounds.size.height;
    CGFloat w = self.bounds.size.width;

    CGFloat fieldLabelWidth = MIN(_fieldLabel.intrinsicContentSize.width, (w - 2*kTextAreaViewInset) );
    CGFloat fieldLabelHeight = _fieldLabel.intrinsicContentSize.height;
    _fieldLabel.frame = (CGRect) {kTextAreaViewInset, kTextAreaViewInset, fieldLabelWidth, fieldLabelHeight};
    
    CGFloat textViewWidth = w - 2*kTextAreaViewInset;
    CGFloat textViewHeight = h - 2*kTextAreaViewInset - fieldLabelHeight - 8.f;
    
    _textView.frame = (CGRect) {kTextAreaViewInset, CGRectGetMaxY(_fieldLabel.frame) + 8.f, textViewWidth, textViewHeight};
}

-(void)reload {
    
    FKSampleTextAreaItem *input = (FKSampleTextAreaItem *)self.item;
    _fieldLabel.text = input.label;
    _textView.text = input.value;
    
    if (input.disabled) {
        _textView.editable = NO;
        _fieldLabel.textColor = [UIColor lightGrayColor];
    } else {
        _textView.editable = YES;
        _fieldLabel.textColor = self.tintColor;
    }
    
    [self setNeedsLayout];
}

@end
